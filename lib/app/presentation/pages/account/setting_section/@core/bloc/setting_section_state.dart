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

part of 'setting_section_bloc.dart';

enum SettingSectionStatus { initial, failure }

extension SettingSectionStatusX on SettingSectionStatus {
  bool get isInitial => this == SettingSectionStatus.initial;
  bool get isFailure => this == SettingSectionStatus.failure;
}

final class SettingSectionState {
  final bool isAuthorized;
  final String currentVersion;
  final SettingSectionStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SettingSectionState({this.isAuthorized = false, this.currentVersion = '', this.status = SettingSectionStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  SettingSectionState copyWith({bool? isAuthorized, String? currentVersion, SettingSectionStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return SettingSectionState(
      isAuthorized: isAuthorized ?? this.isAuthorized,
      currentVersion: currentVersion ?? this.currentVersion,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

