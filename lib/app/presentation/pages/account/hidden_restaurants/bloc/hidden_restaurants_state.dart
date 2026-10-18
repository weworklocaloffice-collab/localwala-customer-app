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

part of 'hidden_restaurants_bloc.dart';

enum HiddenRestaurantsStatus { loading, success, failure, empty, customError, unAuthorized }

extension HiddenRestaurantsStatusX on HiddenRestaurantsStatus {
  bool get isLoading => this == HiddenRestaurantsStatus.loading;
  bool get isSuccess => this == HiddenRestaurantsStatus.success;
  bool get isFailure => this == HiddenRestaurantsStatus.failure;
  bool get isEmpty => this == HiddenRestaurantsStatus.empty;
  bool get isCustomError => this == HiddenRestaurantsStatus.customError;
  bool get isUnAuthorized => this == HiddenRestaurantsStatus.unAuthorized;
}

final class HiddenRestaurantsState {
  final HiddenRestaurantListModel list;
  final HiddenRestaurantsStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const HiddenRestaurantsState({required this.list, this.status = HiddenRestaurantsStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  HiddenRestaurantsState copyWith({HiddenRestaurantListModel? list, HiddenRestaurantsStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return HiddenRestaurantsState(
      list: list ?? this.list,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

