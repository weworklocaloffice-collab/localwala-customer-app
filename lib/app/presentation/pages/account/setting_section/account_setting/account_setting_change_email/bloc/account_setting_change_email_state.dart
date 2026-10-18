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

part of 'account_setting_change_email_bloc.dart';

enum AccountSettingChangeEmailStatus { initial, success, failure, inProgress, loaded, verify }

extension AccountSettingChangeEmailStatusX on AccountSettingChangeEmailStatus {
  bool get isInitial => this == AccountSettingChangeEmailStatus.initial;
  bool get isSuccess => this == AccountSettingChangeEmailStatus.success;
  bool get isFailure => this == AccountSettingChangeEmailStatus.failure;
  bool get isInProgress => this == AccountSettingChangeEmailStatus.inProgress;
  bool get isLoaded => this == AccountSettingChangeEmailStatus.loaded;
  bool get isVerify => this == AccountSettingChangeEmailStatus.verify;
}

final class AccountSettingChangeEmailState {
  final String userEmail;
  final AccountSettingChangeEmailField email;
  final AccountSettingUpdateEmailResponseModel verification;
  final String locale;
  final bool isValid;
  final AccountSettingChangeEmailStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingChangeEmailState({
    this.userEmail = '',
    this.email = const AccountSettingChangeEmailField.pure(),
    required this.verification,
    this.locale = '',
    this.isValid = false,
    this.status = AccountSettingChangeEmailStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountSettingChangeEmailState copyWith({
    String? userEmail,
    AccountSettingChangeEmailField? email,
    String? locale,
    AccountSettingUpdateEmailResponseModel? verification,
    bool? isValid,
    AccountSettingChangeEmailStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountSettingChangeEmailState(
      userEmail: userEmail ?? this.userEmail,
      email: email ?? this.email,
      verification: verification ?? this.verification,
      locale: locale ?? this.locale,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

