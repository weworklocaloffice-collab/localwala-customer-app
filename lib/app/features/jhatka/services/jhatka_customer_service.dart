/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/jhatka/jhatka_customer_endpoints.dart';

/// Customer-side Jhatka calls.
///
/// Two rules the screens rely on, both enforced server side and mirrored
/// here so the UI never offers the impossible:
/// - prices shown with `~` are estimates: the customer pays the estimate and
///   any shortfall is refunded automatically (refund-only, BR-06/BR-21);
/// - COUNT lines (eggs, prawn tiers) are exact and never weighed.
class JhatkaCustomerService {
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<DioApiResponse> home({double? lat, double? lng}) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.home,
      body: <String, dynamic>{
        if (lat case final double la) 'lat': la,
        if (lng case final double ln) 'lng': ln,
      },
    );
  }

  Future<DioApiResponse> availability({double? lat, double? lng}) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.availability,
      body: <String, dynamic>{
        if (lat case final double la) 'lat': la,
        if (lng case final double ln) 'lng': ln,
      },
    );
  }

  /// One shop's public card: name, code, address, service radius and the
  /// minimum delivery minutes. Active outlets only — the server 404s the rest.
  Future<DioApiResponse> outlet(String outletId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.outlet,
        <String, String>{'outlet': outletId},
      ),
    );
  }

  /// Products at one outlet with estimates and in-force overrides.
  /// Prices arrive as RAW PAISE (lean reads) — format, never trust raw.
  Future<DioApiResponse> outletProducts(String outletId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.outletProducts,
        <String, String>{'outlet': outletId},
      ),
    );
  }

  Future<DioApiResponse> product(String productId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.product,
        <String, String>{'product': productId},
      ),
    );
  }

  Future<DioApiResponse> cart() async {
    return _apiRequestService.get(JhatkaCustomerEndpoints.cart);
  }

  /// Add a line. `quantity` is `{value, unit}` — grams for WEIGHT variants,
  /// pieces/dozens for COUNT. The server reprices: a client-supplied price
  /// is structurally impossible to honour.
  Future<DioApiResponse> addToCart({
    required String variant,
    required Map<String, dynamic> quantity,
  }) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.cartItems,
      body: <String, dynamic>{'variant': variant, 'quantity': quantity},
    );
  }

  Future<DioApiResponse> updateCartItem({
    required String itemId,
    required Map<String, dynamic> quantity,
  }) async {
    return _apiRequestService.patch(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.cartItem,
        <String, String>{'item': itemId},
      ),
      body: <String, dynamic>{'quantity': quantity},
    );
  }

  Future<DioApiResponse> removeCartItem(String itemId) async {
    return _apiRequestService.delete(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.cartItem,
        <String, String>{'item': itemId},
      ),
    );
  }

  Future<DioApiResponse> checkoutQuote({String? outlet}) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.checkoutQuote,
      body: <String, dynamic>{
        if (outlet case final String o) 'outlet': o,
      },
    );
  }

  Future<DioApiResponse> placeOrder(Map<String, dynamic> order) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.orders,
      body: order,
    );
  }

  /// Start a gateway payment for an order.
  ///
  /// Returns the `PaymentInitiation` the shared checkout charges against. Calling it
  /// twice for the same order returns the SAME row, so a double tap cannot mint a
  /// second charge.
  ///
  /// `paymentConfigId` is which gateway, never how much: the amount is read from the
  /// order server-side. Passing one here would be refused, and that is deliberate.
  Future<DioApiResponse> payOrder({
    required String orderId,
    required String paymentConfigId,
  }) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderPay,
        <String, String>{'id': orderId},
      ),
      body: <String, dynamic>{'payment': paymentConfigId},
    );
  }

  /// Pay for one subscription occurrence.
  ///
  /// The thing being paid is the OCCURRENCE, not the subscription — one subscription
  /// has many occurrences and one payment does not cover them all. The charge is the
  /// ceiling frozen at generation (§9.5), so a variable-weight line is not reconciled
  /// afterwards.
  /// Pay for one occurrence. `paymentConfigId` optional — omitted, the server
  /// uses the outlet's default gateway (same precedence as the billing sweep).
  /// The amount is never sent: the charge is the frozen ceiling, and a body
  /// carrying one is refused rather than ignored.
  Future<DioApiResponse> paySubscriptionOccurrence({
    required String subscriptionId,
    required String occurrenceId,
    String? paymentConfigId,
  }) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.subscriptionOccurrencePay,
        <String, String>{
          'subscription': subscriptionId,
          'occurrence': occurrenceId,
        },
      ),
      body: <String, dynamic>{
        if (paymentConfigId != null && paymentConfigId.isNotEmpty)
          'payment': paymentConfigId,
      },
    );
  }

  Future<DioApiResponse> orders() async {
    return _apiRequestService.get(JhatkaCustomerEndpoints.orders);
  }

  Future<DioApiResponse> orderDetail(String orderId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.order,
        <String, String>{'id': orderId},
      ),
    );
  }

  Future<DioApiResponse> orderTracking(String orderId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderTracking,
        <String, String>{'id': orderId},
      ),
    );
  }

  /// Cancellation is allowed until ACCEPTED; later it needs the outlet.
  /// The server enforces the window — the screen only asks for the reason.
  Future<DioApiResponse> cancelOrder(String orderId, String reason) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderCancel,
        <String, String>{'id': orderId},
      ),
      body: <String, dynamic>{'reason': reason},
    );
  }

  /// Acknowledges the §3.8 weight notification. Not an approval gate — the
  /// meat is already bagged — it only records that the customer saw the final.
  Future<DioApiResponse> confirmWeight(String orderId) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderConfirmWeight,
        <String, String>{'id': orderId},
      ),
    );
  }

  Future<DioApiResponse> subscriptions() async {
    return _apiRequestService.get(JhatkaCustomerEndpoints.subscriptions);
  }

  /// One subscription with upcoming occurrences and their billing state.
  /// The app shows a pay button exactly where `payDue` is true — one predicate,
  /// server-defined, so client and server cannot disagree about what is owed.
  Future<DioApiResponse> subscriptionDetail(String subscriptionId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.subscription,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  /// Refunds on an order, newest first. Every refund is a document (BR-19) —
  /// this list is what the customer reads instead of a mutated order total.
  Future<DioApiResponse> orderRefunds(String orderId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderRefunds,
        <String, String>{'id': orderId},
      ),
    );
  }

  /// Request a delivery OTP. Issued per order; the rider reads it back at the
  /// door and the server matches it inside the deliver call. Requesting does
  /// not verify — there is no customer verify endpoint by design, because the
  /// check belongs at handover, not in the customer's pocket.
  Future<DioApiResponse> requestOrderOtp(String orderId) async {
    return _apiRequestService.get(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.orderOtp,
        <String, String>{'order': orderId},
      ),
    );
  }

  Future<DioApiResponse> createSubscription(
    Map<String, dynamic> subscription,
  ) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.subscriptions,
      body: subscription,
    );
  }

  /// `action` is one of pause/resume/skip/quantity/schedule/cancel, with a
  /// reason. Changes apply to the NEXT occurrence, never the current one.
  Future<DioApiResponse> manageSubscription({
    required String subscriptionId,
    required String action,
    String? reason,
  }) async {
    return _apiRequestService.patch(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.subscription,
        <String, String>{'subscription': subscriptionId},
      ),
      body: <String, dynamic>{
        'action': action,
        if (reason case final String r) 'reason': r,
      },
    );
  }

  Future<DioApiResponse> deleteSubscription(String subscriptionId) async {
    return _apiRequestService.delete(
      JhatkaCustomerEndpoints.resolve(
        JhatkaCustomerEndpoints.subscription,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> complaint(Map<String, dynamic> complaint) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.complaints,
      body: complaint,
    );
  }

  Future<DioApiResponse> review(Map<String, dynamic> review) async {
    return _apiRequestService.post(
      JhatkaCustomerEndpoints.reviews,
      body: review,
    );
  }
}
