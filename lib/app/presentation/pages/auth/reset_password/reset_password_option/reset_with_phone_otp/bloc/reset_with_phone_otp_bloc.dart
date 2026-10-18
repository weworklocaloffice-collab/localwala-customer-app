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
import 'package:user/app/core/models/forgot_password_response_model.dart';
import 'package:user/app/core/models/request/forgot_password_with_phone_request_model.dart';
import 'package:user/app/core/models/request/update_password_firebase_request_model.dart';
import 'package:user/app/core/models/request/update_password_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/reset_password_form/reset_with_phone_form.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'reset_with_phone_otp_event.dart';
part 'reset_with_phone_otp_state.dart';

class ResetWithPhoneOtpBloc extends Bloc<ResetWithPhoneOtpEvent, ResetWithPhoneOtpState> {
  final AuthRepository _authRepository = AuthRepository();
  ResetWithPhoneOtpBloc()
    : super(
        ResetWithPhoneOtpState(
          verification: ForgotPasswordResponseModel(sent: true, target: '', method: '', otpLength: 0, canResendOtp: false, id: '', provider: '', token: ''),
        ),
      ) {
    on<ResetWithPhoneInitialEvent>(_onResetWithPhoneInitialEvent);
    on<ResetWithPhoneTypeTwoCountryCodeChangedEvent>(_onResetWithPhoneTypeTwoCountryCodeChangedEvent);
    on<ResetWithPhoneTypeTwoCountryCodeUnfocusedEvent>(_onResetWithPhoneTypeTwoCountryCodeUnfocusedEvent);
    on<ResetWithPhoneTypeTwoMobileNumberChangedEvent>(_onResetWithPhoneTypeTwoMobileNumberChangedEvent);
    on<ResetWithPhoneTypeTwoMobileNumberUnfocusedEvent>(_onResetWithPhoneTypeTwoMobileNumberUnfocusedEvent);
    on<ResetWithPhoneTypeTwoSendVerificationSMSEvent>(_onResetWithPhoneTypeTwoSendVerificationSMSEvent);
    on<ResetWithOptionTwoVerificationSuccessEvent>(_onResetWithOptionTwoVerificationSuccessEvent);
    on<ResetWithOptionTwoFirebaseVerificationEvent>(_onResetWithOptionTwoFirebaseVerificationEvent);
    on<ResetWithOptionTwoPasswordChangedEvent>(_onResetWithOptionTwoPasswordChangedEvent);
    on<ResetWithOptionTwoPasswordUnfocusedEvent>(_onResetWithOptionTwoPasswordUnfocusedEvent);
    on<ResetWithOptionTwoConfirmPasswordChangedEvent>(_onResetWithOptionTwoConfirmPasswordChangedEvent);
    on<ResetWithOptionTwoConfirmPasswordUnfocusedEvent>(_onResetWithOptionTwoConfirmPasswordUnfocusedEvent);
    on<ResetWithOptionTwoUpdatePasswordEvent>(_onResetWithOptionTwoUpdatePasswordEvent);
  }

  FutureOr<void> _onResetWithPhoneInitialEvent(ResetWithPhoneInitialEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "reset_password_with_phone_otp"}, 'reset_password_with_phone_otp_screen', 'reset_password_with_phone_otp_screen');
    await _authRepository.getDefaultCountryCode().then((value) {
      if (value.isNotEmpty) {
        try {
          Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
          AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
          final countryCode = ResetWithOptionTwoCountryCodeField.dirty(countryCodeData.dialCode!);
          emit(
            state.copyWith(
              flag: countryCodeData.flag!,
              countryCode: countryCode.isValid ? countryCode : ResetWithOptionTwoCountryCodeField.pure(countryCodeData.dialCode!),
              status: ResetWithPhoneOtpStatus.loaded,
              isPhoneValid: Formz.validate([countryCode, state.mobileNumber]),
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

  FutureOr<void> _onResetWithPhoneTypeTwoCountryCodeChangedEvent(ResetWithPhoneTypeTwoCountryCodeChangedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final countryCode = ResetWithOptionTwoCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCode: countryCode.isValid ? countryCode : ResetWithOptionTwoCountryCodeField.pure(event.countryCode),
        status: ResetWithPhoneOtpStatus.initial,
        isPhoneValid: Formz.validate([countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onResetWithPhoneTypeTwoCountryCodeUnfocusedEvent(ResetWithPhoneTypeTwoCountryCodeUnfocusedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final countryCode = ResetWithOptionTwoCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(countryCode: countryCode, status: ResetWithPhoneOtpStatus.initial, isPhoneValid: Formz.validate([countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onResetWithPhoneTypeTwoMobileNumberChangedEvent(ResetWithPhoneTypeTwoMobileNumberChangedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final mobileNumber = ResetWithOptionTwoMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumber: mobileNumber.isValid ? mobileNumber : ResetWithOptionTwoMobileNumberField.pure(event.mobileNumber),
        status: ResetWithPhoneOtpStatus.initial,
        isPhoneValid: Formz.validate([mobileNumber, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onResetWithPhoneTypeTwoMobileNumberUnfocusedEvent(ResetWithPhoneTypeTwoMobileNumberUnfocusedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final mobileNumber = ResetWithOptionTwoMobileNumberField.dirty(state.mobileNumber.value);
    emit(state.copyWith(mobileNumber: mobileNumber, status: ResetWithPhoneOtpStatus.initial, isPhoneValid: Formz.validate([mobileNumber, state.countryCode])));
  }

  FutureOr<void> _onResetWithPhoneTypeTwoSendVerificationSMSEvent(ResetWithPhoneTypeTwoSendVerificationSMSEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    try {
      final countryCode = ResetWithOptionTwoCountryCodeField.dirty(state.countryCode.value);
      final mobileNumber = ResetWithOptionTwoMobileNumberField.dirty(state.mobileNumber.value);
      emit(state.copyWith(countryCode: countryCode, mobileNumber: mobileNumber, status: ResetWithPhoneOtpStatus.initial, isPhoneValid: Formz.validate([countryCode, mobileNumber])));
      if (state.isPhoneValid && state.countryCode.value.isNotEmpty && state.mobileNumber.value.isNotEmpty) {
        emit(state.copyWith(status: ResetWithPhoneOtpStatus.inProgress));
        final String defaultLocale = await _authRepository.getLocale();
        ForgotPasswordWithPhoneRequestModel param = ForgotPasswordWithPhoneRequestModel(
          countryCode: state.countryCode.value,
          mobileNumber: int.parse(state.mobileNumber.value.toString()),
          locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
        );
        DioApiResponse response = await _authRepository.forgotPasswordWithPhone(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ForgotPasswordResponseModel data = ForgotPasswordResponseModel.fromJson(myMap);
          if (data.sent == false && data.target == 'web_modal') {
            emit(state.copyWith(verification: data, status: data.method! == 'firebase' ? ResetWithPhoneOtpStatus.verifyFirebase : ResetWithPhoneOtpStatus.verifyWeb, locale: defaultLocale));
          } else {
            emit(state.copyWith(verification: data, status: ResetWithPhoneOtpStatus.verify, locale: defaultLocale));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onResetWithOptionTwoVerificationSuccessEvent(ResetWithOptionTwoVerificationSuccessEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    emit(state.copyWith(isVerified: true, status: ResetWithPhoneOtpStatus.initial));
  }

  FutureOr<void> _onResetWithOptionTwoFirebaseVerificationEvent(ResetWithOptionTwoFirebaseVerificationEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    emit(state.copyWith(isVerified: true, firebaseAccessToken: event.accessToken, status: ResetWithPhoneOtpStatus.initial));
  }

  FutureOr<void> _onResetWithOptionTwoPasswordChangedEvent(ResetWithOptionTwoPasswordChangedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final password = ResetWithOptionTwoPasswordField.dirty(event.password);
    emit(state.copyWith(password: password.isValid ? password : ResetWithOptionTwoPasswordField.pure(event.password), status: ResetWithPhoneOtpStatus.initial, isPasswordValid: Formz.validate([password, state.confirmedPassword])));
  }

  FutureOr<void> _onResetWithOptionTwoPasswordUnfocusedEvent(ResetWithOptionTwoPasswordUnfocusedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final password = ResetWithOptionTwoPasswordField.dirty(state.password.value);
    emit(state.copyWith(password: password, status: ResetWithPhoneOtpStatus.initial, isPasswordValid: Formz.validate([password, state.confirmedPassword])));
  }

  FutureOr<void> _onResetWithOptionTwoConfirmPasswordChangedEvent(ResetWithOptionTwoConfirmPasswordChangedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final confirmedPassword = ResetWithOptionTwoConfirmedPasswordField.dirty(password: state.password.value, value: event.password);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: ResetWithPhoneOtpStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onResetWithOptionTwoConfirmPasswordUnfocusedEvent(ResetWithOptionTwoConfirmPasswordUnfocusedEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    final confirmedPassword = ResetWithOptionTwoConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: ResetWithPhoneOtpStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onResetWithOptionTwoUpdatePasswordEvent(ResetWithOptionTwoUpdatePasswordEvent event, Emitter<ResetWithPhoneOtpState> emit) async {
    try {
      final password = ResetWithOptionTwoPasswordField.dirty(state.password.value);
      final confirmPassword = ResetWithOptionTwoConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
      emit(state.copyWith(status: ResetWithPhoneOtpStatus.initial, isPasswordValid: Formz.validate([password, confirmPassword])));
      if (state.isPasswordValid) {
        if (state.verification.id! == 'firebase') {
          emit(state.copyWith(status: ResetWithPhoneOtpStatus.inProgress));
          UpdatePasswordFirebaseRequestModel param = UpdatePasswordFirebaseRequestModel(password: state.password.value.toString(), token: state.firebaseAccessToken, qtoken: state.verification.token!);
          DioApiResponse response = await _authRepository.updatePasswordFirebase(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
            if (!data.success!) {
              emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
            } else {
              emit(state.copyWith(status: ResetWithPhoneOtpStatus.success));
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          emit(state.copyWith(status: ResetWithPhoneOtpStatus.inProgress));
          UpdatePasswordRequestModel param = UpdatePasswordRequestModel(password: state.password.value.toString(), verificationId: state.verification.id!, token: state.verification.token!);
          DioApiResponse response = await _authRepository.updatePassword(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
            if (!data.success!) {
              emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
            } else {
              emit(state.copyWith(status: ResetWithPhoneOtpStatus.success));
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ResetWithPhoneOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

