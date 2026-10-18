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

part of 'restaurants_by_brands_bloc.dart';

enum RestaurantsByBrandsStatus { loading, success, failure, empty, customError, favUpdate, hidden, unhidden }

extension RestaurantsByBrandsStatusX on RestaurantsByBrandsStatus {
  bool get isLoading => this == RestaurantsByBrandsStatus.loading;
  bool get isSuccess => this == RestaurantsByBrandsStatus.success;
  bool get isFailure => this == RestaurantsByBrandsStatus.failure;
  bool get isEmpty => this == RestaurantsByBrandsStatus.empty;
  bool get isCustomError => this == RestaurantsByBrandsStatus.customError;
  bool get isFavUpdate => this == RestaurantsByBrandsStatus.favUpdate;
  bool get isHidden => this == RestaurantsByBrandsStatus.hidden;
  bool get isUnhidden => this == RestaurantsByBrandsStatus.unhidden;
}

final class RestaurantsByBrandsState {
  final RestaurantsByBrandsModel restaurants;
  final List<String> favIds;
  final String hideUnhideId;
  final bool isAuthorized;
  final RestaurantsByBrandsStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantsByBrandsState({
    required this.restaurants,
    this.favIds = const [],
    this.hideUnhideId = '',
    this.isAuthorized = false,
    this.status = RestaurantsByBrandsStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantsByBrandsState copyWith({
    RestaurantsByBrandsModel? restaurants,
    List<String>? favIds,
    String? hideUnhideId,
    bool? isAuthorized,
    RestaurantsByBrandsStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantsByBrandsState(
      restaurants: restaurants ?? this.restaurants,
      favIds: favIds ?? this.favIds,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

