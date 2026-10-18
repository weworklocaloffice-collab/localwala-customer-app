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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:formz/formz.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/global_settings.dart';
import 'package:user/app/core/models/register_otp_verification_response_model.dart';
import 'package:user/app/core/models/request/register_firebase_request_model.dart';
import 'package:user/app/core/models/request/register_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/register_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository = AuthRepository();
  RegisterBloc()
    : super(
        RegisterState(
          verification: OtpVerificationResponseModel(sent: false, provider: '', mode: '', otpLength: 0, canResendOtp: false, target: '', method: '', id: ''),
        ),
      ) {
    on<RegisterInitialEvent>(_onRegisterInitialEvent);
    on<RegisterEmailChangedEvent>(_onRegisterEmailChangedEvent);
    on<RegisterEmailUnfocusedEvent>(_onRegisterEmailUnfocusedEvent);
    on<RegisterPasswordChangedEvent>(_onRegisterPasswordChangedEvent);
    on<RegisterPasswordUnfocusedEvent>(_onRegisterPasswordUnfocusedEvent);
    on<RegisterFirstNameChangedEvent>(_onRegisterFirstNameChangedEvent);
    on<RegisterFirstNameUnfocusedEvent>(_onRegisterFirstNameUnfocusedEvent);
    on<RegisterLastNameChangedEvent>(_onRegisterLastNameChangedEvent);
    on<RegisterLastNameUnfocusedEvent>(_onRegisterLastNameUnfocusedEvent);
    on<RegisterCountryCodeChangedEvent>(_onRegisterCountryCodeChangedEvent);
    on<RegisterCountryCodeUnfocusedEvent>(_onRegisterCountryCodeUnfocusedEvent);
    on<RegisterMobileNumberChangedEvent>(_onRegisterMobileNumberChangedEvent);
    on<RegisterMobileNumberUnfocusedEvent>(_onRegisterMobileNumberUnfocusedEvent);
    on<RegisterReferralCodeChangedEvent>(_onRegisterReferralCodeChangedEvent);
    on<RegisterFormVerificationSubmitEvent>(_onRegisterFormVerificationSubmitEvent);
    on<RegisterFormSubmitEvent>(_onRegisterFormSubmitEvent);
    on<RegisterFormFirebaseVerificationSubmitEvent>(_onRegisterFormFirebaseVerificationSubmitEvent);
  }

  FutureOr<void> _onRegisterInitialEvent(RegisterInitialEvent event, Emitter<RegisterState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "register_account"}, 'register_screen', 'register_screen');
    final bool haveReferralSystem = await _authRepository.getReferralSystemStatus();
    final bool haveVerificationOnSignUp = await _authRepository.haveVerificationOnSignUp();
    await _authRepository.getDefaultCountryCode().then((value) {
      if (value.isNotEmpty) {
        try {
          Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
          AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
          final countryCode = RegisterCountryCodeField.dirty(countryCodeData.dialCode!);
          emit(
            state.copyWith(
              countryCode: countryCode.isValid ? countryCode : RegisterCountryCodeField.pure(countryCodeData.dialCode!),
              flag: countryCodeData.flag!,
              status: RegisterStatus.loaded,
              haveReferralSystem: haveReferralSystem,
              signUpVerification: haveVerificationOnSignUp,
              isValid: Formz.validate([countryCode, state.email, state.password, state.firstName, state.lastName, state.mobileNumber]),
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

  FutureOr<void> _onRegisterEmailChangedEvent(RegisterEmailChangedEvent event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : RegisterEmailField.pure(event.email),
        status: RegisterStatus.initial,
        isValid: Formz.validate([email, state.password, state.firstName, state.lastName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onRegisterEmailUnfocusedEvent(RegisterEmailUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    emit(state.copyWith(email: email, status: RegisterStatus.initial, isValid: Formz.validate([email, state.password, state.firstName, state.lastName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onRegisterPasswordChangedEvent(RegisterPasswordChangedEvent event, Emitter<RegisterState> emit) async {
    final password = RegisterPasswordField.dirty(event.password);
    emit(
      state.copyWith(
        password: password.isValid ? password : RegisterPasswordField.pure(event.password),
        status: RegisterStatus.initial,
        isValid: Formz.validate([password, state.email, state.firstName, state.lastName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onRegisterPasswordUnfocusedEvent(RegisterPasswordUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final password = RegisterPasswordField.dirty(state.password.value);
    emit(state.copyWith(password: password, status: RegisterStatus.initial, isValid: Formz.validate([password, state.email, state.firstName, state.lastName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onRegisterFirstNameChangedEvent(RegisterFirstNameChangedEvent event, Emitter<RegisterState> emit) async {
    final firstName = RegisterFirstNameField.dirty(event.firstName);
    emit(
      state.copyWith(
        firstName: firstName.isValid ? firstName : RegisterFirstNameField.pure(event.firstName),
        status: RegisterStatus.initial,
        isValid: Formz.validate([firstName, state.email, state.password, state.lastName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onRegisterFirstNameUnfocusedEvent(RegisterFirstNameUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final firstName = RegisterFirstNameField.dirty(state.firstName.value);
    emit(state.copyWith(firstName: firstName, status: RegisterStatus.initial, isValid: Formz.validate([firstName, state.email, state.password, state.lastName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onRegisterLastNameChangedEvent(RegisterLastNameChangedEvent event, Emitter<RegisterState> emit) async {
    final lastName = RegisterLastNameField.dirty(event.lastName);
    emit(
      state.copyWith(
        lastName: lastName.isValid ? lastName : RegisterLastNameField.pure(event.lastName),
        status: RegisterStatus.initial,
        isValid: Formz.validate([lastName, state.email, state.password, state.firstName, state.countryCode, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onRegisterLastNameUnfocusedEvent(RegisterLastNameUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final lastName = RegisterLastNameField.dirty(state.lastName.value);
    emit(state.copyWith(lastName: lastName, status: RegisterStatus.initial, isValid: Formz.validate([lastName, state.email, state.password, state.firstName, state.countryCode, state.mobileNumber])));
  }

  FutureOr<void> _onRegisterCountryCodeChangedEvent(RegisterCountryCodeChangedEvent event, Emitter<RegisterState> emit) async {
    final countryCode = RegisterCountryCodeField.dirty(event.countryCode);
    emit(
      state.copyWith(
        countryCode: countryCode.isValid ? countryCode : RegisterCountryCodeField.pure(event.countryCode),
        status: RegisterStatus.initial,
        isValid: Formz.validate([countryCode, state.email, state.password, state.firstName, state.lastName, state.mobileNumber]),
      ),
    );
  }

  FutureOr<void> _onRegisterCountryCodeUnfocusedEvent(RegisterCountryCodeUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final countryCode = RegisterCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(countryCode: countryCode, status: RegisterStatus.initial, isValid: Formz.validate([countryCode, state.email, state.password, state.firstName, state.lastName, state.mobileNumber])));
  }

  FutureOr<void> _onRegisterMobileNumberChangedEvent(RegisterMobileNumberChangedEvent event, Emitter<RegisterState> emit) async {
    final mobileNumber = RegisterMobileNumberField.dirty(event.mobileNumber);
    emit(
      state.copyWith(
        mobileNumber: mobileNumber.isValid ? mobileNumber : RegisterMobileNumberField.pure(event.mobileNumber),
        status: RegisterStatus.initial,
        isValid: Formz.validate([mobileNumber, state.email, state.password, state.firstName, state.lastName, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onRegisterMobileNumberUnfocusedEvent(RegisterMobileNumberUnfocusedEvent event, Emitter<RegisterState> emit) async {
    final mobileNumber = RegisterMobileNumberField.dirty(state.mobileNumber.value);
    emit(state.copyWith(mobileNumber: mobileNumber, status: RegisterStatus.initial, isValid: Formz.validate([mobileNumber, state.email, state.password, state.firstName, state.lastName, state.countryCode])));
  }

  FutureOr<void> _onRegisterReferralCodeChangedEvent(RegisterReferralCodeChangedEvent event, Emitter<RegisterState> emit) async {
    final referralCode = event.referralCode;
    emit(state.copyWith(referralCode: referralCode, status: RegisterStatus.initial));
  }

  FutureOr<void> _onRegisterFormSubmitEvent(RegisterFormSubmitEvent event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    final password = RegisterPasswordField.dirty(state.password.value);
    final firstName = RegisterFirstNameField.dirty(state.firstName.value);
    final lastName = RegisterLastNameField.dirty(state.lastName.value);
    final countryCode = RegisterCountryCodeField.dirty(state.countryCode.value);
    final mobileNumber = RegisterMobileNumberField.dirty(state.mobileNumber.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        status: RegisterStatus.initial,
        isValid: Formz.validate([email, password, firstName, lastName, countryCode, mobileNumber]),
      ),
    );
    if (state.isValid &&
        state.email.value.isNotEmpty &&
        state.password.value.isNotEmpty &&
        state.firstName.value.isNotEmpty &&
        state.lastName.value.isNotEmpty &&
        state.countryCode.value.isNotEmpty &&
        state.mobileNumber.value.isNotEmpty) {
      emit(state.copyWith(status: RegisterStatus.inProgress));
      try {
        final String defaultLocale = await _authRepository.getLocale();
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        UserRegisterRequest registerParam = UserRegisterRequest(
          email: state.email.value,
          password: state.password.value,
          firstName: state.firstName.value,
          lastName: state.lastName.value,
          countryCode: state.countryCode.value,
          mobile: state.mobileNumber.value,
          locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
          isEmailVerified: event.isEmailVerified,
          isMobileVerified: event.isMobileVerified,
          referralCode: state.referralCode,
          userAgent: userAgent,
          verificationId: state.verification.id!.isNotEmpty ? state.verification.id! : '',
          verificationCode: event.otp.isNotEmpty ? event.otp : '',
        );
        DioApiResponse response = await _authRepository.createUserAccount(registerParam);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          if (data.referral != null && data.referral!.status! == true) {
            final String amount = GlobalSettings.globalCurrencySide == 'left' ? '${GlobalSettings.globalCurrencySymbol}${data.referral!.amount!}' : '${data.referral!.amount!}${GlobalSettings.globalCurrencySymbol}';
            String message = '';
            if (data.referral!.received! == 'both') {
              message = 'referral_both_received';
            } else if (data.referral!.received! == 'invitee') {
              message = 'referral_friend_received';
            } else if (data.referral!.received! == 'redeemer') {
              message = 'referral_you_received';
            }
            emit(state.copyWith(status: RegisterStatus.referral, referralMessage: message, referralExtraMessage: amount));
          } else {
            emit(state.copyWith(status: RegisterStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RegisterStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RegisterStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onRegisterFormVerificationSubmitEvent(RegisterFormVerificationSubmitEvent event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    final password = RegisterPasswordField.dirty(state.password.value);
    final firstName = RegisterFirstNameField.dirty(state.firstName.value);
    final lastName = RegisterLastNameField.dirty(state.lastName.value);
    final countryCode = RegisterCountryCodeField.dirty(state.countryCode.value);
    final mobileNumber = RegisterMobileNumberField.dirty(state.mobileNumber.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        status: RegisterStatus.initial,
        isValid: Formz.validate([email, password, firstName, lastName, countryCode, mobileNumber]),
      ),
    );
    if (state.isValid &&
        state.email.value.isNotEmpty &&
        state.password.value.isNotEmpty &&
        state.firstName.value.isNotEmpty &&
        state.lastName.value.isNotEmpty &&
        state.countryCode.value.isNotEmpty &&
        state.mobileNumber.value.isNotEmpty) {
      emit(state.copyWith(status: RegisterStatus.inProgress));
      try {
        final String defaultLocale = await _authRepository.getLocale();
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        UserRegisterRequest registerParam = UserRegisterRequest(
          email: state.email.value,
          password: state.password.value,
          firstName: state.firstName.value,
          lastName: state.lastName.value,
          countryCode: state.countryCode.value,
          mobile: state.mobileNumber.value,
          locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
          isEmailVerified: false,
          isMobileVerified: false,
          referralCode: state.referralCode,
          userAgent: userAgent,
          verificationId: '',
          verificationCode: '',
        );
        DioApiResponse response = await _authRepository.verifySignupAccount(registerParam);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          OtpVerificationResponseModel data = OtpVerificationResponseModel.fromJson(myMap);
          if (data.target == 'web_modal') {
            emit(state.copyWith(verification: data, status: data.method! == 'firebase' ? RegisterStatus.verifyFirebase : RegisterStatus.verifyWeb, locale: defaultLocale));
          } else {
            emit(state.copyWith(verification: data, status: RegisterStatus.verify, locale: defaultLocale));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RegisterStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RegisterStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onRegisterFormFirebaseVerificationSubmitEvent(RegisterFormFirebaseVerificationSubmitEvent event, Emitter<RegisterState> emit) async {
    final email = RegisterEmailField.dirty(state.email.value);
    final password = RegisterPasswordField.dirty(state.password.value);
    final firstName = RegisterFirstNameField.dirty(state.firstName.value);
    final lastName = RegisterLastNameField.dirty(state.lastName.value);
    final countryCode = RegisterCountryCodeField.dirty(state.countryCode.value);
    final mobileNumber = RegisterMobileNumberField.dirty(state.mobileNumber.value);
    emit(
      state.copyWith(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        status: RegisterStatus.initial,
        isValid: Formz.validate([email, password, firstName, lastName, countryCode, mobileNumber]),
      ),
    );

    if (state.isValid &&
        state.email.value.isNotEmpty &&
        state.password.value.isNotEmpty &&
        state.firstName.value.isNotEmpty &&
        state.lastName.value.isNotEmpty &&
        state.countryCode.value.isNotEmpty &&
        state.mobileNumber.value.isNotEmpty) {
      emit(state.copyWith(status: RegisterStatus.inProgress));
      try {
        final String defaultLocale = await _authRepository.getLocale();
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        UserFirebaseRegisterRequest registerParam = UserFirebaseRegisterRequest(
          email: state.email.value,
          password: state.password.value,
          firstName: state.firstName.value,
          lastName: state.lastName.value,
          countryCode: state.countryCode.value,
          mobile: state.mobileNumber.value,
          locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
          isEmailVerified: false,
          isMobileVerified: true,
          referralCode: state.referralCode,
          userAgent: userAgent,
          token: event.accessToken,
        );
        DioApiResponse response = await _authRepository.createUserFirebaseAccount(registerParam);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          if (data.referral != null && data.referral!.status! == true) {
            final String amount = GlobalSettings.globalCurrencySide == 'left' ? '${GlobalSettings.globalCurrencySymbol}${data.referral!.amount!}' : '${data.referral!.amount!}${GlobalSettings.globalCurrencySymbol}';
            String message = '';
            if (data.referral!.received! == 'both') {
              message = 'referral_both_received';
            } else if (data.referral!.received! == 'invitee') {
              message = 'referral_friend_received';
            } else if (data.referral!.received! == 'redeemer') {
              message = 'referral_you_received';
            }
            emit(state.copyWith(status: RegisterStatus.referral, referralMessage: message, referralExtraMessage: amount));
          } else {
            emit(state.copyWith(status: RegisterStatus.success));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RegisterStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RegisterStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

