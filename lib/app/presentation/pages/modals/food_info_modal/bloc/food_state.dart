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

part of 'food_bloc.dart';

enum FoodStatus { loading, success, failure, customError, saveClose, favAdd, favRemove }

extension FoodStateX on FoodStatus {
  bool get isLoading => this == FoodStatus.loading;
  bool get isSuccess => this == FoodStatus.success;
  bool get isFailure => this == FoodStatus.failure;
  bool get isCustomError => this == FoodStatus.customError;
  bool get isFavAdd => this == FoodStatus.favAdd;
  bool get isFavRemove => this == FoodStatus.favRemove;
  bool get isSaveClose => this == FoodStatus.saveClose;
}

final class FoodState {
  final String id;
  final SingleFoodInfoModel info;
  final FoodVariationModalResponseModel cartItem;
  final double originalPrice;
  final double discountPrice;
  final String instruction;
  final FoodStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodState({
    this.id = '',
    required this.info,
    required this.cartItem,
    this.originalPrice = 0.0,
    this.discountPrice = 0.0,
    this.instruction = '',
    this.status = FoodStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  FoodState copyWith({
    String? id,
    SingleFoodInfoModel? info,
    FoodVariationModalResponseModel? cartItem,
    double? originalPrice,
    double? discountPrice,
    String? instruction,
    FoodStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return FoodState(
      info: info ?? this.info,
      id: id ?? this.id,
      cartItem: cartItem ?? this.cartItem,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPrice: discountPrice ?? this.discountPrice,
      instruction: instruction ?? this.instruction,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

