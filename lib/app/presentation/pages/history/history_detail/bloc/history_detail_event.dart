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

part of 'history_detail_bloc.dart';

sealed class HistoryDetailEvent {}

final class HistoryDetailInitialEvent extends HistoryDetailEvent {
  final String id;
  HistoryDetailInitialEvent({required this.id});
}

final class HistoryDetailRepayOrderEvent extends HistoryDetailEvent {}

final class HistoryDetailCancelMyOrderEvent extends HistoryDetailEvent {
  final String reasonId;
  HistoryDetailCancelMyOrderEvent({required this.reasonId});
}

final class HistoryDetailOpenSettingEvent extends HistoryDetailEvent {}

final class HistoryDetailDirectionEvent extends HistoryDetailEvent {
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  HistoryDetailDirectionEvent({required this.startLatitude, required this.startLongitude, required this.endLatitude, required this.endLongitude});
}

final class HistoryDetailFavouriteEvent extends HistoryDetailEvent {}

final class HistoryDetailReviewSavedEvent extends HistoryDetailEvent {}

final class HistoryDetailPaymentChangedEvent extends HistoryDetailEvent {
  final String id;
  HistoryDetailPaymentChangedEvent({required this.id});
}

final class HistoryDetailCallRestaurantEvent extends HistoryDetailEvent {}

final class HistoryDetailCallDriverEvent extends HistoryDetailEvent {}

final class HistoryDetailNewDeliverymanLocation extends HistoryDetailEvent {
  final double latitude;
  final double longitude;
  HistoryDetailNewDeliverymanLocation({required this.latitude, required this.longitude});
}

