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

part of 'select_cuisine_modal_bloc.dart';

enum SelectCuisineModalStatus { loading, success, failure, empty, saved }

extension SelectCuisineModalStatusX on SelectCuisineModalStatus {
  bool get isLoading => this == SelectCuisineModalStatus.loading;
  bool get isSuccess => this == SelectCuisineModalStatus.success;
  bool get isFailure => this == SelectCuisineModalStatus.failure;
  bool get isEmpty => this == SelectCuisineModalStatus.empty;
  bool get isSaved => this == SelectCuisineModalStatus.saved;
}

final class SelectCuisineModalState {
  final ActiveCuisineListModel model;
  final List<String> cuisineIds;
  final List<String> cuisineNames;
  final SelectCuisineModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SelectCuisineModalState({required this.model, this.cuisineIds = const [], this.cuisineNames = const [], this.status = SelectCuisineModalStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  SelectCuisineModalState copyWith({ActiveCuisineListModel? model, List<String>? cuisineIds, List<String>? cuisineNames, SelectCuisineModalStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return SelectCuisineModalState(
      model: model ?? this.model,
      cuisineIds: cuisineIds ?? this.cuisineIds,
      cuisineNames: cuisineNames ?? this.cuisineNames,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

