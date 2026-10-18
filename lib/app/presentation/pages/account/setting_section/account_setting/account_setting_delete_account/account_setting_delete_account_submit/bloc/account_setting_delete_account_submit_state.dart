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

part of 'account_setting_delete_account_submit_bloc.dart';

enum AccountSettingDeleteAccountSubmitStatus { initial, loading, success, failure }

extension AccountSettingDeleteAccountSubmitStatusX on AccountSettingDeleteAccountSubmitStatus {
  bool get isInitial => this == AccountSettingDeleteAccountSubmitStatus.initial;
  bool get isLoading => this == AccountSettingDeleteAccountSubmitStatus.loading;
  bool get isSuccess => this == AccountSettingDeleteAccountSubmitStatus.success;
  bool get isFailure => this == AccountSettingDeleteAccountSubmitStatus.failure;
}

final class AccountSettingDeleteAccountSubmitState {
  final String reason;
  final AccountSettingDeleteAccountSubmitStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingDeleteAccountSubmitState({this.reason = '', this.status = AccountSettingDeleteAccountSubmitStatus.initial, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  AccountSettingDeleteAccountSubmitState copyWith({String? reason, AccountSettingDeleteAccountSubmitStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AccountSettingDeleteAccountSubmitState(
      reason: reason ?? this.reason,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

