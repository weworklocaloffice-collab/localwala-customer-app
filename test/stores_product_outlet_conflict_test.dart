/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Ac 2026 WeWorkLocal.
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
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/stores_product_view.dart';

import 'helpers/stores_fakes.dart';

/// Refuses the first add the way the server does for BR-37: the cart already holds
/// another outlet's products, so the screen must ask before changing anything.
class _OutletConflictService extends FakeStoresService {
  _OutletConflictService({required this.succeedsAfterClear});

  final bool succeedsAfterClear;
  int addCalls = 0;
  bool cleared = false;

  @override
  Future<DioApiResponse> cartAdd(Map<String, dynamic> body) async {
    addCalls += 1;
    lastBody['cartAdd'] = body;
    calls.add('cartAdd');
    if (succeedsAfterClear && addCalls > 1) {
      return fakeResponse(<String, dynamic>{'ok': true});
    }
    return fakeResponse(<String, dynamic>{
      'code': 'CART_OUTLET_CONFLICT',
      'cartOutlet': 'OUTLET-OTHER',
      'requestedOutlet': 'OUTLET1',
    }, statusCode: 409);
  }

  @override
  Future<DioApiResponse> cartClear() async {
    cleared = true;
    calls.add('cartClear');
    return fakeResponse(<String, dynamic>{'ok': true});
  }
}

Map<String, dynamic> _productPayload() => <String, dynamic>{
  'product': <String, dynamic>{
    '_id': 'P1',
    'name': 'Amul Milk',
    'description': 'Fresh',
    'variants': <dynamic>[
      <String, dynamic>{'_id': 'V1', 'name': '500 ml', 'price': 30},
    ],
  },
};

Future<void> _pumpProduct(WidgetTester tester, StoresCustomerService service) async {
  // The add controls live below the fold on the default surface; a widget test only
  // finds what is laid out, so render tall enough for them to exist.
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: StoresProductView(
        productId: 'P1',
        storeId: 'OUTLET1',
        chainId: 'CHAIN1',
        service: service,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('BR-37 outlet conflict', () {
    testWidgets('a conflicting add asks before touching the existing cart',
        (WidgetTester tester) async {
      final _OutletConflictService service =
          _OutletConflictService(succeedsAfterClear: false)
            ..responses = <String, Object?>{'product': _productPayload()};
      await _pumpProduct(tester, service);

      await tester.tap(find.widgetWithText(FilledButton, 'Add to cart'));
      // The add button spins while the request is in flight, so settle by hand: an
      // indeterminate spinner never reaches a settled frame while the dialog is up.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Your cart contains products from another outlet'),
        findsOneWidget,
      );
      expect(service.addCalls, 1);
      expect(service.cleared, isFalse,
          reason: 'showing the dialog must never clear the cart');

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(
        find.text('Your cart contains products from another outlet'),
        findsNothing,
      );
      expect(service.cleared, isFalse);
      expect(service.addCalls, 1, reason: 'cancel must not retry the add');
    });

    testWidgets('clearing the cart retries the add against the browsing outlet',
        (WidgetTester tester) async {
      final _OutletConflictService service =
          _OutletConflictService(succeedsAfterClear: true)
            ..responses = <String, Object?>{
              'product': _productPayload(),
              'cart': <String, dynamic>{'items': <dynamic>[], 'grandTotal': 0},
            };
      await _pumpProduct(tester, service);

      await tester.tap(find.widgetWithText(FilledButton, 'Add to cart'));
      // See above: the in-flight spinner means fixed pumps, not pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Clear cart and continue'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(service.cleared, isTrue);
      expect(service.addCalls, 2);
      expect(service.lastBody['cartAdd']!['outlet'], 'OUTLET1');
      expect(find.text('Added to cart'), findsOneWidget);
    });
  });
}
