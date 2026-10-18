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

part of 'cart_summary_modal_bloc.dart';

enum CartSummaryModalStatus { initial, empty, failure, updateCart, unauthorized, authorized, guestCheckoutStart, guestCheckoutSuccess, guestCheckoutFailed }

extension CartSummaryModalStatusX on CartSummaryModalStatus {
  bool get isInitial => this == CartSummaryModalStatus.initial;
  bool get isEmpty => this == CartSummaryModalStatus.empty;
  bool get isFailure => this == CartSummaryModalStatus.failure;
  bool get isUpdateCart => this == CartSummaryModalStatus.updateCart;
  bool get isUnauthorized => this == CartSummaryModalStatus.unauthorized;
  bool get isAuthorized => this == CartSummaryModalStatus.authorized;
  bool get isGuestCheckoutStart => this == CartSummaryModalStatus.guestCheckoutStart;
  bool get isGuestCheckoutSuccess => this == CartSummaryModalStatus.guestCheckoutSuccess;
  bool get isGuestCheckoutFailed => this == CartSummaryModalStatus.guestCheckoutFailed;
}

final class CartSummaryModalState {
  final List<CartSummaryModel> summary;
  final String checkoutName;
  final String checkoutRestaurant;
  final bool guestCheckout;
  final CartSummaryModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CartSummaryModalState({
    this.summary = const [],
    this.checkoutName = '',
    this.checkoutRestaurant = '',
    this.guestCheckout = false,
    this.status = CartSummaryModalStatus.initial,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  CartSummaryModalState copyWith({
    List<CartSummaryModel>? summary,
    String? checkoutName,
    String? checkoutRestaurant,
    bool? guestCheckout,
    CartSummaryModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return CartSummaryModalState(
      summary: summary ?? this.summary,
      checkoutName: checkoutName ?? this.checkoutName,
      checkoutRestaurant: checkoutRestaurant ?? this.checkoutRestaurant,
      guestCheckout: guestCheckout ?? this.guestCheckout,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

