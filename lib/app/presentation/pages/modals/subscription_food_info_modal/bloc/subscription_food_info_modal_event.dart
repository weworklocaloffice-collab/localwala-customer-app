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

part of 'subscription_food_info_modal_bloc.dart';

sealed class SubscriptionFoodInfoModalEvent {}

final class SubscriptionFoodInfoInitialEvent extends SubscriptionFoodInfoModalEvent {
  final String id;
  final String data;
  final bool canAddAddons;
  final bool canAddVariations;
  final int totalOrders;
  final String inCart;
  SubscriptionFoodInfoInitialEvent({required this.id, required this.data, required this.canAddAddons, required this.canAddVariations, required this.totalOrders, required this.inCart});
}

final class SubscriptionFoodInfoModalAddonsEvent extends SubscriptionFoodInfoModalEvent {
  final int index;
  SubscriptionFoodInfoModalAddonsEvent({required this.index});
}

final class SubscriptionFoodInfoModalVariationOptionEvent extends SubscriptionFoodInfoModalEvent {
  final int vIndex;
  final int oIndex;
  final String type;
  SubscriptionFoodInfoModalVariationOptionEvent({required this.vIndex, required this.oIndex, required this.type});
}

final class SubscriptionFoodInfoModalSaveEvent extends SubscriptionFoodInfoModalEvent {}

final class SubscriptionFoodInfoModalShaveEvent extends SubscriptionFoodInfoModalEvent {}

