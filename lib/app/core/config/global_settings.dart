/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
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

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/services/shared_pref.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GlobalSettings {
  static String globalCurrencySide = '';
  static String globalCurrencySymbol = '';

  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  Future<void> init() async {
    try {
      final currencySide = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.currencySide);
      final currencySymbol = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.currencySymbolKey);
      globalCurrencySide = currencySide ?? '';
      globalCurrencySymbol = currencySymbol ?? '';
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      throw Exception(e);
    }
  }
}

