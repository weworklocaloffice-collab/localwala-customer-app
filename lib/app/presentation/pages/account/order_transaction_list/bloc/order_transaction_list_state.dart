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

part of 'order_transaction_list_bloc.dart';

enum OrderTransactionListStatus { loading, success, failure, empty, unAuthorized }

extension OrderTransactionListStatusX on OrderTransactionListStatus {
  bool get isLoading => this == OrderTransactionListStatus.loading;
  bool get isSuccess => this == OrderTransactionListStatus.success;
  bool get isFailure => this == OrderTransactionListStatus.failure;
  bool get isEmpty => this == OrderTransactionListStatus.empty;
  bool get isUnAuthorized => this == OrderTransactionListStatus.unAuthorized;
}

final class OrderTransactionListState {
  final UserOrderTransactionResponseModel model;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final OrderTransactionListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const OrderTransactionListState({
    required this.model,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = OrderTransactionListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  OrderTransactionListState copyWith({UserOrderTransactionResponseModel? model, int? pageSize, int? currentPage, bool? loadMore, OrderTransactionListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return OrderTransactionListState(
      model: model ?? this.model,
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

