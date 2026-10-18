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

part of 'single_food_from_banner_modal_bloc.dart';

enum SingleFoodFromBannerModalStatus { loading, success, failure, customError, saveClose, favAdd, favRemove, cartUpdate, cartError }

extension SingleFoodFromBannerModalStateX on SingleFoodFromBannerModalStatus {
  bool get isLoading => this == SingleFoodFromBannerModalStatus.loading;
  bool get isSuccess => this == SingleFoodFromBannerModalStatus.success;
  bool get isFailure => this == SingleFoodFromBannerModalStatus.failure;
  bool get isCustomError => this == SingleFoodFromBannerModalStatus.customError;
  bool get isFavAdd => this == SingleFoodFromBannerModalStatus.favAdd;
  bool get isFavRemove => this == SingleFoodFromBannerModalStatus.favRemove;
  bool get isSaveClose => this == SingleFoodFromBannerModalStatus.saveClose;
  bool get isCartUpdate => this == SingleFoodFromBannerModalStatus.cartUpdate;
  bool get isCartError => this == SingleFoodFromBannerModalStatus.cartError;
}

final class SingleFoodFromBannerModalState {
  final String id;
  final String name;
  final SingleFoodInfoFromBannerModel detail;
  final bool isFromCart;
  final bool newItem;
  final bool isRepeated;
  final double originalPrice;
  final double discountPrice;
  final List<FoodInCartModel> list;
  final RepeatQuantityListModal quantityList;
  final String instruction;
  final SingleFoodFromBannerModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SingleFoodFromBannerModalState({
    this.id = '',
    this.name = '',
    required this.detail,
    this.isFromCart = false,
    this.newItem = false,
    this.isRepeated = false,
    this.originalPrice = 0.0,
    this.discountPrice = 0.0,
    this.list = const [],
    required this.quantityList,
    this.instruction = '',
    this.status = SingleFoodFromBannerModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SingleFoodFromBannerModalState copyWith({
    String? id,
    String? name,
    SingleFoodInfoFromBannerModel? detail,
    bool? isFromCart,
    bool? newItem,
    bool? isRepeated,
    double? originalPrice,
    double? discountPrice,
    List<FoodInCartModel>? list,
    RepeatQuantityListModal? quantityList,
    String? instruction,
    SingleFoodFromBannerModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SingleFoodFromBannerModalState(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      isFromCart: isFromCart ?? this.isFromCart,
      newItem: newItem ?? this.newItem,
      isRepeated: isRepeated ?? this.isRepeated,
      list: list ?? this.list,
      quantityList: quantityList ?? this.quantityList,
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

