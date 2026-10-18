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

part of 'tiffin_subscription_request_off_days_modal_bloc.dart';

sealed class TiffinSubscriptionRequestOffDaysModalEvent {}

final class TiffinSubscriptionRequestOffDaysModalInitialEvent extends TiffinSubscriptionRequestOffDaysModalEvent {
  final String purchaseId;
  final List<String> requestedOffDates;
  final List<String> offDays;
  final int totalOrders;
  TiffinSubscriptionRequestOffDaysModalInitialEvent({required this.purchaseId, required this.requestedOffDates, required this.offDays, required this.totalOrders});
}

final class TiffinSubscriptionRequestOffDaysModalSelectedDateEvent extends TiffinSubscriptionRequestOffDaysModalEvent {
  final DateTime date;
  TiffinSubscriptionRequestOffDaysModalSelectedDateEvent({required this.date});
}

final class TiffinSubscriptionRequestOffDaySubmitEvent extends TiffinSubscriptionRequestOffDaysModalEvent {}

