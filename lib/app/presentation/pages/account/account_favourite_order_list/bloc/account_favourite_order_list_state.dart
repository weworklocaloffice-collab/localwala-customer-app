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

part of 'account_favourite_order_list_bloc.dart';

enum AccountFavouriteOrderListStatus { loading, success, failure, empty, unAuthorized }

extension AccountFavouriteOrderListStatusX on AccountFavouriteOrderListStatus {
  bool get isLoading => this == AccountFavouriteOrderListStatus.loading;
  bool get isSuccess => this == AccountFavouriteOrderListStatus.success;
  bool get isFailure => this == AccountFavouriteOrderListStatus.failure;
  bool get isEmpty => this == AccountFavouriteOrderListStatus.empty;
  bool get isUnAuthorized => this == AccountFavouriteOrderListStatus.unAuthorized;
}

final class AccountFavouriteOrderListState {
  final MyFavouriteOrderListResponseModel orderList;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final AccountFavouriteOrderListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountFavouriteOrderListState({
    required this.orderList,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = AccountFavouriteOrderListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountFavouriteOrderListState copyWith({
    MyFavouriteOrderListResponseModel? orderList,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    AccountFavouriteOrderListStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountFavouriteOrderListState(
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

