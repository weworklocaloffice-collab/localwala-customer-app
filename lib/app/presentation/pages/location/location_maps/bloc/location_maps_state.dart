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

part of 'location_maps_bloc.dart';

enum LocationMapsStatus { initial, loading, loaded, current, dragged, failure, deniedForever, confirm }

extension LocationMapStatusX on LocationMapsStatus {
  bool get isInitial => this == LocationMapsStatus.initial;
  bool get isLoading => this == LocationMapsStatus.loading;
  bool get isLoaded => this == LocationMapsStatus.loaded;
  bool get isCurrent => this == LocationMapsStatus.current;
  bool get isDragged => this == LocationMapsStatus.dragged;
  bool get isFailure => this == LocationMapsStatus.failure;
  bool get isDeniedForever => this == LocationMapsStatus.deniedForever;
  bool get isConfirm => this == LocationMapsStatus.confirm;
}

final class LocationMapsState {
  final double latitude;
  final double longitude;
  final String placeId;
  final String title;
  final String description;
  final LocationMapsStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LocationMapsState({
    this.latitude = 0,
    this.longitude = 0,
    this.placeId = '',
    this.title = '',
    this.description = '',
    this.status = LocationMapsStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  LocationMapsState copyWith({double? latitude, double? longitude, String? placeId, String? title, String? description, LocationMapsStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return LocationMapsState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

