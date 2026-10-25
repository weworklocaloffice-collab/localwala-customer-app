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
  final String description;
  final int baseDurationMinutes;
  final int depositPercent;
  final List<String> allowedPaymentModes;

  const LsService({
    required this.id,
    required this.key,
    required this.name,
    required this.bookingMode,
    required this.pricingMode,
    this.description = '',
    this.baseDurationMinutes = 60,
    this.depositPercent = 0,
    this.allowedPaymentModes = const <String>[],
  });

  factory LsService.fromJson(Map<String, dynamic> json) => LsService(
    id: '${json['_id'] ?? json['id'] ?? ''}',
    key: '${json['key'] ?? ''}',
    name: '${json['name'] ?? ''}',
    bookingMode: '${json['bookingMode'] ?? ''}',
    pricingMode: '${json['pricingMode'] ?? ''}',
    description: '${json['description'] ?? ''}',
    baseDurationMinutes:
        int.tryParse('${json['baseDurationMinutes'] ?? 60}') ?? 60,
    depositPercent: int.tryParse('${json['depositPercent'] ?? 0}') ?? 0,
    allowedPaymentModes:
        ((json['allowedPaymentModes'] as List?) ?? const <dynamic>[])
            .map((dynamic e) => '$e')
            .toList(),
  );

  bool get needsQuote =>
      pricingMode == 'QUOTE' || pricingMode == 'INSPECTION_QUOTE';
}

class LsVariant {
  final String id;
  final String name;
  final int durationMinutes;
  final double price;

  const LsVariant({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  factory LsVariant.fromJson(Map<String, dynamic> json) => LsVariant(
    id: '${json['_id'] ?? json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    durationMinutes: int.tryParse('${json['durationMinutes'] ?? 60}') ?? 60,
    price: _asDouble(json['price'] ?? json['basePrice']),
  );
}

class LsAddon {
  final String id;
  final String name;
  final double price;
  final String unit;

  const LsAddon({
    required this.id,
    required this.name,
    required this.price,
    this.unit = '',
  });

  factory LsAddon.fromJson(Map<String, dynamic> json) => LsAddon(
    id: '${json['_id'] ?? json['id'] ?? ''}',
    name: '${json['name'] ?? ''}',
    price: _asDouble(json['price']),
    unit: '${json['unit'] ?? ''}',
  );
}

class LsOffering {
  final String id;
  final String providerId;
  final String providerName;
  final String variantId;
  final double price;
  final int durationMinutes;

  const LsOffering({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.variantId,
    required this.price,
    required this.durationMinutes,
  });

  factory LsOffering.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> provider = Map<String, dynamic>.from(
      json['provider'] as Map? ?? <String, dynamic>{},
    );
    final Map<String, dynamic>? variant = json['variant'] is Map
        ? Map<String, dynamic>.from(json['variant'] as Map)
        : null;
    return LsOffering(
      id: '${json['offering'] ?? json['_id'] ?? ''}',
      providerId: '${provider['_id'] ?? provider['id'] ?? ''}',
      providerName: '${provider['businessName'] ?? ''}',
      variantId: '${variant?['_id'] ?? variant?['id'] ?? ''}',
      price: _asDouble(json['price']),
      durationMinutes: int.tryParse('${json['durationMinutes'] ?? 60}') ?? 60,
    );
  }
}

double _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

/// Customer booking row. Actions mirror the server state table (display
/// only — every transition is allow-listed again server-side).
class LsCustomerBooking {
  final String id;
  final String code;
  final String status;
  final String paymentStatus;
  final String paymentMode;
  final double labourAmount;
  final double partsAmount;
  final double serviceValue;
  final double depositAmount;
  final double balanceAmount;
  final double amountPaid;

  const LsCustomerBooking({
    required this.id,
    required this.code,
    required this.status,
    required this.labourAmount,
    required this.partsAmount,
    this.paymentStatus = 'pending',
    this.paymentMode = 'gateway',
    this.serviceValue = 0,
    this.depositAmount = 0,
    this.balanceAmount = 0,
    this.amountPaid = 0,
  });

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory LsCustomerBooking.fromJson(Map<String, dynamic> json) =>
      LsCustomerBooking(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        code: '${json['bookingCode'] ?? ''}',
        status: '${json['status'] ?? ''}',
        paymentStatus: '${json['paymentStatus'] ?? 'pending'}',
        paymentMode: '${json['paymentMode'] ?? 'gateway'}',
        labourAmount: _num(json['labourAmount']),
        partsAmount: _num(json['partsAmount']),
        serviceValue: _num(json['serviceValue']),
        depositAmount: _num(json['depositAmount']),
        balanceAmount: _num(json['balanceAmount']),
        amountPaid: _num(json['amountPaid']),
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
