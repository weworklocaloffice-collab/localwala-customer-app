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

part of 'notification_list_bloc.dart';

enum NotificationListStatus { loading, success, empty, failure, customError }

extension NotificationListStatusX on NotificationListStatus {
  bool get isLoading => this == NotificationListStatus.loading;
  bool get isSuccess => this == NotificationListStatus.success;
  bool get isEmpty => this == NotificationListStatus.empty;
  bool get isFailure => this == NotificationListStatus.failure;
  bool get isCustomError => this == NotificationListStatus.customError;
}

final class NotificationListState {
  final NotificationListResponseModel response;
  final String user;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final NotificationListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const NotificationListState({
    required this.response,
    this.user = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = NotificationListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  NotificationListState copyWith({
    NotificationListResponseModel? response,
    String? user,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    NotificationListStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return NotificationListState(
      response: response ?? this.response,
      user: user ?? this.user,
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

