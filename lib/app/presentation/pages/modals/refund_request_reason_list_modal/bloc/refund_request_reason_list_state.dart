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

part of 'refund_request_reason_list_bloc.dart';

enum RefundRequestReasonListStatus { loading, success, failure, empty }

extension RefundRequestReasonListStatusX on RefundRequestReasonListStatus {
  bool get isLoading => this == RefundRequestReasonListStatus.loading;
  bool get isSuccess => this == RefundRequestReasonListStatus.success;
  bool get isFailure => this == RefundRequestReasonListStatus.failure;
  bool get isEmpty => this == RefundRequestReasonListStatus.empty;
}

final class RefundRequestReasonListState {
  final RefundRequestListModel list;
  final String reasonId;
  final RefundRequestReasonListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RefundRequestReasonListState({required this.list, this.reasonId = '', this.status = RefundRequestReasonListStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  RefundRequestReasonListState copyWith({RefundRequestListModel? list, String? reasonId, RefundRequestReasonListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return RefundRequestReasonListState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

