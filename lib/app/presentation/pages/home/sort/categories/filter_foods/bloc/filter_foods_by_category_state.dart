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

enum FilterFoodsByCategoryStatus { loading, success, failure, empty, customError, cartUpdate, cartError, favUpdate }

extension FilterFoodsByCategoryStatusX on FilterFoodsByCategoryStatus {
  bool get isLoading => this == FilterFoodsByCategoryStatus.loading;
  bool get isSuccess => this == FilterFoodsByCategoryStatus.success;
  bool get isFailure => this == FilterFoodsByCategoryStatus.failure;
  bool get isEmpty => this == FilterFoodsByCategoryStatus.empty;
  bool get isCustomError => this == FilterFoodsByCategoryStatus.customError;
  bool get isCartUpdate => this == FilterFoodsByCategoryStatus.cartUpdate;
  bool get isCartError => this == FilterFoodsByCategoryStatus.cartError;
  bool get isFavUpdate => this == FilterFoodsByCategoryStatus.favUpdate;
}

final class FilterFoodsByCategoryState {
  final RestaurantFoodsByCategoryModel foods;
  final List<String> favIds;
  final String slug;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final String appLocale;
  final FilterFoodsByCategoryStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FilterFoodsByCategoryState({
    required this.foods,
    this.favIds = const [],
    this.slug = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.appLocale = '',
    this.status = FilterFoodsByCategoryStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FilterFoodsByCategoryState copyWith({
    RestaurantFoodsByCategoryModel? foods,
    List<String>? favIds,
    String? slug,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    String? appLocale,
    FilterFoodsByCategoryStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FilterFoodsByCategoryState(
      foods: foods ?? this.foods,
      favIds: favIds ?? this.favIds,
      slug: slug ?? this.slug,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

