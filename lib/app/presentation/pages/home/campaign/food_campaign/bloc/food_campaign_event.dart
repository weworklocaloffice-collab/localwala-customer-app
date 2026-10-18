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

part of 'food_campaign_bloc.dart';

sealed class FoodCampaignEvent {}

final class FoodCampaignInitialEvent extends FoodCampaignEvent {
  final String id;
  FoodCampaignInitialEvent({required this.id});
}

final class FoodCampaignFavouriteEvent extends FoodCampaignEvent {
  final String id;
  final bool isFavourite;
  FoodCampaignFavouriteEvent({required this.id, required this.isFavourite});
}

final class FoodCampaignVariationModalResponseEvent extends FoodCampaignEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FoodCampaignVariationModalResponseEvent({required this.id, required this.data});
}

final class FoodCampaignFoodQuantityDecreaseEvent extends FoodCampaignEvent {
  final String id;
  FoodCampaignFoodQuantityDecreaseEvent({required this.id});
}

final class FoodCampaignFoodQuantityIncreaseEvent extends FoodCampaignEvent {
  final String id;
  FoodCampaignFoodQuantityIncreaseEvent({required this.id});
}

final class FoodCampaignAddCartEvent extends FoodCampaignEvent {
  final String id;
  FoodCampaignAddCartEvent({required this.id});
}

final class FoodCampaignRepeatFoodOrderResponseEvent extends FoodCampaignEvent {
  final String id;
  final RepeatQuantityModalResponseModel data;
  FoodCampaignRepeatFoodOrderResponseEvent({required this.id, required this.data});
}

final class FoodCampaignFoodVariationModalRepeatResponseEvent extends FoodCampaignEvent {
  final String id;
  final FoodVariationModalResponseDataModel data;
  FoodCampaignFoodVariationModalRepeatResponseEvent({required this.id, required this.data});
}

final class FoodCampaignFoodModalResponseEvent extends FoodCampaignEvent {
  final String id;
  final FoodInfoModalResponseModel response;
  FoodCampaignFoodModalResponseEvent({required this.id, required this.response});
}

