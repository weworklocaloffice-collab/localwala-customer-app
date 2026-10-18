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

part of 'select_delivery_time_modal_bloc.dart';

sealed class SelectDeliveryTimeModalEvent {}

final class SelectDeliveryTimeModalInitialEvent extends SelectDeliveryTimeModalEvent {
  final String deliveryTime;
  SelectDeliveryTimeModalInitialEvent({required this.deliveryTime});
}

final class SelectDeliveryTimeModalFromChangeEvent extends SelectDeliveryTimeModalEvent {
  final String from;
  SelectDeliveryTimeModalFromChangeEvent({required this.from});
}

final class SelectDeliveryTimeModalFromUnfocusedEvent extends SelectDeliveryTimeModalEvent {}

final class SelectDeliveryTimeModalToChangeEvent extends SelectDeliveryTimeModalEvent {
  final String to;
  SelectDeliveryTimeModalToChangeEvent({required this.to});
}

final class SelectDeliveryTimeModalToUnfocusedEvent extends SelectDeliveryTimeModalEvent {}

final class SelectDeliveryTimeChangeEvent extends SelectDeliveryTimeModalEvent {
  final DeliveryTimeTimeModel time;
  SelectDeliveryTimeChangeEvent({required this.time});
}

