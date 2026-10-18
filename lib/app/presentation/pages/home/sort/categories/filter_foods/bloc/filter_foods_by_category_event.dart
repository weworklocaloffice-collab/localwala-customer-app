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

part of 'filter_foods_by_category_bloc.dart';

sealed class FilterFoodsByCategoryEvent {}

final class FilterFoodsByCategoryInitialEvent extends FilterFoodsByCategoryEvent {
  final String name;
  final String slug;
  final String city;
  FilterFoodsByCategoryInitialEvent({required this.name, required this.slug, required this.city});
}

final class FilterFoodsByCategoryFavouriteEvent extends FilterFoodsByCategoryEvent {
  final String id;
  final bool isFavourite;
  FilterFoodsByCategoryFavouriteEvent({required this.id, required this.isFavourite});
}

final class FilterFoodsByCategoryLoadMoreEvent extends FilterFoodsByCategoryEvent {}

final class FilterFoodsVariationModalResponseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FilterFoodsVariationModalResponseEvent({required this.id, required this.data});
}

final class FilterFoodsFoodQuantityDecreaseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  FilterFoodsFoodQuantityDecreaseEvent({required this.id});
}

final class FilterFoodsFoodQuantityIncreaseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  FilterFoodsFoodQuantityIncreaseEvent({required this.id});
}

final class FilterFoodsAddCartEvent extends FilterFoodsByCategoryEvent {
  final String id;
  FilterFoodsAddCartEvent({required this.id});
}

final class FilterFoodsRepeatFoodOrderResponseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  final RepeatQuantityModalResponseModel data;
  FilterFoodsRepeatFoodOrderResponseEvent({required this.id, required this.data});
}

final class FilterFoodsFoodVariationModalRepeatResponseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FilterFoodsFoodVariationModalRepeatResponseEvent({required this.id, required this.data});
}

final class FilterFoodsFoodModalResponseEvent extends FilterFoodsByCategoryEvent {
  final String id;
  final FoodInfoModalResponseModel response;
  FilterFoodsFoodModalResponseEvent({required this.id, required this.response});
}

