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

part of 'loyalty_bloc.dart';

enum LoyaltyStatus { loading, success, failure, empty, redeeming, redeemSuccess, customError, unAuthorized }

extension LoyaltyStatusX on LoyaltyStatus {
  bool get isLoading => this == LoyaltyStatus.loading;
  bool get isSuccess => this == LoyaltyStatus.success;
  bool get isFailure => this == LoyaltyStatus.failure;
  bool get isEmpty => this == LoyaltyStatus.empty;
  bool get isRedeeming => this == LoyaltyStatus.redeeming;
  bool get isRedeemSuccess => this == LoyaltyStatus.redeemSuccess;
  bool get isCustomError => this == LoyaltyStatus.customError;
  bool get isUnAuthorized => this == LoyaltyStatus.unAuthorized;
}

final class LoyaltyState {
  final LoyaltyPointsResponseModel points;
  final LoyaltyStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoyaltyState({required this.points, this.status = LoyaltyStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  LoyaltyState copyWith({LoyaltyPointsResponseModel? points, LoyaltyStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return LoyaltyState(points: points ?? this.points, status: status ?? this.status, statusCode: statusCode ?? this.statusCode, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

