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
import 'package:user/app/core/models/request/account_update_password_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/account_setting_update_password_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'account_setting_update_password_event.dart';
part 'account_setting_update_password_state.dart';

class AccountSettingUpdatePasswordBloc extends Bloc<AccountSettingUpdatePasswordEvent, AccountSettingUpdatePasswordState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingUpdatePasswordBloc() : super(const AccountSettingUpdatePasswordState()) {
    on<AccountSettingUpdatePasswordInitialEvent>(_onAccountSettingUpdatePasswordInitialEvent);
    on<AccountSettingUpdatePasswordPasswordChangedEvent>(_onAccountSettingUpdatePasswordPasswordChangedEvent);
    on<AccountSettingUpdatePasswordPasswordUnfocusedEvent>(_onAccountSettingUpdatePasswordPasswordUnfocusedEvent);
    on<AccountSettingUpdatePasswordConfirmPasswordChangedEvent>(_onAccountSettingUpdatePasswordConfirmPasswordChangedEvent);
    on<AccountSettingUpdatePasswordConfirmPasswordUnfocusedEvent>(_onAccountSettingUpdatePasswordConfirmPasswordUnfocusedEvent);
    on<AccountSettingUpdatePasswordSubmitEvent>(_onAccountSettingUpdatePasswordSubmitEvent);
  }

  FutureOr<void> _onAccountSettingUpdatePasswordInitialEvent(AccountSettingUpdatePasswordInitialEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "update_account_password"}, 'update_password_screen', 'update_password_screen');
  }

  FutureOr<void> _onAccountSettingUpdatePasswordPasswordChangedEvent(AccountSettingUpdatePasswordPasswordChangedEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    final password = AccountSettingChangePasswordPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        password: password.isValid ? password : AccountSettingChangePasswordPasswordField.pure(event.password),
        status: AccountSettingUpdatePasswordStatus.initial,
        isPasswordValid: Formz.validate([password, state.confirmedPassword]),
      ),
    );
  }

  FutureOr<void> _onAccountSettingUpdatePasswordPasswordUnfocusedEvent(AccountSettingUpdatePasswordPasswordUnfocusedEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    final password = AccountSettingChangePasswordPasswordField.dirty(state.password.value);
    emit(state.copyWith(password: password, status: AccountSettingUpdatePasswordStatus.initial, isPasswordValid: Formz.validate([password, state.confirmedPassword])));
  }

  FutureOr<void> _onAccountSettingUpdatePasswordConfirmPasswordChangedEvent(AccountSettingUpdatePasswordConfirmPasswordChangedEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    final confirmedPassword = AccountSettingChangePasswordConfirmedPasswordField.dirty(password: state.password.value, value: event.password);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: AccountSettingUpdatePasswordStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onAccountSettingUpdatePasswordConfirmPasswordUnfocusedEvent(AccountSettingUpdatePasswordConfirmPasswordUnfocusedEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    final confirmedPassword = AccountSettingChangePasswordConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
    emit(state.copyWith(confirmedPassword: confirmedPassword, status: AccountSettingUpdatePasswordStatus.initial, isPasswordValid: Formz.validate([confirmedPassword, state.password])));
  }

  FutureOr<void> _onAccountSettingUpdatePasswordSubmitEvent(AccountSettingUpdatePasswordSubmitEvent event, Emitter<AccountSettingUpdatePasswordState> emit) async {
    try {
      final password = AccountSettingChangePasswordPasswordField.dirty(state.password.value);
      final confirmPassword = AccountSettingChangePasswordConfirmedPasswordField.dirty(password: state.password.value, value: state.confirmedPassword.value);
      emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.initial, isPasswordValid: Formz.validate([password, confirmPassword])));
      if (state.isPasswordValid) {
        emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.inProgress));
        AccountUpdatePasswordRequestModel param = AccountUpdatePasswordRequestModel(password: state.password.value.toString());
        DioApiResponse response = await _authRepository.updateAccountPassword(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
          if (!data.success!) {
            emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            String? refreshToken = await _authRepository.getRefreshToken();
            if (refreshToken.isNotEmpty) {
              DioApiResponse response = await _authRepository.logout(refreshToken);
              if (response.errorType == NetErrorType.none) {
                await _authRepository.onLogoutSuccess();
                emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.success));
              } else {
                Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                await _authRepository.onLogoutSuccess();
                emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.failure, statusCode: data.code!, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.success));
            }
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingUpdatePasswordStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

