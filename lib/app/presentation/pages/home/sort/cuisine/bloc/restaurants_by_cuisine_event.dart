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

part of 'restaurants_by_cuisine_bloc.dart';

sealed class RestaurantsByCuisineEvent {}

final class RestaurantsByCuisineInitialEvent extends RestaurantsByCuisineEvent {
  final String name;
  final String slug;
  final String city;
  RestaurantsByCuisineInitialEvent({required this.name, required this.slug, required this.city});
}

final class RestaurantsByCuisineFavouriteEvent extends RestaurantsByCuisineEvent {
  final String id;
  final bool isFavourite;
  RestaurantsByCuisineFavouriteEvent({required this.id, required this.isFavourite});
}

final class RestaurantsByCuisineLoadMoreEvent extends RestaurantsByCuisineEvent {}

final class RestaurantsByCuisineHideEvent extends RestaurantsByCuisineEvent {
  final String id;
  RestaurantsByCuisineHideEvent({required this.id});
}

final class RestaurantsByCuisineRemoveRestaurantEvent extends RestaurantsByCuisineEvent {
  final String id;
  RestaurantsByCuisineRemoveRestaurantEvent({required this.id});
}

final class RestaurantsByCuisineUndoHideActionEvent extends RestaurantsByCuisineEvent {
  final String id;
  RestaurantsByCuisineUndoHideActionEvent({required this.id});
}

