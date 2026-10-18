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

part of 'food_variations_bloc.dart';

sealed class FoodVariationsEvent {}

final class FoodVariationsInitialEvent extends FoodVariationsEvent {
  final String id;
  final String name;
  final String image;
  final String options;
  final double price;
  final double offerPrice;
  final String discountType;
  final double discount;
  final int purchaseLimit;
  final int stockNumber;
  final String stockType;
  FoodVariationsInitialEvent({
    required this.id,
    required this.name,
    required this.image,
    required this.options,
    required this.price,
    required this.offerPrice,
    required this.discountType,
    required this.discount,
    required this.purchaseLimit,
    required this.stockNumber,
    required this.stockType,
  });
}

final class FoodVariationsAddonsEvent extends FoodVariationsEvent {
  final int index;
  FoodVariationsAddonsEvent({required this.index});
}

final class FoodVariationOptionEvent extends FoodVariationsEvent {
  final int vIndex;
  final int oIndex;
  final String type;
  FoodVariationOptionEvent({required this.vIndex, required this.oIndex, required this.type});
}

final class FoodVariationQuantityEvent extends FoodVariationsEvent {
  final String action;
  FoodVariationQuantityEvent({required this.action});
}

final class FoodVariationInstructionChangeEvent extends FoodVariationsEvent {
  final String instruction;
  FoodVariationInstructionChangeEvent({required this.instruction});
}

final class FoodVariationSaveEvent extends FoodVariationsEvent {}

