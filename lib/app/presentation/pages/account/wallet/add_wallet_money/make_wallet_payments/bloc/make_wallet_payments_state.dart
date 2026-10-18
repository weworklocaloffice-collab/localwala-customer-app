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

part of 'make_wallet_payments_bloc.dart';

enum MakeWalletPaymentsStatus { initial, success }

extension MakeWalletPaymentsStatusX on MakeWalletPaymentsStatus {
  bool get isInitial => this == MakeWalletPaymentsStatus.initial;
  bool get isSuccess => this == MakeWalletPaymentsStatus.success;
}

final class MakeWalletPaymentsState {
  final MakeWalletPaymentsStatus status;
  final String alertMessage;
  final String extraMessage;
  const MakeWalletPaymentsState({this.status = MakeWalletPaymentsStatus.initial, this.alertMessage = '', this.extraMessage = ''});

  MakeWalletPaymentsState copyWith({MakeWalletPaymentsStatus? status, String? alertMessage, String? extraMessage}) {
    return MakeWalletPaymentsState(status: status ?? this.status, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

