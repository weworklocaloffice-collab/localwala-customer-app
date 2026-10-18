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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:bloc/bloc.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_request_off_day_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:user/app/env.dart';
import 'package:user/app/services/titlecase_string.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'tiffin_subscription_request_off_days_modal_event.dart';
part 'tiffin_subscription_request_off_days_modal_state.dart';

class TiffinSubscriptionRequestOffDaysModalBloc extends Bloc<TiffinSubscriptionRequestOffDaysModalEvent, TiffinSubscriptionRequestOffDaysModalState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  TiffinSubscriptionRequestOffDaysModalBloc() : super(const TiffinSubscriptionRequestOffDaysModalState()) {
    on<TiffinSubscriptionRequestOffDaysModalInitialEvent>(_onTiffinSubscriptionRequestOffDaysModalInitialEvent);
    on<TiffinSubscriptionRequestOffDaysModalSelectedDateEvent>(_onTiffinSubscriptionRequestOffDaysModalSelectedDateEvent);
    on<TiffinSubscriptionRequestOffDaySubmitEvent>(_onTiffinSubscriptionRequestOffDaySubmitEvent);
  }

  FutureOr<void> _onTiffinSubscriptionRequestOffDaysModalInitialEvent(TiffinSubscriptionRequestOffDaysModalInitialEvent event, Emitter<TiffinSubscriptionRequestOffDaysModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_request_off_days"}, 'tiffin_subscription_request_off_days_screen', 'tiffin_subscription_request_off_days_screen');
      final String defaultLanguage = await _subscriptionTiffinPackagesRepository.getLocale();
      emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.loading, locale: defaultLanguage.isNotEmpty ? defaultLanguage : Environments.defaultLanguage));
      List<String> offDayList = <String>[];
      for (var element in event.offDays) {
        offDayList.add(element.toString().capitalize());
      }
      emit(state.copyWith(offDays: offDayList.join(' or ')));
      Map<String, String>? dates = getStartAndEndDate(event.totalOrders, event.offDays);
      if (dates != null) {
        String startDateFormat = dates['startDate'].toString();
        String endDateFormat = dates['endDate'].toString();
        if (startDateFormat.isNotEmpty && endDateFormat.isNotEmpty) {
          DateFormat dateFormat = DateFormat("yyyy-MM-dd");
          DateTime startDate = dateFormat.parse(startDateFormat);
          DateTime endDate = dateFormat.parse(endDateFormat);

          List<String> activeDates = [];
          List<String> deactiveDates = [];
          DateTime currentDate = startDate;

          while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
            String dayName = DateFormat('EEEE').format(currentDate).toLowerCase();

            if (event.offDays.contains(dayName)) {
              deactiveDates.add(DateFormat('yyyy-MM-dd').format(currentDate));
            } else {
              activeDates.add(DateFormat('yyyy-MM-dd').format(currentDate));
            }

            currentDate = currentDate.add(const Duration(days: 1));
          }

          List<DateTime> activeCalendarDates = activeDates.map((date) => DateTime.parse(date)).toList();
          List<DateTime> deactiveCalendarDates = deactiveDates.map((date) => DateTime.parse(date)).toList();
          int totalDays = endDate.difference(startDate).inDays;
          emit(state.copyWith(activeDates: activeCalendarDates, deactiveDates: deactiveCalendarDates, totalDays: (totalDays + 1), purchaseId: event.purchaseId, status: TiffinSubscriptionRequestOffDaysModalStatus.success));
        }
      } else {
        emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.empty));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Map<String, String>? getStartAndEndDate(int range, List<String> offDays) {
    DateTime today = DateTime.now();
    DateTime startDate = today.add(const Duration(days: 1));
    DateTime endDate = startDate;
    int daysAdded = 0;

    while (daysAdded < range) {
      endDate = endDate.add(const Duration(days: 1));
      String dayName = DateFormat('EEEE').format(endDate).toLowerCase();

      if (!offDays.contains(dayName)) {
        daysAdded++;
      }
    }

    if (startDate.isBefore(today) || endDate.isBefore(today)) {
      return null;
    }

    return {'startDate': DateFormat('yyyy-MM-dd').format(startDate), 'endDate': DateFormat('yyyy-MM-dd').format(endDate)};
  }

  FutureOr<void> _onTiffinSubscriptionRequestOffDaysModalSelectedDateEvent(TiffinSubscriptionRequestOffDaysModalSelectedDateEvent event, Emitter<TiffinSubscriptionRequestOffDaysModalState> emit) async {
    emit(state.copyWith(selectedDate: '${event.date.year}-${event.date.month}-${event.date.day}', status: TiffinSubscriptionRequestOffDaysModalStatus.success));
  }

  FutureOr<void> _onTiffinSubscriptionRequestOffDaySubmitEvent(TiffinSubscriptionRequestOffDaySubmitEvent event, Emitter<TiffinSubscriptionRequestOffDaysModalState> emit) async {
    try {
      emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.submitStart));
      TiffinSubscriptionRequestOffDayRequestModel param = TiffinSubscriptionRequestOffDayRequestModel(purchaseId: state.purchaseId, offDayDate: state.selectedDate);
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.tiffinSubscriptionRequestOffDay(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.submitSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: TiffinSubscriptionRequestOffDaysModalStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

