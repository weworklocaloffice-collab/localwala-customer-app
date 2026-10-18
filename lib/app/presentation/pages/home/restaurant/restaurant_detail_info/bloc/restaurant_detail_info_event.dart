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

part of 'restaurant_detail_info_bloc.dart';

sealed class RestaurantDetailInfoEvent {}

final class RestaurantDetailInfoInitialEvent extends RestaurantDetailInfoEvent {
  final String id;
  final String name;
  final String slug;
  final String campaignId;
  RestaurantDetailInfoInitialEvent({required this.id, required this.name, required this.slug, required this.campaignId});
}

final class RestaurantDetailInfoFavouriteEvent extends RestaurantDetailInfoEvent {}

final class RestaurantDetailInfoShareEvent extends RestaurantDetailInfoEvent {}

final class RestaurantDetailInfoDirectionEvent extends RestaurantDetailInfoEvent {}

final class RestaurantCallNumberEvent extends RestaurantDetailInfoEvent {}

final class RestaurantShowMoreSlotEvent extends RestaurantDetailInfoEvent {
  final int slotIndex;
  RestaurantShowMoreSlotEvent({required this.slotIndex});
}

