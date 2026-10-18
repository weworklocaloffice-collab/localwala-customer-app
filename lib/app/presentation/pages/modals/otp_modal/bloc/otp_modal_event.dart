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

part of 'otp_modal_bloc.dart';

sealed class OtpModalEvent {}

final class OtpModalInitialEvent extends OtpModalEvent {
  final String provider;
  final String providerId;
  final int otpLength;
  final bool canResendOTP;
  OtpModalInitialEvent({required this.provider, required this.providerId, required this.otpLength, required this.canResendOTP});
}

final class OtpModalOnSubmitEvent extends OtpModalEvent {}

final class OtpModalOnResendEvent extends OtpModalEvent {}

final class OtpModalOnOTPChanged extends OtpModalEvent {
  final String otp;
  OtpModalOnOTPChanged({required this.otp});
}

