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

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Test doubles for the stores customer surface.
///
/// The stores views take their service through an optional constructor parameter, so a
/// widget test passes one of these instead of reaching the network. Before that they built
/// `StoresCustomerService()` inside their `State`, which meant the only way to render a
/// checkout was to have a server — and a screen that has never been rendered is a screen
/// that has never been checked.
///
/// `DioApiResponse` wraps a Dio `Response`, so these return real objects rather than a
/// stand-in: the screens read `.success` and `.body`, and `body` is `jsonEncode(raw.data)`.
/// Building the genuine type means a test cannot pass while the screen would have failed on
/// the real shape.
DioApiResponse fakeResponse(Object? data, {int statusCode = 200}) {
  return DioApiResponse(
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/fake'),
      statusCode: statusCode,
      data: data,
    ),
  );
}

/// A service whose methods are scripted per test.
///
/// Records every call so a test can assert on the REQUEST — which outlet, which chain, what
/// payload — not merely on what the screen rendered. The checkout payload is the thing worth
/// pinning: `addressId` and `addressSnapshot` are what the server refuses an order without,
/// and they are assembled from the app's own address vocabulary.
class FakeStoresService extends StoresCustomerService {
  FakeStoresService();

  final List<String> calls = <String>[];
  final Map<String, Map<String, dynamic>> lastBody = <String, Map<String, dynamic>>{};

  /// Canned responses, keyed by the endpoint constant name.
  Map<String, Object?> responses = <String, Object?>{};

  /// Endpoints with no entry here fail loudly rather than silently returning empty data.
  Object? _reply(String name, [Map<String, dynamic>? body]) {
    calls.add(name);
    if (body != null) lastBody[name] = body;
    if (!responses.containsKey(name)) {
      throw StateError(
        'FakeStoresService: no canned response for "$name". Script it in `responses`. '
        'Failing loudly beats returning empty data, which renders as a screen that merely '
        'looks empty.',
      );
    }
    return responses[name];
  }

  @override
  Future<DioApiResponse> nearby({required double lat, required double lng, double radiusKm = 10}) async =>
      fakeResponse(_reply('nearby'));

  @override
  Future<DioApiResponse> store(String storeId) async => fakeResponse(_reply('store'));

  @override
  Future<DioApiResponse> storeProducts(String storeId) async => fakeResponse(_reply('storeProducts'));

  @override
  Future<DioApiResponse> storeReviews(String storeId) async => fakeResponse(_reply('storeReviews'));

  @override
  Future<DioApiResponse> storeOffers(String storeId) async => fakeResponse(_reply('storeOffers'));

  @override
  Future<DioApiResponse> product(String productId) async => fakeResponse(_reply('product'));

  @override
  Future<DioApiResponse> searchProducts(String query) async => fakeResponse(_reply('searchProducts'));

  @override
  Future<DioApiResponse> cart({required String outlet}) async => fakeResponse(_reply('cart'));

  @override
  Future<DioApiResponse> cartAdd(Map<String, dynamic> body) async =>
      fakeResponse(_reply('cartAdd', body));

  @override
  Future<DioApiResponse> cartUpdate(Map<String, dynamic> body) async =>
      fakeResponse(_reply('cartUpdate', body));

  @override
  Future<DioApiResponse> cartRemove(Map<String, dynamic> body) async =>
      fakeResponse(_reply('cartRemove', body));

  @override
  Future<DioApiResponse> cartClear() async => fakeResponse(_reply('cartClear'));

  @override
  Future<DioApiResponse> checkoutEligibility(Map<String, dynamic> body) async =>
      fakeResponse(_reply('checkoutEligibility', body));

  @override
  Future<DioApiResponse> checkoutSummary(Map<String, dynamic> body) async =>
      fakeResponse(_reply('checkoutSummary', body));

  @override
  Future<DioApiResponse> placeOrder(Map<String, dynamic> body) async =>
      fakeResponse(_reply('placeOrder', body));

  @override
  Future<DioApiResponse> orders() async => fakeResponse(_reply('orders'));

  @override
  Future<DioApiResponse> order(String orderId) async => fakeResponse(_reply('order'));

  @override
  Future<DioApiResponse> cancelOrder(String orderId, Map<String, dynamic> body) async =>
      fakeResponse(_reply('cancelOrder', body));

  @override
  Future<DioApiResponse> payOrder(String orderId, Map<String, dynamic> body) async =>
      fakeResponse(_reply('payOrder', body));

  @override
  Future<DioApiResponse> reviewOrder(String orderId, Map<String, dynamic> body) async =>
      fakeResponse(_reply('reviewOrder', body));

  @override
  Future<DioApiResponse> createReturn(Map<String, dynamic> body) async =>
      fakeResponse(_reply('createReturn', body));

  @override
  Future<DioApiResponse> createExchange(Map<String, dynamic> body) async =>
      fakeResponse(_reply('createExchange', body));

  @override
  Future<DioApiResponse> subscriptions() async => fakeResponse(_reply('subscriptions'));

  @override
  Future<DioApiResponse> createSubscription(Map<String, dynamic> body) async =>
      fakeResponse(_reply('createSubscription', body));

  @override
  Future<DioApiResponse> upcomingSubscriptions({int days = 30}) async =>
      fakeResponse(_reply('upcomingSubscriptions'));

  @override
  Future<DioApiResponse> subscription(String id) async => fakeResponse(_reply('subscription'));

  @override
  Future<DioApiResponse> skipSubscription(String id, String reason) async =>
      fakeResponse(_reply('skipSubscription', <String, dynamic>{'id': id, 'reason': reason}));

  @override
  Future<DioApiResponse> pauseSubscription(String id, String reason) async =>
      fakeResponse(_reply('pauseSubscription', <String, dynamic>{'id': id, 'reason': reason}));

  @override
  Future<DioApiResponse> resumeSubscription(String id) async =>
      fakeResponse(_reply('resumeSubscription', <String, dynamic>{'id': id}));

  @override
  Future<DioApiResponse> cancelSubscription(String id, String reason) async =>
      fakeResponse(_reply('cancelSubscription', <String, dynamic>{'id': id, 'reason': reason}));
}

/// A saved address in the app's vocabulary, ready to be mapped by `addressSnapshot`.
Map<String, dynamic> fakeAddress({
  String id = 'addr-1',
  String name = 'Asha',
  String contact = '+919812345678',
  String flatHouse = '12, 4th Cross',
  String locality = 'Indiranagar',
  String landmark = 'Near the temple',
}) {
  return <String, dynamic>{
    'id': id,
    'receiverName': name,
    'receiverContact': contact,
    'countryCode': '+91',
    'flatHouse': flatHouse,
    'locality': locality,
    'landmark': landmark,
    'location': <String, dynamic>{
      'type': 'Point',
      'coordinates': <double>[77.6408, 12.9784],
    },
  };
}

/// The envelope `GET /addresses` answers with.
Map<String, dynamic> addressListResponse(List<Map<String, dynamic>> addresses) {
  return <String, dynamic>{'list': addresses, 'total': addresses.length};
}

/// Decoded body of a recorded request, for assertions.
Map<String, dynamic> decodeBody(String body) =>
    Map<String, dynamic>.from(jsonDecode(body) as Map);