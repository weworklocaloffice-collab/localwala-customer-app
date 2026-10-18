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

part of 'dining_booking_cancellation_reason_list_modal_bloc.dart';

enum DiningBookingCancellationReasonListModalStatus { loading, success, failure, empty }

extension DiningBookingCancellationReasonListModalStatusX on DiningBookingCancellationReasonListModalStatus {
  bool get isLoading => this == DiningBookingCancellationReasonListModalStatus.loading;
  bool get isSuccess => this == DiningBookingCancellationReasonListModalStatus.success;
  bool get isFailure => this == DiningBookingCancellationReasonListModalStatus.failure;
  bool get isEmpty => this == DiningBookingCancellationReasonListModalStatus.empty;
}

final class DiningBookingCancellationReasonListModalState {
  final DiningBookingCancellationReasonListModel list;
  final String reasonId;
  final DiningBookingCancellationReasonListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingCancellationReasonListModalState({
    required this.list,
    this.reasonId = '',
    this.status = DiningBookingCancellationReasonListModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingCancellationReasonListModalState copyWith({
    DiningBookingCancellationReasonListModel? list,
    String? reasonId,
    DiningBookingCancellationReasonListModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingCancellationReasonListModalState(
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

