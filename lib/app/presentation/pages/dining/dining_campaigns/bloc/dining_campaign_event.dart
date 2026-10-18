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

part of 'dining_campaign_bloc.dart';

sealed class DiningCampaignEvent {}

final class DiningCampaignInitialEvent extends DiningCampaignEvent {
  final String id;
  DiningCampaignInitialEvent({required this.id});
}

final class DiningCampaignHideEvent extends DiningCampaignEvent {
  final String id;
  DiningCampaignHideEvent({required this.id});
}

final class DiningCampaignFavouriteEvent extends DiningCampaignEvent {
  final String id;
  final bool isFavourite;
  DiningCampaignFavouriteEvent({required this.id, required this.isFavourite});
}

final class DiningCampaignRemoveRestaurantEvent extends DiningCampaignEvent {
  final String id;
  DiningCampaignRemoveRestaurantEvent({required this.id});
}

final class DiningCampaignUndoHideActionEvent extends DiningCampaignEvent {
  final String id;
  DiningCampaignUndoHideActionEvent({required this.id});
}

