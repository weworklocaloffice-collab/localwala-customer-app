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

part of 'login_with_phone_otp_bloc.dart';

enum LoginWithPhoneOtpStatus { initial, success, failure, inProgress, loaded, verify, verifyWeb, verifyFirebase, location, socialVerification }

extension LoginWithPhoneOtpStatusX on LoginWithPhoneOtpStatus {
  bool get isInitial => this == LoginWithPhoneOtpStatus.initial;
  bool get isSuccess => this == LoginWithPhoneOtpStatus.success;
  bool get isFailure => this == LoginWithPhoneOtpStatus.failure;
  bool get isInProgress => this == LoginWithPhoneOtpStatus.inProgress;
  bool get isLoaded => this == LoginWithPhoneOtpStatus.loaded;
  bool get isVerify => this == LoginWithPhoneOtpStatus.verify;
  bool get isVerifyWeb => this == LoginWithPhoneOtpStatus.verifyWeb;
  bool get isVerifyFirebase => this == LoginWithPhoneOtpStatus.verifyFirebase;
  bool get isLocation => this == LoginWithPhoneOtpStatus.location;
  bool get isSocialVerification => this == LoginWithPhoneOtpStatus.socialVerification;
}

final class LoginWithPhoneOtpState {
  final bool appleSignInEnabled;
  final bool googleSignInEnabled;
  final bool facebookSignInEnabled;
  final LoginWithTypeFourCountryCodeField countryCode;
  final String flag;
  final LoginWithTypeFourMobileNumberField mobileNumber;
  final LoginWithTypeFourRememberMeField remember;
  final LoginWithPhoneOtpVerificationResponseModel verification;
  final String otpVerification;
  final bool isValid;
  final bool googleSocialLoginClicked;
  final String googleIdToken;
  final SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel;
  final bool facebookSocialLoginClicked;
  final String facebookAccessToken;
  final String locale;
  final LoginWithPhoneOtpStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoginWithPhoneOtpState({
    this.appleSignInEnabled = false,
    this.googleSignInEnabled = false,
    this.facebookSignInEnabled = false,
    this.countryCode = const LoginWithTypeFourCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumber = const LoginWithTypeFourMobileNumberField.pure(),
    this.remember = const LoginWithTypeFourRememberMeField.pure(false),
    required this.verification,
    this.otpVerification = '',
    this.isValid = false,
    this.googleSocialLoginClicked = false,
    this.googleIdToken = '',
    required this.unVerifiedAccountResponseModel,
    this.facebookSocialLoginClicked = false,
    this.facebookAccessToken = '',
    this.locale = 'en',
    this.status = LoginWithPhoneOtpStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  LoginWithPhoneOtpState copyWith({
    bool? appleSignInEnabled,
    bool? googleSignInEnabled,
    bool? facebookSignInEnabled,
    LoginWithTypeFourCountryCodeField? countryCode,
    String? flag,
    LoginWithTypeFourMobileNumberField? mobileNumber,
    LoginWithTypeFourRememberMeField? remember,
    LoginWithPhoneOtpVerificationResponseModel? verification,
    String? otpVerification,
    bool? isValid,
    bool? googleSocialLoginClicked,
    String? googleIdToken,
    SocialUnVerifiedAccountResponseModel? unVerifiedAccountResponseModel,
    bool? facebookSocialLoginClicked,
    String? facebookAccessToken,
    String? locale,
    LoginWithPhoneOtpStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return LoginWithPhoneOtpState(
      appleSignInEnabled: appleSignInEnabled ?? this.appleSignInEnabled,
      googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
      facebookSignInEnabled: facebookSignInEnabled ?? this.facebookSignInEnabled,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      verification: verification ?? this.verification,
      otpVerification: otpVerification ?? this.otpVerification,
      remember: remember ?? this.remember,
      isValid: isValid ?? this.isValid,
      googleSocialLoginClicked: googleSocialLoginClicked ?? this.googleSocialLoginClicked,
      googleIdToken: googleIdToken ?? this.googleIdToken,
      unVerifiedAccountResponseModel: unVerifiedAccountResponseModel ?? this.unVerifiedAccountResponseModel,
      facebookSocialLoginClicked: facebookSocialLoginClicked ?? this.facebookSocialLoginClicked,
      facebookAccessToken: facebookAccessToken ?? this.facebookAccessToken,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

