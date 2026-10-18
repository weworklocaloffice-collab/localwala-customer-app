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

part of 'reset_with_phone_otp_bloc.dart';

enum ResetWithPhoneOtpStatus { initial, loaded, failure, success, inProgress, verify, verifyWeb, verifyFirebase }

extension ResetWithPhoneOtpStatusX on ResetWithPhoneOtpStatus {
  bool get isInitial => this == ResetWithPhoneOtpStatus.initial;
  bool get isLoaded => this == ResetWithPhoneOtpStatus.loaded;
  bool get isFailure => this == ResetWithPhoneOtpStatus.failure;
  bool get isSuccess => this == ResetWithPhoneOtpStatus.success;
  bool get isInProgress => this == ResetWithPhoneOtpStatus.inProgress;
  bool get isVerify => this == ResetWithPhoneOtpStatus.verify;
  bool get isVerifyWeb => this == ResetWithPhoneOtpStatus.verifyWeb;
  bool get isVerifyFirebase => this == ResetWithPhoneOtpStatus.verifyFirebase;
}

final class ResetWithPhoneOtpState {
  final String flag;
  final ResetWithOptionTwoCountryCodeField countryCode;
  final ResetWithOptionTwoMobileNumberField mobileNumber;
  final bool isVerified;
  final String firebaseAccessToken;
  final ResetWithOptionTwoPasswordField password;
  final ResetWithOptionTwoConfirmedPasswordField confirmedPassword;
  final ForgotPasswordResponseModel verification;
  final bool isPhoneValid;
  final bool isPasswordValid;
  final String locale;
  final ResetWithPhoneOtpStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ResetWithPhoneOtpState({
    this.flag = '',
    this.countryCode = const ResetWithOptionTwoCountryCodeField.pure(),
    this.mobileNumber = const ResetWithOptionTwoMobileNumberField.pure(),
    required this.verification,
    this.isVerified = false,
    this.firebaseAccessToken = '',
    this.password = const ResetWithOptionTwoPasswordField.pure(),
    this.confirmedPassword = const ResetWithOptionTwoConfirmedPasswordField.pure(),
    this.isPhoneValid = false,
    this.isPasswordValid = false,
    this.locale = '',
    this.status = ResetWithPhoneOtpStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ResetWithPhoneOtpState copyWith({
    String? flag,
    ResetWithOptionTwoCountryCodeField? countryCode,
    ResetWithOptionTwoMobileNumberField? mobileNumber,
    ForgotPasswordResponseModel? verification,
    bool? isVerified,
    String? firebaseAccessToken,
    ResetWithOptionTwoPasswordField? password,
    ResetWithOptionTwoConfirmedPasswordField? confirmedPassword,
    bool? isPhoneValid,
    bool? isPasswordValid,
    String? locale,
    ResetWithPhoneOtpStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ResetWithPhoneOtpState(
      flag: flag ?? this.flag,
      countryCode: countryCode ?? this.countryCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      verification: verification ?? this.verification,
      isVerified: isVerified ?? this.isVerified,
      firebaseAccessToken: firebaseAccessToken ?? this.firebaseAccessToken,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

