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

/// Customer Jhatka endpoints, mounted at `/v1/jhatka/customer`.
///
/// Verified against `API/src/routes/v1/index.js` and
/// `API/scripts/list.jhatka.routes.js`. No outlet id is ever sent — the
/// server scopes by the access token.
class JhatkaCustomerEndpoints {
  const JhatkaCustomerEndpoints._();

  static const String home = 'v1/jhatka/customer/home';
  static const String availability = 'v1/jhatka/customer/availability';
  static const String outlet = 'v1/jhatka/customer/outlets/{outlet}';
  static const String outletProducts =
      'v1/jhatka/customer/outlets/{outlet}/products';
  static const String product = 'v1/jhatka/customer/products/{product}';
  static const String cart = 'v1/jhatka/customer/cart';
  static const String cartItems = 'v1/jhatka/customer/cart/items';
  static const String cartItem = 'v1/jhatka/customer/cart/items/{item}';
  static const String checkoutQuote = 'v1/jhatka/customer/checkout/quote';
  static const String orders = 'v1/jhatka/customer/orders';
  static const String order = 'v1/jhatka/customer/orders/{id}';
  static const String orderTracking = 'v1/jhatka/customer/orders/{id}/tracking';
  static const String orderCancel = 'v1/jhatka/customer/orders/{id}/cancel';
  static const String orderConfirmWeight =
      'v1/jhatka/customer/orders/{id}/confirm-weight';
  /// Initiate a gateway payment for an order.
  ///
  /// This is the only way an order becomes payable: it creates (or reuses) the
  /// `PaymentInitiation` the shared gateway checkout charges against. It does NOT mark
  /// the order paid — a verified gateway callback does, through `payment.dispatch.js`.
  ///
  /// The body carries the PaymentConfig id and nothing else. An `amount` is refused
  /// server-side rather than ignored, because the amount is the order's own frozen
  /// `estimatedTotal` and BR-06 says it can only ever fall.
  static const String orderPay = 'v1/jhatka/customer/orders/{id}/pay';
  static const String subscriptionOccurrencePay =
      'v1/jhatka/customer/subscriptions/{subscription}/occurrences/{occurrence}/pay';
  static const String subscriptions = 'v1/jhatka/customer/subscriptions';
  static const String subscription =
      'v1/jhatka/customer/subscriptions/{subscription}';
  static const String orderRefunds = 'v1/jhatka/customer/orders/{id}/refunds';
  static const String orderOtp = 'v1/jhatka/customer/orders/{order}/otp';
  static const String complaints = 'v1/jhatka/customer/complaints';
  static const String reviews = 'v1/jhatka/customer/reviews';

  static String resolve(String template, Map<String, String> values) {
    return template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (Match match) {
        final String? value = values[match.group(1)];
        if (value == null || value.isEmpty) {
          throw ArgumentError(
            'Missing "${match.group(1)}" for endpoint $template',
          );
        }
        return Uri.encodeComponent(value);
      },
    );
  }
}
