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
import 'package:user/app/core/models/report_emergency_select_query_model.dart';
import 'package:user/app/core/models/request/report_emergency_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/report_emergency_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'report_emergency_event.dart';
part 'report_emergency_state.dart';

class ReportEmergencyBloc extends Bloc<ReportEmergencyEvent, ReportEmergencyState> {
  final AuthRepository _authRepository = AuthRepository();
  ReportEmergencyBloc()
    : super(
        ReportEmergencyState(
          savedQuery: ReportEmergencyFormSelectModel(label: '', report: ''),
        ),
      ) {
    on<ReportEmergencyInitialEvent>(_onReportEmergencyInitialEvent);
    on<ReportEmergencyFormNameChangedEvent>(_onReportEmergencyFormNameChangedEvent);
    on<ReportEmergencyFormNameUnfocusedEvent>(_onReportEmergencyFormNameUnfocusedEvent);
    on<ReportEmergencyFormCountryCodeChangedEvent>(_onReportEmergencyFormCountryCodeChangedEvent);
    on<ReportEmergencyFormNumberChangedEvent>(_onReportEmergencyFormNumberChangedEvent);
    on<ReportEmergencyFormNumberUnfocusedEvent>(_onReportEmergencyFormNumberUnfocusedEvent);
    on<ReportEmergencyFormEmailChangedEvent>(_onReportEmergencyFormEmailChangedEvent);
    on<ReportEmergencyFormEmailUnfocusedEvent>(_onReportEmergencyFormEmailUnfocusedEvent);
    on<ReportEmergencyFormDescriptionChangedEvent>(_onReportEmergencyFormDescriptionChangedEvent);
    on<ReportEmergencyFormDescriptionUnfocusedEvent>(_onReportEmergencyFormDescriptionUnfocusedEvent);
    on<ReportEmergecyFormSelectQueryEvent>(_onReportEmergecyFormSelectQueryEvent);
    on<ReportEmergencyFormSubmitEvent>(_onReportEmergencyFormSubmitEvent);
  }

  FutureOr<void> _onReportEmergencyInitialEvent(ReportEmergencyInitialEvent event, Emitter<ReportEmergencyState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "report_emergency_form"}, 'report_emergency_screen', 'report_emergency_screen');
    final name = ReportEmergencyFormNameField.dirty(state.userName.value);
    final number = ReportEmergencyFormNumberField.dirty(state.userContact.value);
    final email = ReportEmergencyFormEmailField.dirty(state.userEmail.value);
    final shortDescritpion = ReportEmergencyFormShortDescriptionField.dirty(state.shortDescritpion.value);
    String defaultCountryCode = '';
    String flag = '';
    await _authRepository.getDefaultCountryCode().then((value) {
      if (value.isNotEmpty) {
        try {
          Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
          AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
          defaultCountryCode = countryCodeData.dialCode!;
          flag = countryCodeData.flag!;
        } catch (e, stacktrace) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    });
    List<ReportEmergencyFormSelectModel> queryList = <ReportEmergencyFormSelectModel>[];
    queryList.clear();
    ReportEmergencyFormSelectModel accident = ReportEmergencyFormSelectModel(label: 'dd_report_accident', report: 'accident');
    ReportEmergencyFormSelectModel incident = ReportEmergencyFormSelectModel(label: 'dd_report_incident', report: 'incident');
    queryList.add(accident);
    queryList.add(incident);
    emit(
      state.copyWith(
        userEmail: email.isValid ? email : const ReportEmergencyFormEmailField.pure(''),
        userName: name.isValid ? name : const ReportEmergencyFormNameField.pure(''),
        userCountryCode: ReportEmergencyFormCountryCodeField.pure(defaultCountryCode),
        flag: flag,
        userContact: number.isValid ? number : const ReportEmergencyFormNumberField.pure(''),
        shortDescritpion: shortDescritpion.isValid ? shortDescritpion : const ReportEmergencyFormShortDescriptionField.pure(''),
        query: queryList,
        savedQuery: accident,
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([name, number]),
      ),
    );
  }

  FutureOr<void> _onReportEmergencyFormNameChangedEvent(ReportEmergencyFormNameChangedEvent event, Emitter<ReportEmergencyState> emit) async {
    final name = ReportEmergencyFormNameField.dirty(event.name);
    emit(
      state.copyWith(
        userName: name.isValid ? name : ReportEmergencyFormNameField.pure(event.name),
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onReportEmergencyFormNameUnfocusedEvent(ReportEmergencyFormNameUnfocusedEvent event, Emitter<ReportEmergencyState> emit) async {
    final name = ReportEmergencyFormNameField.dirty(state.userName.value);
    emit(state.copyWith(userName: name, status: ReportEmergencyStatus.initial, isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onReportEmergencyFormCountryCodeChangedEvent(ReportEmergencyFormCountryCodeChangedEvent event, Emitter<ReportEmergencyState> emit) async {
    final countryCode = ReportEmergencyFormCountryCodeField.dirty(event.countryCode);
    emit(state.copyWith(userCountryCode: countryCode, flag: event.flag, status: ReportEmergencyStatus.initial, isValid: Formz.validate([countryCode, state.userName, state.userContact, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onReportEmergencyFormNumberChangedEvent(ReportEmergencyFormNumberChangedEvent event, Emitter<ReportEmergencyState> emit) async {
    final number = ReportEmergencyFormNumberField.dirty(event.number);
    emit(
      state.copyWith(
        userContact: number.isValid ? number : ReportEmergencyFormNumberField.pure(event.number),
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onReportEmergencyFormNumberUnfocusedEvent(ReportEmergencyFormNumberUnfocusedEvent event, Emitter<ReportEmergencyState> emit) async {
    final number = ReportEmergencyFormNumberField.dirty(state.userContact.value);
    emit(state.copyWith(userContact: number, status: ReportEmergencyStatus.initial, isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onReportEmergencyFormEmailChangedEvent(ReportEmergencyFormEmailChangedEvent event, Emitter<ReportEmergencyState> emit) async {
    final email = ReportEmergencyFormEmailField.dirty(event.email);
    emit(
      state.copyWith(
        userEmail: email.isValid ? email : ReportEmergencyFormEmailField.pure(event.email),
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onReportEmergencyFormEmailUnfocusedEvent(ReportEmergencyFormEmailUnfocusedEvent event, Emitter<ReportEmergencyState> emit) async {
    final email = ReportEmergencyFormEmailField.dirty(state.userEmail.value);
    emit(state.copyWith(userEmail: email, status: ReportEmergencyStatus.initial, isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact, state.shortDescritpion])));
  }

  FutureOr<void> _onReportEmergencyFormDescriptionChangedEvent(ReportEmergencyFormDescriptionChangedEvent event, Emitter<ReportEmergencyState> emit) async {
    final shortDescription = ReportEmergencyFormShortDescriptionField.dirty(event.text);
    emit(
      state.copyWith(
        shortDescritpion: shortDescription.isValid ? shortDescription : ReportEmergencyFormShortDescriptionField.pure(event.text),
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([shortDescription, state.userName, state.userCountryCode, state.userContact, state.userEmail]),
      ),
    );
  }

  FutureOr<void> _onReportEmergencyFormDescriptionUnfocusedEvent(ReportEmergencyFormDescriptionUnfocusedEvent event, Emitter<ReportEmergencyState> emit) async {
    final shortDescription = ReportEmergencyFormShortDescriptionField.dirty(state.shortDescritpion.value);
    emit(state.copyWith(shortDescritpion: shortDescription, status: ReportEmergencyStatus.initial, isValid: Formz.validate([shortDescription, state.userName, state.userCountryCode, state.userContact, state.userEmail])));
  }

  FutureOr<void> _onReportEmergecyFormSelectQueryEvent(ReportEmergecyFormSelectQueryEvent event, Emitter<ReportEmergencyState> emit) async {
    ReportEmergencyFormSelectModel newQuery = ReportEmergencyFormSelectModel();
    newQuery = state.query.firstWhere((element) => element.report == event.report);
    emit(state.copyWith(status: ReportEmergencyStatus.initial, savedQuery: newQuery));
  }

  FutureOr<void> _onReportEmergencyFormSubmitEvent(ReportEmergencyFormSubmitEvent event, Emitter<ReportEmergencyState> emit) async {
    final name = ReportEmergencyFormNameField.dirty(state.userName.value);
    final number = ReportEmergencyFormNumberField.dirty(state.userContact.value);
    final countryCode = ReportEmergencyFormCountryCodeField.dirty(state.userCountryCode.value);
    final email = ReportEmergencyFormEmailField.dirty(state.userEmail.value);
    final shortDescription = ReportEmergencyFormShortDescriptionField.dirty(state.shortDescritpion.value);
    emit(
      state.copyWith(
        userName: name,
        userContact: number,
        userCountryCode: countryCode,
        userEmail: email,
        shortDescritpion: shortDescription,
        status: ReportEmergencyStatus.initial,
        isValid: Formz.validate([name, number, countryCode, email, shortDescription]),
      ),
    );
    if (state.isValid && state.userName.value.isNotEmpty && state.userContact.value.isNotEmpty && state.userCountryCode.value.isNotEmpty && state.userEmail.value.isNotEmpty && state.shortDescritpion.value.isNotEmpty) {
      try {
        emit(state.copyWith(status: ReportEmergencyStatus.submit));
        ReportEmergencyFormRequestModel param = ReportEmergencyFormRequestModel(
          type: state.savedQuery.report.toString(),
          userName: state.userName.value.toString(),
          userCountryCode: state.userCountryCode.value.toString(),
          userContact: state.userContact.value.toString(),
          userEmail: state.userEmail.value.toString(),
          shortDescription: state.shortDescritpion.value.toString(),
        );
        DioApiResponse response = await _authRepository.submitReportEmergencyForm(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: ReportEmergencyStatus.failure));
          } else {
            emit(state.copyWith(status: ReportEmergencyStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ReportEmergencyStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: ReportEmergencyStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

