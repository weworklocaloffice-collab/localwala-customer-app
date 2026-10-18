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

part of 'delivery_addresss_list_bloc.dart';

enum DeliveryAddresssListStatus { loading, empty, success, failure, selected }

extension DeliveryAddresssListStatusX on DeliveryAddresssListStatus {
  bool get isLoading => this == DeliveryAddresssListStatus.loading;
  bool get isEmpty => this == DeliveryAddresssListStatus.empty;
  bool get isSuccess => this == DeliveryAddresssListStatus.success;
  bool get isFailure => this == DeliveryAddresssListStatus.failure;
  bool get isSelected => this == DeliveryAddresssListStatus.selected;
}

final class DeliveryAddresssListState {
  final int selectedIndex;
  final String restaurant;
  final String deliveryAddressId;
  final double latitude;
  final double longitude;
  final DeliveryAddressListFromCheckoutModel addresses;
  final DeliveryAddresssListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DeliveryAddresssListState({
    this.selectedIndex = 0,
    this.restaurant = '',
    this.deliveryAddressId = '',
    this.latitude = 0,
    this.longitude = 0,
    required this.addresses,
    this.status = DeliveryAddresssListStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DeliveryAddresssListState copyWith({
    int? selectedIndex,
    String? restaurant,
    String? deliveryAddressId,
    double? latitude,
    double? longitude,
    DeliveryAddressListFromCheckoutModel? addresses,
    DeliveryAddresssListStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DeliveryAddresssListState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      restaurant: restaurant ?? this.restaurant,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

