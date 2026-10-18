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

part of 'subscription_food_info_modal_bloc.dart';

enum SubscriptionFoodInfoModalStatus { loading, success, failure, customError, saveClose, favAdd, favRemove }

extension SubscriptionFoodInfoModalStatusX on SubscriptionFoodInfoModalStatus {
  bool get isLoading => this == SubscriptionFoodInfoModalStatus.loading;
  bool get isSuccess => this == SubscriptionFoodInfoModalStatus.success;
  bool get isFailure => this == SubscriptionFoodInfoModalStatus.failure;
  bool get isCustomError => this == SubscriptionFoodInfoModalStatus.customError;
  bool get isFavAdd => this == SubscriptionFoodInfoModalStatus.favAdd;
  bool get isFavRemove => this == SubscriptionFoodInfoModalStatus.favRemove;
  bool get isSaveClose => this == SubscriptionFoodInfoModalStatus.saveClose;
}

final class SubscriptionFoodInfoModalState {
  final SingleFoodInfoModel info;
  final FoodVariationModalResponseModel cartItem;
  final double originalPrice;
  final double discountPrice;
  final String id;
  final bool canAddAddons;
  final bool canAddVariations;
  final SubscriptionFoodInfoModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SubscriptionFoodInfoModalState({
    required this.info,
    required this.cartItem,
    this.originalPrice = 0.0,
    this.discountPrice = 0.0,
    this.id = '',
    this.canAddAddons = false,
    this.canAddVariations = false,
    this.status = SubscriptionFoodInfoModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SubscriptionFoodInfoModalState copyWith({
    SingleFoodInfoModel? info,
    FoodVariationModalResponseModel? cartItem,
    double? originalPrice,
    double? discountPrice,
    String? id,
    bool? canAddAddons,
    bool? canAddVariations,
    String? categoryInView,
    SubscriptionFoodInfoModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SubscriptionFoodInfoModalState(
      info: info ?? this.info,
      cartItem: cartItem ?? this.cartItem,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      id: id ?? this.id,
      canAddAddons: canAddAddons ?? this.canAddAddons,
      canAddVariations: canAddVariations ?? this.canAddVariations,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

