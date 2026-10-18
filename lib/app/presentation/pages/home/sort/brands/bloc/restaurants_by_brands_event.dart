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

part of 'restaurants_by_brands_bloc.dart';

sealed class RestaurantsByBrandsEvent {}

final class RestaurantsByBrandsInitialEvent extends RestaurantsByBrandsEvent {
  final String id;
  final String slug;
  final String name;
  final String cover;
  final String city;
  RestaurantsByBrandsInitialEvent({required this.id, required this.slug, required this.name, required this.cover, required this.city});
}

final class RestaurantsByBrandsFavouriteEvent extends RestaurantsByBrandsEvent {
  final String id;
  final bool isFavourite;
  RestaurantsByBrandsFavouriteEvent({required this.id, required this.isFavourite});
}

final class RestaurantsByBrandsHideEvent extends RestaurantsByBrandsEvent {
  final String id;
  RestaurantsByBrandsHideEvent({required this.id});
}

final class RestaurantsByBrandsRemoveRestaurantEvent extends RestaurantsByBrandsEvent {
  final String id;
  RestaurantsByBrandsRemoveRestaurantEvent({required this.id});
}

final class RestaurantsByBrandsUndoHideActionEvent extends RestaurantsByBrandsEvent {
  final String id;
  RestaurantsByBrandsUndoHideActionEvent({required this.id});
}

