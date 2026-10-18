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

part of 'favourite_orders_bloc.dart';

enum FavouriteOrdersStatus { loading, success, failure, empty, unAuthorized }

extension FavouriteOrdersStatusX on FavouriteOrdersStatus {
  bool get isLoading => this == FavouriteOrdersStatus.loading;
  bool get isSuccess => this == FavouriteOrdersStatus.success;
  bool get isFailure => this == FavouriteOrdersStatus.failure;
  bool get isEmpty => this == FavouriteOrdersStatus.empty;
  bool get isUnAuthorized => this == FavouriteOrdersStatus.unAuthorized;
}

final class FavouriteOrdersState {
  final MyFavouriteOrderListResponseModel orderList;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final FavouriteOrdersStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FavouriteOrdersState({
    required this.orderList,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = FavouriteOrdersStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FavouriteOrdersState copyWith({MyFavouriteOrderListResponseModel? orderList, int? pageSize, int? currentPage, bool? loadMore, FavouriteOrdersStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FavouriteOrdersState(
      orderList: orderList ?? this.orderList,
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

