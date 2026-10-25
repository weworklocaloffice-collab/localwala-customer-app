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

/// Customer dairy endpoints, mounted at `/v1/dairy`.
///
/// Derived from `API/src/modules/dairy/routes/dairy.route.js`. No outlet id is
/// ever sent — the server scopes by the access token.
class DairyCustomerEndpoints {
  const DairyCustomerEndpoints._();

  // Catalog (shared, read-only)
  static const String categoryTree = 'v1/dairy/catalog/tree';
  static const String productList = 'v1/dairy/catalog/products';
  static const String productSearch = 'v1/dairy/catalog/products/search';
  static const String skuList = 'v1/dairy/catalog/skus';
  static const String brandList = 'v1/dairy/catalog/brands';
  static const String outletDetail = 'v1/dairy/catalog/businesses/{id}';

  // Cart
  static const String cart = 'v1/dairy/customer/cart';
  static const String cartItems = 'v1/dairy/customer/cart/items';
  static const String cartItem = 'v1/dairy/customer/cart/items/{item}';
  static const String cartPriceCheck = 'v1/dairy/customer/cart/price_check';
  static const String cartPriceApply = 'v1/dairy/customer/cart/price_apply';
  static const String cartClear = 'v1/dairy/customer/cart';

  // Orders
  static const String checkout = 'v1/dairy/customer/orders/checkout';
  static const String orderPay = 'v1/dairy/customer/orders/{order}/pay';
  static const String orders = 'v1/dairy/customer/orders';
  static const String order = 'v1/dairy/customer/orders/{order}';
  static const String orderHistory = 'v1/dairy/customer/orders/{order}/history';
  static const String orderCancel = 'v1/dairy/customer/orders/{order}/cancel';

  // Can deposits held in the customer's wallet
  static const String customerDeposits = 'v1/dairy/customer/deposits';

  // Subscriptions
  static const String subscriptions = 'v1/dairy/customer/subscriptions';
  static const String subscription = 'v1/dairy/customer/subscriptions/{subscription}';
  static const String subscriptionUpcoming =
      'v1/dairy/customer/subscriptions/{subscription}/upcoming';
  static const String subscriptionEvents =
      'v1/dairy/customer/subscriptions/{subscription}/events';
  static const String subscriptionSkip =
      'v1/dairy/customer/subscriptions/{subscription}/skip';
  static const String subscriptionUnskip =
      'v1/dairy/customer/subscriptions/{subscription}/unskip';
  static const String subscriptionPause =
      'v1/dairy/customer/subscriptions/{subscription}/pause';
  static const String subscriptionResume =
      'v1/dairy/customer/subscriptions/{subscription}/resume';
  static const String subscriptionQuantity =
      'v1/dairy/customer/subscriptions/{subscription}/quantity';
  static const String subscriptionAddress =
      'v1/dairy/customer/subscriptions/{subscription}/address';
  static const String subscriptionSchedule =
      'v1/dairy/customer/subscriptions/{subscription}/schedule';
  static const String subscriptionCancel =
      'v1/dairy/customer/subscriptions/{subscription}/cancel';
  static const String subscriptionReactivate =
      'v1/dairy/customer/subscriptions/{subscription}/reactivate';

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
