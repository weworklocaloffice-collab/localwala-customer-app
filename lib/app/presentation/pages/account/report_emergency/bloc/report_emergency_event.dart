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

part of 'report_emergency_bloc.dart';

sealed class ReportEmergencyEvent {}

final class ReportEmergencyInitialEvent extends ReportEmergencyEvent {}

final class ReportEmergencyFormNameChangedEvent extends ReportEmergencyEvent {
  final String name;
  ReportEmergencyFormNameChangedEvent({required this.name});
}

final class ReportEmergencyFormNameUnfocusedEvent extends ReportEmergencyEvent {}

final class ReportEmergencyFormCountryCodeChangedEvent extends ReportEmergencyEvent {
  final String flag;
  final String countryCode;
  ReportEmergencyFormCountryCodeChangedEvent({required this.flag, required this.countryCode});
}

final class ReportEmergencyFormNumberChangedEvent extends ReportEmergencyEvent {
  final String number;
  ReportEmergencyFormNumberChangedEvent({required this.number});
}

final class ReportEmergencyFormNumberUnfocusedEvent extends ReportEmergencyEvent {}

final class ReportEmergencyFormEmailChangedEvent extends ReportEmergencyEvent {
  final String email;
  ReportEmergencyFormEmailChangedEvent({required this.email});
}

final class ReportEmergencyFormEmailUnfocusedEvent extends ReportEmergencyEvent {}

final class ReportEmergencyFormDescriptionChangedEvent extends ReportEmergencyEvent {
  final String text;
  ReportEmergencyFormDescriptionChangedEvent({required this.text});
}

final class ReportEmergencyFormDescriptionUnfocusedEvent extends ReportEmergencyEvent {}

final class ReportEmergecyFormSelectQueryEvent extends ReportEmergencyEvent {
  final String report;
  ReportEmergecyFormSelectQueryEvent({required this.report});
}

final class ReportEmergencyFormSubmitEvent extends ReportEmergencyEvent {}

