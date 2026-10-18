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

part of 'restaurants_by_localities_bloc.dart';

sealed class RestaurantsByLocalitiesEvent {}

final class RestaurantsByLocalitiesInitialEvent extends RestaurantsByLocalitiesEvent {
  final String from;
  final String slug;
  final String name;
  RestaurantsByLocalitiesInitialEvent({required this.from, required this.slug, required this.name});
}

final class RestaurantsByLocalitiesLoadMoreEvent extends RestaurantsByLocalitiesEvent {}

final class RestaurantsByLocalitiesFavouriteEvent extends RestaurantsByLocalitiesEvent {
  final String id;
  final bool isFavourite;
  RestaurantsByLocalitiesFavouriteEvent({required this.id, required this.isFavourite});
}

final class RestaurantsByLocalitiesHideEvent extends RestaurantsByLocalitiesEvent {
  final String id;
  RestaurantsByLocalitiesHideEvent({required this.id});
}

final class RestaurantsByLocalitiesRemoveRestaurantEvent extends RestaurantsByLocalitiesEvent {
  final String id;
  RestaurantsByLocalitiesRemoveRestaurantEvent({required this.id});
}

final class RestaurantsByLocalitiesUndoHideActionEvent extends RestaurantsByLocalitiesEvent {
  final String id;
  RestaurantsByLocalitiesUndoHideActionEvent({required this.id});
}

