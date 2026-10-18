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

part of 'restaurants_by_cuisine_bloc.dart';

enum RestaurantsByCuisineStatus { loading, success, failure, empty, customError, favUpdate, hidden, unhidden }

extension RestaurantsByCuisineStatusX on RestaurantsByCuisineStatus {
  bool get isLoading => this == RestaurantsByCuisineStatus.loading;
  bool get isSuccess => this == RestaurantsByCuisineStatus.success;
  bool get isFailure => this == RestaurantsByCuisineStatus.failure;
  bool get isEmpty => this == RestaurantsByCuisineStatus.empty;
  bool get isCustomError => this == RestaurantsByCuisineStatus.customError;
  bool get isFavUpdate => this == RestaurantsByCuisineStatus.favUpdate;
  bool get isHidden => this == RestaurantsByCuisineStatus.hidden;
  bool get isUnhidden => this == RestaurantsByCuisineStatus.unhidden;
}

final class RestaurantsByCuisineState {
  final RestaurantsByCuisineModel restaurants;
  final List<String> favIds;
  final String slug;
  final int pageSize;
  final int currentPage;
  final String hideUnhideId;
  final bool isAuthorized;
  final bool loadMore;
  final RestaurantsByCuisineStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantsByCuisineState({
    required this.restaurants,
    this.favIds = const [],
    this.slug = '',
    required this.pageSize,
    this.currentPage = 0,
    this.hideUnhideId = '',
    this.isAuthorized = false,
    this.loadMore = false,
    this.status = RestaurantsByCuisineStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantsByCuisineState copyWith({
    RestaurantsByCuisineModel? restaurants,
    List<String>? favIds,
    String? slug,
    int? pageSize,
    int? currentPage,
    String? hideUnhideId,
    bool? isAuthorized,
    bool? loadMore,
    RestaurantsByCuisineStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantsByCuisineState(
      restaurants: restaurants ?? this.restaurants,
      favIds: favIds ?? this.favIds,
      slug: slug ?? this.slug,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

