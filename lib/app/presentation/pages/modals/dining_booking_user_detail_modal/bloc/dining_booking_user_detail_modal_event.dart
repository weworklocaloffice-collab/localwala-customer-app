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

part of 'dining_booking_user_detail_modal_bloc.dart';

sealed class DiningBookingUserDetailModalEvent {}

final class DiningBookingUserDetailModalInitialEvent extends DiningBookingUserDetailModalEvent {
  final String userName;
  final String userCountryCode;
  final String userPhoneNumber;
  final String userEmail;
  DiningBookingUserDetailModalInitialEvent({required this.userName, required this.userCountryCode, required this.userPhoneNumber, required this.userEmail});
}

final class DiningBookingUserDetailModalNameChangedEvent extends DiningBookingUserDetailModalEvent {
  final String name;
  DiningBookingUserDetailModalNameChangedEvent({required this.name});
}

final class DiningBookingUserDetailModalNameUnfocusedEvent extends DiningBookingUserDetailModalEvent {}

final class DiningBookingUserDetailModalCountryCodeChangedEvent extends DiningBookingUserDetailModalEvent {
  final String flag;
  final String countryCode;
  DiningBookingUserDetailModalCountryCodeChangedEvent({required this.flag, required this.countryCode});
}

final class DiningBookingUserDetailModalNumberChangedEvent extends DiningBookingUserDetailModalEvent {
  final String number;
  DiningBookingUserDetailModalNumberChangedEvent({required this.number});
}

final class DiningBookingUserDetailModalNumberUnfocusedEvent extends DiningBookingUserDetailModalEvent {}

final class DiningBookingUserDetailModalEmailChangedEvent extends DiningBookingUserDetailModalEvent {
  final String email;
  DiningBookingUserDetailModalEmailChangedEvent({required this.email});
}

final class DiningBookingUserDetailModalEmailUnfocusedEvent extends DiningBookingUserDetailModalEvent {}

final class DiningBookingUserDetailModalSubmitEvent extends DiningBookingUserDetailModalEvent {}

