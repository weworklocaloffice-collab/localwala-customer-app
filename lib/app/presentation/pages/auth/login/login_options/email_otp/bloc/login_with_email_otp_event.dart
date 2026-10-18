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

sealed class LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpInitialEvent extends LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpChangedEvent extends LoginWithEmailOtpEvent {
  final String email;
  LoginWithEmailOtpChangedEvent({required this.email});
}

final class LoginWithEmailOtpUnfocusedEvent extends LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpRememberChangedEvent extends LoginWithEmailOtpEvent {
  final bool checked;
  LoginWithEmailOtpRememberChangedEvent({required this.checked});
}

final class LoginWithEmailOtpFormSubmitEvent extends LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpLoginNowEvent extends LoginWithEmailOtpEvent {
  final String otp;
  LoginWithEmailOtpLoginNowEvent({required this.otp});
}

final class LoginWithEmailOtpGoogleAccountEvent extends LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpRegisterGoogleAccountEvent extends LoginWithEmailOtpEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithEmailOtpRegisterGoogleAccountEvent({required this.model});
}

final class LoginWithEmailOtpFacebookAccountEvent extends LoginWithEmailOtpEvent {}

final class LoginWithEmailOtpRegisterFacebookAccountEvent extends LoginWithEmailOtpEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithEmailOtpRegisterFacebookAccountEvent({required this.model});
}

final class LoginWithGoogleLoginFailedEvent extends LoginWithEmailOtpEvent {
  final String error;
  LoginWithGoogleLoginFailedEvent({required this.error});
}

final class LoginWithGoogleLoginAfterSuccessEvent extends LoginWithEmailOtpEvent {
  final String token;
  LoginWithGoogleLoginAfterSuccessEvent({required this.token});
}

