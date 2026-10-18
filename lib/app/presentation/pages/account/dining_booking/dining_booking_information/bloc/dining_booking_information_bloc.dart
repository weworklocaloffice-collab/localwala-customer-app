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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/create_dining_booking_response_model.dart';
import 'package:user/app/core/models/dining_booking_detail_information_response_model.dart';
import 'package:user/app/core/models/request/cancel_dining_booking_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_detail_information_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_booking_payment_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_booking_information_event.dart';
part 'dining_booking_information_state.dart';

class DiningBookingInformationBloc extends Bloc<DiningBookingInformationEvent, DiningBookingInformationState> {
  final DiningRepository _diningRepository = DiningRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingInformationBloc() : super(DiningBookingInformationState(model: DiningBookingDetailInformationResponseModel(locale: ''))) {
    on<DiningBookingInformationInitialEvent>(_onDiningBookingInformationInitialEvent);
    on<DiningBookingInformationRestaurantDirectionEvent>(_onDiningBookingInformationRestaurantDirectionEvent);
    on<DiningBookingInformationRestaurantCallEvent>(_onDiningBookingInformationRestaurantCallEvent);
    on<DiningBookingInformationPaymentChangedEvent>(_onDiningBookingInformationPaymentChangedEvent);
    on<DiningBookingInformationRepayBookingEvent>(_onDiningBookingInformationRepayBookingEvent);
    on<DiningBookingInformationCancelMyBookingEvent>(_onDiningBookingInformationCancelMyBookingEvent);
  }

  FutureOr<void> _onDiningBookingInformationInitialEvent(DiningBookingInformationInitialEvent event, Emitter<DiningBookingInformationState> emit) async {
    try {
      emit(state.copyWith(status: DiningBookingInformationStatus.loading, bookingId: event.bookingId));
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_details", "id": event.bookingId}, 'dining_booking_detail_screen', 'dining_booking_detail_screen');
      final String userId = await _diningRepository.userId();
      DiningBookingDetailInformationRequestModel param = DiningBookingDetailInformationRequestModel(uid: userId, booking: event.bookingId);
      DioApiResponse response = await _diningRepository.getDiningBookingDetailInformation(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DiningBookingInformationStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          DiningBookingDetailInformationResponseModel detailResponse = DiningBookingDetailInformationResponseModel.fromJson(myMap, locale.toString());
          if (detailResponse.details!.status! == 'pending_payments' && detailResponse.details!.timeDifferenceOfOrderInMinutes! <= Environments.payPendingAmountBeforeMinutesOffCreation) {
            String paymentId = '';
            String paymentName = 'Online Payment';
            String paymentImageUrl = '';
            // Single gateway decision: Razorpay online. Payment screen owns
            // method choice (UPI/Card/NB/Wallet) — no pre-selector popup.
            final rzpIndex = detailResponse.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
            if (rzpIndex != -1) {
              paymentId = detailResponse.payments![rzpIndex].id!;
              paymentName = detailResponse.payments![rzpIndex].name!;
              paymentImageUrl = detailResponse.payments![rzpIndex].image!;
            } else if (detailResponse.primary != null && detailResponse.primary!.name!.isNotEmpty) {
              paymentId = detailResponse.primary!.id!;
              paymentName = detailResponse.primary!.name!;
              paymentImageUrl = detailResponse.primary!.image!;
            } else if (detailResponse.payments!.isNotEmpty) {
              paymentId = detailResponse.payments![0].id!;
              paymentName = detailResponse.payments![0].name!;
              paymentImageUrl = detailResponse.payments![0].image!;
            }
            emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, canPayPending: true));
          }
          if (detailResponse.details!.status! == 'created' || detailResponse.details!.status! == 'accepted') {
            emit(state.copyWith(canCancelBooking: true));
          }
          emit(state.copyWith(model: detailResponse, status: DiningBookingInformationStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingInformationStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingInformationStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingInformationRestaurantDirectionEvent(DiningBookingInformationRestaurantDirectionEvent event, Emitter<DiningBookingInformationState> emit) async {
    try {
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final double restLat = state.model.details!.restaurant!.location!.coordinates![1];
      final double restLng = state.model.details!.restaurant!.location!.coordinates![0];
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          title: 'Destination',
          coords: Coords(restLat, restLng),
        );
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingInformationRestaurantCallEvent(DiningBookingInformationRestaurantCallEvent event, Emitter<DiningBookingInformationState> emit) async {}

  FutureOr<void> _onDiningBookingInformationPaymentChangedEvent(DiningBookingInformationPaymentChangedEvent event, Emitter<DiningBookingInformationState> emit) async {
    final int index = state.model.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.model.payments![index].id!;
      String paymentName = state.model.payments![index].name!;
      String paymentImageUrl = state.model.payments![index].image!;
      emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl));
    }
  }

  FutureOr<void> _onDiningBookingInformationRepayBookingEvent(DiningBookingInformationRepayBookingEvent event, Emitter<DiningBookingInformationState> emit) async {
    try {
      emit(state.copyWith(status: DiningBookingInformationStatus.repayOrderRequested));
      final String userId = await _diningRepository.userId();
      RepayPendingBookingPaymentRequestModel param = RepayPendingBookingPaymentRequestModel(bookingId: state.model.details!.id!, userId: userId, payMethod: state.model.details!.paymentInfo!.id!, newPayMethod: state.newPaymentId);
      DioApiResponse response = await _diningRepository.repayPendingBookingPayment(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        CreateDiningBookingResponseModel diningBookingResponse = CreateDiningBookingResponseModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingInformationStatus.repayOrderSuccess, paymentURL: diningBookingResponse.payLink));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingInformationStatus.repayOrderFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingInformationStatus.repayOrderFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingInformationCancelMyBookingEvent(DiningBookingInformationCancelMyBookingEvent event, Emitter<DiningBookingInformationState> emit) async {
    try {
      emit(state.copyWith(status: DiningBookingInformationStatus.cancelRequested));
      CancelDiningBookingRequestModel param = CancelDiningBookingRequestModel(bookingId: state.model.details!.id!, reasonId: event.reasonId);
      DioApiResponse response = await _diningRepository.cancelDiningBooking(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: DiningBookingInformationStatus.cancelSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingInformationStatus.cancelFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingInformationStatus.cancelFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

