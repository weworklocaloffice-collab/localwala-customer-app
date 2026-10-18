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

part of 'coupon_list_modal_bloc.dart';

enum CouponListModalStatus { loading, success, failure, empty, validationFailure, couponRedeemStart, couponRedeemSuccess, couponRedeemFailed }

extension CouponListModalStatusX on CouponListModalStatus {
  bool get isLoading => this == CouponListModalStatus.loading;
  bool get isSuccess => this == CouponListModalStatus.success;
  bool get isFailure => this == CouponListModalStatus.failure;
  bool get isEmpty => this == CouponListModalStatus.empty;
  bool get isValidationFailure => this == CouponListModalStatus.validationFailure;
  bool get isCouponRedeemStart => this == CouponListModalStatus.couponRedeemStart;
  bool get isCouponRedeemSuccess => this == CouponListModalStatus.couponRedeemSuccess;
  bool get isCouponRedeemFailed => this == CouponListModalStatus.couponRedeemFailed;
}

final class CouponListModalState {
  final CouponListResponseModel coupons;
  final String trackingId;
  final String restaurant;
  final double itemTotal;
  final int redeemCouponIndex;
  final CouponListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CouponListModalState({
    required this.coupons,
    this.trackingId = '',
    this.restaurant = '',
    this.itemTotal = 0,
    this.redeemCouponIndex = 0,
    this.status = CouponListModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  CouponListModalState copyWith({
    CouponListResponseModel? coupons,
    String? trackingId,
    String? restaurant,
    double? itemTotal,
    int? redeemCouponIndex,
    CouponListModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return CouponListModalState(
      coupons: coupons ?? this.coupons,
      trackingId: trackingId ?? this.trackingId,
      restaurant: restaurant ?? this.restaurant,
      itemTotal: itemTotal ?? this.itemTotal,
      redeemCouponIndex: redeemCouponIndex ?? this.redeemCouponIndex,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

