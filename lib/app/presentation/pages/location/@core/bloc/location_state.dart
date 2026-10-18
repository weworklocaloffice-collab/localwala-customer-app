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

part of 'location_bloc.dart';

enum LocationStatus { initial, loading, success, failure, deniedForever }

extension LocationStatusX on LocationStatus {
  bool get isInitial => this == LocationStatus.initial;
  bool get isLoading => this == LocationStatus.loading;
  bool get isSuccess => this == LocationStatus.success;
  bool get isFailure => this == LocationStatus.failure;
  bool get isDeniedForever => this == LocationStatus.deniedForever;
}

final class LocationState {
  final LocationStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LocationState({this.status = LocationStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  LocationState copyWith({LocationStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return LocationState(status: status ?? this.status, statusCode: statusCode ?? this.statusCode, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

