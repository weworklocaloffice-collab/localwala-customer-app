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

part of 'purchased_food_subscription_info_bloc.dart';

sealed class PurchasedFoodSubscriptionInfoEvent {}

final class PurchasedFoodSubscriptionInfoInitialEvent extends PurchasedFoodSubscriptionInfoEvent {
  final String purchaseId;
  PurchasedFoodSubscriptionInfoInitialEvent({required this.purchaseId});
}

final class PurchasedFoodSubscriptionInfoRepayPackageEvent extends PurchasedFoodSubscriptionInfoEvent {}

final class PurchasedFoodSubscriptionInfoPaymentChangedEvent extends PurchasedFoodSubscriptionInfoEvent {
  final String id;
  PurchasedFoodSubscriptionInfoPaymentChangedEvent({required this.id});
}

final class PurchasedFoodSubscriptionInfoCancelPackageEvent extends PurchasedFoodSubscriptionInfoEvent {
  final String reasonId;
  PurchasedFoodSubscriptionInfoCancelPackageEvent({required this.reasonId});
}

final class PurchasedFoodSubscriptionInfoCallRestaurantEvent extends PurchasedFoodSubscriptionInfoEvent {}

