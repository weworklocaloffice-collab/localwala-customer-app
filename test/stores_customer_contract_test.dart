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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/features/stores/stores_customer_endpoints.dart';

/// Asserts every endpoint the customer app CALLS actually exists on the server, with the
/// same HTTP verb.
///
/// This exists because of what went wrong before it did. The stores surface had eleven
/// endpoints that were written, guarded, documented — and unreachable, each a literal path
/// declared after a sibling carrying a parameter in that position, so Express handed the
/// request to the wrong handler. Nothing caught it: the backend's own contract suite reads
/// the PARTNER app's Dart file, and every stores suite calls the service layer directly.
/// The customer app had no equivalent check at all.
///
/// The two apps also drifted independently on verbs. `GET /nearby` was being called with
/// POST, which finds no route and renders as an empty storefront rather than an error —
/// the customer cannot tell "no stores nearby" from "wrong request".
///
/// So this walks it from the CLIENT side, which is the side that has no other check.
void main() {
  final String repoRoot = Directory.current.parent.path;

  /// Reads a sibling-checkout file. Throws rather than using `expect`, because this is
  /// called while `main()` is still setting up — outside any test body — and `expect`
  /// there throws an `OutsideTestException` that hides the real cause.
  String readSource(String relativePath) {
    final File file = File('$repoRoot/$relativePath');
    if (!file.existsSync()) {
      throw StateError(
        'Could not find $relativePath, resolved to ${file.path}. This test needs the '
        'Customer_app and API checkouts side by side. If the repo layout changed, update '
        'the path here — do not delete the test, it is the only client/server drift guard '
        'the customer app has.',
      );
    }
    return file.readAsStringSync();
  }

  // --- the server side -----------------------------------------------------------
  //
  // Read BOTH files. The storefront catch-alls (`/:store`, `/:store/products`, ...) live
  // in their own router precisely because putting them in the customer router shadowed
  // seven partner paths. Reading only one file would report those four as missing and
  // train people to ignore this test.
  final String customerRoutes =
      readSource('API/src/modules/stores/routes/stores.customer.route.js');
  final String storefrontRoutes =
      readSource('API/src/modules/stores/routes/stores.storefront.route.js');

  // Triple-quoted because a raw string does NOT process `\"`, so `['\"]` inside
  // `r"..."` would terminate the string at the backslash.
  final RegExp routePattern =
      RegExp(r'''router\.(get|post|patch|put|delete)\(\s*['"]([^'"]+)['"]''');

  /// The stores router is mounted at `/v1/stores` in the app bootstrap, and the route
  /// FILES declare paths relative to that mount — `router.get('/nearby')` is really
  /// `GET /v1/stores/nearby`. The prefix has to be added here, or every client path
  /// mismatches every server path and the test is pure noise.
  const String mount = '/v1/stores';

  Set<String> serverRoutes(String source) {
    final Set<String> out = <String>{};
    for (final RegExpMatch m in routePattern.allMatches(source)) {
      out.add('${m.group(1)!.toUpperCase()} $mount${m.group(2)}');
    }
    return out;
  }

  final Set<String> live = <String>{
    ...serverRoutes(customerRoutes),
    ...serverRoutes(storefrontRoutes),
  };

  test('the server route files were found and contain routes', () {
    expect(live, isNotEmpty, reason: 'parsed zero routes — the regex or path is wrong');
  });

  // --- the client side -----------------------------------------------------------
  //
  // The constants are the single source of truth for paths, and the SERVICE decides the
  // verb. So both are read, and the pair is what gets checked: a path that exists on the
  // server but is called with the wrong verb is exactly the bug that produced an empty
  // storefront.
  final Map<String, String> constants = <String, String>{
    for (final RegExpMatch m
        in RegExp(r"static const String (\w+)\s*=\s*'([^']+)'")
            .allMatches(readSource(
                'Customer_app/lib/app/features/stores/stores_customer_endpoints.dart')))
      m.group(1)!: m.group(2)!,
  };

  final String serviceSource =
      readSource('Customer_app/lib/app/features/stores/services/stores_customer_service.dart');

  /// `{product}` in the app, `:product` on the server — same slot, different spelling.
  /// The app's constants are written without a leading slash (`v1/stores/nearby`) because
  /// the HTTP client prepends the base URL, while Express paths always start with one.
  String normalise(String path) {
    final String bare = path.split('?').first;
    final String slashed = bare.startsWith('/') ? bare : '/$bare';
    return slashed.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (Match m) => ':${m.group(1)}',
    );
  }

  group('every endpoint the service calls exists on the server', () {
    test('the endpoint constants were parsed', () {
      expect(constants, isNotEmpty);
      expect(constants.containsKey('nearby'), isTrue);
    });

    // Each call is paired with the verb it is issued under. If a constant stops being
    // called, it shows up as "unused" rather than silently rotting.
    final Map<String, String> calledAs = <String, String>{};
    final List<String> unmapped = <String>[];
    final List<RegExpMatch> calls =
        RegExp(r'_apiRequestService\.(get|post|patch|put|delete)\(')
            .allMatches(serviceSource)
            .toList();

    for (int i = 0; i < calls.length; i += 1) {
      final RegExpMatch call = calls[i];
      final int start = call.end;
      final int end = (i + 1 < calls.length) ? calls[i + 1].start : serviceSource.length;
      final String chunk = serviceSource.substring(start, end);

      // Word-boundary anchored. A plain `contains` would make
      // `StoresCustomerEndpoints.cart` match inside `cartAdd`/`cartRemove`/`cartClear`,
      // so a POST to `cartClear` would be reported as "the app calls /cart with POST".
      String? found;
      for (final String name in constants.keys) {
        if (RegExp('StoresCustomerEndpoints\\.$name\\b').hasMatch(chunk)) {
          found = name;
          break;
        }
      }
      if (found == null) {
        unmapped.add('${call.group(1)}: ${chunk.trim().split('\n').first}');
      } else {
        calledAs[found] = call.group(1)!.toUpperCase();
      }
    }

    test('every HTTP call maps to a declared endpoint constant', () {
      expect(unmapped, isEmpty,
          reason: 'these calls could not be traced to an endpoint constant, so they '
              'are unverified: ${unmapped.join(' | ')}');
    });

    test('each endpoint is called with a verb the server actually serves', () {
      final List<String> mismatched = <String>[];
      calledAs.forEach((String name, String verb) {
        final String path = normalise(constants[name]!);
        if (!live.contains('$verb $path')) {
          // Distinguish "wrong verb" from "no such path" — the fixes are different.
          final bool wrongVerbOnly = live.any((String r) => r.endsWith(' $path'));
          mismatched.add(wrongVerbOnly
              ? '$path is served, but the app calls it $verb'
              : '$verb $path is not served at all');
        }
      });
      expect(mismatched, isEmpty, reason: mismatched.join('\n'));
    });

    test('the endpoints the customer flow depends on are all served', () {
      // These are the calls checkout cannot complete without. Named individually so a
      // regression says which step broke rather than "1 of 14".
      for (final String name in <String>[
        'nearby',
        'store',
        'storeProducts',
        'product',
        'cart',
        'cartAdd',
        'cartUpdate',
        'cartRemove',
        'cartClear',
        'checkoutEligibility',
        'checkoutSummary',
        'orders',
        'customerOrders',
        'customerOrder',
        'orderCancel',
        'orderPay',
        'orderReview',
        'createReturn',
        'createExchange',
      ]) {
        final String path = normalise(constants[name]!);
        expect(live.any((String r) => r.endsWith(' $path')), isTrue,
            reason: '$name -> ${constants[name]} is not served by the stores customer '
                'or storefront router');
      }
    });
  });

  group('resolve refuses to build a request against a literal placeholder', () {
    test('it substitutes a supplied parameter', () {
      final String path = StoresCustomerEndpoints.resolve(
        StoresCustomerEndpoints.product,
        <String, String>{'product': 'abc123'},
      );
      expect(path, 'v1/stores/products/abc123');
      expect(path, isNot(contains('{product}')));
    });

    test('it THROWS on a missing parameter instead of sending it', () {
      // The reason this matters: `v1/stores/{store}` with the placeholder left in is a
      // single-segment path, and `/:store` is a real storefront route. An unresolved
      // placeholder would return a store profile — a wrong page, not an error.
      expect(
        () => StoresCustomerEndpoints.resolve(
          StoresCustomerEndpoints.store,
          <String, String>{},
        ),
        throwsArgumentError,
      );
    });

    test('it throws on an empty value as well as a missing key', () {
      expect(
        () => StoresCustomerEndpoints.resolve(
          StoresCustomerEndpoints.store,
          <String, String>{'store': ''},
        ),
        throwsArgumentError,
      );
    });

    test('every templated path names at least one parameter', () {
      // A `{...}` left in a constant is a latent wrong-route bug; assert the shape so it
      // is deliberate rather than accidental.
      for (final MapEntry<String, String> e in constants.entries) {
        if (e.value.contains('{')) {
          expect(
            normalise(e.value),
            matches(RegExp(r':\w+')),
            reason: '${e.key} = ${e.value} looks templated but not like {param}',
          );
        }
      }
    });
  });
}