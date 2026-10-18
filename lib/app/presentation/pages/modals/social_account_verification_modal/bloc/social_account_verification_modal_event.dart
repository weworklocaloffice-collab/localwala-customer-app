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

part of 'social_account_verification_modal_bloc.dart';

sealed class SocialAccountVerificationModalEvent {}

final class SocialAccountVerificationModalInitialEvent extends SocialAccountVerificationModalEvent {
  final String firstName;
  final String lastName;
  SocialAccountVerificationModalInitialEvent({required this.firstName, required this.lastName});
}

final class SocialAccountVerificationModalFirstNameChangedEvent extends SocialAccountVerificationModalEvent {
  final String firstName;
  SocialAccountVerificationModalFirstNameChangedEvent({required this.firstName});
}

final class SocialAccountVerificationModalFirstNameUnfocusedEvent extends SocialAccountVerificationModalEvent {}

final class SocialAccountVerificationModalLastNameChangedEvent extends SocialAccountVerificationModalEvent {
  final String lastName;
  SocialAccountVerificationModalLastNameChangedEvent({required this.lastName});
}

final class SocialAccountVerificationModalLastNameUnfocusedEvent extends SocialAccountVerificationModalEvent {}

final class SocialAccountVerificationModalCountryCodeChangedEvent extends SocialAccountVerificationModalEvent {
  final String countryCode;
  SocialAccountVerificationModalCountryCodeChangedEvent({required this.countryCode});
}

final class SocialAccountVerificationModalCountryCodeUnfocusedEvent extends SocialAccountVerificationModalEvent {}

final class SocialAccountVerificationModalMobileNumberChangedEvent extends SocialAccountVerificationModalEvent {
  final String mobileNumber;
  SocialAccountVerificationModalMobileNumberChangedEvent({required this.mobileNumber});
}

final class SocialAccountVerificationModalMobileNumberUnfocusedEvent extends SocialAccountVerificationModalEvent {}

final class SocialAccountVerificationModalSubmitEvent extends SocialAccountVerificationModalEvent {}

