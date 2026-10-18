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

part of 'account_history_list_bloc.dart';

enum AccountHistoryListStatus { loading, success, failure, empty, unAuthorized }

extension AccountHistoryListStatusX on AccountHistoryListStatus {
  bool get isLoading => this == AccountHistoryListStatus.loading;
  bool get isSuccess => this == AccountHistoryListStatus.success;
  bool get isFailure => this == AccountHistoryListStatus.failure;
  bool get isEmpty => this == AccountHistoryListStatus.empty;
  bool get isUnAuthorized => this == AccountHistoryListStatus.unAuthorized;
}

final class AccountHistoryListState {
  final MyOrderListResponseModel orderList;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final AccountHistoryListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountHistoryListState({
    required this.orderList,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = AccountHistoryListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountHistoryListState copyWith({MyOrderListResponseModel? orderList, int? pageSize, int? currentPage, bool? loadMore, AccountHistoryListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AccountHistoryListState(
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

