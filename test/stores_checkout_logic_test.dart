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

import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/features/stores/stores_checkout_logic.dart';

/// The address mapping is where a wrong field name turns into a 400 that says nothing, so
/// it is asserted field by field against the server's `addressSnapshotValidation`.
void main() {
  final Map<String, dynamic> full = <String, dynamic>{
    'id': 'addr-1',
    'receiverName': 'Asha',
    'receiverContact': '+919812345678',
    'countryCode': '+91',
    'flatHouse': '12, 4th Cross, Indiranagar',
    'landmark': 'Near the temple',
    'locality': 'Indiranagar',
    'location': <String, dynamic>{
      'type': 'Point',
      'coordinates': <double>[77.6408, 12.9784],
    },
  };

  group('addressSnapshot maps the address book onto the server schema', () {
    test('receiverName becomes name, not "receiverName"', () {
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(full);
      expect(s['name'], 'Asha');
      expect(s.containsKey('receiverName'), isFalse);
    });

    test('receiverContact becomes contact', () {
      expect(StoresCheckoutLogic.addressSnapshot(full)['contact'], '+919812345678');
    });

    test('flatHouse becomes line1 — the door-level address', () {
      // This is the single most likely mapping to get wrong: the app calls it flatHouse,
      // the server calls it line1, and a mismatch makes every order 400.
      expect(StoresCheckoutLogic.addressSnapshot(full)['line1'], '12, 4th Cross, Indiranagar');
    });

    test('countryCode is carried through', () {
      expect(StoresCheckoutLogic.addressSnapshot(full)['countryCode'], '+91');
    });

    test('landmark and locality fill the optional fields', () {
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(full);
      expect(s['line2'], 'Near the temple');
      expect(s['locality'], 'Indiranagar');
    });

    test('optional fields are omitted, not sent empty', () {
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(<String, dynamic>{
        'receiverName': 'Asha',
        'receiverContact': '+919812345678',
        'countryCode': '+91',
        'flatHouse': '12',
      });
      expect(s.containsKey('line2'), isFalse);
      expect(s.containsKey('locality'), isFalse);
      expect(s.containsKey('location'), isFalse);
    });

    test('coordinates are NOT swapped: GeoJSON order is [lng, lat]', () {
      // Swapping here would silently relocate every delivery pin while still looking
      // plausible, because India is nowhere near the Gulf of Guinea either way.
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(full);
      final List<dynamic> coords =
          ((s['location'] as Map<String, dynamic>)['coordinates'] as List);
      expect(coords.first, 77.6408, reason: 'longitude first');
      expect(coords.last, 12.9784, reason: 'latitude second');
    });

    test('a location without coordinates is dropped, not half-sent', () {
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(<String, dynamic>{
        'receiverName': 'A',
        'location': <String, dynamic>{'type': 'Point'},
      });
      expect(s.containsKey('location'), isFalse);
    });

    test('a missing location degrades to no location, not a crash', () {
      final Map<String, dynamic> s = StoresCheckoutLogic.addressSnapshot(full);
      s.remove('location');
      expect(StoresCheckoutLogic.snapshotIsComplete(s), isTrue,
          reason: 'location is optional; only the four required fields matter');
    });
  });

  group('snapshotIsComplete mirrors what the server refuses to do without', () {
    test('a full address is complete', () {
      expect(StoresCheckoutLogic.snapshotIsComplete(StoresCheckoutLogic.addressSnapshot(full)),
          isTrue);
    });

    for (final String field in <String>['receiverName', 'receiverContact', 'countryCode', 'flatHouse']) {
      test('missing $field makes the snapshot incomplete', () {
        final Map<String, dynamic> address = Map<String, dynamic>.from(full)..remove(field);
        expect(StoresCheckoutLogic.snapshotIsComplete(
          StoresCheckoutLogic.addressSnapshot(address),
        ), isFalse);
      });

      test('a blank $field makes the snapshot incomplete', () {
        // Blank is not the same as absent: an address saved with an empty contact field
        // must not pass as complete just because the key is present.
        final Map<String, dynamic> address = Map<String, dynamic>.from(full)..[field] = '   ';
        expect(StoresCheckoutLogic.snapshotIsComplete(
          StoresCheckoutLogic.addressSnapshot(address),
        ), isFalse);
      });
    }

    test('an empty address is incomplete', () {
      expect(StoresCheckoutLogic.snapshotIsComplete(
        StoresCheckoutLogic.addressSnapshot(<String, dynamic>{}),
      ), isFalse);
    });
  });

  group('reasonText explains BR-27 codes without hiding unknown ones', () {
    test('every documented reason reads as a sentence, not a code', () {
      const List<String> codes = <String>[
        'STORE_NOT_OPERATIONAL',
        'STORE_NOT_ACTIVE',
        'STORE_LOCATION_MISSING',
        'OUTSIDE_DELIVERY_RADIUS',
        'LOCALITY_NOT_SERVICED',
        'STORE_CLOSED',
        'STORE_HOLIDAY',
        'STORE_AT_CAPACITY',
        'OUTLET_NOT_FOUND',
      ];
      for (final String code in codes) {
        final String text = StoresCheckoutLogic.reasonText(code);
        expect(text, isNot(code), reason: '$code was not translated');
        expect(text.endsWith('.'), isTrue, reason: '$code reads as a fragment: $text');
        expect(text.toLowerCase(), isNot(contains(code.toLowerCase())));
      }
    });

    test('an unknown code is shown verbatim rather than swallowed', () {
      // A new server-side reason must be visible to the customer and to whoever reads the
      // feedback. Mapping it to "Something went wrong" would hide exactly that.
      expect(StoresCheckoutLogic.reasonText('BRAND_NEW_REASON'), 'BRAND_NEW_REASON');
    });
  });
}