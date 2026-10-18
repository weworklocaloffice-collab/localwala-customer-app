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
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/dining_booking_information_response_model.dart';
import 'package:user/app/core/models/dining_booking_table_date_list_model.dart';
import 'package:user/app/core/models/dining_schedule_meal_type_model.dart';
import 'package:user/app/core/models/guest_account_status_response_model.dart';
import 'package:user/app/core/models/request/dining_booking_information_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/env.dart';

part 'restaurant_pre_booking_table_event.dart';
part 'restaurant_pre_booking_table_state.dart';

class RestaurantPreBookingTableBloc extends Bloc<RestaurantPreBookingTableEvent, RestaurantPreBookingTableState> {
  final DiningRepository _diningRepository = DiningRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  RestaurantPreBookingTableBloc() : super(RestaurantPreBookingTableState(model: DiningBookingInformationResponseModel(locale: ''))) {
    on<RestaurantPreBookingTableInitialEvent>(_onRestaurantPreBookingTableInitialEvent);
    on<RestaurantPreBookingChangeDateEvent>(_onRestaurantPreBookingChangeDateEvent);
    on<RestaurantPreBookingChangeGuestEvent>(_onRestaurantPreBookingChangeGuestEvent);
    on<RestaurantPreBookingChangeMealTimeEvent>(_onRestaurantPreBookingChangeMealTimeEvent);
    on<RestaurantPreBookingSaveSlotEvent>(_onRestaurantPreBookingSaveSlotEvent);
    on<RestaurantPreBookingSaveCouponEvent>(_onRestaurantPreBookingSaveCouponEvent);
    on<RestaurantPreBookingTableGuestLoginEvent>(_onRestaurantPreBookingTableGuestLoginEvent);
    on<RestaurantPreBookingTableSubmitEvent>(_onRestaurantPreBookingTableSubmitEvent);
  }

  FutureOr<void> _onRestaurantPreBookingTableInitialEvent(RestaurantPreBookingTableInitialEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "make_dining_booking"}, 'make_dining_booking_screen', 'make_dining_booking_screen');
      emit(state.copyWith(restaurantId: event.restaurant, restaurantName: event.restaurantName, restaurantSlug: event.restaurantSlug, status: RestaurantPreBookingTableStatus.initial));
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      DiningBookingInformationRequestModel param = DiningBookingInformationRequestModel(
        id: event.restaurant,
        slug: event.restaurantSlug,
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
      );
      DioApiResponse response = await _diningRepository.getDiningBookingInformation(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: RestaurantPreBookingTableStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          DiningBookingInformationResponseModel diningInfo = DiningBookingInformationResponseModel.fromJson(myMap, locale.toString());
          if (diningInfo.slots!.isEmpty || diningInfo.guestAvailability!.isEmpty) {
            emit(state.copyWith(status: RestaurantPreBookingTableStatus.empty));
          } else if (diningInfo.slots!.length != 7) {
            emit(state.copyWith(status: RestaurantPreBookingTableStatus.empty));
          } else {
            DateTime today = DateTime.now();
            List<DiningBookTableDateListModel> dateList = <DiningBookTableDateListModel>[];

            for (int i = 0; i <= 6; i++) {
              DateTime nextDate = today.add(Duration(days: i));
              String formattedDate = DateFormat('yyyy-MM-dd').format(nextDate);
              String dateNameString = DateFormat('E, dd MMM').format(nextDate);
              if (i == 0) {
                DiningBookTableDateListModel dateToAdd = DiningBookTableDateListModel(dateFormat: formattedDate, dateName: 'Today');
                dateList.add(dateToAdd);
              } else if (i == 1) {
                DiningBookTableDateListModel dateToAdd = DiningBookTableDateListModel(dateFormat: formattedDate, dateName: 'Tomorrow');
                dateList.add(dateToAdd);
              } else {
                DiningBookTableDateListModel dateToAdd = DiningBookTableDateListModel(dateFormat: formattedDate, dateName: dateNameString);
                dateList.add(dateToAdd);
              }
            }

            String bookingDate = '';
            String bookingFormatDate = '';
            int bookingGuest = 0;
            if (dateList.isNotEmpty && dateList.length == 7) {
              bookingDate = dateList[0].dateName!;
              bookingFormatDate = dateList[0].dateFormat!;
              bookingGuest = diningInfo.guestAvailability![0];
            }

            int dayNumberToday = (DateTime.now().weekday - 1);
            List<DiningScheduleMealTypeModel> mealTimeList = <DiningScheduleMealTypeModel>[];
            mealTimeList.clear();
            DiningScheduleMealTypeModel breakfast = DiningScheduleMealTypeModel(mealIndex: 0, lable: 'Breakfast', value: 'breakfast', slots: []);
            DiningScheduleMealTypeModel lunch = DiningScheduleMealTypeModel(mealIndex: 1, lable: 'Lunch', value: 'lunch', slots: []);
            DiningScheduleMealTypeModel dinner = DiningScheduleMealTypeModel(mealIndex: 2, lable: 'Dinner', value: 'dinner', slots: []);
            mealTimeList.add(breakfast);
            mealTimeList.add(lunch);
            mealTimeList.add(dinner);
            int breakFastIndex = mealTimeList.indexWhere((element) => element.value == 'breakfast');
            int lunchIndex = mealTimeList.indexWhere((element) => element.value == 'lunch');
            int dinnerIndex = mealTimeList.indexWhere((element) => element.value == 'dinner');
            List<String> breakfastSlot = <String>[];
            List<String> lunchSlot = <String>[];
            List<String> dinnerSlot = <String>[];
            DateTime now = DateTime.now();
              for (var element in diningInfo.slots![dayNumberToday].times!) {
              final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false).firstMatch(element.time!);
              if (match == null) continue;
              int hour = int.parse(match.group(1)!);
              int minute = int.parse(match.group(2)!);
              final period = match.group(3)!.toUpperCase();
              if (period == 'PM' && hour != 12) hour += 12;
              if (period == 'AM' && hour == 12) hour = 0;
              DateTime parsedTime = DateTime(now.year, now.month, now.day, hour, minute);
              DateTime timeToCheck = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
              if (element.type! == 'breakfast') {
                if (timeToCheck.isAfter(now)) {
                  breakfastSlot.add(element.time!);
                }
              } else if (element.type! == 'lunch') {
                if (timeToCheck.isAfter(now)) {
                  lunchSlot.add(element.time!);
                }
              } else if (element.type! == 'dinner') {
                if (timeToCheck.isAfter(now)) {
                  dinnerSlot.add(element.time!);
                }
              }
            }

            mealTimeList[breakFastIndex].totalOffers = diningInfo.diningCoupons!.where((element) => element.availability == 'breakfast').length;
            mealTimeList[lunchIndex].totalOffers = diningInfo.diningCoupons!.where((element) => element.availability == 'lunch').length;
            mealTimeList[dinnerIndex].totalOffers = diningInfo.diningCoupons!.where((element) => element.availability == 'dinner').length;

            mealTimeList[breakFastIndex].slots = breakfastSlot;
            mealTimeList[lunchIndex].slots = lunchSlot;
            mealTimeList[dinnerIndex].slots = dinnerSlot;

            mealTimeList.removeWhere((element) => element.slots!.isEmpty);

            mealTimeList.sort((a, b) => a.mealIndex!.compareTo(b.mealIndex!));

            bool canProceedNext = false;
            final bool isAuthorized = await _diningRepository.isAuthorized();
            final String haveUserId = await _diningRepository.userId();
            if (isAuthorized) {
              canProceedNext = true;
            } else if (haveUserId.isNotEmpty) {
              canProceedNext = true;
            }

            emit(
              state.copyWith(
                model: diningInfo,
                dates: dateList,
                bookingDate: bookingDate,
                bookingFormatDate: bookingFormatDate,
                mealTime: mealTimeList,
                toPay: diningInfo.dinnigSetting!.preBookingChargeRequired! ? diningInfo.dinnigSetting!.minBookingCharge! : 0,
                bookingGuest: bookingGuest,
                canProceed: canProceedNext,
                status: RestaurantPreBookingTableStatus.success,
              ),
            );
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantPreBookingTableStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantPreBookingTableStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  String getCurrentMealTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 11) {
      return 'breakfast';
    } else if (hour >= 11 && hour < 15) {
      return 'lunch';
    } else if (hour >= 18 && hour < 23.30) {
      return 'dinner';
    } else {
      return 'none';
    }
  }

  FutureOr<void> _onRestaurantPreBookingChangeDateEvent(RestaurantPreBookingChangeDateEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    final index = state.dates.indexWhere((element) => element.dateFormat == event.dateFormat);
    if (index != -1) {
      emit(
        state.copyWith(
          mealTime: [],
          bookingSlot: '',
          showCoupon: [],
          selectedCoupon: '',
          mealIndexToShow: 0,
          isValid: false,
          toPay: state.model.dinnigSetting!.preBookingChargeRequired! ? state.model.dinnigSetting!.minBookingCharge : 0,
          status: RestaurantPreBookingTableStatus.success,
        ),
      );

      String dateName = state.dates[index].dateName!;
      String dateFormat = state.dates[index].dateFormat!;
      DateTime selectedDate = DateTime.parse(event.dateFormat);
      DateTime today = DateTime.now();
      bool isToday = selectedDate.year == today.year && selectedDate.month == today.month && selectedDate.day == today.day;
      if (isToday) {
        int dayNumberToday = (DateTime.now().weekday - 1);
        List<DiningScheduleMealTypeModel> mealTimeList = <DiningScheduleMealTypeModel>[];
        mealTimeList.clear();
        DiningScheduleMealTypeModel breakfast = DiningScheduleMealTypeModel(mealIndex: 0, lable: 'Breakfast', value: 'breakfast', slots: []);
        DiningScheduleMealTypeModel lunch = DiningScheduleMealTypeModel(mealIndex: 1, lable: 'Lunch', value: 'lunch', slots: []);
        DiningScheduleMealTypeModel dinner = DiningScheduleMealTypeModel(mealIndex: 2, lable: 'Dinner', value: 'dinner', slots: []);
        mealTimeList.add(breakfast);
        mealTimeList.add(lunch);
        mealTimeList.add(dinner);
        int breakFastIndex = mealTimeList.indexWhere((element) => element.value == 'breakfast');
        int lunchIndex = mealTimeList.indexWhere((element) => element.value == 'lunch');
        int dinnerIndex = mealTimeList.indexWhere((element) => element.value == 'dinner');
        List<String> breakfastSlot = <String>[];
        List<String> lunchSlot = <String>[];
        List<String> dinnerSlot = <String>[];
        DateTime now = DateTime.now();
        for (var element in state.model.slots![dayNumberToday].times!) {
          final match = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false).firstMatch(element.time!);
          if (match == null) continue;
          int hour = int.parse(match.group(1)!);
          int minute = int.parse(match.group(2)!);
          final period = match.group(3)!.toUpperCase();
          if (period == 'PM' && hour != 12) hour += 12;
          if (period == 'AM' && hour == 12) hour = 0;
          DateTime parsedTime = DateTime(now.year, now.month, now.day, hour, minute);
          DateTime timeToCheck = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
          if (element.type! == 'breakfast') {
            if (timeToCheck.isAfter(now)) {
              breakfastSlot.add(element.time!);
            }
          } else if (element.type! == 'lunch') {
            if (timeToCheck.isAfter(now)) {
              lunchSlot.add(element.time!);
            }
          } else if (element.type! == 'dinner') {
            if (timeToCheck.isAfter(now)) {
              dinnerSlot.add(element.time!);
            }
          }
        }

        mealTimeList[breakFastIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'breakfast').length;
        mealTimeList[lunchIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'lunch').length;
        mealTimeList[dinnerIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'dinner').length;

        mealTimeList[breakFastIndex].slots = breakfastSlot;
        mealTimeList[lunchIndex].slots = lunchSlot;
        mealTimeList[dinnerIndex].slots = dinnerSlot;

        mealTimeList.removeWhere((element) => element.slots!.isEmpty);

        mealTimeList.sort((a, b) => a.mealIndex!.compareTo(b.mealIndex!));

        emit(state.copyWith(bookingDate: dateName, bookingFormatDate: dateFormat, mealTime: mealTimeList, status: RestaurantPreBookingTableStatus.success));
      } else {
        int dayNumberToday = (selectedDate.weekday - 1);
        List<DiningScheduleMealTypeModel> mealTimeList = <DiningScheduleMealTypeModel>[];
        mealTimeList.clear();
        DiningScheduleMealTypeModel breakfast = DiningScheduleMealTypeModel(mealIndex: 0, lable: 'Breakfast', value: 'breakfast', slots: []);
        DiningScheduleMealTypeModel lunch = DiningScheduleMealTypeModel(mealIndex: 1, lable: 'Lunch', value: 'lunch', slots: []);
        DiningScheduleMealTypeModel dinner = DiningScheduleMealTypeModel(mealIndex: 2, lable: 'Dinner', value: 'dinner', slots: []);
        mealTimeList.add(breakfast);
        mealTimeList.add(lunch);
        mealTimeList.add(dinner);
        int breakFastIndex = mealTimeList.indexWhere((element) => element.value == 'breakfast');
        int lunchIndex = mealTimeList.indexWhere((element) => element.value == 'lunch');
        int dinnerIndex = mealTimeList.indexWhere((element) => element.value == 'dinner');
        List<String> breakfastSlot = <String>[];
        List<String> lunchSlot = <String>[];
        List<String> dinnerSlot = <String>[];
        for (var element in state.model.slots![dayNumberToday].times!) {
          if (element.type! == 'breakfast') {
            breakfastSlot.add(element.time!);
          } else if (element.type! == 'lunch') {
            lunchSlot.add(element.time!);
          } else if (element.type! == 'dinner') {
            dinnerSlot.add(element.time!);
          }
        }

        mealTimeList[breakFastIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'breakfast').length;
        mealTimeList[lunchIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'lunch').length;
        mealTimeList[dinnerIndex].totalOffers = state.model.diningCoupons!.where((element) => element.availability == 'dinner').length;

        mealTimeList[breakFastIndex].slots = breakfastSlot;
        mealTimeList[lunchIndex].slots = lunchSlot;
        mealTimeList[dinnerIndex].slots = dinnerSlot;

        mealTimeList.removeWhere((element) => element.slots!.isEmpty);

        mealTimeList.sort((a, b) => a.mealIndex!.compareTo(b.mealIndex!));
        emit(state.copyWith(bookingDate: dateName, mealTime: mealTimeList, bookingFormatDate: dateFormat, status: RestaurantPreBookingTableStatus.success));
      }
    }
  }

  FutureOr<void> _onRestaurantPreBookingChangeGuestEvent(RestaurantPreBookingChangeGuestEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    emit(state.copyWith(bookingGuest: event.guest, status: RestaurantPreBookingTableStatus.success));
  }

  FutureOr<void> _onRestaurantPreBookingChangeMealTimeEvent(RestaurantPreBookingChangeMealTimeEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    emit(state.copyWith(mealIndexToShow: event.mealIndex, selectedCoupon: '', showCoupon: [], bookingSlot: '', status: RestaurantPreBookingTableStatus.success));
  }

  FutureOr<void> _onRestaurantPreBookingSaveSlotEvent(RestaurantPreBookingSaveSlotEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    List<DiningBookingCouponConfigModel> coupons = <DiningBookingCouponConfigModel>[];
    coupons = state.model.diningCoupons!.where((element) => element.availability == state.mealTime[state.mealIndexToShow].value).toList();
    emit(state.copyWith(selectedMeal: state.mealTime[state.mealIndexToShow].value, showCoupon: coupons, isValid: true, bookingSlot: event.slot, status: RestaurantPreBookingTableStatus.success));
  }

  FutureOr<void> _onRestaurantPreBookingSaveCouponEvent(RestaurantPreBookingSaveCouponEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    final String userId = await _authRepository.userId();
    if (userId.isNotEmpty) {
      try {
        emit(state.copyWith(selectedCoupon: event.couponId, status: RestaurantPreBookingTableStatus.validateCoupon));
        DioApiResponse response = await _diningRepository.verifyDiningCoupon(userId, event.couponId);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel couponResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!couponResponse.success!) {
            emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, selectedCoupon: '', statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            final int couponIndex = state.showCoupon.indexWhere((element) => element.id == event.couponId);
            double toPay = 0.0;
            double preBookingCharge = 0.0;
            double couponCoverCharge = 0.0;
            if (state.model.dinnigSetting!.preBookingChargeRequired! && state.model.dinnigSetting!.minBookingCharge! > 0) {
              preBookingCharge = state.model.dinnigSetting!.minBookingCharge!;
            }
            if (couponIndex != -1) {
              if (state.showCoupon[couponIndex].preBookingChargeRequired!) {
                couponCoverCharge = state.showCoupon[couponIndex].preBookingChargeAmount!;
              }
            }

            String totalPayString = (double.parse(preBookingCharge.toString()) + double.parse(couponCoverCharge.toString())).toStringAsFixed(2);
            toPay = double.parse(totalPayString);

            emit(state.copyWith(selectedCoupon: event.couponId, toPay: toPay, couponCoverCharge: couponCoverCharge, status: RestaurantPreBookingTableStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, statusCode: data.code, selectedCoupon: '', alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, selectedCoupon: '', statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, selectedCoupon: '', statusCode: 0, alertMessage: 'Please login first', extraMessage: ''));
    }
  }

  FutureOr<void> _onRestaurantPreBookingTableGuestLoginEvent(RestaurantPreBookingTableGuestLoginEvent event, Emitter<RestaurantPreBookingTableState> emit) async {
    try {
      emit(state.copyWith(status: RestaurantPreBookingTableStatus.loginGuest));
      String userAgent = 'unknown';
      if (kIsWeb) {
        userAgent = 'browser';
      } else if (Platform.isAndroid) {
        userAgent = 'android';
      } else if (Platform.isIOS) {
        userAgent = 'ios';
      }
      final String appLocale = await _authRepository.getLocale();
      DioApiResponse response = await _authRepository.registerGuestAccount(userAgent, appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        GuestAccountStatusResponseModel initialResponse = GuestAccountStatusResponseModel.fromJson(myMap);
        if (!initialResponse.signup!) {
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveLoginResponse(data);
          emit(state.copyWith(status: RestaurantPreBookingTableStatus.loginGuestSuccess, canProceed: true));
        } else {
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          emit(state.copyWith(status: RestaurantPreBookingTableStatus.loginGuestSuccess, canProceed: true));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantPreBookingTableStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantPreBookingTableSubmitEvent(RestaurantPreBookingTableSubmitEvent event, Emitter<RestaurantPreBookingTableState> emit) async {}
}

