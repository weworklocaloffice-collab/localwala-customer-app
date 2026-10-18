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

part of 'filter_restaurants_by_categories_bloc.dart';

sealed class FilterRestaurantsByCategoriesEvent {}

final class FilterRestaurantsByCategoriesInitialEvent extends FilterRestaurantsByCategoriesEvent {
  final String name;
  final String slug;
  final String city;
  FilterRestaurantsByCategoriesInitialEvent({required this.name, required this.slug, required this.city});
}

final class FilterRestaurantsByCategoriesFavouriteEvent extends FilterRestaurantsByCategoriesEvent {
  final String id;
  final bool isFavourite;
  FilterRestaurantsByCategoriesFavouriteEvent({required this.id, required this.isFavourite});
}

final class FilterRestaurantsByCategoriesLoadMoreEvent extends FilterRestaurantsByCategoriesEvent {}

final class FilterRestaurantsByCategoriesHideEvent extends FilterRestaurantsByCategoriesEvent {
  final String id;
  FilterRestaurantsByCategoriesHideEvent({required this.id});
}

final class FilterRestaurantsByCategoriesRemoveRestaurantEvent extends FilterRestaurantsByCategoriesEvent {
  final String id;
  FilterRestaurantsByCategoriesRemoveRestaurantEvent({required this.id});
}

final class FilterRestaurantsByCategoriesUndoHideActionEvent extends FilterRestaurantsByCategoriesEvent {
  final String id;
  FilterRestaurantsByCategoriesUndoHideActionEvent({required this.id});
}

