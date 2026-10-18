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

part of 'restaurants_review_bloc.dart';

enum RestaurantsReviewStatus { loading, empty, success, failure, customError }

extension RestaurantsReviewStatusX on RestaurantsReviewStatus {
  bool get isLoading => this == RestaurantsReviewStatus.loading;
  bool get isEmpty => this == RestaurantsReviewStatus.empty;
  bool get isSuccess => this == RestaurantsReviewStatus.success;
  bool get isFailure => this == RestaurantsReviewStatus.failure;
  bool get isCustomError => this == RestaurantsReviewStatus.customError;
}

final class RestaurantsReviewState {
  final String id;
  final String name;
  final String ratings;
  final RestaurantReviewsResponseModel detail;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final RestaurantsReviewStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantsReviewState({
    this.id = '',
    this.name = '',
    this.ratings = '0.0',
    required this.detail,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = RestaurantsReviewStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantsReviewState copyWith({
    String? id,
    String? name,
    String? ratings,
    RestaurantReviewsResponseModel? detail,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    RestaurantsReviewStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantsReviewState(
      id: id ?? this.id,
      name: name ?? this.name,
      ratings: ratings ?? this.ratings,
      detail: detail ?? this.detail,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

