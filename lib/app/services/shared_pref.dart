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

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  Future<bool> putBool(String key, bool value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(key, value);
  }

  Future<bool> getBool(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key) ?? false;
  }

  Future<bool> putDouble(String key, double value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(key);
  }

  Future<bool?> putInt(String key, int value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key);
  }

  Future<bool?> putString(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  Future<bool?> putStringList(String key, List<String> value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(key);
  }

  Future<bool> isKeyExists(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(key);
  }

  Future<bool?> clearKey(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }

  Future<bool?> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.clear();
  }
}

