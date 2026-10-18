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

sealed class OrderHelpModalEvent {}

final class OrderHelpModalInitialEvent extends OrderHelpModalEvent {
  final String orderId;
  final int orderNumber;
  final String orderStatus;
  final String paymentMode;
  final bool refundRequestEnable;
  final String restaurant;
  final String payment;
  final bool subscriptionOrder;
  OrderHelpModalInitialEvent({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentMode,
    required this.refundRequestEnable,
    required this.restaurant,
    required this.payment,
    required this.subscriptionOrder,
  });
}

final class OrderHelpModalRefundRequestEvent extends OrderHelpModalEvent {
  final String reasonId;
  OrderHelpModalRefundRequestEvent({required this.reasonId});
}

final class OrderHelpModalOrderSummaryEvent extends OrderHelpModalEvent {}

final class OrderHelpModalOrderInvoiceEvent extends OrderHelpModalEvent {}

