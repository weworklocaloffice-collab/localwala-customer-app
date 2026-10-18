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

part of 'restaurant_tiffin_subscription_packages_bloc.dart';

enum RestaurantTiffinSubscriptionPackagesStatus { loading, success, failure, empty }

extension RestaurantTiffinSubscriptionPackagesStatusX on RestaurantTiffinSubscriptionPackagesStatus {
  bool get isLoading => this == RestaurantTiffinSubscriptionPackagesStatus.loading;
  bool get isSuccess => this == RestaurantTiffinSubscriptionPackagesStatus.success;
  bool get isFailure => this == RestaurantTiffinSubscriptionPackagesStatus.failure;
  bool get isEmpty => this == RestaurantTiffinSubscriptionPackagesStatus.empty;
}

final class RestaurantTiffinSubscriptionPackagesState {
  final String restaurant;
  final String restaurantName;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final TiffinSubscriptionFromListRestaurantResponseModel list;
  final RestaurantTiffinSubscriptionPackagesStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantTiffinSubscriptionPackagesState({
    this.restaurant = '',
    this.restaurantName = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    required this.list,
    this.status = RestaurantTiffinSubscriptionPackagesStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantTiffinSubscriptionPackagesState copyWith({
    String? restaurant,
    String? restaurantName,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    TiffinSubscriptionFromListRestaurantResponseModel? list,
    RestaurantTiffinSubscriptionPackagesStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantTiffinSubscriptionPackagesState(
      restaurant: restaurant ?? this.restaurant,
      restaurantName: restaurantName ?? this.restaurantName,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      list: list ?? this.list,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

