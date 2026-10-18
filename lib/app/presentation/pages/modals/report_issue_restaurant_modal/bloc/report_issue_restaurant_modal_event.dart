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

part of 'report_issue_restaurant_modal_bloc.dart';

sealed class ReportIssueRestaurantModalEvent {}

final class ReportIssueRestaurantModalInitialEvent extends ReportIssueRestaurantModalEvent {
  final String id;
  ReportIssueRestaurantModalInitialEvent({required this.id});
}

final class ReportIssueRestaurantModalSelectReasonEvent extends ReportIssueRestaurantModalEvent {
  final String id;
  final String name;
  ReportIssueRestaurantModalSelectReasonEvent({required this.id, required this.name});
}

final class ReportIssueRestaurantReSelectEvent extends ReportIssueRestaurantModalEvent {}

final class ReportIssueRestaurantMessageChangedEvent extends ReportIssueRestaurantModalEvent {
  final String message;
  ReportIssueRestaurantMessageChangedEvent({required this.message});
}

final class ReportIssueRestaurantMessageUnfocusedEvent extends ReportIssueRestaurantModalEvent {}

final class ReportIssueRestaurantSubmitEvent extends ReportIssueRestaurantModalEvent {}

