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

enum FavouriteRestaurantsStatus { loading, success, failure, unAuthorized, empty, removeFavStart, removeFavDone, removeFavFailed }

extension FavouriteRestaurantsStatusX on FavouriteRestaurantsStatus {
  bool get isLoading => this == FavouriteRestaurantsStatus.loading;
  bool get isSuccess => this == FavouriteRestaurantsStatus.success;
  bool get isFailure => this == FavouriteRestaurantsStatus.failure;
  bool get isUnAuthorized => this == FavouriteRestaurantsStatus.unAuthorized;
  bool get isEmpty => this == FavouriteRestaurantsStatus.empty;
  bool get isRemoveFavStart => this == FavouriteRestaurantsStatus.removeFavStart;
  bool get isRemoveFavDone => this == FavouriteRestaurantsStatus.removeFavDone;
  bool get isRemoveFavFailed => this == FavouriteRestaurantsStatus.removeFavFailed;
}

final class FavouriteRestaurantsState {
  final FavouriteRestaurantModal restaurants;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final FavouriteRestaurantsStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FavouriteRestaurantsState({
    required this.restaurants,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = FavouriteRestaurantsStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FavouriteRestaurantsState copyWith({FavouriteRestaurantModal? restaurants, int? pageSize, int? currentPage, bool? loadMore, FavouriteRestaurantsStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FavouriteRestaurantsState(
      restaurants: restaurants ?? this.restaurants,
      pageSize: pageSize ?? this.pageSize,
      loadMore: loadMore ?? this.loadMore,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

