/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/call_number_fetched_response_model.dart';
import 'package:user/app/core/models/purchased_tiffin_subscription_info_response_model.dart';
import 'package:user/app/core/models/request/purchased_tiffin_subscription_info_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_tiffin_subscription_package_request_model.dart';
import 'package:user/app/core/models/request/user_cancel_tiffin_subscription_package_rquest_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/tiffin_subscription_purchase_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'purchased_food_subscription_info_event.dart';
part 'purchased_food_subscription_info_state.dart';

class PurchasedFoodSubscriptionInfoBloc extends Bloc<PurchasedFoodSubscriptionInfoEvent, PurchasedFoodSubscriptionInfoState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  PurchasedFoodSubscriptionInfoBloc() : super(PurchasedFoodSubscriptionInfoState(info: PurchasedTiffinSubscriptionPackageInfoResponseModel(locale: ''))) {
    on<PurchasedFoodSubscriptionInfoInitialEvent>(_onPurchasedFoodSubscriptionInfoInitialEvent);
    on<PurchasedFoodSubscriptionInfoRepayPackageEvent>(_onPurchasedFoodSubscriptionInfoRepayPackageEvent);
    on<PurchasedFoodSubscriptionInfoPaymentChangedEvent>(_onPurchasedFoodSubscriptionInfoPaymentChangedEvent);
    on<PurchasedFoodSubscriptionInfoCancelPackageEvent>(_onPurchasedFoodSubscriptionInfoCancelPackageEvent);
    on<PurchasedFoodSubscriptionInfoCallRestaurantEvent>(_onPurchasedFoodSubscriptionInfoCallRestaurantEvent);
  }

  FutureOr<void> _onPurchasedFoodSubscriptionInfoInitialEvent(PurchasedFoodSubscriptionInfoInitialEvent event, Emitter<PurchasedFoodSubscriptionInfoState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "purchased_tiffin_subscription"}, 'purchased_tiffin_subscription_screen', 'purchased_tiffin_subscription_screen');
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.loading, purchaseId: event.purchaseId));
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      PurchasedTiffinSubscriptionPackageInfoRequestModel param = PurchasedTiffinSubscriptionPackageInfoRequestModel(id: event.purchaseId, user: userId);
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.getPurchasedSubscriptionPackageInfo(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          PurchasedTiffinSubscriptionPackageInfoResponseModel data = PurchasedTiffinSubscriptionPackageInfoResponseModel.fromJson(myMap, locale.toString());
          if (data.details!.status! == 'pending_payments' && data.details!.timeDifferenceOfOrderInMinutes! <= Environments.payPendingAmountBeforeMinutesOffCreation) {
            String paymentId = '';
            String paymentName = 'Online Payment';
            String paymentImageUrl = '';
            // Single gateway decision: Razorpay online. Payment screen owns
            // method choice (UPI/Card/NB/Wallet) — no pre-selector popup.
            final rzpIndex = data.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
            if (rzpIndex != -1) {
              paymentId = data.payments![rzpIndex].id!;
              paymentName = data.payments![rzpIndex].name!;
              paymentImageUrl = data.payments![rzpIndex].image!;
            } else if (data.primary != null && data.primary!.name!.isNotEmpty) {
              paymentId = data.primary!.id!;
              paymentName = data.primary!.name!;
              paymentImageUrl = data.primary!.image!;
            } else if (data.payments!.isNotEmpty) {
              paymentId = data.payments![0].id!;
              paymentName = data.payments![0].name!;
              paymentImageUrl = data.payments![0].image!;
            }
            emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, isPendingPaymentTimeOver: false));
          }
          String statusName = '';
          if (data.details!.status! == 'created') {
            statusName = 'tiffin_status_ongoing';
          } else if (data.details!.status! == 'cancelled') {
            statusName = 'tiffin_status_cancelled';
          } else if (data.details!.status! == 'completed') {
            statusName = 'tiffin_status_completed';
          } else if (data.details!.status! == 'refunded') {
            statusName = 'tiffin_status_refunded';
          } else if (data.details!.status! == 'partially_refunded') {
            statusName = 'tiffin_status_partial_refund';
          } else if (data.details!.status! == 'pending_payments') {
            statusName = 'tiffin_status_payment_pending';
          }
          emit(state.copyWith(info: data, statusName: statusName, status: PurchasedFoodSubscriptionInfoStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onPurchasedFoodSubscriptionInfoRepayPackageEvent(PurchasedFoodSubscriptionInfoRepayPackageEvent event, Emitter<PurchasedFoodSubscriptionInfoState> emit) async {
    try {
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.repaySubscriptionRequested));
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      RepayPendingTiffinSubscriptionPackageRequestModel param = RepayPendingTiffinSubscriptionPackageRequestModel(
        userId: userId,
        packageId: state.purchaseId,
        payMethod: state.info.details!.paymentInfo!.id!,
        newPayMethod: state.newPaymentId,
      );
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.repayPendingSubscriptionTiffinPackage(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        TiffinSubscriptionPurchaseResponseModel orderResponse = TiffinSubscriptionPurchaseResponseModel.fromJson(myMap);
        emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.repaySubscriptionSuccess, paymentURL: orderResponse.payLink));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.repaySubscriptionFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.repaySubscriptionFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onPurchasedFoodSubscriptionInfoPaymentChangedEvent(PurchasedFoodSubscriptionInfoPaymentChangedEvent event, Emitter<PurchasedFoodSubscriptionInfoState> emit) async {
    final int index = state.info.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.info.payments![index].id!;
      String paymentName = state.info.payments![index].name!;
      String paymentImageUrl = state.info.payments![index].image!;
      emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl));
    }
  }

  FutureOr<void> _onPurchasedFoodSubscriptionInfoCancelPackageEvent(PurchasedFoodSubscriptionInfoCancelPackageEvent event, Emitter<PurchasedFoodSubscriptionInfoState> emit) async {
    try {
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.cancelRequested));
      UserCancelTiffinSubscriptionPackageRequestModel param = UserCancelTiffinSubscriptionPackageRequestModel(id: state.purchaseId, cancellationId: event.reasonId, user: userId);
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.userCancelTiffinSubscriptionPackage(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.cancelSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.cancelFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: PurchasedFoodSubscriptionInfoStatus.cancelFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onPurchasedFoodSubscriptionInfoCallRestaurantEvent(PurchasedFoodSubscriptionInfoCallRestaurantEvent event, Emitter<PurchasedFoodSubscriptionInfoState> emit) async {
    try {
      emit(state.copyWith(callRestaurant: true));
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.fetchRestaurantCallNumber(state.info.details!.restaurant!.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(callRestaurant: false));
          CallNumberFetchedResponseModel callResponse = CallNumberFetchedResponseModel.fromJson(myMap);
          if (callResponse.detail!.contactInfo!.countryCode!.isNotEmpty && callResponse.detail!.contactInfo!.contactNumber!.isNotEmpty) {
            final Uri numberLaunchUri = Uri(scheme: 'tel', path: '${callResponse.detail!.contactInfo!.countryCode!}${callResponse.detail!.contactInfo!.contactNumber!}');
            launchUrl(numberLaunchUri);
          }
        }
      } else {
        emit(state.copyWith(callRestaurant: false));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(callRestaurant: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

