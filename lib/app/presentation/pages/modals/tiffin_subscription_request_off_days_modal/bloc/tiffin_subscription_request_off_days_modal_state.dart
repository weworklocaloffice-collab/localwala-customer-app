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

part of 'tiffin_subscription_request_off_days_modal_bloc.dart';

enum TiffinSubscriptionRequestOffDaysModalStatus { loading, success, failure, empty, submitStart, submitSuccess, submitFailed }

extension TiffinSubscriptionRequestOffDaysModalStatusX on TiffinSubscriptionRequestOffDaysModalStatus {
  bool get isLoading => this == TiffinSubscriptionRequestOffDaysModalStatus.loading;
  bool get isSuccess => this == TiffinSubscriptionRequestOffDaysModalStatus.success;
  bool get isFailure => this == TiffinSubscriptionRequestOffDaysModalStatus.failure;
  bool get isEmpty => this == TiffinSubscriptionRequestOffDaysModalStatus.empty;
  bool get isSubmitStart => this == TiffinSubscriptionRequestOffDaysModalStatus.submitStart;
  bool get isSubmitSuccess => this == TiffinSubscriptionRequestOffDaysModalStatus.submitSuccess;
  bool get isSubmitFailed => this == TiffinSubscriptionRequestOffDaysModalStatus.submitFailed;
}

final class TiffinSubscriptionRequestOffDaysModalState {
  final String purchaseId;
  final String locale;
  final List<String> requestedOffDates;
  final String offDays;
  final int totalOrders;
  final List<DateTime> activeDates;
  final List<DateTime> deactiveDates;
  final int totalDays;
  final String selectedDate;
  final TiffinSubscriptionRequestOffDaysModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const TiffinSubscriptionRequestOffDaysModalState({
    this.purchaseId = '',
    this.locale = 'en',
    this.requestedOffDates = const [],
    this.offDays = '',
    this.totalOrders = 0,
    this.activeDates = const [],
    this.deactiveDates = const [],
    this.totalDays = 0,
    this.selectedDate = '',
    this.status = TiffinSubscriptionRequestOffDaysModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  TiffinSubscriptionRequestOffDaysModalState copyWith({
    String? purchaseId,
    String? locale,
    List<String>? requestedOffDates,
    String? offDays,
    int? totalOrders,
    List<DateTime>? activeDates,
    List<DateTime>? deactiveDates,
    int? totalDays,
    String? selectedDate,
    TiffinSubscriptionRequestOffDaysModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return TiffinSubscriptionRequestOffDaysModalState(
      purchaseId: purchaseId ?? this.purchaseId,
      locale: locale ?? this.locale,
      requestedOffDates: requestedOffDates ?? this.requestedOffDates,
      offDays: offDays ?? this.offDays,
      totalOrders: totalOrders ?? this.totalOrders,
      activeDates: activeDates ?? this.activeDates,
      deactiveDates: deactiveDates ?? this.deactiveDates,
      totalDays: totalDays ?? this.totalDays,
      selectedDate: selectedDate ?? this.selectedDate,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

