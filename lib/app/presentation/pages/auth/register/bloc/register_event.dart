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

sealed class RegisterEvent {}

final class RegisterInitialEvent extends RegisterEvent {}

final class RegisterEmailChangedEvent extends RegisterEvent {
  final String email;
  RegisterEmailChangedEvent({required this.email});
}

final class RegisterEmailUnfocusedEvent extends RegisterEvent {}

final class RegisterPasswordChangedEvent extends RegisterEvent {
  final String password;
  RegisterPasswordChangedEvent({required this.password});
}

final class RegisterPasswordUnfocusedEvent extends RegisterEvent {}

final class RegisterFirstNameChangedEvent extends RegisterEvent {
  final String firstName;
  RegisterFirstNameChangedEvent({required this.firstName});
}

final class RegisterFirstNameUnfocusedEvent extends RegisterEvent {}

final class RegisterLastNameChangedEvent extends RegisterEvent {
  final String lastName;
  RegisterLastNameChangedEvent({required this.lastName});
}

final class RegisterLastNameUnfocusedEvent extends RegisterEvent {}

final class RegisterCountryCodeChangedEvent extends RegisterEvent {
  final String countryCode;
  RegisterCountryCodeChangedEvent({required this.countryCode});
}

final class RegisterCountryCodeUnfocusedEvent extends RegisterEvent {}

final class RegisterMobileNumberChangedEvent extends RegisterEvent {
  final String mobileNumber;
  RegisterMobileNumberChangedEvent({required this.mobileNumber});
}

final class RegisterMobileNumberUnfocusedEvent extends RegisterEvent {}

final class RegisterReferralCodeChangedEvent extends RegisterEvent {
  final String referralCode;
  RegisterReferralCodeChangedEvent({required this.referralCode});
}

final class RegisterFormVerificationSubmitEvent extends RegisterEvent {}

final class RegisterFormSubmitEvent extends RegisterEvent {
  final bool isEmailVerified;
  final bool isMobileVerified;
  final String otp;
  RegisterFormSubmitEvent({required this.isEmailVerified, required this.isMobileVerified, required this.otp});
}

final class RegisterFormFirebaseVerificationSubmitEvent extends RegisterEvent {
  final String accessToken;
  RegisterFormFirebaseVerificationSubmitEvent({required this.accessToken});
}

