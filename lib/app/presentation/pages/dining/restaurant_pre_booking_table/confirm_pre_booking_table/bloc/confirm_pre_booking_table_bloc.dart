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
import 'package:intl/intl.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/create_dining_booking_response_model.dart';
import 'package:user/app/core/models/dining_booking_confirm_response_model.dart';
import 'package:user/app/core/models/request/create_dining_booking_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_confirm_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/visited_campaign_detail_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/home_repository.dart';

part 'confirm_pre_booking_table_event.dart';
part 'confirm_pre_booking_table_state.dart';

class ConfirmPreBookingTableBloc extends Bloc<ConfirmPreBookingTableEvent, ConfirmPreBookingTableState> {
  final DiningRepository _diningRepository = DiningRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  ConfirmPreBookingTableBloc() : super(ConfirmPreBookingTableState(model: DiningBookingConfirmResponseModel(locale: ''))) {
    on<ConfirmPreBookingTableInitialEvent>(_onConfirmPreBookingTableInitialEvent);
    on<ConfirmPreBookingPaymentChangeEvent>(_onConfirmPreBookingPaymentChangeEvent);
    on<ConfirmPreBookingUserInfoChangeEvent>(_onConfirmPreBookingUserInfoChangeEvent);
    on<ConfirmPreBookingSpecialRequestChangeEvent>(_onConfirmPreBookingSpecialRequestChangeEvent);
    on<ConfirmPreBookingSubmitEvent>(_onConfirmPreBookingSubmitEvent);
  }

  FutureOr<void> _onConfirmPreBookingTableInitialEvent(ConfirmPreBookingTableInitialEvent event, Emitter<ConfirmPreBookingTableState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "confirm_dining_booking"}, 'confirm_dining_booking_screen', 'confirm_dining_booking_screen');
    VisitedCampaignDetailModel visitedCampaignDetail = await _homeRepository.getVisitedCampaignDetail();
    try {
      emit(
        state.copyWith(
          restaurant: event.restaurant,
          selectedDate: event.selectedDate,
          selectedGuest: event.selectedGuest,
          selectedSlot: event.selectedSlot,
          selectedCoupon: event.selectedCoupon,
          campaignId: visitedCampaignDetail.id,
          status: ConfirmPreBookingTableStatus.loading,
        ),
      );
      final String userId = await _diningRepository.userId();
      DiningBookingConfirmRequestModel param = DiningBookingConfirmRequestModel(slug: event.restaurant, uid: userId, coupon: event.selectedCoupon);
      DioApiResponse response = await _diningRepository.getDiningBookingConfirmation(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        DiningBookingConfirmResponseModel diningInfo = DiningBookingConfirmResponseModel.fromJson(myMap, locale.toString());
        DateTime dateTime = DateTime.parse(event.selectedDate);
        String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
        double toPay = 0.0;
        double preBookingCharge = 0.0;
        double couponCoverCharge = 0.0;
        if (diningInfo.dinnigSetting!.preBookingChargeRequired! && diningInfo.dinnigSetting!.minBookingCharge! > 0) {
          preBookingCharge = diningInfo.dinnigSetting!.minBookingCharge!;
        }
        if (event.selectedCoupon.isNotEmpty && diningInfo.coupon!.name!.isNotEmpty && diningInfo.coupon!.id! == event.selectedCoupon && diningInfo.coupon!.preBookingChargeRequired!) {
          couponCoverCharge = diningInfo.coupon!.preBookingChargeAmount!;
        }
        String totalPayString = (double.parse(preBookingCharge.toString()) + double.parse(couponCoverCharge.toString())).toStringAsFixed(2);
        toPay = double.parse(totalPayString);
        String userName = '';
        String userContact = '';
        String userContryCode = '';
        String userEmail = '';
        bool isValid = false;
        final String userRole = await _diningRepository.userRole();
        if (userId.isNotEmpty && diningInfo.user!.firstName!.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
          userName = '${diningInfo.user!.firstName!} ${diningInfo.user!.lastName!}';
          userContact = diningInfo.user!.mobile!;
          userContryCode = diningInfo.user!.countryCode!;
          userEmail = diningInfo.user!.email!;
          isValid = true;
        }
        String paymentId = '';
        String paymentName = 'Online Payment';
        String paymentImageUrl = '';
        // Single gateway decision: Razorpay online. Payment screen owns
        // method choice (UPI/Card/NB/Wallet) — no pre-selector popup.
        final rzpIndex = diningInfo.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
        if (rzpIndex != -1) {
          paymentId = diningInfo.payments![rzpIndex].id!;
          paymentName = diningInfo.payments![rzpIndex].name!;
          paymentImageUrl = diningInfo.payments![rzpIndex].image!;
        } else if (diningInfo.primary != null && diningInfo.primary!.name!.isNotEmpty) {
          paymentId = diningInfo.primary!.id!;
          paymentName = diningInfo.primary!.name!;
          paymentImageUrl = diningInfo.primary!.image!;
        } else if (diningInfo.payments!.isNotEmpty) {
          paymentId = diningInfo.payments![0].id!;
          paymentName = diningInfo.payments![0].name!;
          paymentImageUrl = diningInfo.payments![0].image!;
        }
        emit(
          state.copyWith(
            model: diningInfo,
            formatedDate: formattedDate,
            userName: userName,
            userContryCode: userContryCode,
            userContact: userContact,
            userEmail: userEmail,
            grandTotal: toPay,
            payment: paymentId,
            paymentName: paymentName,
            paymentImageURL: paymentImageUrl,
            isValid: isValid,
            status: ConfirmPreBookingTableStatus.success,
          ),
        );
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ConfirmPreBookingTableStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ConfirmPreBookingTableStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onConfirmPreBookingPaymentChangeEvent(ConfirmPreBookingPaymentChangeEvent event, Emitter<ConfirmPreBookingTableState> emit) async {
    final int index = state.model.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.model.payments![index].id!;
      String paymentName = state.model.payments![index].name!;
      String paymentImageUrl = state.model.payments![index].image!;
      emit(state.copyWith(payment: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, status: ConfirmPreBookingTableStatus.success));
    }
  }

  FutureOr<void> _onConfirmPreBookingUserInfoChangeEvent(ConfirmPreBookingUserInfoChangeEvent event, Emitter<ConfirmPreBookingTableState> emit) async {
    emit(state.copyWith(userName: event.name, userContryCode: event.countryCode, userContact: event.phoneNumber, userEmail: event.email, isValid: true, status: ConfirmPreBookingTableStatus.success));
  }

  FutureOr<void> _onConfirmPreBookingSpecialRequestChangeEvent(ConfirmPreBookingSpecialRequestChangeEvent event, Emitter<ConfirmPreBookingTableState> emit) async {
    emit(state.copyWith(userSpecialRequest: event.instructions, status: ConfirmPreBookingTableStatus.success));
  }

  FutureOr<void> _onConfirmPreBookingSubmitEvent(ConfirmPreBookingSubmitEvent event, Emitter<ConfirmPreBookingTableState> emit) async {
    try {
      emit(state.copyWith(status: ConfirmPreBookingTableStatus.makeBooking));
      final String userId = await _diningRepository.userId();
      CreateDiningBookingRequestModel param = CreateDiningBookingRequestModel(
        user: userId,
        payment: state.payment,
        restaurant: state.model.restaurant!.id!,
        coupon: state.selectedCoupon,
        bookingDate: state.selectedDate,
        bookingSlot: state.selectedSlot,
        guest: state.selectedGuest,
        userName: state.userName,
        userCountryCode: int.parse(state.userContryCode.toString()),
        userContact: state.userContact.toString(),
        userEmail: state.userEmail,
        specialRequest: state.userSpecialRequest,
        campaignId: state.campaignId,
      );
      DioApiResponse response = await _diningRepository.createDiningBooking(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        CreateDiningBookingResponseModel diningBookingResponse = CreateDiningBookingResponseModel.fromJson(myMap);
        await _homeRepository.clearVisitedCampaignDetail();
        if (diningBookingResponse.status == 'offline') {
          emit(state.copyWith(status: ConfirmPreBookingTableStatus.bookingPlaced));
        } else {
          emit(state.copyWith(status: ConfirmPreBookingTableStatus.makePayment, paymentURL: diningBookingResponse.payLink));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ConfirmPreBookingTableStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ConfirmPreBookingTableStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

