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

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/social/services/contacts_service.dart';
import 'package:user/app/services/shared_pref.dart';

/// Owns WHEN sync runs: initial sync on first permission, then at most once
/// per [refreshInterval] unless the user explicitly refreshes. Never sync on
/// every app open. Keep this out of the reels UI — call it from settings and
/// from a single app-start check.
class ContactSyncController {
  static const String _lastSyncKey = '_socialLastSyncAt';
  static const Duration refreshInterval = Duration(days: 7);

  final ContactsService _service = ContactsService();
  final SharedPreferencesManager _prefs = SharedPreferencesManager();
  final ApiRequestService _api = ApiRequestService();

  Future<DateTime?> lastSyncAt() async {
    final raw = await _prefs.getString(_lastSyncKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> isSyncDue() async {
    final last = await lastSyncAt();
    if (last == null) return true;
    return DateTime.now().difference(last) >= refreshInterval;
  }

  /// Returns the sync result, or a non-synced result when not due (unless
  /// [force] — the explicit "Refresh" button in settings).
  Future<ContactsSyncResult> syncIfDue({bool force = false}) async {
    if (!force && !await isSyncDue()) {
      return const ContactsSyncResult(
        synced: false,
        permission: ContactsPermission.granted,
      );
    }
    final result = await _service.syncContacts();
    if (result.synced && result.lastSyncAt != null) {
      await _prefs.putString(
        _lastSyncKey,
        result.lastSyncAt!.toIso8601String(),
      );
    }
    return result;
  }

  Future<Map<String, dynamic>?> getPrivacy() async {
    final response = await _api.get(ApiEndPoints.v1request.socialPrivacy);
    if (!response.success) return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Either toggle may be null to leave it unchanged.
  Future<bool> updatePrivacy({
    bool? findFriendsEnabled,
    bool? showActivityToContacts,
  }) async {
    final body = <String, dynamic>{};
    if (findFriendsEnabled != null) {
      body['findFriendsEnabled'] = findFriendsEnabled;
    }
    if (showActivityToContacts != null) {
      body['showActivityToContacts'] = showActivityToContacts;
    }
    if (body.isEmpty) {
      return false;
    }
    final response = await _api.patch(
      ApiEndPoints.v1request.socialPrivacy,
      body: body,
    );
    return response.success;
  }
}
