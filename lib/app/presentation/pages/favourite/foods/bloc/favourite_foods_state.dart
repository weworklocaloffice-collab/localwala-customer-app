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

part of 'favourite_foods_bloc.dart';

enum FavouriteFoodsStatus { loading, success, failure, unAuthorized, empty, removeFavStart, removeFavDone, removeFavFailed, customError, cartUpdate, cartError, removeSilence }

extension FavouriteFoodsStatusX on FavouriteFoodsStatus {
  bool get isLoading => this == FavouriteFoodsStatus.loading;
  bool get isSuccess => this == FavouriteFoodsStatus.success;
  bool get isFailure => this == FavouriteFoodsStatus.failure;
  bool get isUnAuthorized => this == FavouriteFoodsStatus.unAuthorized;
  bool get isEmpty => this == FavouriteFoodsStatus.empty;
  bool get isRemoveFavStart => this == FavouriteFoodsStatus.removeFavStart;
  bool get isRemoveFavDone => this == FavouriteFoodsStatus.removeFavDone;
  bool get isRemoveFailed => this == FavouriteFoodsStatus.removeFavFailed;
  bool get isCustomError => this == FavouriteFoodsStatus.customError;
  bool get isCartUpdate => this == FavouriteFoodsStatus.cartUpdate;
  bool get isCartError => this == FavouriteFoodsStatus.cartError;
  bool get isRemoveSilence => this == FavouriteFoodsStatus.removeSilence;
}

final class FavouriteFoodsState {
  final FavouriteFoodListModel foods;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final String appLocale;
  final FavouriteFoodsStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FavouriteFoodsState({
    required this.foods,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.appLocale = '',
    this.status = FavouriteFoodsStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FavouriteFoodsState copyWith({FavouriteFoodListModel? foods, int? pageSize, int? currentPage, bool? loadMore, String? appLocale, FavouriteFoodsStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FavouriteFoodsState(
      foods: foods ?? this.foods,
      pageSize: pageSize ?? this.pageSize,
      loadMore: loadMore ?? this.loadMore,
      appLocale: appLocale ?? this.appLocale,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

