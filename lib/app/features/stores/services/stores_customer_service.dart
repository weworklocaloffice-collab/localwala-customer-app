/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
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

import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/stores/stores_customer_endpoints.dart';

/// Customer-side Local Stores calls.
///
/// Two rules the screens rely on, both enforced server-side and mirrored here so the UI
/// never offers the impossible:
///
/// - BR-37 lives here as an error, not a precondition: adding an item from a second
///   outlet answers `409 CART_OUTLET_CONFLICT` with both outlet ids. The app surfaces
///   that conflict as the specification's dialog ("Your cart contains products from
///   another outlet") instead of pretending the server will merge.
/// - Prices shown are the outlet's (`resolveBasket` recomputes server-side), never the
///   chain's. A price the client sends is not trusted.
class StoresCustomerService {
  final ApiRequestService _apiRequestService = ApiRequestService();

  //// Browse ////

  /// `GET /v1/stores/nearby?lat=&lng=` — both are REQUIRED: the route answers 400
  /// without them and there is no "all stores" fallback to fall back on.
  ///
  /// Note the verb. This is a GET with a query string, not a POST body; a POST here
  /// finds no route and the app shows an empty storefront instead of an error.
  Future<DioApiResponse> nearby({required double lat, required double lng, double radiusKm = 10}) {
    return _apiRequestService.get(
      '${StoresCustomerEndpoints.nearby}'
      '?lat=$lat&lng=$lng&radiusKm=$radiusKm',
    );
  }

  Future<DioApiResponse> searchProducts(String query) {
    return _apiRequestService.get(
      '${StoresCustomerEndpoints.searchProducts}?q=${Uri.encodeQueryComponent(query)}',
    );
  }

  Future<DioApiResponse> product(String productId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.product,
        <String, String>{'product': productId},
      ),
    );
  }

  /// A store's public card. The `{store}` segment is a slug or id the customer navigated
  /// to — not a tenancy claim. Active outlets only; the server 404s the rest.
  Future<DioApiResponse> store(String storeId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.store,
        <String, String>{'store': storeId},
      ),
    );
  }

  Future<DioApiResponse> storeProducts(String storeId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.storeProducts,
        <String, String>{'store': storeId},
      ),
    );
  }

  Future<DioApiResponse> storeReviews(String storeId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.storeReviews,
        <String, String>{'store': storeId},
      ),
    );
  }

  Future<DioApiResponse> storeOffers(String storeId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.storeOffers,
        <String, String>{'store': storeId},
      ),
    );
  }

  //// Cart ////

  /// `GET /cart?outlet=` — the outlet is REQUIRED in the query. The cart is keyed
  /// `(customer, outlet)`, so omitting it finds nothing and answers `{ cart: null }`,
  /// which reads as an empty cart rather than as a malformed request.
  Future<DioApiResponse> cart({required String outlet}) {
    return _apiRequestService.get('${StoresCustomerEndpoints.cart}?outlet=$outlet');
  }

  Future<DioApiResponse> cartAdd(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.cartAdd, body: body);
  }

  Future<DioApiResponse> cartUpdate(Map<String, dynamic> body) {
    return _apiRequestService.patch(StoresCustomerEndpoints.cartUpdate, body: body);
  }

  Future<DioApiResponse> cartRemove(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.cartRemove, body: body);
  }

  Future<DioApiResponse> cartClear() {
    return _apiRequestService.post(StoresCustomerEndpoints.cartClear, body: <String, dynamic>{});
  }

  //// Checkout ////

  Future<DioApiResponse> checkoutEligibility(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.checkoutEligibility, body: body);
  }

  Future<DioApiResponse> checkoutSummary(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.checkoutSummary, body: body);
  }

  //// Orders ////

  Future<DioApiResponse> placeOrder(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.orders, body: body);
  }

  Future<DioApiResponse> orders() {
    return _apiRequestService.get(StoresCustomerEndpoints.customerOrders);
  }

  Future<DioApiResponse> order(String orderId) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.customerOrder,
        <String, String>{'order': orderId},
      ),
    );
  }

  Future<DioApiResponse> cancelOrder(String orderId, Map<String, dynamic> body) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.orderCancel,
        <String, String>{'order': orderId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> payOrder(String orderId, Map<String, dynamic> body) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.orderPay,
        <String, String>{'order': orderId},
      ),
      body: body,
    );
  }

  //// Post-sale ////

  Future<DioApiResponse> reviewOrder(String orderId, Map<String, dynamic> body) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.orderReview,
        <String, String>{'order': orderId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> createReturn(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.createReturn, body: body);
  }

  Future<DioApiResponse> createExchange(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.createExchange, body: body);
  }

  //// Recurring subscriptions ////

  Future<DioApiResponse> subscriptions() {
    return _apiRequestService.get(StoresCustomerEndpoints.subscriptions);
  }

  /// Create a recurring delivery.
  ///
  /// `outlet` is REQUIRED by the server and must be the store the customer is subscribing
  /// at. This is not cosmetic: the route is guarded by `appAuth`, a customer token, so the
  /// server has no outlet in the session to fall back on. Before the server-side fix, the
  /// handler read the outlet from that empty session AND the schema refused one in the
  /// body — so a customer could neither send nor inherit a store, and every subscription
  /// they created was orphaned. `chain` is optional and derived from the outlet server-side.
  ///
  /// `items` carries variant + quantity only. Prices are re-derived at billing time from
  /// the outlet's own rows (BR-36), so anything sent here is ignored — there is deliberately
  /// no price field.
  Future<DioApiResponse> createSubscription(Map<String, dynamic> body) {
    return _apiRequestService.post(StoresCustomerEndpoints.subscriptions, body: body);
  }

  Future<DioApiResponse> upcomingSubscriptions({int days = 30}) {
    return _apiRequestService.get('${StoresCustomerEndpoints.subscriptionsUpcoming}?days=$days');
  }

  Future<DioApiResponse> subscription(String id) {
    return _apiRequestService.get(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.subscription,
        <String, String>{'subscription': id},
      ),
    );
  }

  /// Skip the next delivery only. There is no "skip all" — a customer pausing
  /// indefinitely is a different decision, and the server keeps them separate.
  Future<DioApiResponse> skipSubscription(String id, String reason) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.subscriptionSkip,
        <String, String>{'subscription': id},
      ),
      body: <String, dynamic>{'reason': reason},
    );
  }

  Future<DioApiResponse> pauseSubscription(String id, String reason) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.subscriptionPause,
        <String, String>{'subscription': id},
      ),
      body: <String, dynamic>{'reason': reason},
    );
  }

  Future<DioApiResponse> resumeSubscription(String id) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.subscriptionResume,
        <String, String>{'subscription': id},
      ),
      body: <String, dynamic>{},
    );
  }

  /// Cancellation is why `reason` is required by the server on every one of these: the
  /// reason is stored on the subscription history and is what the store reads when the
  /// customer later asks why deliveries stopped.
  Future<DioApiResponse> cancelSubscription(String id, String reason) {
    return _apiRequestService.post(
      StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.subscriptionCancel,
        <String, String>{'subscription': id},
      ),
      body: <String, dynamic>{'reason': reason},
    );
  }
}