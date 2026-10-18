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

part of 'cancellation_reason_list_bloc.dart';

enum CancellationReasonListStatus { loading, success, failure, empty }

extension CancellationReasonListStatusX on CancellationReasonListStatus {
  bool get isLoading => this == CancellationReasonListStatus.loading;
  bool get isSuccess => this == CancellationReasonListStatus.success;
  bool get isFailure => this == CancellationReasonListStatus.failure;
  bool get isEmpty => this == CancellationReasonListStatus.empty;
}

final class CancellationReasonListState {
  final OrderCancellationListModel list;
  final String reasonId;
  final CancellationReasonListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CancellationReasonListState({required this.list, this.reasonId = '', this.status = CancellationReasonListStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  CancellationReasonListState copyWith({OrderCancellationListModel? list, String? reasonId, CancellationReasonListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return CancellationReasonListState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

