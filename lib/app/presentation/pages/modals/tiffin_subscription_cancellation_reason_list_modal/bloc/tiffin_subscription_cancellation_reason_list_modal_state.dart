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

part of 'tiffin_subscription_cancellation_reason_list_modal_bloc.dart';

enum TiffinSubscriptionCancellationReasonListModalStatus { loading, success, failure, empty }

extension TiffinSubscriptionCancellationReasonListModalStatusX on TiffinSubscriptionCancellationReasonListModalStatus {
  bool get isLoading => this == TiffinSubscriptionCancellationReasonListModalStatus.loading;
  bool get isSuccess => this == TiffinSubscriptionCancellationReasonListModalStatus.success;
  bool get isFailure => this == TiffinSubscriptionCancellationReasonListModalStatus.failure;
  bool get isEmpty => this == TiffinSubscriptionCancellationReasonListModalStatus.empty;
}

final class TiffinSubscriptionCancellationReasonListModalState {
  final TiffinSubscriptionCancellationReasonListModel list;
  final String reasonId;
  final TiffinSubscriptionCancellationReasonListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const TiffinSubscriptionCancellationReasonListModalState({
    required this.list,
    this.reasonId = '',
    this.status = TiffinSubscriptionCancellationReasonListModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  TiffinSubscriptionCancellationReasonListModalState copyWith({
    TiffinSubscriptionCancellationReasonListModel? list,
    String? reasonId,
    TiffinSubscriptionCancellationReasonListModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return TiffinSubscriptionCancellationReasonListModalState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

