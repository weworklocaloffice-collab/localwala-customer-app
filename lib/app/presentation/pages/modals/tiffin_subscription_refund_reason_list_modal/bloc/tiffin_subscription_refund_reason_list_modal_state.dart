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

part of 'tiffin_subscription_refund_reason_list_modal_bloc.dart';

enum TiffinSubscriptionRefundReasonListModalStatus { loading, success, failure, empty }

extension TiffinSubscriptionRefundReasonListModalStatusX on TiffinSubscriptionRefundReasonListModalStatus {
  bool get isLoading => this == TiffinSubscriptionRefundReasonListModalStatus.loading;
  bool get isSuccess => this == TiffinSubscriptionRefundReasonListModalStatus.success;
  bool get isFailure => this == TiffinSubscriptionRefundReasonListModalStatus.failure;
  bool get isEmpty => this == TiffinSubscriptionRefundReasonListModalStatus.empty;
}

final class TiffinSubscriptionRefundReasonListModalState {
  final TiffinSubscriptionRefundReasonListModel list;
  final String reasonId;
  final TiffinSubscriptionRefundReasonListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const TiffinSubscriptionRefundReasonListModalState({
    required this.list,
    this.reasonId = '',
    this.status = TiffinSubscriptionRefundReasonListModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  TiffinSubscriptionRefundReasonListModalState copyWith({
    TiffinSubscriptionRefundReasonListModel? list,
    String? reasonId,
    TiffinSubscriptionRefundReasonListModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return TiffinSubscriptionRefundReasonListModalState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

