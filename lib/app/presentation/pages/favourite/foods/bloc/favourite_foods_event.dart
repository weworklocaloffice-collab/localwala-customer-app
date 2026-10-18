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

part of 'favourite_foods_bloc.dart';

sealed class FavouriteFoodsEvent {}

final class FavouriteFoodsInitialEvent extends FavouriteFoodsEvent {}

final class FavouriteFoodsLoadMoreEvent extends FavouriteFoodsEvent {}

final class FavouriteFoodsDeleteFoodEvent extends FavouriteFoodsEvent {
  final String foodId;
  FavouriteFoodsDeleteFoodEvent({required this.foodId});
}

final class FavouriteFoodsVariationModalResponseEvent extends FavouriteFoodsEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FavouriteFoodsVariationModalResponseEvent({required this.id, required this.data});
}

final class FavouriteFoodsFoodQuantityDecreaseEvent extends FavouriteFoodsEvent {
  final String id;
  FavouriteFoodsFoodQuantityDecreaseEvent({required this.id});
}

final class FavouriteFoodsFoodQuantityIncreaseEvent extends FavouriteFoodsEvent {
  final String id;
  FavouriteFoodsFoodQuantityIncreaseEvent({required this.id});
}

final class FavouriteFoodsAddCartEvent extends FavouriteFoodsEvent {
  final String id;
  FavouriteFoodsAddCartEvent({required this.id});
}

final class FavouriteFoodsRepeatFoodOrderResponseEvent extends FavouriteFoodsEvent {
  final String id;
  final RepeatQuantityModalResponseModel data;
  FavouriteFoodsRepeatFoodOrderResponseEvent({required this.id, required this.data});
}

final class FavouriteFoodsFoodVariationModalRepeatResponseEvent extends FavouriteFoodsEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FavouriteFoodsFoodVariationModalRepeatResponseEvent({required this.id, required this.data});
}

final class FavouriteFoodsRefreshCartEvent extends FavouriteFoodsEvent {}

final class FavouriteFoodsSilenceEvent extends FavouriteFoodsEvent {}

final class FavouriteFoodModalResponseEvent extends FavouriteFoodsEvent {
  final String id;
  final FoodInfoModalResponseModel response;
  FavouriteFoodModalResponseEvent({required this.id, required this.response});
}

