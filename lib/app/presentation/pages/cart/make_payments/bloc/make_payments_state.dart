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

part of 'make_payments_bloc.dart';

enum MakePaymentStatus { initial, success }

extension MakePaymentStatusX on MakePaymentStatus {
  bool get isInitial => this == MakePaymentStatus.initial;
  bool get isSuccess => this == MakePaymentStatus.success;
}

final class MakePaymentsState {
  final MakePaymentStatus status;
  final String alertMessage;
  final String extraMessage;
  const MakePaymentsState({this.status = MakePaymentStatus.initial, this.alertMessage = '', this.extraMessage = ''});

  MakePaymentsState copyWith({MakePaymentStatus? status, String? alertMessage, String? extraMessage}) {
    return MakePaymentsState(status: status ?? this.status, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

