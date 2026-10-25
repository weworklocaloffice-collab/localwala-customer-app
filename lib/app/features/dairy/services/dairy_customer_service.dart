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
import 'package:user/app/features/dairy/dairy_customer_endpoints.dart';

/// Customer-side dairy calls.
///
/// Prices arrive as paise integers and are formatted in the UI; the server is
/// the only authority on totals. Can deposits are held in the wallet and released
/// on return, so a customer never pays them twice.
class DairyCustomerService {
  final ApiRequestService _apiRequestService = ApiRequestService();

  // ---- Catalog ----
  Future<DioApiResponse> categoryTree() async {
    return _apiRequestService.get(DairyCustomerEndpoints.categoryTree);
  }

  /// [business] filters the storefront to one outlet's products.
  Future<DioApiResponse> productList({String? business}) async {
    final String query =
        business == null || business.isEmpty ? '' : '?business=$business';
    return _apiRequestService.get(DairyCustomerEndpoints.productList + query);
  }

  Future<DioApiResponse> skuList() async {
    return _apiRequestService.get(DairyCustomerEndpoints.skuList);
  }

  Future<DioApiResponse> outletDetail(String outletId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.outletDetail,
        <String, String>{'id': outletId},
      ),
    );
  }

  Future<DioApiResponse> brandList() async {
    return _apiRequestService.get(DairyCustomerEndpoints.brandList);
  }

  /// Faceted search. Null filters are simply omitted from the query — the
  /// server treats an absent key as "no constraint", and [minPrice]/[maxPrice]
  /// are rupees (the server converts to paise itself).
  Future<DioApiResponse> searchProducts({
    String? category,
    String? subCategory,
    String? brand,
    String? fatLevel,
    String? milkType,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    final Map<String, String> query = <String, String>{
      if (category != null && category.isNotEmpty) 'category': category,
      if (subCategory != null && subCategory.isNotEmpty) 'subCategory': subCategory,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
      if (fatLevel != null && fatLevel.isNotEmpty) 'fatLevel': fatLevel,
      if (milkType != null && milkType.isNotEmpty) 'milkType': milkType,
      if (search != null && search.isNotEmpty) 'search': search,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
    };
    final String qs = query.entries.map((MapEntry<String, String> e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return _apiRequestService.get(
      DairyCustomerEndpoints.productSearch + (qs.isEmpty ? '' : '?$qs'),
    );
  }

  // ---- Cart ----
  Future<DioApiResponse> cart() async {
    return _apiRequestService.get(DairyCustomerEndpoints.cart);
  }

  Future<DioApiResponse> addToCart({
    required String sku,
    required int quantity,
  }) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.cartItems,
      body: <String, dynamic>{'sku': sku, 'quantity': quantity},
    );
  }

  Future<DioApiResponse> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    return _apiRequestService.patch(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.cartItem,
        <String, String>{'item': itemId},
      ),
      body: <String, dynamic>{'quantity': quantity},
    );
  }

  Future<DioApiResponse> removeCartItem(String itemId) async {
    return _apiRequestService.delete(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.cartItem,
        <String, String>{'item': itemId},
      ),
    );
  }

  Future<DioApiResponse> clearCart() async {
    return _apiRequestService.delete(DairyCustomerEndpoints.cartClear);
  }

  Future<DioApiResponse> priceCheck() async {
    return _apiRequestService.get(DairyCustomerEndpoints.cartPriceCheck);
  }

  Future<DioApiResponse> priceApply(Map<String, dynamic> body) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.cartPriceApply,
      body: body,
    );
  }

  // ---- Orders ----
  Future<DioApiResponse> checkout(Map<String, dynamic> body) async {
    return _apiRequestService.post(DairyCustomerEndpoints.checkout, body: body);
  }

  Future<DioApiResponse> payOrder({
    required String orderId,
    required String paymentConfigId,
  }) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.orderPay,
        <String, String>{'order': orderId},
      ),
      body: <String, dynamic>{'payment': paymentConfigId},
    );
  }

  Future<DioApiResponse> orders() async {
    return _apiRequestService.get(DairyCustomerEndpoints.orders);
  }

  Future<DioApiResponse> orderDetail(String orderId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.order,
        <String, String>{'order': orderId},
      ),
    );
  }

  Future<DioApiResponse> orderHistory(String orderId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.orderHistory,
        <String, String>{'order': orderId},
      ),
    );
  }

  Future<DioApiResponse> cancelOrder(String orderId) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.orderCancel,
        <String, String>{'order': orderId},
      ),
    );
  }

  /// Cans the customer currently holds and the deposit still owed on them.
  /// The money side is a wallet hold, released when the cans come back.
  Future<DioApiResponse> myDeposits() async {
    return _apiRequestService.get(DairyCustomerEndpoints.customerDeposits);
  }

  // ---- Subscriptions ----
  Future<DioApiResponse> createSubscription(Map<String, dynamic> body) async {
    return _apiRequestService.post(DairyCustomerEndpoints.subscriptions, body: body);
  }

  Future<DioApiResponse> subscriptions() async {
    return _apiRequestService.get(DairyCustomerEndpoints.subscriptions);
  }

  Future<DioApiResponse> subscriptionDetail(String subscriptionId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscription,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> subscriptionUpcoming(String subscriptionId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionUpcoming,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> subscriptionEvents(String subscriptionId) async {
    return _apiRequestService.get(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionEvents,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> skipSubscription(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionSkip,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> unskipSubscription(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionUnskip,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> pauseSubscription(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionPause,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> resumeSubscription(String subscriptionId) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionResume,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> changeSubscriptionQuantity(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.patch(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionQuantity,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> changeSubscriptionAddress(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.patch(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionAddress,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> changeSubscriptionSchedule(String subscriptionId, Map<String, dynamic> body) async {
    return _apiRequestService.patch(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionSchedule,
        <String, String>{'subscription': subscriptionId},
      ),
      body: body,
    );
  }

  Future<DioApiResponse> cancelSubscription(String subscriptionId) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionCancel,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }

  Future<DioApiResponse> reactivateSubscription(String subscriptionId) async {
    return _apiRequestService.post(
      DairyCustomerEndpoints.resolve(
        DairyCustomerEndpoints.subscriptionReactivate,
        <String, String>{'subscription': subscriptionId},
      ),
    );
  }
}
