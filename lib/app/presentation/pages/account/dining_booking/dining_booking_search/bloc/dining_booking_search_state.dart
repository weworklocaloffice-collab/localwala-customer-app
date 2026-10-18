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

part of 'dining_booking_search_bloc.dart';

enum DiningBookingSearchStatus { initial, loading, success, failure, empty }

extension DiningBookingSearchStatusX on DiningBookingSearchStatus {
  bool get isInitial => this == DiningBookingSearchStatus.initial;
  bool get isLoading => this == DiningBookingSearchStatus.loading;
  bool get isSuccess => this == DiningBookingSearchStatus.success;
  bool get isFailure => this == DiningBookingSearchStatus.failure;
  bool get isEmpty => this == DiningBookingSearchStatus.empty;
}

final class DiningBookingSearchState {
  final String query;
  final DiningBookingSearchResponseModel model;
  final DiningBookingSearchStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingSearchState({this.query = '', required this.model, this.status = DiningBookingSearchStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  DiningBookingSearchState copyWith({String? query, DiningBookingSearchResponseModel? model, DiningBookingSearchStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return DiningBookingSearchState(
      query: query ?? this.query,
      model: model ?? this.model,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

