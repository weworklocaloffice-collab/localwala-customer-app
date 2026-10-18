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

part of 'hide_restaurant_reason_modal_bloc.dart';

sealed class HideRestaurantReasonModalEvent {}

final class HideRestaurantReasonModalInitialEvent extends HideRestaurantReasonModalEvent {
  final String restaurantId;
  final String restaurantName;
  HideRestaurantReasonModalInitialEvent({required this.restaurantId, required this.restaurantName});
}

final class HideRestaurantReasonSelectEvent extends HideRestaurantReasonModalEvent {
  final String reasonId;
  HideRestaurantReasonSelectEvent({required this.reasonId});
}

final class HideRestaurantReasonSubmitEvent extends HideRestaurantReasonModalEvent {}

