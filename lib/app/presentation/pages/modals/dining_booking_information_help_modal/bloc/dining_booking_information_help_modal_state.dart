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

part of 'dining_booking_information_help_modal_bloc.dart';

enum DiningBookingInformationHelpModalStatus {
  initial,
  refundRequestStarted,
  refundRequestFailed,
  refundRequestSuccess,
  summaryDownloadStarted,
  summaryDownloadFailed,
  summaryDownloadSuccess,
  invoiceDownloadStarted,
  invoiceDownloadFailed,
  invoiceDownloadSuccess,
  customError,
}

extension DiningBookingInformationHelpModalStatusX on DiningBookingInformationHelpModalStatus {
  bool get isInitial => this == DiningBookingInformationHelpModalStatus.initial;
  bool get isRefundRequestStarted => this == DiningBookingInformationHelpModalStatus.refundRequestStarted;
  bool get isRefundRequestFailed => this == DiningBookingInformationHelpModalStatus.refundRequestFailed;
  bool get isRefundRequestSuccess => this == DiningBookingInformationHelpModalStatus.refundRequestSuccess;
  bool get isSummaryDownloadStarted => this == DiningBookingInformationHelpModalStatus.summaryDownloadStarted;
  bool get isSummaryDownloadFailed => this == DiningBookingInformationHelpModalStatus.summaryDownloadFailed;
  bool get isSummaryDownloadSuccess => this == DiningBookingInformationHelpModalStatus.summaryDownloadSuccess;
  bool get isInvoiceDownloadStarted => this == DiningBookingInformationHelpModalStatus.invoiceDownloadStarted;
  bool get isInvoiceDownloadFailed => this == DiningBookingInformationHelpModalStatus.invoiceDownloadFailed;
  bool get isInvoiceDownloadSuccess => this == DiningBookingInformationHelpModalStatus.invoiceDownloadSuccess;
  bool get isCustomError => this == DiningBookingInformationHelpModalStatus.customError;
}

final class DiningBookingInformationHelpModalState {
  final String bookingId;
  final String bookingStatus;
  final String paymentMode;
  final bool refundRequestEnable;
  final String restaurant;
  final String payment;
  final bool canRequestRefund;
  final String downloadPath;
  final DiningBookingInformationHelpModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingInformationHelpModalState({
    this.bookingId = '',
    this.bookingStatus = '',
    this.paymentMode = '',
    this.refundRequestEnable = false,
    this.restaurant = '',
    this.payment = '',
    this.canRequestRefund = false,
    this.downloadPath = '',
    this.status = DiningBookingInformationHelpModalStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingInformationHelpModalState copyWith({
    String? bookingId,
    String? bookingStatus,
    String? paymentMode,
    bool? refundRequestEnable,
    String? restaurant,
    String? payment,
    bool? canRequestRefund,
    String? downloadPath,
    DiningBookingInformationHelpModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingInformationHelpModalState(
      bookingId: bookingId ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      refundRequestEnable: refundRequestEnable ?? this.refundRequestEnable,
      restaurant: restaurant ?? this.restaurant,
      payment: payment ?? this.payment,
      canRequestRefund: canRequestRefund ?? this.canRequestRefund,
      downloadPath: downloadPath ?? this.downloadPath,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

