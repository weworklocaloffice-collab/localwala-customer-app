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

part of 'payment_modal_bloc.dart';

enum PaymentModalStatus { loading, success, failure, selected }

extension PaymentModalStatusX on PaymentModalStatus {
  bool get isLoading => this == PaymentModalStatus.loading;
  bool get isSuccess => this == PaymentModalStatus.success;
  bool get isFailure => this == PaymentModalStatus.failure;
  bool get isSelected => this == PaymentModalStatus.selected;
}

final class PaymentModalState {
  final List<PaymentListModel> paymentList;
  final PaymentModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const PaymentModalState({this.paymentList = const [], this.status = PaymentModalStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  PaymentModalState copyWith({List<PaymentListModel>? paymentList, PaymentModalStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return PaymentModalState(
      paymentList: paymentList ?? this.paymentList,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

