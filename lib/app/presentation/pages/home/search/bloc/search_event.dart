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

part of 'search_bloc.dart';

sealed class SearchEvent {}

final class SearchInitialEvent extends SearchEvent {}

final class SearchFindResultEvent extends SearchEvent {
  final String searchQuery;
  SearchFindResultEvent({required this.searchQuery});
}

final class SearchSaveHistoryEvent extends SearchEvent {
  final String type;
  final int index;
  SearchSaveHistoryEvent({required this.type, required this.index});
}

final class SearchOnLocalSearchHistoryTapEvent extends SearchEvent {
  final int index;
  SearchOnLocalSearchHistoryTapEvent({required this.index});
}

final class SearchOnLocalSearchHistoryDeleteEvent extends SearchEvent {
  final int index;
  SearchOnLocalSearchHistoryDeleteEvent({required this.index});
}

final class SearchExecuteQueryEvent extends SearchEvent {
  final String query;
  SearchExecuteQueryEvent({required this.query});
}

