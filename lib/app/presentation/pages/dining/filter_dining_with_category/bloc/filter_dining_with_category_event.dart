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

part of 'filter_dining_with_category_bloc.dart';

sealed class FilterDiningWithCategoryEvent {}

final class FilterDiningWithCategoryInitialEvent extends FilterDiningWithCategoryEvent {
  final String name;
  final String slug;
  final String city;
  FilterDiningWithCategoryInitialEvent({required this.name, required this.slug, required this.city});
}

final class FilterDiningWithCategoryLoadMoreEvent extends FilterDiningWithCategoryEvent {}

final class FilterDiningWithCategoryFavouriteEvent extends FilterDiningWithCategoryEvent {
  final String id;
  final bool isFavourite;
  FilterDiningWithCategoryFavouriteEvent({required this.id, required this.isFavourite});
}

final class FilterDiningWithCategoryHideEvent extends FilterDiningWithCategoryEvent {
  final String id;
  FilterDiningWithCategoryHideEvent({required this.id});
}

final class FilterDiningWithCategoryRemoveRestaurantEvent extends FilterDiningWithCategoryEvent {
  final String id;
  FilterDiningWithCategoryRemoveRestaurantEvent({required this.id});
}

final class FilterDiningWithCategoryUndoHideActionEvent extends FilterDiningWithCategoryEvent {
  final String id;
  FilterDiningWithCategoryUndoHideActionEvent({required this.id});
}

