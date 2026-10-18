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

enum FoodSearchStatus { initial, empty, success, failure, initialCartUpdate, initialCartError, initialFoodFav, searchCartUpdate, searchCartError, searchFoodFav, cartError, customError }

extension FoodSearchStatusX on FoodSearchStatus {
  bool get isInitial => this == FoodSearchStatus.initial;
  bool get isSuccess => this == FoodSearchStatus.success;
  bool get isFailure => this == FoodSearchStatus.failure;
  bool get isEmpty => this == FoodSearchStatus.empty;
  bool get isInitialCartUpdate => this == FoodSearchStatus.initialCartUpdate;
  bool get isInitialCartError => this == FoodSearchStatus.initialCartError;
  bool get isInitialFoodFav => this == FoodSearchStatus.initialFoodFav;
  bool get isSearchCartUpdate => this == FoodSearchStatus.searchCartUpdate;
  bool get isSearchCartError => this == FoodSearchStatus.searchCartError;
  bool get isSearchFoodFav => this == FoodSearchStatus.searchFoodFav;
  bool get isCartError => this == FoodSearchStatus.cartError;
  bool get isCustomError => this == FoodSearchStatus.customError;
}

final class FoodSearchState {
  final FoodSearchInitialResponseModel initialData;
  final FoodSearchResultResponseModel response;
  final List<String> initialFavIds;
  final List<String> resultFavIds;
  final String uid;
  final String id;
  final String name;
  final String appLocale;
  final FoodSearchStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodSearchState({
    required this.initialData,
    required this.response,
    this.initialFavIds = const [],
    this.resultFavIds = const [],
    this.uid = '',
    this.id = '',
    this.name = '',
    this.appLocale = '',
    this.status = FoodSearchStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FoodSearchState copyWith({
    FoodSearchInitialResponseModel? initialData,
    FoodSearchResultResponseModel? response,
    List<String>? initialFavIds,
    List<String>? resultFavIds,
    String? uid,
    String? id,
    String? name,
    String? appLocale,
    FoodSearchStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FoodSearchState(
      initialData: initialData ?? this.initialData,
      response: response ?? this.response,
      initialFavIds: initialFavIds ?? this.initialFavIds,
      resultFavIds: resultFavIds ?? this.resultFavIds,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      name: name ?? this.name,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

