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

enum ResetWithEmailOtpStatus { initial, failure, success, inProgress, verify, verifyWeb }

extension ResetWithEmailOtpStatusX on ResetWithEmailOtpStatus {
  bool get isInitial => this == ResetWithEmailOtpStatus.initial;
  bool get isFailure => this == ResetWithEmailOtpStatus.failure;
  bool get isSuccess => this == ResetWithEmailOtpStatus.success;
  bool get isInProgress => this == ResetWithEmailOtpStatus.inProgress;
  bool get isVerify => this == ResetWithEmailOtpStatus.verify;
  bool get isVerifyWeb => this == ResetWithEmailOtpStatus.verifyWeb;
}

final class ResetWithEmailOtpState {
  final bool isVerified;
  final ResetWithOptionOneEmailField email;
  final ResetWithOptionOnePasswordField password;
  final ResetWithOptionOneConfirmedPasswordField confirmedPassword;
  final ForgotPasswordResponseModel verification;
  final bool isEmailValid;
  final bool isPasswordValid;
  final String locale;
  final ResetWithEmailOtpStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ResetWithEmailOtpState({
    required this.verification,
    this.isVerified = false,
    this.email = const ResetWithOptionOneEmailField.pure(),
    this.password = const ResetWithOptionOnePasswordField.pure(),
    this.confirmedPassword = const ResetWithOptionOneConfirmedPasswordField.pure(),
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.locale = '',
    this.status = ResetWithEmailOtpStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ResetWithEmailOtpState copyWith({
    ForgotPasswordResponseModel? verification,
    bool? isVerified,
    ResetWithOptionOneEmailField? email,
    ResetWithOptionOnePasswordField? password,
    ResetWithOptionOneConfirmedPasswordField? confirmedPassword,
    bool? isEmailValid,
    bool? isPasswordValid,
    String? locale,
    ResetWithEmailOtpStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ResetWithEmailOtpState(
      verification: verification ?? this.verification,
      isVerified: isVerified ?? this.isVerified,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

