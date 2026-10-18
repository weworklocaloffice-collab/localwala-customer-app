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

part of 'account_setting_update_password_bloc.dart';

enum AccountSettingUpdatePasswordStatus { initial, failure, success, inProgress, verify }

extension AccountSettingUpdatePasswordStatusX on AccountSettingUpdatePasswordStatus {
  bool get isInitial => this == AccountSettingUpdatePasswordStatus.initial;
  bool get isFailure => this == AccountSettingUpdatePasswordStatus.failure;
  bool get isSuccess => this == AccountSettingUpdatePasswordStatus.success;
  bool get isInProgress => this == AccountSettingUpdatePasswordStatus.inProgress;
  bool get isVerify => this == AccountSettingUpdatePasswordStatus.verify;
}

final class AccountSettingUpdatePasswordState {
  final AccountSettingChangePasswordPasswordField password;
  final AccountSettingChangePasswordConfirmedPasswordField confirmedPassword;
  final bool isPasswordValid;
  final String locale;
  final AccountSettingUpdatePasswordStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingUpdatePasswordState({
    this.password = const AccountSettingChangePasswordPasswordField.pure(),
    this.confirmedPassword = const AccountSettingChangePasswordConfirmedPasswordField.pure(),
    this.isPasswordValid = false,
    this.locale = '',
    this.status = AccountSettingUpdatePasswordStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountSettingUpdatePasswordState copyWith({
    AccountSettingChangePasswordPasswordField? password,
    AccountSettingChangePasswordConfirmedPasswordField? confirmedPassword,
    bool? isPasswordValid,
    String? locale,
    AccountSettingUpdatePasswordStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountSettingUpdatePasswordState(
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

