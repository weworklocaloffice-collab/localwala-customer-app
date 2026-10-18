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

part of 'dining_bloc.dart';

enum DiningStatus { loading, empty, success, failure, customError, restaurantFav, hidden, unhidden }

extension DiningStatusX on DiningStatus {
  bool get isLoading => this == DiningStatus.loading;
  bool get isEmpty => this == DiningStatus.empty;
  bool get isSuccess => this == DiningStatus.success;
  bool get isFailure => this == DiningStatus.failure;
  bool get isCustomError => this == DiningStatus.customError;
  bool get isRestaurantFav => this == DiningStatus.restaurantFav;
  bool get isHidden => this == DiningStatus.hidden;
  bool get isUnhidden => this == DiningStatus.unhidden;
}

final class DiningState {
  final DiningResponseModel model;
  final String addressTitle;
  final String addressSubTitle;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final bool isAuthorized;
  final String locale;
  final List<String> favIds;
  final String hideUnhideId;
  final DiningStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningState({
    required this.model,
    this.addressTitle = '0',
    this.addressSubTitle = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.isAuthorized = false,
    this.locale = '',
    this.favIds = const [],
    this.hideUnhideId = '',
    this.status = DiningStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningState copyWith({
    DiningResponseModel? model,
    String? addressTitle,
    String? addressSubTitle,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    bool? isAuthorized,
    String? locale,
    List<String>? favIds,
    String? hideUnhideId,
    DiningStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningState(
      model: model ?? this.model,
      addressTitle: addressTitle ?? this.addressTitle,
      addressSubTitle: addressSubTitle ?? this.addressSubTitle,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      locale: locale ?? this.locale,
      favIds: favIds ?? this.favIds,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

