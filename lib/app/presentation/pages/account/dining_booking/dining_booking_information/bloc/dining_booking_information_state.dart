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

part of 'dining_booking_information_bloc.dart';

enum DiningBookingInformationStatus { loading, success, failure, customError, repayOrderRequested, repayOrderSuccess, repayOrderFailed, cancelRequested, cancelSuccess, cancelFailed }

extension DiningBookingInformationStatusX on DiningBookingInformationStatus {
  bool get isLoading => this == DiningBookingInformationStatus.loading;
  bool get isSuccess => this == DiningBookingInformationStatus.success;
  bool get isFailure => this == DiningBookingInformationStatus.failure;
  bool get isCustomError => this == DiningBookingInformationStatus.customError;
  bool get isRepayOrderRequested => this == DiningBookingInformationStatus.repayOrderRequested;
  bool get isRepayOrderSuccess => this == DiningBookingInformationStatus.repayOrderSuccess;
  bool get isRepayOrderFailed => this == DiningBookingInformationStatus.repayOrderFailed;
  bool get isCancelRequested => this == DiningBookingInformationStatus.cancelRequested;
  bool get isCancelSuccess => this == DiningBookingInformationStatus.cancelSuccess;
  bool get isCancelFailed => this == DiningBookingInformationStatus.cancelFailed;
}

final class DiningBookingInformationState {
  final String bookingId;
  final DiningBookingDetailInformationResponseModel model;
  final bool canPayPending;
  final bool canCancelBooking;
  final String newPaymentId;
  final String paymentName;
  final String paymentImageURL;
  final String? paymentURL;
  final DiningBookingInformationStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingInformationState({
    this.bookingId = '',
    required this.model,
    this.canPayPending = false,
    this.canCancelBooking = false,
    this.newPaymentId = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.paymentURL = '',
    this.status = DiningBookingInformationStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingInformationState copyWith({
    String? bookingId,
    DiningBookingDetailInformationResponseModel? model,
    bool? canPayPending,
    bool? canCancelBooking,
    String? newPaymentId,
    String? paymentName,
    String? paymentImageURL,
    String? paymentURL,
    DiningBookingInformationStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingInformationState(
      bookingId: bookingId ?? this.bookingId,
      model: model ?? this.model,
      canPayPending: canPayPending ?? this.canPayPending,
      canCancelBooking: canCancelBooking ?? this.canCancelBooking,
      newPaymentId: newPaymentId ?? this.newPaymentId,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      paymentURL: paymentURL ?? this.paymentURL,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

