import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/features/dairy/dairy_customer_endpoints.dart';

void main() {
  test('Dairy customer marketing endpoints are served by the Dairy router', () {
    final String routes = File(
      '../API/src/modules/dairy/routes/dairy.route.js',
    ).readAsStringSync();
    expect(DairyCustomerEndpoints.marketingFeatured,
        'v1/dairy/customer/marketing/featured');
    expect(routes, contains("'/customer/marketing/featured'"));
    expect(routes, contains("'/customer/marketing/campaigns/:campaign/events'"));
    expect(DairyCustomerEndpoints.marketingEvent,
        'v1/dairy/customer/marketing/campaigns/{campaign}/events');
  });

  test('Dairy coupons are quoted by the Dairy API and applied at checkout', () {
    final String routes = File(
      '../API/src/modules/dairy/routes/dairy.route.js',
    ).readAsStringSync();
    final String orderValidation = File(
      '../API/src/modules/dairy/validations/dairy.order.validation.js',
    ).readAsStringSync();
    expect(DairyCustomerEndpoints.couponQuote, 'v1/dairy/customer/coupons/quote');
    expect(DairyCustomerEndpoints.availableCoupons,
        'v1/dairy/customer/coupons/available');
    expect(routes, contains("'/customer/coupons/quote'"));
    expect(routes, contains("'/customer/coupons/available'"));
    expect(orderValidation, contains('couponCode:'));
  });
}
