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

part of 'dining_booking_transaction_bloc.dart';

enum DiningBookingTransactionStatus { loading, success, failure, empty, unAuthorized }

extension DiningBookingTransactionStatusX on DiningBookingTransactionStatus {
  bool get isLoading => this == DiningBookingTransactionStatus.loading;
  bool get isSuccess => this == DiningBookingTransactionStatus.success;
  bool get isFailure => this == DiningBookingTransactionStatus.failure;
  bool get isEmpty => this == DiningBookingTransactionStatus.empty;
  bool get isUnAuthorized => this == DiningBookingTransactionStatus.unAuthorized;
}

final class DiningBookingTransactionState {
  final UserDiningTransactionResponseModel model;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final DiningBookingTransactionStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingTransactionState({
    required this.model,
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = DiningBookingTransactionStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingTransactionState copyWith({
    UserDiningTransactionResponseModel? model,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    DiningBookingTransactionStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingTransactionState(
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

