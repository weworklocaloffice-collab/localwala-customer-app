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

part of 'restaurant_menu_modal_bloc.dart';

enum RestaurantMenuModalStatus { initial, success, failure }

extension RestaurantMenuModalStatusX on RestaurantMenuModalStatus {
  bool get isInitial => this == RestaurantMenuModalStatus.initial;
  bool get isSuccess => this == RestaurantMenuModalStatus.success;
  bool get isFailure => this == RestaurantMenuModalStatus.failure;
}

final class RestaurantMenuModalState {
  final String currentInView;
  final RestaurantMenuModalStatus status;
  final bool isDarkTheme;
  final String alertMessage;
  final String extraMessage;
  const RestaurantMenuModalState({this.currentInView = '', this.status = RestaurantMenuModalStatus.initial, this.isDarkTheme = false, this.alertMessage = '', this.extraMessage = ''});

  RestaurantMenuModalState copyWith({String? currentInView, RestaurantMenuModalStatus? status, bool? isDarkTheme, String? alertMessage, String? extraMessage}) {
    return RestaurantMenuModalState(
      currentInView: currentInView ?? this.currentInView,
      status: status ?? this.status,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

