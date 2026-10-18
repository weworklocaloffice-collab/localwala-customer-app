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

part of 'home_bloc.dart';

enum HomeStatus { loading, empty, success, failure, customError, cartUpdate, cartError, restaurantFav, foodFav, hidden, unhidden }

extension HomeStatusX on HomeStatus {
  bool get isLoading => this == HomeStatus.loading;
  bool get isEmpty => this == HomeStatus.empty;
  bool get isSuccess => this == HomeStatus.success;
  bool get isFailure => this == HomeStatus.failure;
  bool get isCustomError => this == HomeStatus.customError;
  bool get isCartUpdate => this == HomeStatus.cartUpdate;
  bool get isCartError => this == HomeStatus.cartError;
  bool get isRestaurantFav => this == HomeStatus.restaurantFav;
  bool get isFoodFav => this == HomeStatus.foodFav;
  bool get isHidden => this == HomeStatus.hidden;
  bool get isUnhidden => this == HomeStatus.unhidden;
}

final class HomeState {
  final HomeResponseModel homeData;
  final List<CampaignListModel> campaignList;
  final String addressTitle;
  final String addressSubTitle;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final String hideUnhideId;
  final int notificationCount;
  final bool isAuthorized;
  final String locale;
  final List<String> favRestIds;
  final String appLocale;
  final HomeStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const HomeState({
    required this.homeData,
    this.campaignList = const [],
    this.addressTitle = '0',
    this.addressSubTitle = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.hideUnhideId = '',
    this.notificationCount = 0,
    this.isAuthorized = false,
    this.locale = '',
    this.favRestIds = const [],
    this.appLocale = '',
    this.status = HomeStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  HomeState copyWith({
    HomeResponseModel? homeData,
    List<CampaignListModel>? campaignList,
    String? addressTitle,
    String? addressSubTitle,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    bool? isAuthorized,
    String? hideUnhideId,
    int? notificationCount,
    String? locale,
    List<String>? favRestIds,
    String? appLocale,
    HomeStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return HomeState(
      homeData: homeData ?? this.homeData,
      campaignList: campaignList ?? this.campaignList,
      addressTitle: addressTitle ?? this.addressTitle,
      addressSubTitle: addressSubTitle ?? this.addressSubTitle,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      notificationCount: notificationCount ?? this.notificationCount,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      locale: locale ?? this.locale,
      favRestIds: favRestIds ?? this.favRestIds,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}
