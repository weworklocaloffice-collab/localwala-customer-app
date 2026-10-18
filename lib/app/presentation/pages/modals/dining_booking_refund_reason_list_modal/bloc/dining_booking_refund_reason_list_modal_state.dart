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

part of 'dining_booking_refund_reason_list_modal_bloc.dart';

enum DiningBookingRefundReasonListModalStatus { loading, success, failure, empty }

extension DiningBookingRefundReasonListModalStatusX on DiningBookingRefundReasonListModalStatus {
  bool get isLoading => this == DiningBookingRefundReasonListModalStatus.loading;
  bool get isSuccess => this == DiningBookingRefundReasonListModalStatus.success;
  bool get isFailure => this == DiningBookingRefundReasonListModalStatus.failure;
  bool get isEmpty => this == DiningBookingRefundReasonListModalStatus.empty;
}

final class DiningBookingRefundReasonListModalState {
  final DiningBookingRefundReasonListModel list;
  final String reasonId;
  final DiningBookingRefundReasonListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingRefundReasonListModalState({required this.list, this.reasonId = '', this.status = DiningBookingRefundReasonListModalStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  DiningBookingRefundReasonListModalState copyWith({DiningBookingRefundReasonListModel? list, String? reasonId, DiningBookingRefundReasonListModalStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return DiningBookingRefundReasonListModalState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

