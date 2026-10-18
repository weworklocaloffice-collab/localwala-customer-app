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

part of 'food_search_bloc.dart';

sealed class FoodSearchEvent {}

final class FoodSearchInitialEvent extends FoodSearchEvent {
  final String id;
  final String name;
  FoodSearchInitialEvent({required this.id, required this.name});
}

final class FoodSearchFindResultEvent extends FoodSearchEvent {
  final String searchQuery;
  FoodSearchFindResultEvent({required this.searchQuery});
}

final class FoodSearchModalResponseEvent extends FoodSearchEvent {
  final String id;
  final String collection;
  final FoodInfoModalResponseModel response;
  FoodSearchModalResponseEvent({required this.id, required this.collection, required this.response});
}

final class FoodSearchVariationModalResponseEvent extends FoodSearchEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FoodSearchVariationModalResponseEvent({required this.id, required this.data});
}

final class FoodSearchAddCartEvent extends FoodSearchEvent {
  final String id;
  FoodSearchAddCartEvent({required this.id});
}

final class FoodSearchRepeatFoodOrderResponseEvent extends FoodSearchEvent {
  final String id;
  final RepeatQuantityModalResponseModel data;
  FoodSearchRepeatFoodOrderResponseEvent({required this.id, required this.data});
}

final class FoodSearchFoodQuantityDecreaseEvent extends FoodSearchEvent {
  final String id;
  FoodSearchFoodQuantityDecreaseEvent({required this.id});
}

final class FoodSearchFoodVariationModalRepeatResponseEvent extends FoodSearchEvent {
  final String id;
  FoodVariationModalResponseDataModel data;
  FoodSearchFoodVariationModalRepeatResponseEvent({required this.id, required this.data});
}

final class FoodSearchFoodQuantityIncreaseEvent extends FoodSearchEvent {
  final String id;
  FoodSearchFoodQuantityIncreaseEvent({required this.id});
}

final class FoodSearchExecuteEvent extends FoodSearchEvent {
  final String query;
  FoodSearchExecuteEvent({required this.query});
}

