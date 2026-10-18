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

part of 'reset_with_email_otp_bloc.dart';

sealed class ResetWithEmailOtpEvent {}

final class ResetWithEmailOtpInitialEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOneEmailChangedEvent extends ResetWithEmailOtpEvent {
  final String email;
  ResetWithOptionOneEmailChangedEvent({required this.email});
}

final class ResetWithOptionOneEmailUnfocusedEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOneSendVerificationMailEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOneVerificationSuccessEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOnePasswordChangedEvent extends ResetWithEmailOtpEvent {
  final String password;

  ResetWithOptionOnePasswordChangedEvent({required this.password});
}

final class ResetWithOptionOnePasswordUnfocusedEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOneConfirmPasswordChangedEvent extends ResetWithEmailOtpEvent {
  final String password;

  ResetWithOptionOneConfirmPasswordChangedEvent({required this.password});
}

final class ResetWithOptionOneConfirmPasswordUnfocusedEvent extends ResetWithEmailOtpEvent {}

final class ResetWithOptionOneUpdatePasswordEvent extends ResetWithEmailOtpEvent {}

