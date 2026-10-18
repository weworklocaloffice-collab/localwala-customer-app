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

part of 'order_help_modal_bloc.dart';

enum OrderHelpModalStatus {
  initial,
  refundRequestStarted,
  refundRequestFailed,
  refundRequestSuccess,
  orderSummaryDownloadStarted,
  orderSummaryDownloadFailed,
  orderSummaryDownloadSuccess,
  orderInvoiceDownloadStarted,
  orderInvoiceDownloadFailed,
  orderInvoiceDownloadSuccess,
  customError,
}

extension OrderHelpModalStatusX on OrderHelpModalStatus {
  bool get isInitial => this == OrderHelpModalStatus.initial;
  bool get isRefundRequestStarted => this == OrderHelpModalStatus.refundRequestStarted;
  bool get isRefundRequestFailed => this == OrderHelpModalStatus.refundRequestFailed;
  bool get isRefundRequestSuccess => this == OrderHelpModalStatus.refundRequestSuccess;
  bool get isOrderSummaryDownloadStarted => this == OrderHelpModalStatus.orderSummaryDownloadStarted;
  bool get isOrderSummaryDownloadFailed => this == OrderHelpModalStatus.orderSummaryDownloadFailed;
  bool get isOrderSummaryDownloadSuccess => this == OrderHelpModalStatus.orderSummaryDownloadSuccess;
  bool get isOrderInvoiceDownloadStarted => this == OrderHelpModalStatus.orderInvoiceDownloadStarted;
  bool get isOrderInvoiceDownloadFailed => this == OrderHelpModalStatus.orderInvoiceDownloadFailed;
  bool get isOrderInvoiceDownloadSuccess => this == OrderHelpModalStatus.orderInvoiceDownloadSuccess;
  bool get isCustomError => this == OrderHelpModalStatus.customError;
}

final class OrderHelpModalState {
  final String orderId;
  final int orderNumber;
  final String orderStatus;
  final String paymentMode;
  final bool refundRequestEnable;
  final String restaurant;
  final String payment;
  final bool canRequestRefund;
  final String downloadPath;
  final OrderHelpModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const OrderHelpModalState({
    this.orderId = '',
    this.orderNumber = 0,
    this.orderStatus = '',
    this.paymentMode = '',
    this.refundRequestEnable = false,
    this.restaurant = '',
    this.payment = '',
    this.canRequestRefund = false,
    this.downloadPath = '',
    this.status = OrderHelpModalStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  OrderHelpModalState copyWith({
    String? orderId,
    int? orderNumber,
    String? orderStatus,
    String? paymentMode,
    bool? refundRequestEnable,
    String? restaurant,
    String? payment,
    bool? canRequestRefund,
    String? downloadPath,
    OrderHelpModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return OrderHelpModalState(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      orderStatus: orderStatus ?? this.orderStatus,
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

