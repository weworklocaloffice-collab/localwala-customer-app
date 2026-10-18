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

part of 'food_subscriptions_info_bloc.dart';

enum FoodSubscriptionsInfoStatus { loading, success, failure }

extension FoodSubscriptionsInfoStatusX on FoodSubscriptionsInfoStatus {
  bool get isLoading => this == FoodSubscriptionsInfoStatus.loading;
  bool get isSuccess => this == FoodSubscriptionsInfoStatus.success;
  bool get isFailure => this == FoodSubscriptionsInfoStatus.failure;
}

final class FoodSubscriptionsInfoState {
  final String id;
  final bool isAuthorized;
  final SubscriptionTiffinPackageInfoModel info;
  final FoodSubscriptionsInfoStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodSubscriptionsInfoState({this.id = '', this.isAuthorized = false, required this.info, this.status = FoodSubscriptionsInfoStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  FoodSubscriptionsInfoState copyWith({String? id, bool? isAuthorized, SubscriptionTiffinPackageInfoModel? info, FoodSubscriptionsInfoStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FoodSubscriptionsInfoState(
      id: id ?? this.id,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      info: info ?? this.info,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

