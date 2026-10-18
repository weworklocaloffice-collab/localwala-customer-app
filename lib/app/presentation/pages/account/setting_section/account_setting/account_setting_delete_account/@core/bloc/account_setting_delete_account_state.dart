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

part of 'account_setting_delete_account_bloc.dart';

enum AccountSettingDeleteAccountStatus { loading, success, failure, empty }

extension AccountSettingDeleteAccountStatusX on AccountSettingDeleteAccountStatus {
  bool get isLoading => this == AccountSettingDeleteAccountStatus.loading;
  bool get isSuccess => this == AccountSettingDeleteAccountStatus.success;
  bool get isFailure => this == AccountSettingDeleteAccountStatus.failure;
  bool get isEmpty => this == AccountSettingDeleteAccountStatus.empty;
}

final class AccountSettingDeleteAccountState {
  final AccountSettingDeleteAccountReasonListResponseModel list;
  final AccountSettingDeleteAccountStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingDeleteAccountState({required this.list, this.status = AccountSettingDeleteAccountStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  AccountSettingDeleteAccountState copyWith({AccountSettingDeleteAccountReasonListResponseModel? list, AccountSettingDeleteAccountStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AccountSettingDeleteAccountState(
      list: list ?? this.list,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

