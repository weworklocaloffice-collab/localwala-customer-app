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

/// Catalogue service row. Price display rules: FIXED shows its band,
/// QUOTE/INSPECTION_QUOTE shows "quote needed" — never a fake fixed price.
class LsService {
  final String id;
  final String key;
  final String name;
  final String bookingMode;
  final String pricingMode;

  const LsService({
    required this.id,
    required this.key,
    required this.name,
    required this.bookingMode,
    required this.pricingMode,
  });

  factory LsService.fromJson(Map<String, dynamic> json) => LsService(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        key: '${json['key'] ?? ''}',
        name: '${json['name'] ?? ''}',
        bookingMode: '${json['bookingMode'] ?? ''}',
        pricingMode: '${json['pricingMode'] ?? ''}',
      );

  bool get needsQuote =>
      pricingMode == 'QUOTE' || pricingMode == 'INSPECTION_QUOTE';
}

/// Customer booking row. Actions mirror the server state table (display
/// only — every transition is allow-listed again server-side).
class LsCustomerBooking {
  final String id;
  final String code;
  final String status;
  final double labourAmount;
  final double partsAmount;

  const LsCustomerBooking({
    required this.id,
    required this.code,
    required this.status,
    required this.labourAmount,
    required this.partsAmount,
  });

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory LsCustomerBooking.fromJson(Map<String, dynamic> json) =>
      LsCustomerBooking(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        code: '${json['bookingCode'] ?? ''}',
        status: '${json['status'] ?? ''}',
        labourAmount: _num(json['labourAmount']),
        partsAmount: _num(json['partsAmount']),
      );

  List<String> get actions {
    switch (status) {
      case 'DRAFT':
        return const <String>['REQUESTED', 'CANCELLED'];
      case 'CONFIRMED':
        return const <String>['CANCELLED'];
      case 'COMPLETED':
        return const <String>['DISPUTED'];
      default:
        return const <String>[];
    }
  }
}
