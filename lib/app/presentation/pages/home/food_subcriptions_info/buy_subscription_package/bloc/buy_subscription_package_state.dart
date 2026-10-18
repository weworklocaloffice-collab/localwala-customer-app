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

part of 'buy_subscription_package_bloc.dart';

enum BuySubscriptionPackageStatus { loading, success, failure, customError, placingOrder, makePayment }

extension BuySubscriptionPackageStatusX on BuySubscriptionPackageStatus {
  bool get isLoading => this == BuySubscriptionPackageStatus.loading;
  bool get isSuccess => this == BuySubscriptionPackageStatus.success;
  bool get isFailure => this == BuySubscriptionPackageStatus.failure;
  bool get isCustomError => this == BuySubscriptionPackageStatus.customError;
  bool get isPlacingOrder => this == BuySubscriptionPackageStatus.placingOrder;
  bool get isMakePayment => this == BuySubscriptionPackageStatus.makePayment;
}

final class BuySubscriptionPackageState {
  final String id;
  final BuySubscriptionTiffinPackageResponseModel info;
  final String payment;
  final String paymentName;
  final String paymentImageURL;
  final String foodInstruction;
  final String deliveryInstructionId;
  final String deliveryInstruction;
  final String deliveryInstructionImage;
  final String deliveryAddressId;
  final double itemTotal;
  final double serviceCharge;
  final double foodServiceCharge;
  final double extraCharge;
  final double packagingCharges;
  final double packagingChargesTax;
  final double grandTotal;
  final int addressTitleNumber;
  final String addressTitle;
  final String addressSubTitle;
  final String receiverName;
  final String receiverCountryCode;
  final String receiverContact;
  final String savedSlot;
  final List<FoodInCartModel> inCart;
  final DeliveryAddressModalResponseModel savedAddress;
  final String paymentURL;
  final String appLocale;
  final BuySubscriptionPackageStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const BuySubscriptionPackageState({
    this.id = '',
    required this.info,
    this.payment = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.foodInstruction = '',
    this.deliveryInstructionId = '',
    this.deliveryInstruction = '',
    this.deliveryInstructionImage = '',
    this.deliveryAddressId = '',
    this.itemTotal = 0,
    this.serviceCharge = 0,
    this.foodServiceCharge = 0,
    this.extraCharge = 0,
    this.packagingCharges = 0,
    this.packagingChargesTax = 0,
    this.grandTotal = 0,
    this.addressTitleNumber = 0,
    this.addressTitle = '0',
    this.addressSubTitle = '',
    this.receiverName = '',
    this.receiverCountryCode = '',
    this.receiverContact = '',
    this.savedSlot = '',
    this.inCart = const [],
    required this.savedAddress,
    this.paymentURL = '',
    this.appLocale = '',
    this.status = BuySubscriptionPackageStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  BuySubscriptionPackageState copyWith({
    String? id,
    BuySubscriptionTiffinPackageResponseModel? info,
    String? payment,
    String? paymentName,
    String? paymentImageURL,
    String? foodInstruction,
    String? deliveryInstructionId,
    String? deliveryInstruction,
    String? deliveryInstructionImage,
    String? deliveryAddressId,
    double? itemTotal,
    double? serviceCharge,
    double? foodServiceCharge,
    double? extraCharge,
    double? packagingCharges,
    double? packagingChargesTax,
    double? grandTotal,
    int? addressTitleNumber,
    String? addressTitle,
    String? addressSubTitle,
    String? receiverName,
    String? receiverCountryCode,
    String? receiverContact,
    String? savedSlot,
    List<FoodInCartModel>? inCart,
    DeliveryAddressModalResponseModel? savedAddress,
    String? paymentURL,
    String? appLocale,
    BuySubscriptionPackageStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return BuySubscriptionPackageState(
      id: id ?? this.id,
      info: info ?? this.info,
      payment: payment ?? this.payment,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      foodInstruction: foodInstruction ?? this.foodInstruction,
      deliveryInstructionId: deliveryInstructionId ?? this.deliveryInstructionId,
      deliveryInstruction: deliveryInstruction ?? this.deliveryInstruction,
      deliveryInstructionImage: deliveryInstructionImage ?? this.deliveryInstructionImage,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      itemTotal: itemTotal ?? this.itemTotal,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      foodServiceCharge: foodServiceCharge ?? this.foodServiceCharge,
      extraCharge: extraCharge ?? this.extraCharge,
      packagingCharges: packagingCharges ?? this.packagingCharges,
      packagingChargesTax: packagingChargesTax ?? this.packagingChargesTax,
      grandTotal: grandTotal ?? this.grandTotal,
      addressTitleNumber: addressTitleNumber ?? this.addressTitleNumber,
      addressTitle: addressTitle ?? this.addressTitle,
      addressSubTitle: addressSubTitle ?? this.addressSubTitle,
      receiverName: receiverName ?? this.receiverName,
      receiverCountryCode: receiverCountryCode ?? this.receiverCountryCode,
      receiverContact: receiverContact ?? this.receiverContact,
      savedSlot: savedSlot ?? this.savedSlot,
      inCart: inCart ?? this.inCart,
      savedAddress: savedAddress ?? this.savedAddress,
      paymentURL: paymentURL ?? this.paymentURL,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

