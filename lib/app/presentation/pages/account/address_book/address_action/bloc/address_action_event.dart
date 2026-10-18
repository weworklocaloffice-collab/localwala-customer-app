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

part of 'address_action_bloc.dart';

sealed class AddressActionEvent {}

final class AddressActionInitialEvent extends AddressActionEvent {
  final bool isNew;
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
  AddressActionInitialEvent({
    required this.isNew,
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

final class AddressActionTitleChangeEvent extends AddressActionEvent {
  final int title;
  AddressActionTitleChangeEvent({required this.title});
}

final class AddressActionNameChanged extends AddressActionEvent {
  final String name;
  AddressActionNameChanged({required this.name});
}

final class AddressActionNameUnfocused extends AddressActionEvent {}

final class AddressActionCountryCodeChanged extends AddressActionEvent {
  final String flag;
  final String countryCode;
  AddressActionCountryCodeChanged({required this.flag, required this.countryCode});
}

final class AddressActionNumberChanged extends AddressActionEvent {
  final String number;
  AddressActionNumberChanged({required this.number});
}

final class AddressActionNumberUnfocused extends AddressActionEvent {}

final class AddressActionHouseChanged extends AddressActionEvent {
  final String house;
  AddressActionHouseChanged({required this.house});
}

final class AddressActionHouseUnfocused extends AddressActionEvent {}

final class AddressActionLocalityChanged extends AddressActionEvent {
  final String locality;
  AddressActionLocalityChanged({required this.locality});
}

final class AddressActionLocalityUnfocused extends AddressActionEvent {}

final class AddressActionLandmarkChanged extends AddressActionEvent {
  final String landmark;
  AddressActionLandmarkChanged({required this.landmark});
}

final class AddressActionSubmitted extends AddressActionEvent {}

