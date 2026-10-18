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

part of 'account_setting_change_mobile_bloc.dart';

enum AccountSettingChangeMobileStatus { initial, loaded, failure, success, inProgress, verify, verifyWeb, verifyFirebase }

extension AccountSettingChangeMobileStatusX on AccountSettingChangeMobileStatus {
  bool get isInitial => this == AccountSettingChangeMobileStatus.initial;
  bool get isLoaded => this == AccountSettingChangeMobileStatus.loaded;
  bool get isFailure => this == AccountSettingChangeMobileStatus.failure;
  bool get isSuccess => this == AccountSettingChangeMobileStatus.success;
  bool get isInProgress => this == AccountSettingChangeMobileStatus.inProgress;
  bool get isVerify => this == AccountSettingChangeMobileStatus.verify;
  bool get isVerifyWeb => this == AccountSettingChangeMobileStatus.verifyWeb;
  bool get isVerifyFirebase => this == AccountSettingChangeMobileStatus.verifyFirebase;
}

final class AccountSettingChangeMobileState {
  final String userMobileNumber;
  final String flag;
  final AccountSettingUpdateMobileCountryCodeField countryCode;
  final AccountSettingUpdateMobileNumberField mobileNumber;
  final AccountSettingUpdateMobileResponseModel verification;
  final bool isPhoneValid;
  final String locale;
  final AccountSettingChangeMobileStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingChangeMobileState({
    this.userMobileNumber = '',
    this.flag = '',
    this.countryCode = const AccountSettingUpdateMobileCountryCodeField.pure(),
    this.mobileNumber = const AccountSettingUpdateMobileNumberField.pure(),
    required this.verification,
    this.isPhoneValid = false,
    this.locale = '',
    this.status = AccountSettingChangeMobileStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountSettingChangeMobileState copyWith({
    String? userMobileNumber,
    String? flag,
    AccountSettingUpdateMobileCountryCodeField? countryCode,
    AccountSettingUpdateMobileNumberField? mobileNumber,
    AccountSettingUpdateMobileResponseModel? verification,
    bool? isPhoneValid,
    String? locale,
    AccountSettingChangeMobileStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountSettingChangeMobileState(
      userMobileNumber: userMobileNumber ?? this.userMobileNumber,
      flag: flag ?? this.flag,
      countryCode: countryCode ?? this.countryCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      verification: verification ?? this.verification,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

