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

part of 'cart_bloc.dart';

enum CartStatus { loading, empty, success, failure, customError, cartUpdate, cartError, unauthorized, authorized, guestCheckoutStart, guestCheckoutSuccess, guestCheckoutFailed }

extension CartStatusX on CartStatus {
  bool get isLoading => this == CartStatus.loading;
  bool get isEmpty => this == CartStatus.empty;
  bool get isSuccess => this == CartStatus.success;
  bool get isFailure => this == CartStatus.failure;
  bool get isCustomError => this == CartStatus.customError;
  bool get isCartUpdate => this == CartStatus.cartUpdate;
  bool get isCartError => this == CartStatus.cartError;
  bool get isUnauthorized => this == CartStatus.unauthorized;
  bool get isAuthorized => this == CartStatus.authorized;
  bool get isGuestCheckoutStart => this == CartStatus.guestCheckoutStart;
  bool get isGuestCheckoutSuccess => this == CartStatus.guestCheckoutSuccess;
  bool get isGuestCheckoutFailed => this == CartStatus.guestCheckoutFailed;
}

final class CartState {
  final List<CartSummaryModel> summary;
  final String checkoutName;
  final String checkoutRestaurant;
  final bool guestCheckout;
  final CartStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const CartState({this.summary = const [], this.checkoutName = '', this.checkoutRestaurant = '', this.guestCheckout = false, this.status = CartStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  CartState copyWith({List<CartSummaryModel>? summary, String? checkoutName, String? checkoutRestaurant, bool? guestCheckout, CartStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return CartState(
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

