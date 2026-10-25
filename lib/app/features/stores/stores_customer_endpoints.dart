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

/// Customer Local Stores endpoints, mounted at `/v1/stores`.
///
/// Verified against `API/src/modules/stores/routes/stores.customer.route.js` on
/// 2026-10-13. Two things about that file matter here and are easy to get wrong:
///
/// 1. ROUTE ORDER IS LOAD-BEARING. `/:store` matches any single segment, so every
///    literal path (`/nearby`, `/cart`, `/products/search`, `/customer/*`) is declared
///    BEFORE it. A client that invents a new literal path is fine — but one that calls
///    `/cart` with the wrong method will land on the storefront instead of failing.
/// 2. The customer never sends an outlet id to widen anything. BR-37 (one outlet per
///    cart) is enforced server-side with `CART_OUTLET_CONFLICT`; the app surfaces the
///    conflict, it does not prevent it client-side and pretend the server agrees.
class StoresCustomerEndpoints {
  const StoresCustomerEndpoints._();

  //// Browse (public) ////

  static const String nearby = 'v1/stores/nearby';
  static const String catalogTree = 'v1/stores/catalog/tree';
  static const String chains = 'v1/stores/chains';
  static const String chain = 'v1/stores/chains/{chain}';
  static const String chainProducts = 'v1/stores/chains/{chain}/products';
  static const String chainReviews = 'v1/stores/chains/{chain}/reviews';
  static const String chainOffers = 'v1/stores/chains/{chain}/offers';
  static const String searchProducts = 'v1/stores/products/search';
  static const String product = 'v1/stores/products/{product}';
  static const String store = 'v1/stores/{store}';
  static const String storeProducts = 'v1/stores/{store}/products';
  static const String storeReviews = 'v1/stores/{store}/reviews';
  static const String storeOffers = 'v1/stores/{store}/offers';
  static const String storeCoupons = 'v1/stores/{store}/coupons';

  //// Cart (BR-37: exactly one outlet per cart) ////

  static const String cart = 'v1/stores/cart';
  static const String cartAdd = 'v1/stores/cart/add';
  static const String cartUpdate = 'v1/stores/cart/update';
  static const String cartRemove = 'v1/stores/cart/remove';
  static const String cartClear = 'v1/stores/cart/clear';

  //// Checkout ////

  static const String checkoutEligibility = 'v1/stores/checkout/eligibility';
  static const String checkoutSummary = 'v1/stores/checkout/summary';

  //// Orders ////

  static const String orders = 'v1/stores/orders';
  static const String customerOrders = 'v1/stores/customer/orders';
  static const String customerOrder = 'v1/stores/customer/orders/{order}';
  static const String customerOrderTrack = 'v1/stores/customer/orders/{order}/track';
  static const String orderCancel = 'v1/stores/orders/{order}/cancel';

  /// Initiates a gateway payment. Creates (or reuses) the PaymentInitiation the shared
  /// gateway charges against — it does NOT mark the order paid. A verified callback does.
  /// The body carries the PaymentConfig id; an `amount` is refused server-side, because
  /// the amount is the order's own frozen total.
  static const String orderPay = 'v1/stores/orders/{order}/pay';

  //// Favourites (saved chains, not outlets) ////

  static const String customerFavourites = 'v1/stores/customer/favourites';
  static const String chainFavourite = 'v1/stores/chains/{chain}/favourite';

  //// Post-sale ////

  static const String orderReview = 'v1/stores/customer/orders/{order}/review';
  static const String createReturn = 'v1/stores/customer/returns';
  static const String createExchange = 'v1/stores/customer/exchanges';
  static const String customerWarranties = 'v1/stores/customer/warranties';
  static const String customerWarranty = 'v1/stores/customer/warranties/{warranty}';

  //// Recurring subscriptions ////

  /// Shared by list and create — `POST /subscriptions` and `GET /subscriptions` on the
  /// same path.
  static const String subscriptions = 'v1/stores/subscriptions';

  /// LITERAL BEFORE PARAM on the server, and it is easy to get wrong:
  /// `/subscriptions/upcoming` is declared BEFORE `/subscriptions/:subscription`, so a
  /// reorder would make Express read 'upcoming' as a subscription id and cast-fail. That
  /// shipped once; `verify.stores.route.reachability.js` now fails the build if it returns.
  static const String subscriptionsUpcoming = 'v1/stores/subscriptions/upcoming';
  static const String subscription = 'v1/stores/subscriptions/{subscription}';
  static const String subscriptionStatus = 'v1/stores/subscriptions/{subscription}/{status}';
  static const String subscriptionSkip = 'v1/stores/subscriptions/{subscription}/skip';
  static const String subscriptionPause = 'v1/stores/subscriptions/{subscription}/pause';
  static const String subscriptionResume = 'v1/stores/subscriptions/{subscription}/resume';
  static const String subscriptionCancel = 'v1/stores/subscriptions/{subscription}/cancel';

  /// Substitute placeholders. Throws on an unresolved placeholder rather than issuing a
  /// request against a literal `{store}` — which would match the `/:store` storefront
  /// route and return a shop profile instead of failing visibly.
  static String resolve(String path, Map<String, String> params) {
    var out = path;
    final RegExp placeholder = RegExp(r'\{(\w+)\}');
    out = out.replaceAllMapped(placeholder, (Match m) {
      final String? value = params[m.group(1)];
      if (value == null || value.isEmpty) {
        throw ArgumentError('Missing path parameter ${m.group(1)} for $path');
      }
      return value;
    });
    return out;
  }
}