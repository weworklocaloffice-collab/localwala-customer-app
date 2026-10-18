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

part of 'food_variation_modal_repeat_bloc.dart';

enum FoodVariationModalRepeatStatus { loading, success, failure, customError, successClose }

extension FoodVariationModalRepeatStatusX on FoodVariationModalRepeatStatus {
  bool get isLoading => this == FoodVariationModalRepeatStatus.loading;
  bool get isSuccess => this == FoodVariationModalRepeatStatus.success;
  bool get isFailure => this == FoodVariationModalRepeatStatus.failure;
  bool get isCustomError => this == FoodVariationModalRepeatStatus.customError;
  bool get isSuccessClose => this == FoodVariationModalRepeatStatus.successClose;
}

final class FoodVariationModalRepeatState {
  final List<FoodInCartModel> list;
  final RepeatQuantityListModal quantityList;
  final FoodVariationModalRepeatStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodVariationModalRepeatState({this.list = const [], required this.quantityList, this.status = FoodVariationModalRepeatStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  FoodVariationModalRepeatState copyWith({List<FoodInCartModel>? list, RepeatQuantityListModal? quantityList, FoodVariationModalRepeatStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FoodVariationModalRepeatState(
      list: list ?? this.list,
      quantityList: quantityList ?? this.quantityList,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

