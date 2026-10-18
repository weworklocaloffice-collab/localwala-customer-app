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

part of 'home_bloc.dart';

sealed class HomeEvent {}

final class HomeInitialEvent extends HomeEvent {}

final class HomeLoadMoreEvent extends HomeEvent {}

final class HomeFavouriteEvent extends HomeEvent {
  final String type;
  final String id;
  final String collection;
  final bool isFavourite;
  HomeFavouriteEvent({required this.type, required this.id, required this.collection, required this.isFavourite});
}

final class HomeHideRestaurantEvent extends HomeEvent {
  final String id;
  HomeHideRestaurantEvent({required this.id});
}

final class HomeRemoveRestaurantFromListEvent extends HomeEvent {
  final String id;
  HomeRemoveRestaurantFromListEvent({required this.id});
}

final class HomeUndoHideActionEvent extends HomeEvent {
  final String id;
  HomeUndoHideActionEvent({required this.id});
}

final class HomeFoodVariationModalResponseEvent extends HomeEvent {
  final String id;
  final String collection;
  final FoodVariationModalResponseDataModel data;
  HomeFoodVariationModalResponseEvent({required this.id, required this.collection, required this.data});
}

final class HomeFoodQuantityDecreaseEvent extends HomeEvent {
  final String id;
  final String collection;
  HomeFoodQuantityDecreaseEvent({required this.id, required this.collection});
}

final class HomeFoodQuantityIncreaseEvent extends HomeEvent {
  final String id;
  final String collection;
  HomeFoodQuantityIncreaseEvent({required this.id, required this.collection});
}

final class HomeAddCartEvent extends HomeEvent {
  final String id;
  final String collection;
  HomeAddCartEvent({required this.id, required this.collection});
}

final class HomeRepeatFoodOrderResponseEvent extends HomeEvent {
  final String id;
  final String collection;
  final RepeatQuantityModalResponseModel data;
  HomeRepeatFoodOrderResponseEvent({required this.id, required this.collection, required this.data});
}

final class HomeFoodVariationModalRepeatResponseEvent extends HomeEvent {
  final String id;
  final String collection;
  final FoodVariationModalResponseDataModel data;
  HomeFoodVariationModalRepeatResponseEvent({required this.id, required this.collection, required this.data});
}

final class HomeRefreshCartEvent extends HomeEvent {}

final class HomeRefreshFoodFavEvent extends HomeEvent {
  final List<String> inFavList;
  HomeRefreshFoodFavEvent({required this.inFavList});
}

final class HomeRefreshRestaurantFavEvent extends HomeEvent {
  final List<String> inFavList;
  HomeRefreshRestaurantFavEvent({required this.inFavList});
}

final class HomeFoodModalResponseEvent extends HomeEvent {
  final String id;
  final String collection;
  final FoodInfoModalResponseModel response;
  HomeFoodModalResponseEvent({required this.id, required this.collection, required this.response});
}

final class HomeSilentHideEvent extends HomeEvent {
  final String id;
  HomeSilentHideEvent({required this.id});
}

final class HomeSilentUnHideEvent extends HomeEvent {
  final String id;
  HomeSilentUnHideEvent({required this.id});
}

final class HomeSilentNotificationEvent extends HomeEvent {}

final class HomeNotificationListClickEvent extends HomeEvent {}

final class HomePullRefreshEvent extends HomeEvent {}
