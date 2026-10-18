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

/// Pure, testable parts of checkout. No widgets, no network, no shared state.
///
/// These two functions were private methods on the checkout screen, which made them
/// untestable — and they are precisely where a wrong field name produces a 400 that tells
/// the customer nothing useful. `addressSnapshot` in particular maps the app's address
/// book vocabulary onto the server's `addressSnapshot` schema, and every one of those names
/// is a guess that can silently be wrong.
///
/// Kept separate from the view so the mapping can be asserted directly.
class StoresCheckoutLogic {
  const StoresCheckoutLogic._();

  /// The app's address book -> the server's `addressSnapshot`.
  ///
  /// The server requires `name`, `contact`, `countryCode` and `line1`; anything absent is
  /// omitted rather than sent as an empty string, because Joi rejects `''` for a required
  /// string in some paths and an empty `line1` is a delivery address with no door on it.
  ///
  /// The name mapping is the load-bearing part:
  ///   receiverName    -> name       (who receives)
  ///   receiverContact -> contact    (how to reach them)
  ///   flatHouse       -> line1      (the app's name for the door-level address)
  ///   landmark        -> line2      (optional)
  ///   locality        -> locality   (optional)
  ///
  /// `location` is passed through as GeoJSON (`type` + `coordinates`) because the server
  /// measures delivery distance from it. Note the app stores coordinates as
  /// `[lng, lat]` and so does GeoJSON — the order is NOT swapped here, and swapping it
  /// would silently move every delivery pin.
  static Map<String, dynamic> addressSnapshot(Map<String, dynamic> address) {
    final Map<String, dynamic> snapshot = <String, dynamic>{};

    void put(String key, Object? value) {
      final String text = '${value ?? ''}'.trim();
      if (text.isNotEmpty) snapshot[key] = text;
    }

    put('name', address['receiverName']);
    put('contact', address['receiverContact']);
    put('countryCode', address['countryCode']);
    put('line1', address['flatHouse']);
    put('line2', address['landmark']);
    put('locality', address['locality']);

    final dynamic location = address['location'];
    if (location is Map && location['coordinates'] is List) {
      snapshot['location'] = <String, dynamic>{
        'type': '${location['type'] ?? 'Point'}',
        'coordinates': location['coordinates'],
      };
    }

    return snapshot;
  }

  /// True when the snapshot carries the four fields the server will not do without.
  ///
  /// Checked client-side so the customer is told what is missing BEFORE a 400 arrives, and
  /// so the screen can disable Place order rather than let it fail.
  static bool snapshotIsComplete(Map<String, dynamic> snapshot) {
    for (final String key in <String>['name', 'contact', 'countryCode', 'line1']) {
      if ('${snapshot[key] ?? ''}'.trim().isEmpty) return false;
    }
    return true;
  }

  /// BR-27 eligibility reason codes in words.
  ///
  /// The server decides eligibility; this only makes its answer readable. An unrecognised
  /// code is shown verbatim rather than swallowed — a new code should be visible to the
  /// customer and to whoever reads the feedback, not hidden behind generic text.
  static String reasonText(String code) {
    switch (code) {
      case 'STORE_NOT_OPERATIONAL':
        return 'This store is not taking orders right now.';
      case 'STORE_NOT_ACTIVE':
        return 'This store is not available.';
      case 'STORE_LOCATION_MISSING':
        return 'This store has not set a delivery location.';
      case 'OUTSIDE_DELIVERY_RADIUS':
        return 'This address is outside the store\'s delivery area.';
      case 'LOCALITY_NOT_SERVICED':
        return 'This store does not deliver to your area.';
      case 'STORE_CLOSED':
        return 'The store is closed right now.';
      case 'STORE_HOLIDAY':
        return 'The store is closed for a holiday today.';
      case 'STORE_AT_CAPACITY':
        return 'The store has reached today\'s order limit.';
      case 'OUTLET_NOT_FOUND':
        return 'This store could not be found.';
      case 'CART_EMPTY':
        return 'There is nothing in your cart.';
      case 'MIN_ORDER_NOT_MET':
        return 'This order is below the store\'s minimum.';
      case 'OUT_OF_STOCK':
        return 'An item is no longer available.';
      case 'NO_ADDRESS_SELECTED':
        return 'Choose a delivery address.';
      case 'ELIGIBILITY_CHECK_FAILED':
        return 'Could not check whether this store can deliver to you.';
      default:
        return code;
    }
  }
}