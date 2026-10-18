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
import 'package:user/app/core/models/account_setting_update_mobile_number_response_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_after_firebase_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_after_verification_request_model.dart';
import 'package:user/app/core/models/request/account_update_mobile_number_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/account_setting_update_mobile_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'account_setting_change_mobile_event.dart';
part 'account_setting_change_mobile_state.dart';

class AccountSettingChangeMobileBloc extends Bloc<AccountSettingChangeMobileEvent, AccountSettingChangeMobileState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingChangeMobileBloc()
    : super(
        AccountSettingChangeMobileState(
          verification: AccountSettingUpdateMobileResponseModel(sent: true, target: '', method: '', otpLength: 0, canResendOtp: false, id: '', provider: ''),
        ),
      ) {
    on<AccountSettingChangeMobileInitialEvent>(_onAccountSettingChangeMobileInitialEvent);
    on<AccountSettingChangeMobileCountryCodeChangedEvent>(_onAccountSettingChangeMobileCountryCodeChangedEvent);
    on<AccountSettingChangeMobileCountryCodeUnfocusedEvent>(_onAccountSettingChangeMobileCountryCodeUnfocusedEvent);
    on<AccountSettingChangeMobileNumberChangedEvent>(_onAccountSettingChangeMobileNumberChangedEvent);
    on<AccountSettingChangeMobileNumberUnfocusedEvent>(_onAccountSettingChangeMobileNumberUnfocusedEvent);
    on<AccountSettingChangeMobileSubmitEvent>(_onAccountSettingChangeMobileSubmitEvent);
    on<AccountSettingChangeMobileVerificationSuccessEvent>(_onAccountSettingChangeMobileVerificationSuccessEvent);
    on<AccountSettingChangeMobileFirebaseVerificationEvent>(_onAccountSettingChangeMobileFirebaseVerificationEvent);
  }

  FutureOr<void> _onAccountSettingChangeMobileInitialEvent(AccountSettingChangeMobileInitialEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "change_mobile_number"}, 'change_mobile_number_screen', 'change_mobile_number_screen');
      await _authRepository.getDefaultCountryCode().then((value) async {
        if (value.isNotEmpty) {
          final String countryCode = await _authRepository.userCountryCode();
          final String mobileNumber = await _authRepository.userMobile();
          final String compileCountryCode = countryCode.toString().replaceAll('+', '');
          final String userMobileNumber = '+$compileCountryCode $mobileNumber';
          Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
          AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
          final defaultCountryCode = AccountSettingUpdateMobileCountryCodeField.dirty(countryCodeData.dialCode!);
          emit(
            state.copyWith(
              userMobileNumber: userMobileNumber,
              flag: countryCodeData.flag!,
              isPhoneValid: Formz.validate([defaultCountryCode, state.mobileNumber]),
              countryCode: defaultCountryCode.isValid ? defaultCountryCode : AccountSettingUpdateMobileCountryCodeField.pure(countryCodeData.dialCode!),
              status: AccountSettingChangeMobileStatus.loaded,
            ),
          );
        }
      });
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingChangeMobileCountryCodeChangedEvent(AccountSettingChangeMobileCountryCodeChangedEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    final countryCode = AccountSettingUpdateMobileCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCode: countryCode.isValid ? countryCode : AccountSettingUpdateMobileCountryCodeField.pure(event.countryCode),
        status: AccountSettingChangeMobileStatus.initial,
        isPhoneValid: Formz.validate([countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onAccountSettingChangeMobileCountryCodeUnfocusedEvent(AccountSettingChangeMobileCountryCodeUnfocusedEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    final countryCode = AccountSettingUpdateMobileCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(countryCode: countryCode, status: AccountSettingChangeMobileStatus.initial, isPhoneValid: Formz.validate([countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onAccountSettingChangeMobileNumberChangedEvent(AccountSettingChangeMobileNumberChangedEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    final mobileNumber = AccountSettingUpdateMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumber: mobileNumber.isValid ? mobileNumber : AccountSettingUpdateMobileNumberField.pure(event.mobileNumber),
        status: AccountSettingChangeMobileStatus.initial,
        isPhoneValid: Formz.validate([mobileNumber, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onAccountSettingChangeMobileNumberUnfocusedEvent(AccountSettingChangeMobileNumberUnfocusedEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    final mobileNumber = AccountSettingUpdateMobileNumberField.dirty(state.mobileNumber.value);
    emit(state.copyWith(mobileNumber: mobileNumber, status: AccountSettingChangeMobileStatus.initial, isPhoneValid: Formz.validate([mobileNumber, state.countryCode])));
  }

  FutureOr<void> _onAccountSettingChangeMobileSubmitEvent(AccountSettingChangeMobileSubmitEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    try {
      final countryCode = AccountSettingUpdateMobileCountryCodeField.dirty(state.countryCode.value);
      final mobileNumber = AccountSettingUpdateMobileNumberField.dirty(state.mobileNumber.value);
      emit(state.copyWith(countryCode: countryCode, mobileNumber: mobileNumber, status: AccountSettingChangeMobileStatus.initial, isPhoneValid: Formz.validate([countryCode, mobileNumber])));
      if (state.isPhoneValid && state.countryCode.value.isNotEmpty && state.mobileNumber.value.isNotEmpty) {
        emit(state.copyWith(status: AccountSettingChangeMobileStatus.inProgress));
        final String defaultLocale = await _authRepository.getLocale();
        AccountUpdateMobileNumberRequestModel param = AccountUpdateMobileNumberRequestModel(
          countryCode: state.countryCode.value,
          mobileNumber: int.parse(state.mobileNumber.value.toString()),
          locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
        );
        DioApiResponse response = await _authRepository.updateAccountMobileNumber(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          AccountSettingUpdateMobileResponseModel data = AccountSettingUpdateMobileResponseModel.fromJson(myMap);
          if (data.sent == false && data.target == 'web_modal') {
            emit(state.copyWith(verification: data, status: data.method! == 'firebase' ? AccountSettingChangeMobileStatus.verifyFirebase : AccountSettingChangeMobileStatus.verifyWeb, locale: defaultLocale));
          } else {
            emit(state.copyWith(verification: data, status: AccountSettingChangeMobileStatus.verify, locale: defaultLocale));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingChangeMobileVerificationSuccessEvent(AccountSettingChangeMobileVerificationSuccessEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    try {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.inProgress));
      AccountUpdateMobileNumberAfterVerificationRequestModel param = AccountUpdateMobileNumberAfterVerificationRequestModel(
        countryCode: state.countryCode.value,
        mobileNumber: int.parse(state.mobileNumber.value.toString()),
        verificationId: state.verification.id!,
      );
      DioApiResponse response = await _authRepository.updateAccountMobileNumberAfterVerification(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
        if (!data.success!) {
          emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          String? refreshToken = await _authRepository.getRefreshToken();
          if (refreshToken.isNotEmpty) {
            DioApiResponse response = await _authRepository.logout(refreshToken);
            if (response.errorType == NetErrorType.none) {
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeMobileStatus.success));
            } else {
              Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: data.code!, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _authRepository.onLogoutSuccess();
            emit(state.copyWith(status: AccountSettingChangeMobileStatus.success));
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingChangeMobileFirebaseVerificationEvent(AccountSettingChangeMobileFirebaseVerificationEvent event, Emitter<AccountSettingChangeMobileState> emit) async {
    try {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.inProgress));
      AccountUpdateMobileNumberAfterFirebaseVerificationRequestModel param = AccountUpdateMobileNumberAfterFirebaseVerificationRequestModel(
        countryCode: state.countryCode.value,
        mobileNumber: int.parse(state.mobileNumber.value.toString()),
        token: event.accessToken,
      );
      DioApiResponse response = await _authRepository.updateAccountMobileNumberAfterFirebaseVerification(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
        if (!data.success!) {
          emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          String? refreshToken = await _authRepository.getRefreshToken();
          if (refreshToken.isNotEmpty) {
            DioApiResponse response = await _authRepository.logout(refreshToken);
            if (response.errorType == NetErrorType.none) {
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeMobileStatus.success));
            } else {
              Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _authRepository.onLogoutSuccess();
              emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: data.code!, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _authRepository.onLogoutSuccess();
            emit(state.copyWith(status: AccountSettingChangeMobileStatus.success));
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingChangeMobileStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

