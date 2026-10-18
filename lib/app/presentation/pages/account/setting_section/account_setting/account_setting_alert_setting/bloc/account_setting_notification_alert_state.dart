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

part of 'account_setting_notification_alert_bloc.dart';

enum AccountSettingNotificationAlertStatus { loading, success, failure, update, updated, updateFailed }

extension AccountSettingNotificationAlertStatusX on AccountSettingNotificationAlertStatus {
  bool get isLoading => this == AccountSettingNotificationAlertStatus.loading;
  bool get isSuccess => this == AccountSettingNotificationAlertStatus.success;
  bool get isFailure => this == AccountSettingNotificationAlertStatus.failure;
  bool get isUpdate => this == AccountSettingNotificationAlertStatus.update;
  bool get isUpdated => this == AccountSettingNotificationAlertStatus.updated;
  bool get isUpdateFailed => this == AccountSettingNotificationAlertStatus.updateFailed;
}

final class AccountSettingNotificationAlertState {
  final String settingId;
  final bool newsletters;
  final bool promoEmail;
  final bool promoNotification;
  final bool promoWhatsApp;
  final bool socialEmail;
  final bool socialNotification;
  final bool orderEmail;
  final bool orderNotification;
  final bool orderWhatsApp;
  final bool importantUpdate;
  final AccountSettingNotificationAlertStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AccountSettingNotificationAlertState({
    this.settingId = '',
    this.newsletters = false,
    this.promoEmail = false,
    this.promoNotification = false,
    this.promoWhatsApp = false,
    this.socialEmail = false,
    this.socialNotification = false,
    this.orderEmail = false,
    this.orderNotification = false,
    this.orderWhatsApp = false,
    this.importantUpdate = false,
    this.status = AccountSettingNotificationAlertStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AccountSettingNotificationAlertState copyWith({
    String? settingId,
    bool? newsletters,
    bool? promoEmail,
    bool? promoNotification,
    bool? promoWhatsApp,
    bool? socialEmail,
    bool? socialNotification,
    bool? orderEmail,
    bool? orderNotification,
    bool? orderWhatsApp,
    bool? importantUpdate,
    AccountSettingNotificationAlertStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AccountSettingNotificationAlertState(
      settingId: settingId ?? this.settingId,
      newsletters: newsletters ?? this.newsletters,
      promoEmail: promoEmail ?? this.promoEmail,
      promoNotification: promoNotification ?? this.promoNotification,
      promoWhatsApp: promoWhatsApp ?? this.promoWhatsApp,
      socialEmail: socialEmail ?? this.socialEmail,
      socialNotification: socialNotification ?? this.socialNotification,
      orderEmail: orderEmail ?? this.orderEmail,
      orderNotification: orderNotification ?? this.orderNotification,
      orderWhatsApp: orderWhatsApp ?? this.orderWhatsApp,
      importantUpdate: importantUpdate ?? this.importantUpdate,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

