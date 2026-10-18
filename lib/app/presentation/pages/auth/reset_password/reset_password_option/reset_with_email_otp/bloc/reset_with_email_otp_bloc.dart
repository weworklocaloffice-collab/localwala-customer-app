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
import 'package:user/app/core/models/request/forgot_password_with_email_request_model.dart';
import 'package:user/app/core/models/request/update_password_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/reset_password_form/reset_with_email_form.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'reset_with_email_otp_event.dart';
part 'reset_with_email_otp_state.dart';

class ResetWithEmailOtpBloc extends Bloc<ResetWithEmailOtpEvent, ResetWithEmailOtpState> {
  final AuthRepository _authRepository = AuthRepository();
  ResetWithEmailOtpBloc()
    : super(
        ResetWithEmailOtpState(
          verification: ForgotPasswordResponseModel(sent: true, target: '', method: '', otpLength: 0, canResendOtp: false, id: '', provider: '', token: ''),
        ),
      ) {
    on<ResetWithEmailOtpInitialEvent>(_onResetWithEmailOtpInitialEvent);
    on<ResetWithOptionOneEmailChangedEvent>(_onResetWithOptionOneEmailChangedEvent);
    on<ResetWithOptionOneEmailUnfocusedEvent>(_onResetWithOptionOneEmailUnfocusedEvent);
    on<ResetWithOptionOneSendVerificationMailEvent>(_onResetWithOptionOneSendVerificationMailEvent);
    on<ResetWithOptionOneVerificationSuccessEvent>(_onResetWithOptionOneVerificationSuccessEvent);
    on<ResetWithOptionOnePasswordChangedEvent>(_onResetWithOptionOnePasswordChangedEvent);
    on<ResetWithOptionOnePasswordUnfocusedEvent>(_onResetWithOptionOnePasswordUnfocusedEvent);
    on<ResetWithOptionOneConfirmPasswordChangedEvent>(_onResetWithOptionOneConfirmPasswordChangedEvent);
    on<ResetWithOptionOneConfirmPasswordUnfocusedEvent>(_onResetWithOptionOneConfirmPasswordUnfocusedEvent);
    on<ResetWithOptionOneUpdatePasswordEvent>(_onResetWithOptionOneUpdatePasswordEvent);
  }

  FutureOr<void> _onResetWithEmailOtpInitialEvent(ResetWithEmailOtpInitialEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "reset_password_with_email_otp"}, 'reset_password_with_email_otp_screen', 'reset_password_with_email_otp_screen');
  }

  FutureOr<void> _onResetWithOptionOneEmailChangedEvent(ResetWithOptionOneEmailChangedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final email = ResetWithOptionOneEmailField.dirty(event.email);
    emit(state.copyWith(email: email.isValid ? email : ResetWithOptionOneEmailField.pure(event.email), status: ResetWithEmailOtpStatus.initial, isEmailValid: Formz.validate([email])));
  }

  FutureOr<void> _onResetWithOptionOneEmailUnfocusedEvent(ResetWithOptionOneEmailUnfocusedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final email = ResetWithOptionOneEmailField.dirty(state.email.value);
    emit(state.copyWith(email: email, status: ResetWithEmailOtpStatus.initial, isEmailValid: Formz.validate([email])));
  }

  FutureOr<void> _onResetWithOptionOneSendVerificationMailEvent(ResetWithOptionOneSendVerificationMailEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    try {
      final email = ResetWithOptionOneEmailField.dirty(state.email.value);
      emit(state.copyWith(email: email, status: ResetWithEmailOtpStatus.initial, isEmailValid: Formz.validate([email])));
      if (state.isEmailValid && state.email.value.isNotEmpty) {
        emit(state.copyWith(status: ResetWithEmailOtpStatus.inProgress));
        final String defaultLocale = await _authRepository.getLocale();
        ForgotPasswordWithEmailRequestModel param = ForgotPasswordWithEmailRequestModel(email: state.email.value, locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage);
        DioApiResponse response = await _authRepository.forgotPasswordWithEmail(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ForgotPasswordResponseModel data = ForgotPasswordResponseModel.fromJson(myMap);
          if (data.sent == false && data.target == 'web_modal') {
            emit(state.copyWith(verification: data, status: ResetWithEmailOtpStatus.verifyWeb, locale: defaultLocale));
          } else {
            emit(state.copyWith(verification: data, status: ResetWithEmailOtpStatus.verify, locale: defaultLocale));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ResetWithEmailOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ResetWithEmailOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onResetWithOptionOneVerificationSuccessEvent(ResetWithOptionOneVerificationSuccessEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    emit(state.copyWith(isVerified: true, status: ResetWithEmailOtpStatus.initial));
  }

  FutureOr<void> _onResetWithOptionOnePasswordChangedEvent(ResetWithOptionOnePasswordChangedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final password = ResetWithOptionOnePasswordField.dirty(event.password);
    emit(state.copyWith(password: password.isValid ? password : ResetWithOptionOnePasswordField.pure(event.password), status: ResetWithEmailOtpStatus.initial, isPasswordValid: Formz.validate([password, state.confirmedPassword])));
  }

  FutureOr<void> _onResetWithOptionOnePasswordUnfocusedEvent(ResetWithOptionOnePasswordUnfocusedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final password = ResetWithOptionOnePasswordField.dirty(state.password.value);
    emit(state.copyWith(password: password, status: ResetWithEmailOtpStatus.initial, isPasswordValid: Formz.validate([password, state.confirmedPassword])));
  }

  FutureOr<void> _onResetWithOptionOneConfirmPasswordChangedEvent(ResetWithOptionOneConfirmPasswordChangedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final confirmedPassword = ResetWithOptionOneConfirmedPasswordField.dirty(password: state.password.value, value: event.password);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: ResetWithEmailOtpStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onResetWithOptionOneConfirmPasswordUnfocusedEvent(ResetWithOptionOneConfirmPasswordUnfocusedEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    final confirmedPassword = ResetWithOptionOneConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: ResetWithEmailOtpStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onResetWithOptionOneUpdatePasswordEvent(ResetWithOptionOneUpdatePasswordEvent event, Emitter<ResetWithEmailOtpState> emit) async {
    try {
      final password = ResetWithOptionOnePasswordField.dirty(state.password.value);
      final confirmPassword = ResetWithOptionOneConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
      emit(state.copyWith(status: ResetWithEmailOtpStatus.initial, isPasswordValid: Formz.validate([password, confirmPassword])));
      if (state.isPasswordValid) {
        emit(state.copyWith(status: ResetWithEmailOtpStatus.inProgress));
        UpdatePasswordRequestModel param = UpdatePasswordRequestModel(password: state.password.value.toString(), verificationId: state.verification.id!, token: state.verification.token!);
        DioApiResponse response = await _authRepository.updatePassword(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
          if (!data.success!) {
            emit(state.copyWith(status: ResetWithEmailOtpStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            emit(state.copyWith(status: ResetWithEmailOtpStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ResetWithEmailOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ResetWithEmailOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

