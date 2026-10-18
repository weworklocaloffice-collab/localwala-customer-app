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

part of 'restaurant_campaign_bloc.dart';

sealed class RestaurantCampaignEvent {}

final class RestaurantCampaignInitialEvent extends RestaurantCampaignEvent {
  final String id;
  RestaurantCampaignInitialEvent({required this.id});
}

final class RestaurantCampaignFavouriteEvent extends RestaurantCampaignEvent {
  final String id;
  final bool isFavourite;
  RestaurantCampaignFavouriteEvent({required this.id, required this.isFavourite});
}

final class RestaurantCampaignHideEvent extends RestaurantCampaignEvent {
  final String id;
  RestaurantCampaignHideEvent({required this.id});
}

final class RestaurantCampaignRemoveRestaurantEvent extends RestaurantCampaignEvent {
  final String id;
  RestaurantCampaignRemoveRestaurantEvent({required this.id});
}

final class RestaurantCampaignUndoHideActionEvent extends RestaurantCampaignEvent {
  final String id;
  RestaurantCampaignUndoHideActionEvent({required this.id});
}

final class RestaurantCampaignNavigateEvent extends RestaurantCampaignEvent {}

