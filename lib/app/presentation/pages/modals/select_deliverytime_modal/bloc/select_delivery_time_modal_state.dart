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

part of 'select_delivery_time_modal_bloc.dart';

enum SelectDeliveryTimeModalStatus { loading, fetched, initial, submit, failure }

extension SelectDeliveryTimeModalStatusX on SelectDeliveryTimeModalStatus {
  bool get isLoading => this == SelectDeliveryTimeModalStatus.loading;
  bool get isFetched => this == SelectDeliveryTimeModalStatus.fetched;
  bool get isInitial => this == SelectDeliveryTimeModalStatus.initial;
  bool get isSubmit => this == SelectDeliveryTimeModalStatus.submit;
  bool get isFailure => this == SelectDeliveryTimeModalStatus.failure;
}

final class SelectDeliveryTimeModalState {
  final DeliveryTimeFromField from;
  final DeliveryTimeToField to;
  final DeliveryTimeTimeModel time;
  final List<DeliveryTimeTimeModel> timeList;
  final bool isValid;
  final SelectDeliveryTimeModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SelectDeliveryTimeModalState({
    this.from = const DeliveryTimeFromField.pure(),
    this.to = const DeliveryTimeToField.pure(),
    required this.time,
    this.timeList = const [],
    this.isValid = false,
    this.status = SelectDeliveryTimeModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  SelectDeliveryTimeModalState copyWith({
    DeliveryTimeFromField? from,
    DeliveryTimeToField? to,
    DeliveryTimeTimeModel? time,
    List<DeliveryTimeTimeModel>? timeList,
    bool? isValid,
    SelectDeliveryTimeModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return SelectDeliveryTimeModalState(
      from: from ?? this.from,
      to: to ?? this.to,
      time: time ?? this.time,
      timeList: timeList ?? this.timeList,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

class DeliveryTimeTimeModel {
  String? label;
  String? value;

  DeliveryTimeTimeModel({this.label, this.value});

  DeliveryTimeTimeModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}

