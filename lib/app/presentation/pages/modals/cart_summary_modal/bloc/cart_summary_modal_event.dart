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

part of 'cart_summary_modal_bloc.dart';

sealed class CartSummaryModalEvent {}

final class CartSummaryModalInitialEvent extends CartSummaryModalEvent {}

final class CartSummaryModalRemoveCartItemByRestaurantEvent extends CartSummaryModalEvent {
  final String restaurantId;
  CartSummaryModalRemoveCartItemByRestaurantEvent({required this.restaurantId});
}

final class CartSummaryModalClearCartEvent extends CartSummaryModalEvent {}

final class CartSummaryModalOnCheckoutEvent extends CartSummaryModalEvent {
  final String name;
  final String restaurant;
  CartSummaryModalOnCheckoutEvent({required this.name, required this.restaurant});
}

final class CartSummaryModalGuestCheckoutEvent extends CartSummaryModalEvent {}

final class CartSummaryModalChangeInitialEvent extends CartSummaryModalEvent {}

