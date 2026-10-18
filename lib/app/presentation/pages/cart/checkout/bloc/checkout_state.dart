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

part of 'checkout_bloc.dart';

enum CheckoutStatus { loading, empty, success, failure, customError, cartUpdate, cartError, placingOrder, orderPlaced, makePayment }

extension CheckoutStatusX on CheckoutStatus {
  bool get isLoading => this == CheckoutStatus.loading;
  bool get isEmpty => this == CheckoutStatus.empty;
  bool get isSuccess => this == CheckoutStatus.success;
  bool get isFailure => this == CheckoutStatus.failure;
  bool get isCustomError => this == CheckoutStatus.customError;
  bool get isCartUpdate => this == CheckoutStatus.cartUpdate;
  bool get isCartError => this == CheckoutStatus.cartError;
  bool get isPlacingOrder => this == CheckoutStatus.placingOrder;
  bool get isOrderPlaced => this == CheckoutStatus.orderPlaced;
  bool get isMakePayment => this == CheckoutStatus.makePayment;
}

final class CheckoutState {
  final String user;
  final String orderTo;
  final String trackingId;
  final OrderSettingsModel orderSettings;
  final String restaurant;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final List<FoodInCartModel> inCart;
  final String foodInstruction;
  final String deliveryInstructionId;
  final String deliveryInstruction;
  final String deliveryInstructionImage;
  final double itemTotal;
  final double realPrice;
  final double itemDiscount;
  final bool couponUsed;
  final String couponTitle;
  final CouponConfigModel couponData;
  final double couponDiscount;
  final bool walletUsed;
  final double walletAmount;
  final double serviceCharge;
  final String serviceChargeName;
  final double foodServiceCharge;
  final String foodServiceChargeName;
  final double deliveryTip;
  final double extraCharge;
  final double deliveryCharge;
  final double packagingCharges;
  final double packagingChargesTax;
  final double grandTotal;
  final String deliveryAddressId;
  final String payment;
  final String paymentName;
  final String paymentImageURL;
  final String addressTitle;
  final String addressSubTitle;
  final String receiverName;
  final String receiverCountryCode;
  final String receiverContact;
  final bool instantOrder;
  final bool scheduleOrder;
  final String scheduleDate;
  final String scheduleTime;
  final List<String> timeSlots;
  final int customerCanOrderWithinDays;
  final String locale;
  final bool isMinAmountSatisfied;
  final bool canDeliverNow;
  final bool? coversRestaurant;
  final String coversReason;
  final String paymentURL;
  final List<String> permissionList;
  final CheckoutStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CheckoutState({
    this.user = '',
    this.orderTo = 'homedelivery',
    this.trackingId = '',
    required this.orderSettings,
    this.restaurant = '',
    this.deliveryLatitude = 0.0,
    this.deliveryLongitude = 0.0,
    this.inCart = const [],
    this.foodInstruction = '',
    this.deliveryInstructionId = '',
    this.deliveryInstruction = '',
    this.deliveryInstructionImage = '',
    this.itemTotal = 0,
    this.realPrice = 0,
    this.itemDiscount = 0,
    this.couponUsed = false,
    this.couponTitle = '',
    required this.couponData,
    this.couponDiscount = 0,
    this.walletUsed = false,
    this.walletAmount = 0,
    this.serviceCharge = 0,
    this.serviceChargeName = '',
    this.foodServiceCharge = 0,
    this.foodServiceChargeName = '',
    this.deliveryTip = 0,
    this.extraCharge = 0,
    this.packagingCharges = 0,
    this.packagingChargesTax = 0,
    this.deliveryCharge = 0,
    this.grandTotal = 0,
    this.deliveryAddressId = '',
    this.payment = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.addressTitle = '0',
    this.addressSubTitle = '',
    this.receiverName = '',
    this.receiverCountryCode = '',
    this.receiverContact = '',
    this.instantOrder = true,
    this.scheduleOrder = false,
    this.scheduleDate = '',
    this.scheduleTime = '',
    this.timeSlots = const [],
    this.customerCanOrderWithinDays = 0,
    this.locale = 'locale',
    this.isMinAmountSatisfied = false,
    this.canDeliverNow = false,
    this.coversRestaurant,
    this.coversReason = '',
    this.paymentURL = '',
    this.permissionList = const [],
    this.status = CheckoutStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  CheckoutState copyWith({
    String? user,
    String? orderTo,
    String? trackingId,
    OrderSettingsModel? orderSettings,
    String? restaurant,
    double? deliveryLatitude,
    double? deliveryLongitude,
    List<FoodInCartModel>? inCart,
    String? foodInstruction,
    String? deliveryInstructionId,
    String? deliveryInstruction,
    String? deliveryInstructionImage,
    double? itemTotal,
    double? realPrice,
    double? itemDiscount,
    bool? couponUsed,
    String? couponTitle,
    CouponConfigModel? couponData,
    double? couponDiscount,
    bool? walletUsed,
    double? walletAmount,
    double? serviceCharge,
    String? serviceChargeName,
    double? foodServiceCharge,
    String? foodServiceChargeName,
    double? deliveryTip,
    double? extraCharge,
    double? deliveryCharge,
    double? packagingCharges,
    double? packagingChargesTax,
    double? grandTotal,
    String? deliveryAddressId,
    String? payment,
    String? paymentName,
    String? paymentImageURL,
    String? addressTitle,
    String? addressSubTitle,
    String? receiverName,
    String? receiverCountryCode,
    String? receiverContact,
    bool? instantOrder,
    bool? scheduleOrder,
    String? scheduleDate,
    String? scheduleTime,
    List<String>? timeSlots,
    int? customerCanOrderWithinDays,
    String? locale,
    bool? isMinAmountSatisfied,
    bool? canDeliverNow,
    bool? coversRestaurant,
    String? coversReason,
    bool? clearCovers,
    String? paymentURL,
    List<String>? permissionList,
    CheckoutStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return CheckoutState(
      user: user ?? this.user,
      orderTo: orderTo ?? this.orderTo,
      trackingId: trackingId ?? this.trackingId,
      orderSettings: orderSettings ?? this.orderSettings,
      restaurant: restaurant ?? this.restaurant,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      inCart: inCart ?? this.inCart,
      foodInstruction: foodInstruction ?? this.foodInstruction,
      deliveryInstructionId: deliveryInstructionId ?? this.deliveryInstructionId,
      deliveryInstruction: deliveryInstruction ?? this.deliveryInstruction,
      deliveryInstructionImage: deliveryInstructionImage ?? this.deliveryInstructionImage,
      itemTotal: itemTotal ?? this.itemTotal,
      realPrice: realPrice ?? this.realPrice,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      couponUsed: couponUsed ?? this.couponUsed,
      couponTitle: couponTitle ?? this.couponTitle,
      couponData: couponData ?? this.couponData,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      walletUsed: walletUsed ?? this.walletUsed,
      walletAmount: walletAmount ?? this.walletAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      serviceChargeName: serviceChargeName ?? this.serviceChargeName,
      foodServiceCharge: foodServiceCharge ?? this.foodServiceCharge,
      foodServiceChargeName: foodServiceChargeName ?? this.foodServiceChargeName,
      deliveryTip: deliveryTip ?? this.deliveryTip,
      extraCharge: extraCharge ?? this.extraCharge,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      packagingCharges: packagingCharges ?? this.packagingCharges,
      packagingChargesTax: packagingChargesTax ?? this.packagingChargesTax,
      grandTotal: grandTotal ?? this.grandTotal,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      payment: payment ?? this.payment,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      addressTitle: addressTitle ?? this.addressTitle,
      addressSubTitle: addressSubTitle ?? this.addressSubTitle,
      receiverName: receiverName ?? this.receiverName,
      receiverCountryCode: receiverCountryCode ?? this.receiverCountryCode,
      receiverContact: receiverContact ?? this.receiverContact,
      instantOrder: instantOrder ?? this.instantOrder,
      scheduleOrder: scheduleOrder ?? this.scheduleOrder,
      scheduleDate: scheduleDate ?? this.scheduleDate,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      timeSlots: timeSlots ?? this.timeSlots,
      customerCanOrderWithinDays: customerCanOrderWithinDays ?? this.customerCanOrderWithinDays,
      locale: locale ?? this.locale,
      isMinAmountSatisfied: isMinAmountSatisfied ?? this.isMinAmountSatisfied,
      canDeliverNow: canDeliverNow ?? this.canDeliverNow,
      // Nullable fields cannot reset through ?? (null means "keep"), so an
      // explicit flag clears the coverage banner on address change.
      coversRestaurant: clearCovers == true ? null : (coversRestaurant ?? this.coversRestaurant),
      coversReason: clearCovers == true ? '' : (coversReason ?? this.coversReason),
      paymentURL: paymentURL ?? this.paymentURL,
      permissionList: permissionList ?? this.permissionList,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

