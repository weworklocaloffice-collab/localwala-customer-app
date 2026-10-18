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

part of 'dining_bloc.dart';

sealed class DiningEvent {}

final class DiningInitialEvent extends DiningEvent {}

final class DiningLoadMoreEvent extends DiningEvent {}

final class DiningFavouriteEvent extends DiningEvent {
  final String id;
  final bool isFavourite;
  DiningFavouriteEvent({required this.id, required this.isFavourite});
}

final class DiningHideEvent extends DiningEvent {
  final String id;
  DiningHideEvent({required this.id});
}

final class DiningRemoveRestaurantFromListEvent extends DiningEvent {
  final String id;
  DiningRemoveRestaurantFromListEvent({required this.id});
}

final class DiningUndoHideActionEvent extends DiningEvent {
  final String id;
  DiningUndoHideActionEvent({required this.id});
}

final class DiningSilentHideEvent extends DiningEvent {
  final String id;
  DiningSilentHideEvent({required this.id});
}

final class DiningSilentUnHideEvent extends DiningEvent {
  final String id;
  DiningSilentUnHideEvent({required this.id});
}

final class DiningRefreshFavouriteEvent extends DiningEvent {
  final List<String> inFavList;
  DiningRefreshFavouriteEvent({required this.inFavList});
}

final class DiningPullRefreshEvent extends DiningEvent {}

