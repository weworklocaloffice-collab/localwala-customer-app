/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

/// Decode/format helpers shared by the dairy screens.
///
/// The dairy API answers with bare lists, `{items: []}` or `{list: []}`
/// depending on the endpoint, and every money field arrives as a number the
/// server already converted from paise. These keep that handling in one place
/// instead of re-deciding it per screen.
library;

List<dynamic> decodeList(dynamic decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map) {
    final dynamic wrapped = decoded['items'] ?? decoded['list'] ?? decoded['results'];
    if (wrapped is List) return wrapped;
  }
  return const <dynamic>[];
}

Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

String formatMoney(dynamic v) {
  if (v == null) return '-';
  final double? d = double.tryParse(v.toString());
  if (d == null) return v.toString();
  return '₹${d.toStringAsFixed(d == d.roundToDouble() ? 0 : 2)}';
}

String formatDate(dynamic v) {
  if (v == null) return '';
  final DateTime? d = DateTime.tryParse(v.toString());
  return d == null ? v.toString() : '${d.day}/${d.month}/${d.year}';
}
