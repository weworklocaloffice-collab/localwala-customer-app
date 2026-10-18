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

sealed class DeliveryAddresssListEvent {}

final class DeliveryAddressListInitialEvent extends DeliveryAddresssListEvent {
  final double deliveryArea;
  final String restaurant;
  final String deliveryAddressId;
  DeliveryAddressListInitialEvent({required this.deliveryArea, required this.restaurant, required this.deliveryAddressId});
}

final class DeliveryAddresssRefreshEvent extends DeliveryAddresssListEvent {}

final class DeliveryAddressSelectEvent extends DeliveryAddresssListEvent {
  final String id;
  DeliveryAddressSelectEvent({required this.id});
}

