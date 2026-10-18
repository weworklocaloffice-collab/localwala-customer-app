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

part of 'login_with_email_password_bloc.dart';

enum LoginWithEmailPasswordStatus { initial, success, failure, inProgress, location, socialVerification }

extension LoginWithEmailPasswordStatusX on LoginWithEmailPasswordStatus {
  bool get isInitial => this == LoginWithEmailPasswordStatus.initial;
  bool get isSuccess => this == LoginWithEmailPasswordStatus.success;
  bool get isFailure => this == LoginWithEmailPasswordStatus.failure;
  bool get isInProgress => this == LoginWithEmailPasswordStatus.inProgress;
  bool get isLocation => this == LoginWithEmailPasswordStatus.location;
  bool get isSocialVerification => this == LoginWithEmailPasswordStatus.socialVerification;
}

final class LoginWithEmailPasswordState {
  final bool appleSignInEnabled;
  final bool googleSignInEnabled;
  final bool facebookSignInEnabled;
  final LoginWithTypeOneEmailField email;
  final LoginWithTypeOnePasswordField password;
  final LoginWithTypeOneRememberMeField remember;
  final bool isValid;
  final bool googleSocialLoginClicked;
  final String googleIdToken;
  final SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel;
  final bool facebookSocialLoginClicked;
  final String facebookAccessToken;
  final LoginWithEmailPasswordStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoginWithEmailPasswordState({
    this.appleSignInEnabled = false,
    this.googleSignInEnabled = false,
    this.facebookSignInEnabled = false,
    this.email = const LoginWithTypeOneEmailField.pure(),
    this.password = const LoginWithTypeOnePasswordField.pure(),
    this.remember = const LoginWithTypeOneRememberMeField.pure(false),
    this.isValid = false,
    this.googleSocialLoginClicked = false,
    this.googleIdToken = '',
    required this.unVerifiedAccountResponseModel,
    this.facebookSocialLoginClicked = false,
    this.facebookAccessToken = '',
    this.status = LoginWithEmailPasswordStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  LoginWithEmailPasswordState copyWith({
    bool? appleSignInEnabled,
    bool? googleSignInEnabled,
    bool? facebookSignInEnabled,
    LoginWithTypeOneEmailField? email,
    LoginWithTypeOnePasswordField? password,
    LoginWithTypeOneRememberMeField? remember,
    bool? isValid,
    bool? googleSocialLoginClicked,
    String? googleIdToken,
    SocialUnVerifiedAccountResponseModel? unVerifiedAccountResponseModel,
    bool? facebookSocialLoginClicked,
    String? facebookAccessToken,
    LoginWithEmailPasswordStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return LoginWithEmailPasswordState(
      appleSignInEnabled: appleSignInEnabled ?? this.appleSignInEnabled,
      googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
      facebookSignInEnabled: facebookSignInEnabled ?? this.facebookSignInEnabled,
      email: email ?? this.email,
      password: password ?? this.password,
      remember: remember ?? this.remember,
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

