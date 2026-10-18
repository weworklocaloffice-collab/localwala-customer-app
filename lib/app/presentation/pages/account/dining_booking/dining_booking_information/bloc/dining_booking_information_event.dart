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

sealed class DiningBookingInformationEvent {}

final class DiningBookingInformationInitialEvent extends DiningBookingInformationEvent {
  final String bookingId;
  DiningBookingInformationInitialEvent({required this.bookingId});
}

final class DiningBookingInformationRestaurantDirectionEvent extends DiningBookingInformationEvent {}

final class DiningBookingInformationRestaurantCallEvent extends DiningBookingInformationEvent {}

final class DiningBookingInformationPaymentChangedEvent extends DiningBookingInformationEvent {
  final String id;
  DiningBookingInformationPaymentChangedEvent({required this.id});
}

final class DiningBookingInformationRepayBookingEvent extends DiningBookingInformationEvent {}

final class DiningBookingInformationCancelMyBookingEvent extends DiningBookingInformationEvent {
  final String reasonId;
  DiningBookingInformationCancelMyBookingEvent({required this.reasonId});
}

