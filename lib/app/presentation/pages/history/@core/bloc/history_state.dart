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

part of 'history_bloc.dart';

enum HistoryStatus { loading, success, failure, empty, unAuthorized }

extension HistoryStatusX on HistoryStatus {
  bool get isLoading => this == HistoryStatus.loading;
  bool get isSuccess => this == HistoryStatus.success;
  bool get isFailure => this == HistoryStatus.failure;
  bool get isEmpty => this == HistoryStatus.empty;
  bool get isUnAuthorized => this == HistoryStatus.unAuthorized;
}

final class HistoryState {
  final MyOrderListResponseModel orderList;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final HistoryStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const HistoryState({required this.orderList, required this.pageSize, this.currentPage = 0, this.loadMore = false, this.status = HistoryStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  HistoryState copyWith({MyOrderListResponseModel? orderList, int? pageSize, int? currentPage, bool? loadMore, HistoryStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return HistoryState(
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

