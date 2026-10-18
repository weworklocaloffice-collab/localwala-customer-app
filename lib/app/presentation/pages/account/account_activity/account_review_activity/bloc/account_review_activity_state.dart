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

part of 'account_review_activity_bloc.dart';

enum AccountReviewActivityStatus { loading, success, failure, empty }

extension AccountReviewActivityStatusX on AccountReviewActivityStatus {
  bool get isLoading => this == AccountReviewActivityStatus.loading;
  bool get isSuccess => this == AccountReviewActivityStatus.success;
  bool get isFailure => this == AccountReviewActivityStatus.failure;
  bool get isEmpty => this == AccountReviewActivityStatus.empty;
}

final class AccountReviewActivityState {
  final MyReviewListActivityModel model;
  final bool isFoodReviewOpen;
  final bool isRestaurantReviewOpen;
  final bool isDriverReviewOpen;
  final AccountReviewActivityStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountReviewActivityState({
    required this.model,
    this.isFoodReviewOpen = true,
    this.isRestaurantReviewOpen = true,
    this.isDriverReviewOpen = true,
    this.status = AccountReviewActivityStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountReviewActivityState copyWith({
    MyReviewListActivityModel? model,
    bool? isFoodReviewOpen,
    bool? isRestaurantReviewOpen,
    bool? isDriverReviewOpen,
    AccountReviewActivityStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountReviewActivityState(
      model: model ?? this.model,
      isFoodReviewOpen: isFoodReviewOpen ?? this.isFoodReviewOpen,
      isRestaurantReviewOpen: isRestaurantReviewOpen ?? this.isRestaurantReviewOpen,
      isDriverReviewOpen: isDriverReviewOpen ?? this.isDriverReviewOpen,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

