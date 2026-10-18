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

import 'package:crypto/crypto.dart';

/// Canonical phone normalisation for contact matching.
///
/// MUST stay identical to the backend (`contacts.service.js`) and to every
/// other client: digits only, then strip leading zeros.
/// `+91 98765 43210` -> `919876543210`.
String normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.replaceFirst(RegExp(r'^0+'), '');
}

/// SHA-256 hex of a normalised number. Only hashes leave the device.
String sha256Hex(String normalized) {
  return sha256.convert(utf8.encode(normalized)).toString();
}
