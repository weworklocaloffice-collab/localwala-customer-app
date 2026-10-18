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

part of 'restaurant_pre_booking_table_bloc.dart';

sealed class RestaurantPreBookingTableEvent {}

final class RestaurantPreBookingTableInitialEvent extends RestaurantPreBookingTableEvent {
  final String restaurant;
  final String restaurantName;
  final String restaurantSlug;
  RestaurantPreBookingTableInitialEvent({required this.restaurant, required this.restaurantName, required this.restaurantSlug});
}

final class RestaurantPreBookingChangeDateEvent extends RestaurantPreBookingTableEvent {
  final String dateFormat;
  RestaurantPreBookingChangeDateEvent({required this.dateFormat});
}

final class RestaurantPreBookingChangeGuestEvent extends RestaurantPreBookingTableEvent {
  final int guest;
  RestaurantPreBookingChangeGuestEvent({required this.guest});
}

final class RestaurantPreBookingChangeMealTimeEvent extends RestaurantPreBookingTableEvent {
  final int mealIndex;
  RestaurantPreBookingChangeMealTimeEvent({required this.mealIndex});
}

final class RestaurantPreBookingSaveSlotEvent extends RestaurantPreBookingTableEvent {
  final String slot;
  RestaurantPreBookingSaveSlotEvent({required this.slot});
}

final class RestaurantPreBookingSaveCouponEvent extends RestaurantPreBookingTableEvent {
  final String couponId;
  RestaurantPreBookingSaveCouponEvent({required this.couponId});
}

final class RestaurantPreBookingTableGuestLoginEvent extends RestaurantPreBookingTableEvent {}

final class RestaurantPreBookingTableSubmitEvent extends RestaurantPreBookingTableEvent {}

