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

part of 'favourite_restaurants_bloc.dart';

sealed class FavouriteRestaurantsEvent {}

final class FavouriteRestaurantsInitialEvent extends FavouriteRestaurantsEvent {}

final class FavouriteRestaurantsLoadMoreEvent extends FavouriteRestaurantsEvent {}

final class FavouriteDeleteRestaurantEvent extends FavouriteRestaurantsEvent {
  final String restaurantId;
  FavouriteDeleteRestaurantEvent({required this.restaurantId});
}

final class FavouriteRestaurantsSilenceEvent extends FavouriteRestaurantsEvent {}

