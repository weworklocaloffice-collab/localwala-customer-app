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

part of 'login_with_phone_password_bloc.dart';

enum LoginWithPhonePasswordStatus { initial, success, failure, inProgress, loaded, location, socialVerification }

extension LoginWithPhonePasswordStatusX on LoginWithPhonePasswordStatus {
  bool get isInitial => this == LoginWithPhonePasswordStatus.initial;
  bool get isSuccess => this == LoginWithPhonePasswordStatus.success;
  bool get isFailure => this == LoginWithPhonePasswordStatus.failure;
  bool get isInProgress => this == LoginWithPhonePasswordStatus.inProgress;
  bool get isLoaded => this == LoginWithPhonePasswordStatus.loaded;
  bool get isLocation => this == LoginWithPhonePasswordStatus.location;
  bool get isSocialVerification => this == LoginWithPhonePasswordStatus.socialVerification;
}

final class LoginWithPhonePasswordState {
  final bool appleSignInEnabled;
  final bool googleSignInEnabled;
  final bool facebookSignInEnabled;
  final LoginWithTypeTwoCountryCodeField countryCode;
  final String flag;
  final LoginWithTypeTwoMobileNumberField mobileNumber;
  final LoginWithTypeTwoPasswordField password;
  final LoginWithTypeTwoRememberMeField remember;
  final bool isValid;
  final bool googleSocialLoginClicked;
  final String googleIdToken;
  final SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel;
  final bool facebookSocialLoginClicked;
  final String facebookAccessToken;
  final LoginWithPhonePasswordStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoginWithPhonePasswordState({
    this.appleSignInEnabled = false,
    this.googleSignInEnabled = false,
    this.facebookSignInEnabled = false,
    this.countryCode = const LoginWithTypeTwoCountryCodeField.pure(),
    this.flag = '',
    this.mobileNumber = const LoginWithTypeTwoMobileNumberField.pure(),
    this.password = const LoginWithTypeTwoPasswordField.pure(),
    this.remember = const LoginWithTypeTwoRememberMeField.pure(false),
    this.isValid = false,
    this.googleSocialLoginClicked = false,
    this.googleIdToken = '',
    required this.unVerifiedAccountResponseModel,
    this.facebookSocialLoginClicked = false,
    this.facebookAccessToken = '',
    this.status = LoginWithPhonePasswordStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  LoginWithPhonePasswordState copyWith({
    bool? appleSignInEnabled,
    bool? googleSignInEnabled,
    bool? facebookSignInEnabled,
    LoginWithTypeTwoCountryCodeField? countryCode,
    String? flag,
    LoginWithTypeTwoMobileNumberField? mobileNumber,
    LoginWithTypeTwoPasswordField? password,
    LoginWithTypeTwoRememberMeField? remember,
    bool? isValid,
    bool? googleSocialLoginClicked,
    String? googleIdToken,
    SocialUnVerifiedAccountResponseModel? unVerifiedAccountResponseModel,
    bool? facebookSocialLoginClicked,
    String? facebookAccessToken,
    LoginWithPhonePasswordStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return LoginWithPhonePasswordState(
      appleSignInEnabled: appleSignInEnabled ?? this.appleSignInEnabled,
      googleSignInEnabled: googleSignInEnabled ?? this.googleSignInEnabled,
      facebookSignInEnabled: facebookSignInEnabled ?? this.facebookSignInEnabled,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      mobileNumber: mobileNumber ?? this.mobileNumber,
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

