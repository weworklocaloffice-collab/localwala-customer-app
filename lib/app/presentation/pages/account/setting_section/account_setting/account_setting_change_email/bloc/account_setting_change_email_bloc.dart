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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:formz/formz.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/account_setting_update_email_response_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/account_update_email_after_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_email_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/account_setting_update_email_form.dart';
import 'package:user/app/env.dart';

part 'account_setting_change_email_event.dart';
part 'account_setting_change_email_state.dart';

class AccountSettingChangeEmailBloc extends Bloc<AccountSettingChangeEmailEvent, AccountSettingChangeEmailState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingChangeEmailBloc()
    : super(
        AccountSettingChangeEmailState(
          verification: AccountSettingUpdateEmailResponseModel(sent: true, target: '', method: '', otpLength: 0, canResendOtp: false, id: '', provider: ''),
        ),
      ) {
    on<AccountSettingChangeEmailInitialEvent>(_onAccountSettingChangeEmailInitialEvent);
    on<AccountSettingChangeEmailChangedEvent>(_onAccountSettingChangeEmailChangedEvent);
    on<AccountSettingChangeEmailUnfocusedEvent>(_onAccountSettingChangeEmailUnfocusedEvent);
    on<AccountSettingChangeEmailSubmitEvent>(_onAccountSettingChangeEmailSubmitEvent);
    on<AccountSettingChangeEmailVerificationSuccessEvent>(_onAccountSettingChangeEmailVerificationSuccessEvent);
  }

  FutureOr<void> _onAccountSettingChangeEmailInitialEvent(AccountSettingChangeEmailInitialEvent event, Emitter<AccountSettingChangeEmailState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "change_email"}, 'change_email_screen', 'change_email_screen');
      final String userEmail = await _authRepository.userEmail();
      emit(state.copyWith(userEmail: userEmail, status: AccountSettingChangeEmailStatus.initial));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingChangeEmailChangedEvent(AccountSettingChangeEmailChangedEvent event, Emitter<AccountSettingChangeEmailState> emit) async {
    final email = AccountSettingChangeEmailField.dirty(event.email);
    emit(state.copyWith(email: email.isValid ? email : AccountSettingChangeEmailField.pure(event.email), status: AccountSettingChangeEmailStatus.initial, isValid: Formz.validate([email])));
  }

  FutureOr<void> _onAccountSettingChangeEmailUnfocusedEvent(AccountSettingChangeEmailUnfocusedEvent event, Emitter<AccountSettingChangeEmailState> emit) async {
    final email = AccountSettingChangeEmailField.dirty(state.email.value);
    emit(state.copyWith(email: email, status: AccountSettingChangeEmailStatus.initial, isValid: Formz.validate([email])));
  }

  FutureOr<void> _onAccountSettingChangeEmailSubmitEvent(AccountSettingChangeEmailSubmitEvent event, Emitter<AccountSettingChangeEmailState> emit) async {
    try {
      final email = AccountSettingChangeEmailField.dirty(state.email.value);
      emit(state.copyWith(email: email, status: AccountSettingChangeEmailStatus.initial, isValid: Formz.validate([email])));
      if (state.isValid && state.email.value.isNotEmpty) {
        emit(state.copyWith(status: AccountSettingChangeEmailStatus.inProgress));
        final String defaultLocale = await _authRepository.getLocale();
        AccountUpdateEmailRequestModel param = AccountUpdateEmailRequestModel(email: state.email.value, locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage);
        DioApiResponse response = await _authRepository.updateAccountEmail(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          AccountSettingUpdateEmailResponseModel data = AccountSettingUpdateEmailResponseModel.fromJson(myMap);
          emit(state.copyWith(verification: data, status: AccountSettingChangeEmailStatus.verify, locale: defaultLocale));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingChangeEmailVerificationSuccessEvent(AccountSettingChangeEmailVerificationSuccessEvent event, Emitter<AccountSettingChangeEmailState> emit) async {
    try {
      emit(state.copyWith(status: AccountSettingChangeEmailStatus.inProgress));
      AccountUpdateEmailAfterVerificationRequestModel param = AccountUpdateEmailAfterVerificationRequestModel(email: state.email.value, verificationId: state.verification.id!);
      DioApiResponse response = await _authRepository.updateAccountEmailAfterVerification(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
        if (!data.success!) {
          emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          String? refreshToken = await _authRepository.getRefreshToken();
          if (refreshToken.isNotEmpty) {
            DioApiResponse response = await _authRepository.logout(refreshToken);
            if (response.errorType == NetErrorType.none) {
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeEmailStatus.success));
            } else {
              Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: data.code!, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _authRepository.onLogoutSuccess();
            emit(state.copyWith(status: AccountSettingChangeEmailStatus.success));
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeEmailStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

