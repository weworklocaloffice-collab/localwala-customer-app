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

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/social/models/matched_contact.dart';
import 'package:user/app/features/social/services/contact_phone.dart';

/// Server cap — keep the client at or under it so sync never 400s.
const int maxContactsPerSync = 2000;

enum ContactsPermission { granted, denied, permanentlyDenied }

class ContactsSyncResult {
  final bool synced;
  final ContactsPermission permission;
  final List<MatchedContact> matched;
  final int matchedCount;
  final DateTime? lastSyncAt;

  const ContactsSyncResult({
    required this.synced,
    required this.permission,
    this.matched = const [],
    this.matchedCount = 0,
    this.lastSyncAt,
  });
}

/// "Find friends from contacts": permission → read → normalize → SHA-256 →
/// POST /v1/social/contacts/sync. Raw numbers never leave the device and the
/// address book itself is never uploaded.
class ContactsService {
  final ApiRequestService _api = ApiRequestService();

  Future<ContactsPermission> requestPermission() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    // `limited` (iOS 18+ contact picker) still yields usable numbers.
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited) {
      return ContactsPermission.granted;
    }
    return status == PermissionStatus.permanentlyDenied ||
            status == PermissionStatus.restricted
        ? ContactsPermission.permanentlyDenied
        : ContactsPermission.denied;
  }

  /// Reads phone numbers, returns their unique hashes (capped). Pure device
  /// work — no network, safe to call for a pre-sync count.
  Future<List<String>> readContactHashes() async {
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    final hashes = <String>{};
    for (final contact in contacts) {
      for (final phone in contact.phones) {
        final normalized = normalizePhone(phone.number);
        if (normalized.isEmpty) continue;
        hashes.add(sha256Hex(normalized));
        if (hashes.length >= maxContactsPerSync) break;
      }
      if (hashes.length >= maxContactsPerSync) break;
    }
    return hashes.toList();
  }

  Future<ContactsSyncResult> syncContacts() async {
    final permission = await requestPermission();
    if (permission != ContactsPermission.granted) {
      return ContactsSyncResult(synced: false, permission: permission);
    }
    final hashes = await readContactHashes();
    if (hashes.isEmpty) {
      return ContactsSyncResult(synced: true, permission: permission);
    }
    final response = await _api.post(
      ApiEndPoints.v1request.syncContacts,
      body: {'contacts': hashes},
    );
    if (!response.success) {
      return ContactsSyncResult(synced: false, permission: permission);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = (data['matchedUsers'] as List?) ?? [];
    final matched = raw
        .map((e) => MatchedContact.fromJson(e as Map<String, dynamic>))
        .toList();
    DateTime? lastSyncAt;
    final lastSyncRaw = data['lastSyncAt'] as String?;
    if (lastSyncRaw != null) lastSyncAt = DateTime.tryParse(lastSyncRaw);
    return ContactsSyncResult(
      synced: true,
      permission: permission,
      matched: matched,
      matchedCount: (data['matchedCount'] as num?)?.toInt() ?? matched.length,
      lastSyncAt: lastSyncAt ?? DateTime.now(),
    );
  }
}
