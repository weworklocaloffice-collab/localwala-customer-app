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

part of 'firebase_verification_modal_bloc.dart';

sealed class FirebaseVerificationModalEvent {}

final class FirebaseVerificationModalInitialEvent extends FirebaseVerificationModalEvent {
  final String countryCode;
  final String mobileNumber;
  FirebaseVerificationModalInitialEvent({required this.countryCode, required this.mobileNumber});
}

final class FirebaseVerificationModalErrorEvent extends FirebaseVerificationModalEvent {
  final String error;
  FirebaseVerificationModalErrorEvent({required this.error});
}

final class FirebaseVerificationIdEvent extends FirebaseVerificationModalEvent {
  final String id;
  FirebaseVerificationIdEvent({required this.id});
}

final class FirebaseVerificationSMSChangeEvent extends FirebaseVerificationModalEvent {
  final String otp;
  FirebaseVerificationSMSChangeEvent({required this.otp});
}

final class FirebaseVerificationVerifyEvent extends FirebaseVerificationModalEvent {}

