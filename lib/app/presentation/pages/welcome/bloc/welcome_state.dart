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

part of 'welcome_bloc.dart';

enum WelcomeStatus { loading, authorized, unAuthorized, failure, maintenance, connectionError, home, location, appLocale, forceUpdate }

extension WelcomeStatusX on WelcomeStatus {
  bool get isLoading => this == WelcomeStatus.loading;
  bool get isAuthorized => this == WelcomeStatus.authorized;
  bool get isUnAuthorized => this == WelcomeStatus.unAuthorized;
  bool get isFailure => this == WelcomeStatus.failure;
  bool get isHome => this == WelcomeStatus.home;
  bool get isLocation => this == WelcomeStatus.location;
  bool get isAppLocale => this == WelcomeStatus.appLocale;
}

final class WelcomeState {
  final String locale;
  final int currentPageIndex;
  final WelcomeStatus status;
  final String alertMessage;
  final String extraMessage;
  final int statusCode;
  const WelcomeState({this.locale = '', this.currentPageIndex = 0, this.status = WelcomeStatus.loading, this.alertMessage = '', this.extraMessage = '', this.statusCode = 0});

  WelcomeState copyWith({String? locale, int? currentPageIndex, WelcomeStatus? status, String? alertMessage, String? extraMessage, int? statusCode}) {
    return WelcomeState(
      locale: locale ?? this.locale,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      status: status ?? this.status,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}

