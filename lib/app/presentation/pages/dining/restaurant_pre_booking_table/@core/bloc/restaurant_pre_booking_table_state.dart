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

part of 'restaurant_pre_booking_table_bloc.dart';

enum RestaurantPreBookingTableStatus { initial, empty, success, failure, customError, validateCoupon, loginGuest, loginGuestSuccess }

extension RestaurantPreBookingTableStatusX on RestaurantPreBookingTableStatus {
  bool get isInitial => this == RestaurantPreBookingTableStatus.initial;
  bool get isSuccess => this == RestaurantPreBookingTableStatus.success;
  bool get isFailure => this == RestaurantPreBookingTableStatus.failure;
  bool get isEmpty => this == RestaurantPreBookingTableStatus.empty;
  bool get isCustomError => this == RestaurantPreBookingTableStatus.customError;
  bool get isValidateCoupon => this == RestaurantPreBookingTableStatus.validateCoupon;
  bool get isLoginGuest => this == RestaurantPreBookingTableStatus.loginGuest;
  bool get isLoginGuestSuccess => this == RestaurantPreBookingTableStatus.loginGuestSuccess;
}

final class RestaurantPreBookingTableState {
  final String restaurantId;
  final String restaurantName;
  final String restaurantSlug;
  final bool canProceed;
  final DiningBookingInformationResponseModel model;
  final List<DiningScheduleMealTypeModel> mealTime;
  final List<DiningBookingCouponConfigModel> showCoupon;
  final String selectedCoupon;
  final double couponCoverCharge;
  final int mealIndexToShow;
  final List<DiningBookTableDateListModel> dates;
  final String bookingDate;
  final String bookingFormatDate;
  final String selectedMeal;
  final int bookingGuest;
  final String bookingSlot;
  final bool isValid;
  final double toPay;
  final RestaurantPreBookingTableStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantPreBookingTableState({
    this.restaurantId = '',
    this.restaurantName = '',
    this.restaurantSlug = '',
    this.canProceed = false,
    required this.model,
    this.dates = const [],
    this.mealTime = const [],
    this.showCoupon = const [],
    this.selectedCoupon = '',
    this.couponCoverCharge = 0.0,
    this.mealIndexToShow = 0,
    this.bookingDate = '',
    this.bookingFormatDate = '',
    this.selectedMeal = '',
    this.bookingGuest = 0,
    this.bookingSlot = '',
    this.isValid = false,
    this.toPay = 0.0,
    this.status = RestaurantPreBookingTableStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantPreBookingTableState copyWith({
    String? restaurantId,
    String? restaurantName,
    String? restaurantSlug,
    bool? canProceed,
    DiningBookingInformationResponseModel? model,
    List<DiningBookTableDateListModel>? dates,
    List<DiningScheduleMealTypeModel>? mealTime,
    List<DiningBookingCouponConfigModel>? showCoupon,
    String? selectedCoupon,
    double? couponCoverCharge,
    int? mealIndexToShow,
    String? bookingDate,
    String? bookingFormatDate,
    String? selectedMeal,
    int? bookingGuest,
    String? bookingSlot,
    bool? isValid,
    double? toPay,
    RestaurantPreBookingTableStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantPreBookingTableState(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantSlug: restaurantSlug ?? this.restaurantSlug,
      canProceed: canProceed ?? this.canProceed,
      model: model ?? this.model,
      dates: dates ?? this.dates,
      mealTime: mealTime ?? this.mealTime,
      showCoupon: showCoupon ?? this.showCoupon,
      selectedCoupon: selectedCoupon ?? this.selectedCoupon,
      couponCoverCharge: couponCoverCharge ?? this.couponCoverCharge,
      mealIndexToShow: mealIndexToShow ?? this.mealIndexToShow,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingFormatDate: bookingFormatDate ?? this.bookingFormatDate,
      selectedMeal: selectedMeal ?? this.selectedMeal,
      bookingGuest: bookingGuest ?? this.bookingGuest,
      bookingSlot: bookingSlot ?? this.bookingSlot,
      isValid: isValid ?? this.isValid,
      toPay: toPay ?? this.toPay,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

