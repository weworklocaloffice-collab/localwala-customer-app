/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 *
 * This source code is proprietary to WeWorkLocal.
 */

import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/services/shared_pref.dart';

/// Local-only "Recently viewed" store for real estate properties.
///
/// Backed by `shared_preferences`. No backend round-trip — the customer
/// app's "Recently viewed" screen is purely a device-local history.
///
/// API:
///   - [record] — push a property id, dedup, cap at 20, write back.
///   - [list]   — read the last 20 ids, newest first.
///   - [clear]  — wipe the list (a "Clear history" button).
///
/// The store is intentionally tiny (just an id list). The screen that
/// displays the list joins against the public
/// `/v1/realestate/public/properties/{id}` endpoint for each entry.
class RecentlyViewedStore {
  static const int _maxItems = 20;

  final SharedPreferencesManager _prefs;
  RecentlyViewedStore(this._prefs);

  String get _key => SharedPreferencesKey.publicKeys.realEstateRecentlyViewed;

  /// Record a property id at the top of the list. Dedups so a re-view
  /// moves the entry rather than duplicating it. Trims to [_maxItems].
  Future<void> record(String propertyId) async {
    if (propertyId.isEmpty) return;
    final list = await _read();
    list.removeWhere((id) => id == propertyId);
    list.insert(0, propertyId);
    if (list.length > _maxItems) {
      list.removeRange(_maxItems, list.length);
    }
    await _prefs.putStringList(_key, list);
  }

  /// Last 20 viewed property ids, newest first.
  Future<List<String>> list() => _read();

  /// Wipe the history.
  Future<void> clear() async {
    await _prefs.putStringList(_key, const <String>[]);
  }

  Future<List<String>> _read() async {
    final raw = await _prefs.getStringList(_key);
    return raw == null ? <String>[] : raw;
  }
}
