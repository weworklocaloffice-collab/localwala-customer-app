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

part of 'buy_subscription_package_bloc.dart';

sealed class BuySubscriptionPackageEvent {}

final class BuySubscriptionPackageInitialEvent extends BuySubscriptionPackageEvent {
  final String id;
  BuySubscriptionPackageInitialEvent({required this.id});
}

final class BuySubscriptionPackageSlotSelectEvent extends BuySubscriptionPackageEvent {
  final String slot;
  BuySubscriptionPackageSlotSelectEvent({required this.slot});
}

final class BuySubscriptionPackagePaymentChangeEvent extends BuySubscriptionPackageEvent {
  final String id;
  BuySubscriptionPackagePaymentChangeEvent({required this.id});
}

final class BuySubscriptionPackageDeliveryAddressChangeEvent extends BuySubscriptionPackageEvent {
  final DeliveryAddressModalResponseModel selected;
  BuySubscriptionPackageDeliveryAddressChangeEvent({required this.selected});
}

final class BuySubscriptionPackageInstructionsEvent extends BuySubscriptionPackageEvent {
  final String instructions;
  BuySubscriptionPackageInstructionsEvent({required this.instructions});
}

final class BuySubscriptionPackageDeliveryInstructionClearEvent extends BuySubscriptionPackageEvent {}

final class BuySubscriptionPackageDeliveryInstructionChangeEvent extends BuySubscriptionPackageEvent {
  final DeliveryInstructionModalResponseModel data;
  BuySubscriptionPackageDeliveryInstructionChangeEvent({required this.data});
}

final class BuySubscriptionPackageReceiverChangeEvent extends BuySubscriptionPackageEvent {
  final String name;
  final String countryCode;
  final String phoneNumber;
  BuySubscriptionPackageReceiverChangeEvent({required this.name, required this.countryCode, required this.phoneNumber});
}

final class BuySubscriptionPackageFoodModalResponseEvent extends BuySubscriptionPackageEvent {
  final String id;
  final FoodInfoModalResponseModel response;
  BuySubscriptionPackageFoodModalResponseEvent({required this.id, required this.response});
}

final class BuySubscriptionPackageCreateOrderEvent extends BuySubscriptionPackageEvent {}

