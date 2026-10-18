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

part of 'report_emergency_bloc.dart';

enum ReportEmergencyStatus { initial, submit, success, failure }

extension ReportEmergencyStatusX on ReportEmergencyStatus {
  bool get isInitial => this == ReportEmergencyStatus.initial;
  bool get isSuccess => this == ReportEmergencyStatus.success;
  bool get isSubmit => this == ReportEmergencyStatus.submit;
  bool get isFailure => this == ReportEmergencyStatus.failure;
}

final class ReportEmergencyState {
  final List<ReportEmergencyFormSelectModel> query;
  final ReportEmergencyFormSelectModel savedQuery;
  final ReportEmergencyFormEmailField userEmail;
  final ReportEmergencyFormNameField userName;
  final ReportEmergencyFormCountryCodeField userCountryCode;
  final String flag;
  final ReportEmergencyFormNumberField userContact;
  final ReportEmergencyFormShortDescriptionField shortDescritpion;
  final bool isValid;
  final ReportEmergencyStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ReportEmergencyState({
    this.query = const [],
    required this.savedQuery,
    this.userEmail = const ReportEmergencyFormEmailField.pure(),
    this.userName = const ReportEmergencyFormNameField.pure(),
    this.userCountryCode = const ReportEmergencyFormCountryCodeField.pure(),
    this.flag = '',
    this.userContact = const ReportEmergencyFormNumberField.pure(),
    this.shortDescritpion = const ReportEmergencyFormShortDescriptionField.pure(),
    this.isValid = false,
    this.status = ReportEmergencyStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ReportEmergencyState copyWith({
    List<ReportEmergencyFormSelectModel>? query,
    ReportEmergencyFormSelectModel? savedQuery,
    ReportEmergencyFormEmailField? userEmail,
    ReportEmergencyFormNameField? userName,
    ReportEmergencyFormCountryCodeField? userCountryCode,
    String? flag,
    ReportEmergencyFormNumberField? userContact,
    ReportEmergencyFormShortDescriptionField? shortDescritpion,
    bool? isValid,
    ReportEmergencyStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ReportEmergencyState(
      query: query ?? this.query,
      savedQuery: savedQuery ?? this.savedQuery,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userCountryCode: userCountryCode ?? this.userCountryCode,
      flag: flag ?? this.flag,
      userContact: userContact ?? this.userContact,
      shortDescritpion: shortDescritpion ?? this.shortDescritpion,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

