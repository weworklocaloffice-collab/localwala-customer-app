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

enum FirebaseVerificationModalStatus { sending, sent, sentFailed, verifying, verified, verifyFailed }

extension FirebaseVerificationModalStatusX on FirebaseVerificationModalStatus {
  bool get isSending => this == FirebaseVerificationModalStatus.sending;
  bool get isSent => this == FirebaseVerificationModalStatus.sent;
  bool get isSentFailed => this == FirebaseVerificationModalStatus.sentFailed;
  bool get isVerifying => this == FirebaseVerificationModalStatus.verifying;
  bool get isVerified => this == FirebaseVerificationModalStatus.verified;
  bool get isVerifyFailed => this == FirebaseVerificationModalStatus.verifyFailed;
}

final class FirebaseVerificationModalState {
  final String toNumber;
  final String countryCode;
  final String mobileNumber;
  final String verificationId;
  final String smsCode;
  final String accessToken;
  final FirebaseVerificationModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FirebaseVerificationModalState({
    this.toNumber = '',
    this.countryCode = '',
    this.mobileNumber = '',
    this.verificationId = '',
    this.smsCode = '',
    this.accessToken = '',
    this.status = FirebaseVerificationModalStatus.sending,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FirebaseVerificationModalState copyWith({
    String? toNumber,
    String? countryCode,
    String? mobileNumber,
    String? verificationId,
    String? smsCode,
    String? accessToken,
    FirebaseVerificationModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FirebaseVerificationModalState(
      toNumber: toNumber ?? this.toNumber,
      countryCode: countryCode ?? this.countryCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      verificationId: verificationId ?? this.verificationId,
      smsCode: smsCode ?? this.smsCode,
      accessToken: accessToken ?? this.accessToken,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

