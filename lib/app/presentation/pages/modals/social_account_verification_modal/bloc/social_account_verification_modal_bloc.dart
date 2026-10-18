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
import 'package:user/app/core/models/request/check_mobile_number_exist_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/login_form/social_account_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'social_account_verification_modal_event.dart';
part 'social_account_verification_modal_state.dart';

class SocialAccountVerificationModalBloc extends Bloc<SocialAccountVerificationModalEvent, SocialAccountVerificationModalState> {
  final AuthRepository _authRepository = AuthRepository();
  SocialAccountVerificationModalBloc() : super(const SocialAccountVerificationModalState()) {
    on<SocialAccountVerificationModalInitialEvent>(_onSocialAccountVerificationModalInitialEvent);
    on<SocialAccountVerificationModalFirstNameChangedEvent>(_onSocialAccountVerificationModalFirstNameChangedEvent);
    on<SocialAccountVerificationModalFirstNameUnfocusedEvent>(_onSocialAccountVerificationModalFirstNameUnfocusedEvent);
    on<SocialAccountVerificationModalLastNameChangedEvent>(_onSocialAccountVerificationModalLastNameChangedEvent);
    on<SocialAccountVerificationModalLastNameUnfocusedEvent>(_onSocialAccountVerificationModalLastNameUnfocusedEvent);
    on<SocialAccountVerificationModalCountryCodeChangedEvent>(_onSocialAccountVerificationModalCountryCodeChangedEvent);
    on<SocialAccountVerificationModalCountryCodeUnfocusedEvent>(_onSocialAccountVerificationModalCountryCodeUnfocusedEvent);
    on<SocialAccountVerificationModalMobileNumberChangedEvent>(_onSocialAccountVerificationModalMobileNumberChangedEvent);
    on<SocialAccountVerificationModalMobileNumberUnfocusedEvent>(_onSocialAccountVerificationModalMobileNumberUnfocusedEvent);
    on<SocialAccountVerificationModalSubmitEvent>(_onSocialAccountVerificationModalSubmitEvent);
  }

  FutureOr<void> _onSocialAccountVerificationModalInitialEvent(SocialAccountVerificationModalInitialEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "social_account_verification"}, 'social_account_verification_screen', 'social_account_verification_screen');
    await _authRepository.getDefaultCountryCode().then((value) {
      if (value.isNotEmpty) {
        try {
          Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
          AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
          final countryCode = SocialAccountVerificationCountryCodeField.dirty(countryCodeData.dialCode!);
          final firstName = SocialAccountVerificationFirstNameField.dirty(state.firstName.value);
          final lastName = SocialAccountVerificationLastNameField.dirty(state.lastName.value);
          emit(
            state.copyWith(
              countryCode: countryCode.isValid ? countryCode : SocialAccountVerificationCountryCodeField.pure(countryCodeData.dialCode!),
              flag: countryCodeData.flag!,
              firstName: firstName.isValid ? firstName : SocialAccountVerificationFirstNameField.pure(event.firstName),
              lastName: lastName.isValid ? lastName : SocialAccountVerificationLastNameField.pure(event.lastName),
              status: SocialAccountVerificationModalStatus.loaded,
              isValid: Formz.validate([countryCode, state.firstName, state.lastName, state.mobileNumber]),
            ),
          );
        } catch (e, stacktrace) {
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    });
  }

  FutureOr<void> _onSocialAccountVerificationModalFirstNameChangedEvent(SocialAccountVerificationModalFirstNameChangedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final firstName = SocialAccountVerificationFirstNameField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName.isValid ? firstName : SocialAccountVerificationFirstNameField.pure(event.firstName),
        status: SocialAccountVerificationModalStatus.initial,
        isValid: Formz.validate([firstName, state.lastName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onSocialAccountVerificationModalFirstNameUnfocusedEvent(SocialAccountVerificationModalFirstNameUnfocusedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final firstName = SocialAccountVerificationFirstNameField.dirty(state.firstName.value);
    emit(state.copyWith(firstName: firstName, status: SocialAccountVerificationModalStatus.initial, isValid: Formz.validate([firstName, state.lastName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onSocialAccountVerificationModalLastNameChangedEvent(SocialAccountVerificationModalLastNameChangedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final lastName = SocialAccountVerificationLastNameField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastName: lastName.isValid ? lastName : SocialAccountVerificationLastNameField.pure(event.lastName),
        status: SocialAccountVerificationModalStatus.initial,
        isValid: Formz.validate([lastName, state.firstName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onSocialAccountVerificationModalLastNameUnfocusedEvent(SocialAccountVerificationModalLastNameUnfocusedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final lastName = SocialAccountVerificationLastNameField.dirty(state.lastName.value);
    emit(state.copyWith(lastName: lastName, status: SocialAccountVerificationModalStatus.initial, isValid: Formz.validate([lastName, state.firstName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onSocialAccountVerificationModalCountryCodeChangedEvent(SocialAccountVerificationModalCountryCodeChangedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final countryCode = SocialAccountVerificationCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCode: countryCode.isValid ? countryCode : SocialAccountVerificationCountryCodeField.pure(event.countryCode),
        status: SocialAccountVerificationModalStatus.initial,
        isValid: Formz.validate([countryCode, state.firstName, state.lastName, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onSocialAccountVerificationModalCountryCodeUnfocusedEvent(SocialAccountVerificationModalCountryCodeUnfocusedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final countryCode = SocialAccountVerificationCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(countryCode: countryCode, status: SocialAccountVerificationModalStatus.initial, isValid: Formz.validate([countryCode, state.firstName, state.lastName, state.mobileNumber])));
  }

  FutureOr<void> _onSocialAccountVerificationModalMobileNumberChangedEvent(SocialAccountVerificationModalMobileNumberChangedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final mobileNumber = SocialAccountVerificationMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumber: mobileNumber.isValid ? mobileNumber : SocialAccountVerificationMobileNumberField.pure(event.mobileNumber),
        status: SocialAccountVerificationModalStatus.initial,
        isValid: Formz.validate([mobileNumber, state.firstName, state.lastName, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onSocialAccountVerificationModalMobileNumberUnfocusedEvent(SocialAccountVerificationModalMobileNumberUnfocusedEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final mobileNumber = SocialAccountVerificationMobileNumberField.dirty(state.mobileNumber.value);
    emit(state.copyWith(mobileNumber: mobileNumber, status: SocialAccountVerificationModalStatus.initial, isValid: Formz.validate([mobileNumber, state.firstName, state.lastName, state.countryCode])));
  }

  FutureOr<void> _onSocialAccountVerificationModalSubmitEvent(SocialAccountVerificationModalSubmitEvent event, Emitter<SocialAccountVerificationModalState> emit) async {
    final firstName = SocialAccountVerificationFirstNameField.dirty(state.firstName.value);
    final lastName = SocialAccountVerificationLastNameField.dirty(state.lastName.value);
    final countryCode = SocialAccountVerificationCountryCodeField.dirty(state.countryCode.value);
    final mobileNumber = SocialAccountVerificationMobileNumberField.dirty(state.mobileNumber.value);
    emit(
      state.copyWith(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        status: SocialAccountVerificationModalStatus.initial,
        isValid: Formz.validate([firstName, lastName, countryCode, mobileNumber]),
      ),
    );
    if (state.isValid && state.firstName.value.isNotEmpty && state.lastName.value.isNotEmpty && state.countryCode.value.isNotEmpty && state.mobileNumber.value.isNotEmpty) {
      try {
        emit(state.copyWith(status: SocialAccountVerificationModalStatus.inProgress));
        CheckMobileNumberExistRequestModel param = CheckMobileNumberExistRequestModel(countryCode: state.countryCode.value, mobile: state.mobileNumber.value);
        DioApiResponse response = await _authRepository.checkMobileNumberExist(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: SocialAccountVerificationModalStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SocialAccountVerificationModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: SocialAccountVerificationModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

