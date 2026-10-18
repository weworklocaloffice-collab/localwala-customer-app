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

part of 'dining_booking_bloc.dart';

enum DiningBookingStatus { loading, success, failure, empty, unAuthorized }

extension DiningBookingStatusX on DiningBookingStatus {
  bool get isLoading => this == DiningBookingStatus.loading;
  bool get isSuccess => this == DiningBookingStatus.success;
  bool get isFailure => this == DiningBookingStatus.failure;
  bool get isEmpty => this == DiningBookingStatus.empty;
  bool get isUnAuthorized => this == DiningBookingStatus.unAuthorized;
}

final class DiningBookingState {
  final DiningBookingListResponseModel model;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final bool isAuthorized;
  final DiningBookingStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingState({
    required this.model,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.isAuthorized = false,
    this.status = DiningBookingStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingState copyWith({
    DiningBookingListResponseModel? model,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    bool? isAuthorized,
    DiningBookingStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingState(
      model: model ?? this.model,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

