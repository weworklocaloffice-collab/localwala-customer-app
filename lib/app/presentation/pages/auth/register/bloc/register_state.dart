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

part of 'register_bloc.dart';

enum RegisterStatus { initial, success, failure, inProgress, loaded, verify, verifyWeb, verifyFirebase, referral }

extension RegisterStatusX on RegisterStatus {
  bool get isInitial => this == RegisterStatus.initial;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
  bool get isInProgress => this == RegisterStatus.inProgress;
  bool get isLoaded => this == RegisterStatus.loaded;
  bool get isVerify => this == RegisterStatus.verify;
  bool get isVerifyWeb => this == RegisterStatus.verifyWeb;
  bool get isVerifyFirebase => this == RegisterStatus.verifyFirebase;
  bool get isReferral => this == RegisterStatus.referral;
}

final class RegisterState {
  final RegisterEmailField email;
  final RegisterPasswordField password;
  final RegisterFirstNameField firstName;
  final RegisterLastNameField lastName;
  final RegisterCountryCodeField countryCode;
  final String flag;
  final RegisterMobileNumberField mobileNumber;
  final bool haveReferralSystem;
  final bool signUpVerification;
  final String referralCode;
  final OtpVerificationResponseModel verification;
  final String otpVerification;
  final bool isValid;
  final String referralMessage;
  final String referralExtraMessage;
  final String locale;
  final RegisterStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RegisterState({
    this.email = const RegisterEmailField.pure(),
    this.password = const RegisterPasswordField.pure(),
    this.firstName = const RegisterFirstNameField.pure(),
    this.lastName = const RegisterLastNameField.pure(),
    this.countryCode = const RegisterCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumber = const RegisterMobileNumberField.pure(),
    this.haveReferralSystem = false,
    this.signUpVerification = false,
    this.referralCode = '',
    required this.verification,
    this.otpVerification = '',
    this.isValid = false,
    this.referralMessage = '',
    this.referralExtraMessage = '',
    this.locale = '',
    this.status = RegisterStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RegisterState copyWith({
    RegisterEmailField? email,
    RegisterPasswordField? password,
    RegisterFirstNameField? firstName,
    RegisterLastNameField? lastName,
    RegisterCountryCodeField? countryCode,
    String? flag,
    RegisterMobileNumberField? mobileNumber,
    bool? haveReferralSystem,
    String? referralCode,
    bool? signUpVerification,
    OtpVerificationResponseModel? verification,
    String? otpVerification,
    bool? isValid,
    String? referralMessage,
    String? referralExtraMessage,
    String? locale,
    RegisterStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      haveReferralSystem: haveReferralSystem ?? this.haveReferralSystem,
      signUpVerification: signUpVerification ?? this.signUpVerification,
      referralCode: referralCode ?? this.referralCode,
      verification: verification ?? this.verification,
      otpVerification: otpVerification ?? this.otpVerification,
      isValid: isValid ?? this.isValid,
      locale: locale ?? this.locale,
      referralMessage: referralMessage ?? this.referralMessage,
      referralExtraMessage: referralExtraMessage ?? this.referralExtraMessage,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

