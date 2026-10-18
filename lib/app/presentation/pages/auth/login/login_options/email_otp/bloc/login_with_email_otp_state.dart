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

part of 'login_with_email_otp_bloc.dart';

enum LoginWithEmailOtpStatus { initial, success, failure, inProgress, loaded, verify, location, socialVerification }

extension LoginWithEmailOtpStatusX on LoginWithEmailOtpStatus {
  bool get isInitial => this == LoginWithEmailOtpStatus.initial;
  bool get isSuccess => this == LoginWithEmailOtpStatus.success;
  bool get isFailure => this == LoginWithEmailOtpStatus.failure;
  bool get isInProgress => this == LoginWithEmailOtpStatus.inProgress;
  bool get isLoaded => this == LoginWithEmailOtpStatus.loaded;
  bool get isVerify => this == LoginWithEmailOtpStatus.verify;
  bool get isLocation => this == LoginWithEmailOtpStatus.location;
  bool get isSocialVerification => this == LoginWithEmailOtpStatus.socialVerification;
}

final class LoginWithEmailOtpState {
  final bool appleSignInEnabled;
  final bool googleSignInEnabled;
  final bool facebookSignInEnabled;
  final LoginWithTypeThreeEmailField email;
  final LoginWithTypeThreeRememberMeField remember;
  final OtpVerificationResponseModel verification;
  final String otpVerification;
  final bool isValid;
  final bool googleSocialLoginClicked;
  final String googleIdToken;
  final SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel;
  final bool facebookSocialLoginClicked;
  final String facebookAccessToken;
  final LoginWithEmailOtpStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoginWithEmailOtpState({
    this.appleSignInEnabled = false,
    this.googleSignInEnabled = false,
    this.facebookSignInEnabled = false,
    this.email = const LoginWithTypeThreeEmailField.pure(),
    this.remember = const LoginWithTypeThreeRememberMeField.pure(false),
    required this.verification,
    this.otpVerification = '',
    this.isValid = false,
    this.googleSocialLoginClicked = false,
    this.googleIdToken = '',
    required this.unVerifiedAccountResponseModel,
    this.facebookSocialLoginClicked = false,
    this.facebookAccessToken = '',
    this.status = LoginWithEmailOtpStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  LoginWithEmailOtpState copyWith({
    bool? appleSignInEnabled,
    bool? googleSignInEnabled,
    bool? facebookSignInEnabled,
    LoginWithTypeThreeEmailField? email,
    LoginWithTypeThreeRememberMeField? remember,
    OtpVerificationResponseModel? verification,
    String? otpVerification,
    bool? isValid,
    bool? googleSocialLoginClicked,
    String? googleIdToken,
    SocialUnVerifiedAccountResponseModel? unVerifiedAccountResponseModel,
    bool? facebookSocialLoginClicked,
    String? facebookAccessToken,
    LoginWithEmailOtpStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return LoginWithEmailOtpState(
      appleSignInEnabled: appleSignInEnabled ?? this.appleSignInEnabled,
      googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
      facebookSignInEnabled: facebookSignInEnabled ?? this.facebookSignInEnabled,
      email: email ?? this.email,
      remember: remember ?? this.remember,
      verification: verification ?? this.verification,
      otpVerification: otpVerification ?? this.otpVerification,
      isValid: isValid ?? this.isValid,
      googleSocialLoginClicked: googleSocialLoginClicked ?? this.googleSocialLoginClicked,
      googleIdToken: googleIdToken ?? this.googleIdToken,
      unVerifiedAccountResponseModel: unVerifiedAccountResponseModel ?? this.unVerifiedAccountResponseModel,
      facebookSocialLoginClicked: facebookSocialLoginClicked ?? this.facebookSocialLoginClicked,
      facebookAccessToken: facebookAccessToken ?? this.facebookAccessToken,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

