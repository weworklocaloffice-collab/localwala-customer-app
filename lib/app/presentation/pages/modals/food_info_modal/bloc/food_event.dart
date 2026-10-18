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

part of 'food_bloc.dart';

sealed class FoodEvent {}

final class FoodInitialEvent extends FoodEvent {
  final String id;
  final String from;
  final String data;
  final String extraInfo;
  FoodInitialEvent({required this.id, required this.from, required this.data, required this.extraInfo});
}

final class FoodQuantityEvent extends FoodEvent {
  final String action;
  FoodQuantityEvent({required this.action});
}

final class FoodSaveEvent extends FoodEvent {}

final class FoodFavouriteEvent extends FoodEvent {}

final class FoodAddonsEvent extends FoodEvent {
  final int index;
  FoodAddonsEvent({required this.index});
}

final class FoodVariationOptionEvent extends FoodEvent {
  final int vIndex;
  final int oIndex;
  final String type;
  FoodVariationOptionEvent({required this.vIndex, required this.oIndex, required this.type});
}

final class FoodInstructionChangeEvent extends FoodEvent {
  final String instruction;
  FoodInstructionChangeEvent({required this.instruction});
}

final class FoodShareEvent extends FoodEvent {}

