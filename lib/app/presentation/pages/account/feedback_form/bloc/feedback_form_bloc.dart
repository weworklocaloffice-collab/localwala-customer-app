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
import 'package:user/app/core/models/request/feedback_form_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/feedback_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'feedback_form_event.dart';
part 'feedback_form_state.dart';

class FeedbackFormBloc extends Bloc<FeedbackFormEvent, FeedbackFormState> {
  final AuthRepository _authRepository = AuthRepository();
  FeedbackFormBloc() : super(const FeedbackFormState()) {
    on<FeedbackFormInitialEvent>(_onFeedbackFormInitialEvent);
    on<FeedbackFormNameChangedEvent>(_onFeedbackFormNameChangedEvent);
    on<FeedbackFormNameUnfocusedEvent>(_onFeedbackFormNameUnfocusedEvent);
    on<FeedbackFormCountryCodeChangedEvent>(_onFeedbackFormCountryCodeChangedEvent);
    on<FeedbackFormNumberChangedEvent>(_onFeedbackFormNumberChangedEvent);
    on<FeedbackFormNumberUnfocusedEvent>(_onFeedbackFormNumberUnfocusedEvent);
    on<FeedbackFormEmailChangedEvent>(_onFeedbackFormEmailChangedEvent);
    on<FeedbackFormEmailUnfocusedEvent>(_onFeedbackFormEmailUnfocusedEvent);
    on<FeedbackFormDescriptionChangedEvent>(_onFeedbackFormDescriptionChangedEvent);
    on<FeedbackFormDescriptionUnfocusedEvent>(_onFeedbackFormDescriptionUnfocusedEvent);
    on<FeedbackFormSubmitEvent>(_onFeedbackFormSubmitEvent);
  }

  FutureOr<void> _onFeedbackFormInitialEvent(FeedbackFormInitialEvent event, Emitter<FeedbackFormState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "feedback_form"}, 'feedback_form_screen', 'feedback_form_screen');
    final name = FeedbackFormNameField.dirty(state.userName.value);
    final number = FeedbackFormNumberField.dirty(state.userContact.value);
    final email = FeedbackFormEmailField.dirty(state.userEmail.value);
    final shortDescritpion = FeedbackFormShortDescriptionField.dirty(state.shortDescritpion.value);
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
    emit(
      state.copyWith(
        userEmail: email.isValid ? email : const FeedbackFormEmailField.pure(''),
        userName: name.isValid ? name : const FeedbackFormNameField.pure(''),
        userCountryCode: FeedbackFormCountryCodeField.pure(defaultCountryCode),
        flag: flag,
        userContact: number.isValid ? number : const FeedbackFormNumberField.pure(''),
        shortDescritpion: shortDescritpion.isValid ? shortDescritpion : const FeedbackFormShortDescriptionField.pure(''),
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([name, number]),
      ),
    );
  }

  FutureOr<void> _onFeedbackFormNameChangedEvent(FeedbackFormNameChangedEvent event, Emitter<FeedbackFormState> emit) async {
    final name = FeedbackFormNameField.dirty(event.name);
    emit(
      state.copyWith(
        userName: name.isValid ? name : FeedbackFormNameField.pure(event.name),
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onFeedbackFormNameUnfocusedEvent(FeedbackFormNameUnfocusedEvent event, Emitter<FeedbackFormState> emit) async {
    final name = FeedbackFormNameField.dirty(state.userName.value);
    emit(state.copyWith(userName: name, status: FeedbackFormStatus.initial, isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onFeedbackFormCountryCodeChangedEvent(FeedbackFormCountryCodeChangedEvent event, Emitter<FeedbackFormState> emit) async {
    final countryCode = FeedbackFormCountryCodeField.dirty(event.countryCode);
    emit(state.copyWith(userCountryCode: countryCode, flag: event.flag, status: FeedbackFormStatus.initial, isValid: Formz.validate([countryCode, state.userName, state.userContact, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onFeedbackFormNumberChangedEvent(FeedbackFormNumberChangedEvent event, Emitter<FeedbackFormState> emit) async {
    final number = FeedbackFormNumberField.dirty(event.number);
    emit(
      state.copyWith(
        userContact: number.isValid ? number : FeedbackFormNumberField.pure(event.number),
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onFeedbackFormNumberUnfocusedEvent(FeedbackFormNumberUnfocusedEvent event, Emitter<FeedbackFormState> emit) async {
    final number = FeedbackFormNumberField.dirty(state.userContact.value);
    emit(state.copyWith(userContact: number, status: FeedbackFormStatus.initial, isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail, state.shortDescritpion])));
  }

  FutureOr<void> _onFeedbackFormEmailChangedEvent(FeedbackFormEmailChangedEvent event, Emitter<FeedbackFormState> emit) async {
    final email = FeedbackFormEmailField.dirty(event.email);
    emit(
      state.copyWith(
        userEmail: email.isValid ? email : FeedbackFormEmailField.pure(event.email),
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact, state.shortDescritpion]),
      ),
    );
  }

  FutureOr<void> _onFeedbackFormEmailUnfocusedEvent(FeedbackFormEmailUnfocusedEvent event, Emitter<FeedbackFormState> emit) async {
    final email = FeedbackFormEmailField.dirty(state.userEmail.value);
    emit(state.copyWith(userEmail: email, status: FeedbackFormStatus.initial, isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact, state.shortDescritpion])));
  }

  FutureOr<void> _onFeedbackFormDescriptionChangedEvent(FeedbackFormDescriptionChangedEvent event, Emitter<FeedbackFormState> emit) async {
    final shortDescription = FeedbackFormShortDescriptionField.dirty(event.text);
    emit(
      state.copyWith(
        shortDescritpion: shortDescription.isValid ? shortDescription : FeedbackFormShortDescriptionField.pure(event.text),
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([shortDescription, state.userName, state.userCountryCode, state.userContact, state.userEmail]),
      ),
    );
  }

  FutureOr<void> _onFeedbackFormDescriptionUnfocusedEvent(FeedbackFormDescriptionUnfocusedEvent event, Emitter<FeedbackFormState> emit) async {
    final shortDescription = FeedbackFormShortDescriptionField.dirty(state.shortDescritpion.value);
    emit(state.copyWith(shortDescritpion: shortDescription, status: FeedbackFormStatus.initial, isValid: Formz.validate([shortDescription, state.userName, state.userCountryCode, state.userContact, state.userEmail])));
  }

  FutureOr<void> _onFeedbackFormSubmitEvent(FeedbackFormSubmitEvent event, Emitter<FeedbackFormState> emit) async {
    final name = FeedbackFormNameField.dirty(state.userName.value);
    final number = FeedbackFormNumberField.dirty(state.userContact.value);
    final countryCode = FeedbackFormCountryCodeField.dirty(state.userCountryCode.value);
    final email = FeedbackFormEmailField.dirty(state.userEmail.value);
    final shortDescription = FeedbackFormShortDescriptionField.dirty(state.shortDescritpion.value);
    emit(
      state.copyWith(
        userName: name,
        userContact: number,
        userCountryCode: countryCode,
        userEmail: email,
        shortDescritpion: shortDescription,
        status: FeedbackFormStatus.initial,
        isValid: Formz.validate([name, number, countryCode, email, shortDescription]),
      ),
    );
    if (state.isValid && state.userName.value.isNotEmpty && state.userContact.value.isNotEmpty && state.userCountryCode.value.isNotEmpty && state.userEmail.value.isNotEmpty && state.shortDescritpion.value.isNotEmpty) {
      try {
        emit(state.copyWith(status: FeedbackFormStatus.submit));
        FeedbackFormRequestModel param = FeedbackFormRequestModel(
          userName: state.userName.value.toString(),
          userCountryCode: state.userCountryCode.value.toString(),
          userContact: state.userContact.value.toString(),
          userEmail: state.userEmail.value.toString(),
          shortDescription: state.shortDescritpion.value.toString(),
        );
        DioApiResponse response = await _authRepository.submitFeedbackForm(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FeedbackFormStatus.failure));
          } else {
            emit(state.copyWith(status: FeedbackFormStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FeedbackFormStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FeedbackFormStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

