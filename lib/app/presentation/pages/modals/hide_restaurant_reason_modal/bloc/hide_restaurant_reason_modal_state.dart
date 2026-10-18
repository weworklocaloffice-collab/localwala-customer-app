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

part of 'hide_restaurant_reason_modal_bloc.dart';

enum HideRestaurantReasonModalStatus { loading, success, failure, empty, submit, submitSuccess, submitFailed }

extension HideRestaurantReasonModalStatusX on HideRestaurantReasonModalStatus {
  bool get isLoading => this == HideRestaurantReasonModalStatus.loading;
  bool get isSuccess => this == HideRestaurantReasonModalStatus.success;
  bool get isFailure => this == HideRestaurantReasonModalStatus.failure;
  bool get isEmpty => this == HideRestaurantReasonModalStatus.empty;
  bool get isSubmit => this == HideRestaurantReasonModalStatus.submit;
  bool get isSubmitSuccess => this == HideRestaurantReasonModalStatus.submitSuccess;
  bool get isSubmitFailed => this == HideRestaurantReasonModalStatus.submitFailed;
}

final class HideRestaurantReasonModalState {
  final String restaurantId;
  final String restaurantName;
  final HideRestaurantReasonListModel list;
  final String reasonId;
  final HideRestaurantReasonModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const HideRestaurantReasonModalState({
    this.restaurantId = '',
    this.restaurantName = '',
    required this.list,
    this.reasonId = '',
    this.status = HideRestaurantReasonModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  HideRestaurantReasonModalState copyWith({
    String? restaurantId,
    String? restaurantName,
    HideRestaurantReasonListModel? list,
    String? reasonId,
    HideRestaurantReasonModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return HideRestaurantReasonModalState(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      list: list ?? this.list,
      reasonId: reasonId ?? this.reasonId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

