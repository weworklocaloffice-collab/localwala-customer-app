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

part of 'confirm_pre_booking_table_bloc.dart';

sealed class ConfirmPreBookingTableEvent {}

final class ConfirmPreBookingTableInitialEvent extends ConfirmPreBookingTableEvent {
  final String restaurant;
  final String selectedDate;
  final int selectedGuest;
  final String selectedSlot;
  final String selectedCoupon;
  ConfirmPreBookingTableInitialEvent({required this.restaurant, required this.selectedDate, required this.selectedGuest, required this.selectedSlot, required this.selectedCoupon});
}

final class ConfirmPreBookingPaymentChangeEvent extends ConfirmPreBookingTableEvent {
  final String id;
  ConfirmPreBookingPaymentChangeEvent({required this.id});
}

final class ConfirmPreBookingUserInfoChangeEvent extends ConfirmPreBookingTableEvent {
  final String name;
  final String countryCode;
  final String phoneNumber;
  final String email;
  ConfirmPreBookingUserInfoChangeEvent({required this.name, required this.countryCode, required this.phoneNumber, required this.email});
}

final class ConfirmPreBookingSpecialRequestChangeEvent extends ConfirmPreBookingTableEvent {
  final String instructions;
  ConfirmPreBookingSpecialRequestChangeEvent({required this.instructions});
}

final class ConfirmPreBookingSubmitEvent extends ConfirmPreBookingTableEvent {}

