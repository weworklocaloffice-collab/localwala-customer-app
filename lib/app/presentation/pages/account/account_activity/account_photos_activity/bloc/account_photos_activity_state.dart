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

part of 'account_photos_activity_bloc.dart';

enum AccountPhotosActivityStatus { loading, empty, success, failure }

extension AccountPhotosActivityStatusX on AccountPhotosActivityStatus {
  bool get isLoading => this == AccountPhotosActivityStatus.loading;
  bool get isSuccess => this == AccountPhotosActivityStatus.success;
  bool get isFailure => this == AccountPhotosActivityStatus.failure;
  bool get isEmpty => this == AccountPhotosActivityStatus.empty;
}

final class AccountPhotosActivityState {
  final MyMediaFilesResponseModel model;
  final AccountPhotosActivityStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountPhotosActivityState({required this.model, this.status = AccountPhotosActivityStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  AccountPhotosActivityState copyWith({MyMediaFilesResponseModel? model, AccountPhotosActivityStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AccountPhotosActivityState(
      model: model ?? this.model,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

