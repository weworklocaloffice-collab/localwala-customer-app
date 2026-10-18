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

sealed class LoginWithPhoneOtpEvent {}

final class LoginWithPhoneOtpInitialEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithTypeFourCountryCodeChangedEvent extends LoginWithPhoneOtpEvent {
  final String countryCode;
  LoginWithTypeFourCountryCodeChangedEvent({required this.countryCode});
}

final class LoginWithTypeFourCountryCodeUnfocusedEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithTypeFourMobileNumberChangedEvent extends LoginWithPhoneOtpEvent {
  final String mobileNumber;
  LoginWithTypeFourMobileNumberChangedEvent({required this.mobileNumber});
}

final class LoginWithTypeFourMobileNumberUnfocusedEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithTypeFourRememberChangedEvent extends LoginWithPhoneOtpEvent {
  final bool checked;
  LoginWithTypeFourRememberChangedEvent({required this.checked});
}

final class LoginWithTypeFourFormSubmitEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithPhoneOtpLoginNowEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithPhoneOtpFirebaseVerificationEvent extends LoginWithPhoneOtpEvent {
  final String accessToken;
  LoginWithPhoneOtpFirebaseVerificationEvent({required this.accessToken});
}

final class LoginWithPhoneOtpGoogleAccountEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithPhoneOtpRegisterGoogleAccountEvent extends LoginWithPhoneOtpEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithPhoneOtpRegisterGoogleAccountEvent({required this.model});
}

final class LoginWithPhoneOtpFacebookAccountEvent extends LoginWithPhoneOtpEvent {}

final class LoginWithPhoneOtpRegisterFacebookAccountEvent extends LoginWithPhoneOtpEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithPhoneOtpRegisterFacebookAccountEvent({required this.model});
}

final class LoginWithGoogleLoginFailedEvent extends LoginWithPhoneOtpEvent {
  final String error;
  LoginWithGoogleLoginFailedEvent({required this.error});
}

final class LoginWithGoogleLoginAfterSuccessEvent extends LoginWithPhoneOtpEvent {
  final String token;
  LoginWithGoogleLoginAfterSuccessEvent({required this.token});
}

