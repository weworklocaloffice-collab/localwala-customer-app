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

part of 'restaurant_bloc.dart';

enum RestaurantStatus {
  loading,
  success,
  failure,
  empty,
  closed,
  customError,
  cartUpdate,
  cartError,
  favAdd,
  favRemove,
  favFoodUpdate,
  startHide,
  hideRequestFailed,
  hideSuccess,
  startUnhide,
  unHideRequestFailed,
  unHideSuccess,
  unauthorized,
  authorized,
  guestCheckoutStart,
  guestCheckoutSuccess,
  guestCheckoutFailed,
}

extension RestaurantStatusX on RestaurantStatus {
  bool get isLoading => this == RestaurantStatus.loading;
  bool get isSuccess => this == RestaurantStatus.success;
  bool get isFailure => this == RestaurantStatus.failure;
  bool get isCustomError => this == RestaurantStatus.customError;
  bool get isEmpty => this == RestaurantStatus.empty;
  bool get isClosed => this == RestaurantStatus.closed;
  bool get isCartUpdate => this == RestaurantStatus.cartUpdate;
  bool get isCartError => this == RestaurantStatus.cartError;
  bool get isFavAdd => this == RestaurantStatus.favAdd;
  bool get isFavRemove => this == RestaurantStatus.favRemove;
  bool get isFavFoodUpdate => this == RestaurantStatus.favFoodUpdate;
  bool get isStartHide => this == RestaurantStatus.startHide;
  bool get isHideRequestFailed => this == RestaurantStatus.hideRequestFailed;
  bool get isHideSuccess => this == RestaurantStatus.hideSuccess;
  bool get isStartUnhide => this == RestaurantStatus.startUnhide;
  bool get isUnhideRequestFailed => this == RestaurantStatus.unHideRequestFailed;
  bool get isUnhideSuccess => this == RestaurantStatus.unHideSuccess;
  bool get isUnauthorized => this == RestaurantStatus.unauthorized;
  bool get isAuthorized => this == RestaurantStatus.authorized;
  bool get isGuestCheckoutStart => this == RestaurantStatus.guestCheckoutStart;
  bool get isGuestCheckoutSuccess => this == RestaurantStatus.guestCheckoutSuccess;
  bool get isGuestCheckoutFailed => this == RestaurantStatus.guestCheckoutFailed;
}

final class RestaurantState {
  final bool isAuthorized;
  final RestaurantInfoResponseModel info;
  final List<RestaurantModalCategoryModel> category;
  final List<String> favIds;
  final String slug;
  final String name;
  final String categoryInView;
  final bool isRecommendedOpen;
  final Map<String, GlobalKey> globalMainCategoriesKey;
  final int cartTotalItem;
  final String cartSubTitle;
  final String cartHelpOne;
  final String cartHelpTwo;
  final String cartHelpThree;
  final double cartTotalAmount;
  final bool guestCheckout;
  final String campaignId;
  final String appLocale;
  final RestaurantStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantState({
    this.isAuthorized = false,
    required this.info,
    this.category = const [],
    this.favIds = const [],
    this.slug = '',
    this.name = '',
    this.categoryInView = '',
    this.isRecommendedOpen = true,
    this.globalMainCategoriesKey = const {},
    this.cartTotalItem = 0,
    this.cartSubTitle = '',
    this.cartHelpOne = '',
    this.cartHelpTwo = '',
    this.cartHelpThree = '',
    this.cartTotalAmount = 0,
    this.guestCheckout = false,
    this.campaignId = '',
    this.appLocale = '',
    this.status = RestaurantStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantState copyWith({
    bool? isAuthorized,
    RestaurantInfoResponseModel? info,
    List<RestaurantModalCategoryModel>? category,
    List<String>? favIds,
    String? slug,
    String? name,
    String? categoryInView,
    bool? isRecommendedOpen,
    Map<String, GlobalKey>? globalMainCategoriesKey,
    int? cartTotalItem,
    String? cartSubTitle,
    String? cartHelpOne,
    String? cartHelpTwo,
    String? cartHelpThree,
    double? cartTotalAmount,
    bool? guestCheckout,
    String? campaignId,
    String? appLocale,
    RestaurantStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantState(
      isAuthorized: isAuthorized ?? this.isAuthorized,
      info: info ?? this.info,
      category: category ?? this.category,
      favIds: favIds ?? this.favIds,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      categoryInView: categoryInView ?? this.categoryInView,
      isRecommendedOpen: isRecommendedOpen ?? this.isRecommendedOpen,
      globalMainCategoriesKey: globalMainCategoriesKey ?? this.globalMainCategoriesKey,
      cartTotalItem: cartTotalItem ?? this.cartTotalItem,
      cartSubTitle: cartSubTitle ?? this.cartSubTitle,
      cartHelpOne: cartHelpOne ?? this.cartHelpOne,
      cartHelpTwo: cartHelpTwo ?? this.cartHelpTwo,
      cartHelpThree: cartHelpThree ?? this.cartHelpThree,
      cartTotalAmount: cartTotalAmount ?? this.cartTotalAmount,
      guestCheckout: guestCheckout ?? this.guestCheckout,
      campaignId: campaignId ?? this.campaignId,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

