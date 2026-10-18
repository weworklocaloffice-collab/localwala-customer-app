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

part of 'restaurant_detail_info_bloc.dart';

enum RestaurantDetailInfoStatus { loading, success, failure, customError, favAdd, favRemove, callRequested }

extension RestaurantDetailInfoStatusX on RestaurantDetailInfoStatus {
  bool get isLoading => this == RestaurantDetailInfoStatus.loading;
  bool get isSuccess => this == RestaurantDetailInfoStatus.success;
  bool get isFailure => this == RestaurantDetailInfoStatus.failure;
  bool get isCustomError => this == RestaurantDetailInfoStatus.customError;
  bool get isFavAdd => this == RestaurantDetailInfoStatus.favAdd;
  bool get isFavRemove => this == RestaurantDetailInfoStatus.favRemove;
  bool get isCallRequested => this == RestaurantDetailInfoStatus.callRequested;
}

const List<String> daysList = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

final class RestaurantDetailInfoState {
  final RestaurantDetailInformationResponseModel model;
  final List<String> daysName;
  final bool isAuthorized;
  final String slug;
  final String name;
  final RestaurantDetailInfoStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantDetailInfoState({
    required this.model,
    this.daysName = daysList,
    this.isAuthorized = false,
    this.slug = '',
    this.name = '',
    this.status = RestaurantDetailInfoStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantDetailInfoState copyWith({
    RestaurantDetailInformationResponseModel? model,
    bool? isAuthorized,
    String? slug,
    String? name,
    RestaurantDetailInfoStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantDetailInfoState(
      model: model ?? this.model,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

