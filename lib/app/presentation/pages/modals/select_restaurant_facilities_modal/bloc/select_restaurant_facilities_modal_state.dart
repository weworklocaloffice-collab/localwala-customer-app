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

part of 'select_restaurant_facilities_modal_bloc.dart';

enum SelectRestaurantFacilitiesModalStatus { loading, success, failure, empty, saved }

extension SelectRestaurantFacilitiesModalStatusX on SelectRestaurantFacilitiesModalStatus {
  bool get isLoading => this == SelectRestaurantFacilitiesModalStatus.loading;
  bool get isSuccess => this == SelectRestaurantFacilitiesModalStatus.success;
  bool get isFailure => this == SelectRestaurantFacilitiesModalStatus.failure;
  bool get isEmpty => this == SelectRestaurantFacilitiesModalStatus.empty;
  bool get isSaved => this == SelectRestaurantFacilitiesModalStatus.saved;
}

final class SelectRestaurantFacilitiesModalState {
  final ActiveRestaurantFacilitiyListModel model;
  final List<String> facilityIds;
  final List<String> facilityNames;
  final SelectRestaurantFacilitiesModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SelectRestaurantFacilitiesModalState({
    required this.model,
    this.facilityIds = const [],
    this.facilityNames = const [],
    this.status = SelectRestaurantFacilitiesModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SelectRestaurantFacilitiesModalState copyWith({
    ActiveRestaurantFacilitiyListModel? model,
    List<String>? facilityIds,
    List<String>? facilityNames,
    SelectRestaurantFacilitiesModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SelectRestaurantFacilitiesModalState(
      model: model ?? this.model,
      facilityIds: facilityIds ?? this.facilityIds,
      facilityNames: facilityNames ?? this.facilityNames,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

