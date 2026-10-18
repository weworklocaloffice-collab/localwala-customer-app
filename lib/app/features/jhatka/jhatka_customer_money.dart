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

/// Customer money boundary.
///
/// The customer API is mixed-unit by endpoint, and getting it wrong is a
/// 100x display bug that looks exactly like a pricing bug:
/// - LEAN reads (product variants, order lists, subscriptions) arrive as
///   RAW PAISE — format with [formatPaise].
/// - HYDRATED reads (cart, quote) arrive as RUPEES — format with
///   [formatRupees].
/// When in doubt, check the route: `.lean()` means paise.
library;

/// Raw paise (lean reads) to display: 40000 -> "Rs 400.00".
String formatPaise(num paise) {
  final int p = paise.round();
  final bool negative = p < 0;
  final int abs = p.abs();
  final String rupees = (abs ~/ 100).toString();
  final String tail = (abs % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}Rs $rupees.$tail';
}

/// Rupees (hydrated reads) to display.
String formatRupees(num rupees) {
  return formatPaise((rupees * 100).round());
}
