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

part of 'add_wallet_money_bloc.dart';

enum AddWalletMoneyStatus { loading, initial, newCount, success, failure, empty, fetchingPaymentLink, paymentLinkFetched, paymentLinkFailed }

extension AddWalletMoneyStatusX on AddWalletMoneyStatus {
  bool get isLoading => this == AddWalletMoneyStatus.loading;
  bool get isInitial => this == AddWalletMoneyStatus.initial;
  bool get isNewCount => this == AddWalletMoneyStatus.newCount;
  bool get isSuccess => this == AddWalletMoneyStatus.success;
  bool get isFailure => this == AddWalletMoneyStatus.failure;
  bool get isEmpty => this == AddWalletMoneyStatus.empty;
  bool get isFetchingPaymentLink => this == AddWalletMoneyStatus.fetchingPaymentLink;
  bool get isPaymentLinkFetched => this == AddWalletMoneyStatus.paymentLinkFetched;
  bool get isPaymentLinkFailed => this == AddWalletMoneyStatus.paymentLinkFailed;
}

final class AddWalletMoneyState {
  final WalletAddMoneyBasicDetailModel basicDetail;
  final WalletAmountField amount;
  final List<String> suggested;
  final String payment;
  final String paymentName;
  final String paymentImageURL;
  final String paymentLinkId;
  final AddWalletMoneyStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AddWalletMoneyState({
    required this.basicDetail,
    this.amount = const WalletAmountField.pure('50'),
    this.suggested = const ['50', '100', '150', '200'],
    this.payment = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.paymentLinkId = '',
    this.status = AddWalletMoneyStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  AddWalletMoneyState copyWith({
    WalletAddMoneyBasicDetailModel? basicDetail,
    WalletAmountField? amount,
    List<String>? suggested,
    String? payment,
    String? paymentName,
    String? paymentImageURL,
    String? paymentLinkId,
    AddWalletMoneyStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return AddWalletMoneyState(
      basicDetail: basicDetail ?? this.basicDetail,
      amount: amount ?? this.amount,
      suggested: suggested ?? this.suggested,
      payment: payment ?? this.payment,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      paymentLinkId: paymentLinkId ?? this.paymentLinkId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

