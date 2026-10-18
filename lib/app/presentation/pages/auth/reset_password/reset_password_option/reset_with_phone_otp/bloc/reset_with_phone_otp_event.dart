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

sealed class ResetWithPhoneOtpEvent {}

final class ResetWithPhoneInitialEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithPhoneTypeTwoCountryCodeChangedEvent extends ResetWithPhoneOtpEvent {
  final String countryCode;
  ResetWithPhoneTypeTwoCountryCodeChangedEvent({required this.countryCode});
}

final class ResetWithPhoneTypeTwoCountryCodeUnfocusedEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithPhoneTypeTwoMobileNumberChangedEvent extends ResetWithPhoneOtpEvent {
  final String mobileNumber;
  ResetWithPhoneTypeTwoMobileNumberChangedEvent({required this.mobileNumber});
}

final class ResetWithPhoneTypeTwoMobileNumberUnfocusedEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithPhoneTypeTwoSendVerificationSMSEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithOptionTwoFirebaseVerificationEvent extends ResetWithPhoneOtpEvent {
  final String accessToken;
  ResetWithOptionTwoFirebaseVerificationEvent({required this.accessToken});
}

final class ResetWithOptionTwoVerificationSuccessEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithOptionTwoPasswordChangedEvent extends ResetWithPhoneOtpEvent {
  final String password;

  ResetWithOptionTwoPasswordChangedEvent({required this.password});
}

final class ResetWithOptionTwoPasswordUnfocusedEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithOptionTwoConfirmPasswordChangedEvent extends ResetWithPhoneOtpEvent {
  final String password;

  ResetWithOptionTwoConfirmPasswordChangedEvent({required this.password});
}

final class ResetWithOptionTwoConfirmPasswordUnfocusedEvent extends ResetWithPhoneOtpEvent {}

final class ResetWithOptionTwoUpdatePasswordEvent extends ResetWithPhoneOtpEvent {}

