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

part of 'filter_dining_with_category_bloc.dart';

enum FilterDiningWithCategoryStatus { loading, success, failure, empty, customError, favUpdate, hidden, unhidden }

extension FilterDiningWithCategoryStatusX on FilterDiningWithCategoryStatus {
  bool get isLoading => this == FilterDiningWithCategoryStatus.loading;
  bool get isSuccess => this == FilterDiningWithCategoryStatus.success;
  bool get isFailure => this == FilterDiningWithCategoryStatus.failure;
  bool get isEmpty => this == FilterDiningWithCategoryStatus.empty;
  bool get isCustomError => this == FilterDiningWithCategoryStatus.customError;
  bool get isFavUpdate => this == FilterDiningWithCategoryStatus.favUpdate;
  bool get isHidden => this == FilterDiningWithCategoryStatus.hidden;
  bool get isUnhidden => this == FilterDiningWithCategoryStatus.unhidden;
}

final class FilterDiningWithCategoryState {
  final DiningByCategoryResponseModel model;
  final String name;
  final List<String> favIds;
  final String hideUnhideId;
  final String slug;
  final int pageSize;
  final int currentPage;
  final bool isAuthorized;
  final bool loadMore;
  final FilterDiningWithCategoryStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FilterDiningWithCategoryState({
    required this.model,
    this.name = '',
    this.favIds = const [],
    this.hideUnhideId = '',
    this.slug = '',
    required this.pageSize,
    this.currentPage = 0,
    this.isAuthorized = false,
    this.loadMore = false,
    this.status = FilterDiningWithCategoryStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FilterDiningWithCategoryState copyWith({
    DiningByCategoryResponseModel? model,
    String? name,
    List<String>? favIds,
    String? hideUnhideId,
    String? slug,
    int? pageSize,
    int? currentPage,
    bool? isAuthorized,
    bool? loadMore,
    FilterDiningWithCategoryStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FilterDiningWithCategoryState(
      model: model ?? this.model,
      name: name ?? this.name,
      favIds: favIds ?? this.favIds,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      slug: slug ?? this.slug,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

