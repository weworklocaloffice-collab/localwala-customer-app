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

part of 'select_restaurant_type_modal_bloc.dart';

enum SelectRestaurantTypeModalStatus { loading, success, failure, empty, saved }

extension SelectRestaurantTypeModalStatusX on SelectRestaurantTypeModalStatus {
  bool get isLoading => this == SelectRestaurantTypeModalStatus.loading;
  bool get isSuccess => this == SelectRestaurantTypeModalStatus.success;
  bool get isFailure => this == SelectRestaurantTypeModalStatus.failure;
  bool get isEmpty => this == SelectRestaurantTypeModalStatus.empty;
  bool get isSaved => this == SelectRestaurantTypeModalStatus.saved;
}

final class SelectRestaurantTypeModalState {
  final ActiveRestaurantTypeListResponseModel model;
  final List<String> typeIds;
  final List<String> typeNames;
  final SelectRestaurantTypeModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SelectRestaurantTypeModalState({
    required this.model,
    this.typeIds = const [],
    this.typeNames = const [],
    this.status = SelectRestaurantTypeModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SelectRestaurantTypeModalState copyWith({
    ActiveRestaurantTypeListResponseModel? model,
    List<String>? typeIds,
    List<String>? typeNames,
    SelectRestaurantTypeModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SelectRestaurantTypeModalState(
      model: model ?? this.model,
      typeIds: typeIds ?? this.typeIds,
      typeNames: typeNames ?? this.typeNames,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

