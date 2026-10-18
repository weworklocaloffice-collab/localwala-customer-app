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

sealed class DiningBookingInformationHelpModalEvent {}

final class DiningBookingInformationHelpModalInitialEvent extends DiningBookingInformationHelpModalEvent {
  final String bookingId;
  final String bookingStatus;
  final String paymentMode;
  final bool refundRequestEnable;
  final String restaurant;
  final String payment;
  DiningBookingInformationHelpModalInitialEvent({required this.bookingId, required this.bookingStatus, required this.paymentMode, required this.refundRequestEnable, required this.restaurant, required this.payment});
}

final class DiningBookingInformationHelpModalRefundRequestEvent extends DiningBookingInformationHelpModalEvent {
  final String reasonId;
  DiningBookingInformationHelpModalRefundRequestEvent({required this.reasonId});
}

final class DiningBookingInformationHelpModalSummaryEvent extends DiningBookingInformationHelpModalEvent {}

final class DiningBookingInformationHelpModalInvoiceEvent extends DiningBookingInformationHelpModalEvent {}

