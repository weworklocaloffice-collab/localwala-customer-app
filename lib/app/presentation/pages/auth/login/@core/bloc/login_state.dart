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

part of 'login_bloc.dart';

enum LoginStatus { initial, notificationGranted, notificationDicline, location, home, guestRegisterStart, guestRegisterFailed, guestRegisterHome, guestRegisterLocation }

extension LoginStatusX on LoginStatus {
  bool get isInitial => this == LoginStatus.initial;
  bool get isNotificationGranted => this == LoginStatus.notificationGranted;
  bool get isNotificationDicline => this == LoginStatus.notificationDicline;
  bool get isLocation => this == LoginStatus.location;
  bool get isHome => this == LoginStatus.home;
  bool get isGuestRegisterStart => this == LoginStatus.guestRegisterStart;
  bool get isGuestRegisterFailed => this == LoginStatus.guestRegisterFailed;
  bool get isGuestRegisterHome => this == LoginStatus.guestRegisterHome;
  bool get isGuestRegisterLocation => this == LoginStatus.guestRegisterLocation;
}

final class LoginState {
  final String userLoginWith;
  final bool guestCheckout;
  final String locale;
  final LoginStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const LoginState({this.userLoginWith = '', this.guestCheckout = false, this.locale = '', this.status = LoginStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  LoginState copyWith({String? userLoginWith, bool? guestCheckout, String? locale, LoginStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return LoginState(
      userLoginWith: userLoginWith ?? this.userLoginWith,
      guestCheckout: guestCheckout ?? this.guestCheckout,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

