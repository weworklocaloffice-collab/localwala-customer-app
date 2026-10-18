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

sealed class LocationMapsEvent {}

final class LocationMapInitialEvent extends LocationMapsEvent {
  final double latitude;
  final double longitude;
  final String placeId;
  final String title;
  final String description;
  LocationMapInitialEvent({required this.latitude, required this.longitude, required this.placeId, required this.title, required this.description});
}

final class LocationMapPositionChangedEvent extends LocationMapsEvent {
  final double latitude;
  final double longitude;
  LocationMapPositionChangedEvent({required this.latitude, required this.longitude});
}

final class LocationMapPositionEndedEvent extends LocationMapsEvent {}

final class LocationMapsConfirmEvent extends LocationMapsEvent {}

final class LocationMapsLocateMeEvent extends LocationMapsEvent {}

final class LocationMapsOpenSettingEvent extends LocationMapsEvent {}

