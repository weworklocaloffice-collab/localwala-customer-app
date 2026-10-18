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

sealed class LoginWithPhonePasswordEvent {}

final class LoginWithPhonePasswordInitialEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoCountryCodeChangedEvent extends LoginWithPhonePasswordEvent {
  final String countryCode;
  LoginWithTypeTwoCountryCodeChangedEvent({required this.countryCode});
}

final class LoginWithTypeTwoCountryCodeUnfocusedEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoMobileNumberChangedEvent extends LoginWithPhonePasswordEvent {
  final String mobileNumber;
  LoginWithTypeTwoMobileNumberChangedEvent({required this.mobileNumber});
}

final class LoginWithTypeTwoMobileNumberUnfocusedEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoPasswordChangedEvent extends LoginWithPhonePasswordEvent {
  final String password;
  LoginWithTypeTwoPasswordChangedEvent({required this.password});
}

final class LoginWithTypeTwoPasswordUnfocusedEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoRememberChangedEvent extends LoginWithPhonePasswordEvent {
  final bool checked;
  LoginWithTypeTwoRememberChangedEvent({required this.checked});
}

final class LoginWithTypeTwoFormSubmitEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoGoogleAccountEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoRegisterGoogleAccountEvent extends LoginWithPhonePasswordEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithTypeTwoRegisterGoogleAccountEvent({required this.model});
}

final class LoginWithTypeTwoFacebookAccountEvent extends LoginWithPhonePasswordEvent {}

final class LoginWithTypeTwoRegisterFacebookAccountEvent extends LoginWithPhonePasswordEvent {
  final SocialAccountVerificationModalResponseModel model;
  LoginWithTypeTwoRegisterFacebookAccountEvent({required this.model});
}

final class LoginWithGoogleLoginFailedEvent extends LoginWithPhonePasswordEvent {
  final String error;
  LoginWithGoogleLoginFailedEvent({required this.error});
}

final class LoginWithGoogleLoginAfterSuccessEvent extends LoginWithPhonePasswordEvent {
  final String token;
  LoginWithGoogleLoginAfterSuccessEvent({required this.token});
}

