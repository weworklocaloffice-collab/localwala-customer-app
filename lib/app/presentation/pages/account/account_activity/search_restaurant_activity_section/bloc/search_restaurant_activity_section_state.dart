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

part of 'search_restaurant_activity_section_bloc.dart';

enum SearchRestaurantActivitySectionStatus { initial, empty, success, failure }

extension SearchRestaurantActivitySectionStatusX on SearchRestaurantActivitySectionStatus {
  bool get isInitial => this == SearchRestaurantActivitySectionStatus.initial;
  bool get isSuccess => this == SearchRestaurantActivitySectionStatus.success;
  bool get isFailure => this == SearchRestaurantActivitySectionStatus.failure;
  bool get isEmpty => this == SearchRestaurantActivitySectionStatus.empty;
}

final class SearchRestaurantActivitySectionState {
  final SearchRestaurantForReviewResponseModel model;
  final SearchRestaurantActivitySectionStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SearchRestaurantActivitySectionState({required this.model, this.status = SearchRestaurantActivitySectionStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  SearchRestaurantActivitySectionState copyWith({SearchRestaurantForReviewResponseModel? model, SearchRestaurantActivitySectionStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return SearchRestaurantActivitySectionState(
      model: model ?? this.model,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

