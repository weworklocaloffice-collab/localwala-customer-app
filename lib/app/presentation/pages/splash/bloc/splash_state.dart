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

part of 'splash_bloc.dart';

enum SplashStatus { loading, intro, authorized, unAuthorized, failure, maintenance, connectionError, home, location, appLocale, forceUpdate }

extension SplashStatusX on SplashStatus {
  bool get isLoading => this == SplashStatus.loading;
  bool get isIntro => this == SplashStatus.intro;
  bool get isAuthorized => this == SplashStatus.authorized;
  bool get isUnAuthorized => this == SplashStatus.unAuthorized;
  bool get isFailure => this == SplashStatus.failure;
  bool get isMaintenance => this == SplashStatus.maintenance;
  bool get isConnectionError => this == SplashStatus.connectionError;
  bool get isHome => this == SplashStatus.home;
  bool get isLocation => this == SplashStatus.location;
  bool get isAppLocale => this == SplashStatus.appLocale;
  bool get isForceUpdate => this == SplashStatus.forceUpdate;
}

final class SplashState {
  final String appLocale;
  final String businessEmail;
  final String businessMobile;
  final String newUpdateVersion;
  final String versionUpdateUrl;
  final SplashStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SplashState({
    this.appLocale = '',
    this.businessEmail = '',
    this.businessMobile = '',
    this.newUpdateVersion = '',
    this.versionUpdateUrl = '',
    this.status = SplashStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SplashState copyWith({String? appLocale, String? businessEmail, String? businessMobile, String? newUpdateVersion, String? versionUpdateUrl, SplashStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return SplashState(
      appLocale: appLocale ?? this.appLocale,
      businessEmail: businessEmail ?? this.businessEmail,
      businessMobile: businessMobile ?? this.businessMobile,
      newUpdateVersion: newUpdateVersion ?? this.newUpdateVersion,
      versionUpdateUrl: versionUpdateUrl ?? this.versionUpdateUrl,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

