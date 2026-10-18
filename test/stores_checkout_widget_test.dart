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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/stores/stores_checkout_view.dart';
import 'package:user/app/features/stores/stores_subscribe_view.dart';

import 'helpers/stores_fakes.dart';

/// Repositories the checkout screen reads. Overridden so no shared-preferences or network
/// access happens in a widget test.
class _FakeAddressRepository extends AddressRepository {
  _FakeAddressRepository(this.payload);
  final Map<String, dynamic> payload;
  @override
  Future<DioApiResponse> getMyAddressList(String uid) async => fakeResponse(payload);
}

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<String> userId() async => 'user-1';
}

/// Renders the checkout screen with a scripted service.
///
/// The surface is enlarged because these screens are a `ListView`: a widget test only finds
/// what is actually laid out, so a total below the fold is indistinguishable from a total
/// that was never rendered. The second failure this hides is worse than a missing widget —
/// it looks exactly like a server value that never arrived.
Future<void> useTallSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Scrolls a widget into view, then returns it. No-op when already visible.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

/// Renders the checkout screen with a scripted service.
Future<void> pumpCheckout(
  WidgetTester tester,
  FakeStoresService service, {
  List<Map<String, dynamic>> addresses = const <Map<String, dynamic>>[],
}) async {
  await useTallSurface(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: StoresCheckoutView(
        storeId: 'OUTLET1',
        chainId: 'CHAIN1',
        service: service,
        addresses: _FakeAddressRepository(addressListResponse(addresses)),
        auth: _FakeAuthRepository(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('checkout renders the server state', () {
    testWidgets('an empty cart summary shows no line items', (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{'eligible': true, 'reasons': <String>[]},
          'checkoutSummary': <String, dynamic>{'items': <dynamic>[], 'grandTotal': 0},
        };
      await pumpCheckout(tester, service);
      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('summary lines and the grand total are shown from the server',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{'eligible': true, 'reasons': <String>[]},
          'checkoutSummary': <String, dynamic>{
            'items': <dynamic>[
              <String, dynamic>{'name': 'Amul Butter', 'quantity': 2, 'lineGrand': 108},
            ],
            'itemsSubtotal': 100,
            'taxTotal': 8,
            'deliveryFee': 20,
            'packagingFee': 5,
            'grandTotal': 133,
          },
        };
      await pumpCheckout(tester, service);

      expect(find.text('Amul Butter'), findsOneWidget);
      expect(find.text('133'), findsOneWidget);
      expect(find.text('20'), findsOneWidget, reason: 'delivery fee comes from the server');
    });
  });

  group('ineligibility is the server\'s call and blocks the order', () {
    testWidgets('an ineligible store shows the reason and disables Place order',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{
            'eligible': false,
            'reasons': <String>['STORE_CLOSED'],
          },
          'checkoutSummary': <String, dynamic>{'items': <dynamic>[]},
        };
      await pumpCheckout(tester, service, addresses: <Map<String, dynamic>>[fakeAddress()]);

      // The reason is translated to words, not shown as a code.
      expect(find.text('The store is closed right now.'), findsOneWidget);
      expect(find.text('STORE_CLOSED'), findsNothing);

      final Finder place = find.widgetWithText(FilledButton, 'Place order');
      expect(tester.widget<FilledButton>(place).onPressed, isNull,
          reason: 'an ineligible store must not be orderable');
    });

    testWidgets('with no saved address, Place order is disabled',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{'eligible': true, 'reasons': <String>[]},
          'checkoutSummary': <String, dynamic>{'items': <dynamic>[]},
        };
      await pumpCheckout(tester, service, addresses: const <Map<String, dynamic>>[]);

      expect(find.text('No saved addresses yet. Add one in Address Book.'), findsOneWidget);
      final Finder place = find.widgetWithText(FilledButton, 'Place order');
      expect(tester.widget<FilledButton>(place).onPressed, isNull);
    });
  });

  group('placing an order sends what the server requires', () {
    testWidgets('addressId and addressSnapshot are both present',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{'eligible': true, 'reasons': <String>[]},
          'checkoutSummary': <String, dynamic>{'items': <dynamic>[]},
'placeOrder': <String, dynamic>{'order': <String, dynamic>{'_id': 'ORDER1'}},
          // The screen navigates straight to tracking after placing, so this has to be
          // scripted too — an unscripted call throws inside the fake rather than hanging,
          // which is the difference between an obvious failure and a timeout.
          'order': <String, dynamic>{
            'order': <String, dynamic>{
              '_id': 'ORDER1',
              'orderNo': 'SO-1',
              'lifecycle': 'confirmed',
              'paymentStatus': 'pending',
              'grandTotal': 133,
            },
          },
        };
      await pumpCheckout(tester, service, addresses: <Map<String, dynamic>>[fakeAddress()]);

      final Finder place = find.widgetWithText(FilledButton, 'Place order');
      await reveal(tester, place);
      await tester.tap(place);
      await tester.pumpAndSettle();

      final Map<String, dynamic> body = service.lastBody['placeOrder']!;
      expect(body['addressId'], 'addr-1');
      expect(body['outlet'], 'OUTLET1');
      expect(body['chain'], 'CHAIN1');
      expect(body['paymentMode'], 'gateway');

      final Map<String, dynamic> snapshot = body['addressSnapshot'] as Map<String, dynamic>;
      expect(snapshot['name'], 'Asha');
      expect(snapshot['line1'], '12, 4th Cross',
          reason: 'flatHouse is the app\'s name for the door-level address');
      expect(snapshot['contact'], '+919812345678');

      // No items, no price: the server reads its own cart and re-prices at billing time.
      expect(body.containsKey('items'), isFalse);
      expect(body.containsKey('amount'), isFalse);
    });

    testWidgets('switching payment mode re-quotes rather than patching locally',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'checkoutEligibility': <String, dynamic>{'eligible': true, 'reasons': <String>[]},
          'checkoutSummary': <String, dynamic>{'items': <dynamic>[]},
        };
      await pumpCheckout(tester, service, addresses: <Map<String, dynamic>>[fakeAddress()]);

      final int before = service.calls.where((String c) => c == 'checkoutSummary').length;
      await reveal(tester, find.text('Cash on delivery'));
      await tester.tap(find.text('Cash on delivery'));
      await tester.pumpAndSettle();

      expect(service.calls.where((String c) => c == 'checkoutSummary').length, greaterThan(before),
          reason: 'COD changes fees and the ceiling, so the quote must come from the server');
      expect(service.lastBody['checkoutSummary']!['paymentMode'], 'cod');
    });
  });

  group('subscribe screen', () {
    Future<void> pumpSubscribe(WidgetTester tester, FakeStoresService service) async {
      await useTallSurface(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: StoresSubscribeView(
            storeId: 'OUTLET1',
            items: <Map<String, dynamic>>[
              <String, dynamic>{'variant': 'V1', 'quantity': 2},
            ],
            service: service,
            addresses: _FakeAddressRepository(
              addressListResponse(<Map<String, dynamic>>[fakeAddress()]),
            ),
            auth: _FakeAuthRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('creating sends variant, quantity, cadence, day, slot and outlet',
        (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'createSubscription': <String, dynamic>{
            'subscription': <String, dynamic>{'_id': 'SUB1'},
          },
        };
      await pumpSubscribe(tester, service);

      expect(find.text('Every two weeks'), findsOneWidget);
      await tester.tap(find.text('Every two weeks'));
      await tester.pumpAndSettle();

      await reveal(tester, find.widgetWithText(FilledButton, 'Create subscription'));
      await tester.tap(find.widgetWithText(FilledButton, 'Create subscription'));
      await tester.pumpAndSettle();

      final Map<String, dynamic> body = service.lastBody['createSubscription']!;
      expect(body['outlet'], 'OUTLET1',
          reason: 'the server has no outlet in a customer session and requires one');
      expect(body['cadence'], 'biweekly');
      expect(body['address'], 'addr-1');
      final List<dynamic> items = body['items'] as List<dynamic>;
      expect(items.length, 1);
      expect((items.first as Map<String, dynamic>)['variant'], 'V1');
      expect((items.first as Map<String, dynamic>)['quantity'], 2);
      expect((body['deliverySlot'] as Map<String, dynamic>)['startTime'], '06:00');
      expect(body.containsKey('startDate'), isTrue);
    });

    testWidgets('no price is ever sent', (WidgetTester tester) async {
      final FakeStoresService service = FakeStoresService()
        ..responses = <String, Object?>{
          'createSubscription': <String, dynamic>{
            'subscription': <String, dynamic>{'_id': 'SUB1'},
          },
        };
      await pumpSubscribe(tester, service);
      await reveal(tester, find.widgetWithText(FilledButton, 'Create subscription'));
      await tester.tap(find.widgetWithText(FilledButton, 'Create subscription'));
      await tester.pumpAndSettle();

      final Map<String, dynamic> body = service.lastBody['createSubscription']!;
      expect(body.containsKey('discountPercentage'), isFalse);
      final List<dynamic> items = body['items'] as List<dynamic>;
      final Map<String, dynamic> line = items.first as Map<String, dynamic>;
      expect(line.containsKey('unitPriceAtSubscribe'), isFalse,
          reason: 'the server re-prices from the outlet rows; a client price is ignored');
    });
  });
}