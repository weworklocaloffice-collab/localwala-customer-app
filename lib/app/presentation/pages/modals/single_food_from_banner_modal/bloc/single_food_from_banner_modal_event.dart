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

part of 'single_food_from_banner_modal_bloc.dart';

sealed class SingleFoodFromBannerModalEvent {}

final class SingleFoodFromBannerModalInitialEvent extends SingleFoodFromBannerModalEvent {
  final String id;
  final String name;
  SingleFoodFromBannerModalInitialEvent({required this.id, required this.name});
}

final class SingleFoodFromBannerModalQuantityEvent extends SingleFoodFromBannerModalEvent {
  final String action;
  SingleFoodFromBannerModalQuantityEvent({required this.action});
}

final class SingleFoodFromBannerModalSaveEvent extends SingleFoodFromBannerModalEvent {}

final class SingleFoodFromBannerModalFavouriteEvent extends SingleFoodFromBannerModalEvent {}

final class SingleFoodFromBannerModalAddonsEvent extends SingleFoodFromBannerModalEvent {
  final int index;
  SingleFoodFromBannerModalAddonsEvent({required this.index});
}

final class SingleFoodFromBannerModalVariationOptionEvent extends SingleFoodFromBannerModalEvent {
  final int vIndex;
  final int oIndex;
  final String type;
  SingleFoodFromBannerModalVariationOptionEvent({required this.vIndex, required this.oIndex, required this.type});
}

final class SingleFoodFromBannerModalRepeatIncreaseEvent extends SingleFoodFromBannerModalEvent {
  final int index;
  final String uuid;
  SingleFoodFromBannerModalRepeatIncreaseEvent({required this.index, required this.uuid});
}

final class SingleFoodFromBannerModalRepeatDecreaseEvent extends SingleFoodFromBannerModalEvent {
  final int index;
  final String uuid;
  SingleFoodFromBannerModalRepeatDecreaseEvent({required this.index, required this.uuid});
}

final class SingleFoodFromBannerModalNewItemEvent extends SingleFoodFromBannerModalEvent {}

final class SingleFoodFromBannerModalNewItemSaveEvent extends SingleFoodFromBannerModalEvent {}

final class SingleFoodInstructionChangeEvent extends SingleFoodFromBannerModalEvent {
  final String instruction;
  SingleFoodInstructionChangeEvent({required this.instruction});
}

final class SingleFoodShareEvent extends SingleFoodFromBannerModalEvent {}

