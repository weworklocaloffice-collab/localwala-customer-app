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

part of 'location_search_bloc.dart';

sealed class LocationSearchEvent {}

final class LocationSearchInitialEvent extends LocationSearchEvent {}

final class LocationSearchInputEvent extends LocationSearchEvent {
  final String searchText;
  LocationSearchInputEvent({required this.searchText});
}

final class LocationSearchLocalSelectEvent extends LocationSearchEvent {
  final LocalSearchHistoryModel localResult;
  LocationSearchLocalSelectEvent({required this.localResult});
}

final class LocationSearchSelectEvent extends LocationSearchEvent {
  final Predictions predictions;
  LocationSearchSelectEvent({required this.predictions});
}

final class LocationSearchLiveLocationEvent extends LocationSearchEvent {}

final class LocationSearchOpenSettingEvent extends LocationSearchEvent {}

final class LocationSearchSavedAddressEvent extends LocationSearchEvent {
  final AddressDataModel result;
  LocationSearchSavedAddressEvent({required this.result});
}

final class LocationSearchExecuteEvent extends LocationSearchEvent {
  final String query;
  LocationSearchExecuteEvent({required this.query});
}

