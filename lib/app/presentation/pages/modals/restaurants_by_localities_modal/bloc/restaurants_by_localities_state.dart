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

part of 'restaurants_by_localities_bloc.dart';

enum RestaurantsByLocalitiesStatus { loading, success, failure, empty, customError, favUpdate, hidden, unhidden }

extension RestaurantsByLocalitiesStatusX on RestaurantsByLocalitiesStatus {
  bool get isLoading => this == RestaurantsByLocalitiesStatus.loading;
  bool get isSuccess => this == RestaurantsByLocalitiesStatus.success;
  bool get isFailure => this == RestaurantsByLocalitiesStatus.failure;
  bool get isEmpty => this == RestaurantsByLocalitiesStatus.empty;
  bool get isCustomError => this == RestaurantsByLocalitiesStatus.customError;
  bool get isFavUpdate => this == RestaurantsByLocalitiesStatus.favUpdate;
  bool get isHidden => this == RestaurantsByLocalitiesStatus.hidden;
  bool get isUnhidden => this == RestaurantsByLocalitiesStatus.unhidden;
}

final class RestaurantsByLocalitiesState {
  final RestaurantsByLocalitiesModel restaurants;
  final List<String> favIds;
  final String name;
  final String slug;
  final String from;
  final int pageSize;
  final int currentPage;
  final String hideUnhideId;
  final bool isAuthorized;
  final bool loadMore;
  final RestaurantsByLocalitiesStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantsByLocalitiesState({
    required this.restaurants,
    this.favIds = const [],
    this.name = '',
    this.slug = '',
    this.from = '',
    required this.pageSize,
    this.currentPage = 0,
    this.hideUnhideId = '',
    this.isAuthorized = false,
    this.loadMore = false,
    this.status = RestaurantsByLocalitiesStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantsByLocalitiesState copyWith({
    RestaurantsByLocalitiesModel? restaurants,
    List<String>? favIds,
    String? name,
    String? slug,
    String? from,
    int? pageSize,
    int? currentPage,
    String? hideUnhideId,
    bool? isAuthorized,
    bool? loadMore,
    RestaurantsByLocalitiesStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantsByLocalitiesState(
      restaurants: restaurants ?? this.restaurants,
      favIds: favIds ?? this.favIds,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      from: from ?? this.from,
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

