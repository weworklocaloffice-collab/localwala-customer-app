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

enum FilterRestaurantsByCategoriesStatus { loading, success, failure, empty, customError, favUpdate, hidden, unhidden }

extension FilterRestaurantsByCategoriesStatusX on FilterRestaurantsByCategoriesStatus {
  bool get isLoading => this == FilterRestaurantsByCategoriesStatus.loading;
  bool get isSuccess => this == FilterRestaurantsByCategoriesStatus.success;
  bool get isFailure => this == FilterRestaurantsByCategoriesStatus.failure;
  bool get isEmpty => this == FilterRestaurantsByCategoriesStatus.empty;
  bool get isCustomError => this == FilterRestaurantsByCategoriesStatus.customError;
  bool get isFavUpdate => this == FilterRestaurantsByCategoriesStatus.favUpdate;
  bool get isHidden => this == FilterRestaurantsByCategoriesStatus.hidden;
  bool get isUnhidden => this == FilterRestaurantsByCategoriesStatus.unhidden;
}

final class FilterRestaurantsByCategoriesState {
  final RestaurantsByCategoryModel restaurants;
  final List<String> favIds;
  final String hideUnhideId;
  final String slug;
  final int pageSize;
  final int currentPage;
  final bool isAuthorized;
  final bool loadMore;
  final FilterRestaurantsByCategoriesStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FilterRestaurantsByCategoriesState({
    required this.restaurants,
    this.favIds = const [],
    this.hideUnhideId = '',
    this.slug = '',
    required this.pageSize,
    this.currentPage = 0,
    this.isAuthorized = false,
    this.loadMore = false,
    this.status = FilterRestaurantsByCategoriesStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FilterRestaurantsByCategoriesState copyWith({
    RestaurantsByCategoryModel? restaurants,
    List<String>? favIds,
    String? hideUnhideId,
    String? slug,
    int? pageSize,
    int? currentPage,
    bool? isAuthorized,
    bool? loadMore,
    FilterRestaurantsByCategoriesStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FilterRestaurantsByCategoriesState(
      restaurants: restaurants ?? this.restaurants,
      favIds: favIds ?? this.favIds,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      slug: slug ?? this.slug,
      pageSize: pageSize ?? this.pageSize,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      loadMore: loadMore ?? this.loadMore,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

