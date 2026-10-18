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

part of 'new_address_map_bloc.dart';

sealed class NewAddressMapEvent {}

final class NewAddressMapInitialEvent extends NewAddressMapEvent {
  final bool isNew;
  final bool fromDelivery;
  final String id;
  final double latitude;
  final double longitude;
  final int title;
  final String receiverName;
  final String countryCode;
  final String receiverContact;
  final String flatHouse;
  final String locality;
  final String landmark;
  NewAddressMapInitialEvent({
    required this.isNew,
    required this.fromDelivery,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.receiverName,
    required this.countryCode,
    required this.receiverContact,
    required this.flatHouse,
    required this.locality,
    required this.landmark,
  });
}

final class NewAddressMapOpenSettingEvent extends NewAddressMapEvent {}

final class NewAddressMapLocateMeEvent extends NewAddressMapEvent {}

final class NewAddressMapPositionChangedEvent extends NewAddressMapEvent {
  final double latitude;
  final double longitude;
  NewAddressMapPositionChangedEvent({required this.latitude, required this.longitude});
}

final class NewAddressMapPositionEndedEvent extends NewAddressMapEvent {}

