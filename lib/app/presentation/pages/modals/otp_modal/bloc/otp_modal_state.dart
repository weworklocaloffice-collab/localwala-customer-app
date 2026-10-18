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

enum OtpModalStatus { initial, inProgress, success, failure, resend, successResent }

extension OtpModalStatusX on OtpModalStatus {
  bool get isInitial => this == OtpModalStatus.initial;
  bool get isSuccess => this == OtpModalStatus.success;
  bool get isFailure => this == OtpModalStatus.failure;
  bool get isResend => this == OtpModalStatus.resend;
  bool get isInProgress => this == OtpModalStatus.inProgress;
  bool get isSuccessResent => this == OtpModalStatus.successResent;
}

final class OtpModalState {
  final String id;
  final String provider;
  final String otp;
  final OtpModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const OtpModalState({this.id = '', this.provider = '', this.otp = '', this.status = OtpModalStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  OtpModalState copyWith({String? id, String? provider, String? otp, OtpModalStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return OtpModalState(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      otp: otp ?? this.otp,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

