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

part of 'food_subscription_transaction_list_bloc.dart';

enum FoodSubscriptionTransactionListStatus { loading, success, failure, empty, unAuthorized }

extension FoodSubscriptionTransactionListStatusX on FoodSubscriptionTransactionListStatus {
  bool get isLoading => this == FoodSubscriptionTransactionListStatus.loading;
  bool get isSuccess => this == FoodSubscriptionTransactionListStatus.success;
  bool get isFailure => this == FoodSubscriptionTransactionListStatus.failure;
  bool get isEmpty => this == FoodSubscriptionTransactionListStatus.empty;
  bool get isUnAuthorized => this == FoodSubscriptionTransactionListStatus.unAuthorized;
}

final class FoodSubscriptionTransactionListState {
  final UserFoodSubscriptionTransactionResponseModel model;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final FoodSubscriptionTransactionListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodSubscriptionTransactionListState({
    required this.model,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = FoodSubscriptionTransactionListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FoodSubscriptionTransactionListState copyWith({
    UserFoodSubscriptionTransactionResponseModel? model,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    FoodSubscriptionTransactionListStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FoodSubscriptionTransactionListState(
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

