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
import 'package:formz/formz.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/report_issue_restaurant_reason_list_model.dart';
import 'package:user/app/core/models/request/report_issue_restaurat_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:user/app/core/validations/report_issue_restaurant_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'report_issue_restaurant_modal_event.dart';
part 'report_issue_restaurant_modal_state.dart';

class ReportIssueRestaurantModalBloc extends Bloc<ReportIssueRestaurantModalEvent, ReportIssueRestaurantModalState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final AuthRepository _authRepository = AuthRepository();
  ReportIssueRestaurantModalBloc()
    : super(
        ReportIssueRestaurantModalState(
          list: ReportIssueRestaurantReasonListModel(reasons: [], locale: ''),
        ),
      ) {
    on<ReportIssueRestaurantModalInitialEvent>(_onReportIssueRestaurantModalInitialEvent);
    on<ReportIssueRestaurantModalSelectReasonEvent>(_onReportIssueRestaurantModalSelectReasonEvent);
    on<ReportIssueRestaurantReSelectEvent>(_onReportIssueRestaurantReSelectEvent);
    on<ReportIssueRestaurantMessageChangedEvent>(_onReportIssueRestaurantMessageChangedEvent);
    on<ReportIssueRestaurantMessageUnfocusedEvent>(_onReportIssueRestaurantMessageUnfocusedEvent);
    on<ReportIssueRestaurantSubmitEvent>(_onReportIssueRestaurantSubmitEvent);
  }

  FutureOr<void> _onReportIssueRestaurantModalInitialEvent(ReportIssueRestaurantModalInitialEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "report_issue_restaurant"}, 'report_issue_restaurant_screen', 'report_issue_restaurant_screen');
      emit(state.copyWith(status: ReportIssueRestaurantModalStatus.loading, restaurant: event.id));
      DioApiResponse response = await _restaurantRepository.getReportIssueRestaurantReasons();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        ReportIssueRestaurantReasonListModel data = ReportIssueRestaurantReasonListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? ReportIssueRestaurantModalStatus.success : ReportIssueRestaurantModalStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ReportIssueRestaurantModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ReportIssueRestaurantModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onReportIssueRestaurantModalSelectReasonEvent(ReportIssueRestaurantModalSelectReasonEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    emit(state.copyWith(reasonId: event.id, reasonName: event.name, issueSelected: true));
  }

  FutureOr<void> _onReportIssueRestaurantReSelectEvent(ReportIssueRestaurantReSelectEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    emit(state.copyWith(reasonId: '', reasonName: '', issueSelected: false));
  }

  FutureOr<void> _onReportIssueRestaurantMessageChangedEvent(ReportIssueRestaurantMessageChangedEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    final message = ReportIssueRestaurantMessageField.dirty(event.message);
    emit(state.copyWith(message: message.isValid ? message : ReportIssueRestaurantMessageField.pure(event.message), isValid: Formz.validate([message])));
  }

  FutureOr<void> _onReportIssueRestaurantMessageUnfocusedEvent(ReportIssueRestaurantMessageUnfocusedEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    final message = ReportIssueRestaurantMessageField.dirty(state.message.value);
    emit(state.copyWith(message: message, isValid: Formz.validate([message])));
  }

  FutureOr<void> _onReportIssueRestaurantSubmitEvent(ReportIssueRestaurantSubmitEvent event, Emitter<ReportIssueRestaurantModalState> emit) async {
    final message = ReportIssueRestaurantMessageField.dirty(state.message.value);
    emit(state.copyWith(message: message, isValid: Formz.validate([message])));
    if (state.isValid && state.message.value.isNotEmpty) {
      try {
        emit(state.copyWith(status: ReportIssueRestaurantModalStatus.inProgress));
        final String userId = await _restaurantRepository.userId();
        ReportIssueRestaurantRequestModel param = ReportIssueRestaurantRequestModel(user: userId, restaurant: state.restaurant, reason: state.reasonId, message: state.message.value.toString());
        DioApiResponse response = await _restaurantRepository.saveReportIssueRestaurant(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: ReportIssueRestaurantModalStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            emit(state.copyWith(status: ReportIssueRestaurantModalStatus.reportSent));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ReportIssueRestaurantModalStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: ReportIssueRestaurantModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

