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

part of 'web_otp_modal_bloc.dart';

enum WebOtpModalStatus { initial, success, failed }

extension WebOtpModalStatusX on WebOtpModalStatus {
  bool get isInitial => this == WebOtpModalStatus.initial;
  bool get isSuccess => this == WebOtpModalStatus.success;
  bool get isFailed => this == WebOtpModalStatus.failed;
}

final class WebOtpModalState {
  final String otpId;
  final String locale;
  final WebOtpModalStatus status;
  final String dummyOTP;
  final String alertMessage;
  final String extraMessage;
  const WebOtpModalState({this.otpId = '', this.locale = '', this.status = WebOtpModalStatus.initial, this.dummyOTP = '', this.alertMessage = '', this.extraMessage = ''});

  WebOtpModalState copyWith({String? otpId, String? locale, WebOtpModalStatus? status, String? dummyOTP, String? alertMessage, String? extraMessage}) {
    return WebOtpModalState(
      otpId: otpId ?? this.otpId,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      dummyOTP: dummyOTP ?? this.dummyOTP,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

