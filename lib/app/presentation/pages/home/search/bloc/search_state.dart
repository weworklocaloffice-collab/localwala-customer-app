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

enum SearchStatus { initial, empty, success, failure, navigate }

extension SearchStatusX on SearchStatus {
  bool get isInitial => this == SearchStatus.initial;
  bool get isSuccess => this == SearchStatus.success;
  bool get isFailure => this == SearchStatus.failure;
  bool get isEmpty => this == SearchStatus.empty;
  bool get isNavigate => this == SearchStatus.navigate;
}

final class SearchState {
  final GlobalSearchInitialResponseModel initialData;
  final GlobalSearchResultModel result;
  final List<GlobalSearchHistoryModel> localHistory;
  final double latitude;
  final double longitude;
  final String navigateTo;
  final List<String> navigationArgs;
  final SearchStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SearchState({
    required this.initialData,
    required this.result,
    this.localHistory = const [],
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.navigateTo = '',
    this.navigationArgs = const [],
    this.status = SearchStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SearchState copyWith({
    GlobalSearchInitialResponseModel? initialData,
    GlobalSearchResultModel? result,
    List<GlobalSearchHistoryModel>? localHistory,
    double? latitude,
    double? longitude,
    String? navigateTo,
    List<String>? navigationArgs,
    SearchStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SearchState(
      initialData: initialData ?? this.initialData,
      result: result ?? this.result,
      localHistory: localHistory ?? this.localHistory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      navigateTo: navigateTo ?? this.navigateTo,
      navigationArgs: navigationArgs ?? this.navigationArgs,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

