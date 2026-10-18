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

part of 'dining_on_map_bloc.dart';

enum DiningOnMapStatus { initial, locationFetched, empty, success, failure, customError }

extension DiningOnMapStatusX on DiningOnMapStatus {
  bool get isInitial => this == DiningOnMapStatus.initial;
  bool get isLocationFetched => this == DiningOnMapStatus.locationFetched;
  bool get isEmpty => this == DiningOnMapStatus.empty;
  bool get isSuccess => this == DiningOnMapStatus.success;
  bool get isFailure => this == DiningOnMapStatus.failure;
  bool get isCustomError => this == DiningOnMapStatus.customError;
}

final class DiningOnMapState {
  final NearMeDiningRestaurantsOnMapResponseModel model;
  final double latitude;
  final double longitude;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final DiningOnMapStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningOnMapState({
    required this.model,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.markers = const <Marker>{},
    this.polyline = const <Polyline>{},
    this.status = DiningOnMapStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningOnMapState copyWith({
    NearMeDiningRestaurantsOnMapResponseModel? model,
    double? latitude,
    double? longitude,
    Set<Marker>? markers,
    Set<Polyline>? polyline,
    DiningOnMapStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningOnMapState(
      model: model ?? this.model,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      markers: markers ?? this.markers,
      polyline: polyline ?? this.polyline,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

