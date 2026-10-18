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

part of 'app_page_bloc.dart';

enum AppPageStatus { loading, loaded, failure }

extension AppPageStatusX on AppPageStatus {
  bool get isLoading => this == AppPageStatus.loading;
  bool get isLoaded => this == AppPageStatus.loaded;
  bool get isFailure => this == AppPageStatus.failure;
}

final class AppPageState {
  final String title;
  final String description;
  final AppPageStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AppPageState({this.title = '', this.description = '', this.status = AppPageStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  AppPageState copyWith({String? title, String? description, AppPageStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AppPageState(
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

