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

part of 'dining_search_bloc.dart';

enum DiningSearchStatus { initial, empty, success, failure }

extension DiningSearchStatusX on DiningSearchStatus {
  bool get isInitial => this == DiningSearchStatus.initial;
  bool get isSuccess => this == DiningSearchStatus.success;
  bool get isFailure => this == DiningSearchStatus.failure;
  bool get isEmpty => this == DiningSearchStatus.empty;
}

final class DiningSearchState {
  final GlobalDiningSearchInitialResponseModel initialData;
  final GlobalDiningSearchResultModel result;
  final double latitude;
  final double longitude;
  final String navigateTo;
  final List<String> navigationArgs;
  final DiningSearchStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningSearchState({
    required this.initialData,
    required this.result,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.navigateTo = '',
    this.navigationArgs = const [],
    this.status = DiningSearchStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningSearchState copyWith({
    GlobalDiningSearchInitialResponseModel? initialData,
    GlobalDiningSearchResultModel? result,
    double? latitude,
    double? longitude,
    String? navigateTo,
    List<String>? navigationArgs,
    DiningSearchStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningSearchState(
      initialData: initialData ?? this.initialData,
      result: result ?? this.result,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      navigateTo: navigateTo ?? this.navigateTo,
      navigationArgs: navigationArgs ?? this.navigationArgs,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

