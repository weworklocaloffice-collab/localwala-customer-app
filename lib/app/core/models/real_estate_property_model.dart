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
 * This source code is proprietary to WeWorkLocal.
 */

/// Real Estate property model — a PUBLISHED listing the customer can see.
class PropertyModel {
  final String id;
  final String? propertyCode;
  final String? title;
  final String? description;
  final String? transactionType; // BUY | RENT
  final double? price;
  final bool priceOnRequest;
  final String? city;
  final String? locality;
  final String? state;
  final String? addressLine;
  final String? pincode;
  final double? area;
  final int? bedrooms;
  final int? bathrooms;
  final int? parking;
  final List<String> amenities;
  final List<String> media;
  final String? status;
  final String? availability; // AVAILABLE | ON_HOLD | SOLD | RENTED
  final DateTime? publishedAt;
  final int views;
  final int enquiries;
  final int visits;
  final bool verified;
  final String? projectName;
  final String? builderName;
  final double? latitude;
  final double? longitude;

  const PropertyModel({
    required this.id,
    this.propertyCode,
    this.title,
    this.description,
    this.transactionType,
    this.price,
    this.priceOnRequest = false,
    this.city,
    this.locality,
    this.state,
    this.addressLine,
    this.pincode,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.parking,
    this.amenities = const [],
    this.media = const [],
    this.status,
    this.availability,
    this.publishedAt,
    this.views = 0,
    this.enquiries = 0,
    this.visits = 0,
    this.verified = false,
    this.projectName,
    this.builderName,
    this.latitude,
    this.longitude,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? intOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    String? strOrNull(dynamic v) => v == null
        ? null
        : v is String
        ? v
        : v.toString();
    final location = json['location'];
    double? lat;
    double? lng;
    if (location is Map<String, dynamic> && location['coordinates'] is List) {
      final c = (location['coordinates'] as List);
      if (c.length >= 2) {
        lng = numOrNull(c[0]);
        lat = numOrNull(c[1]);
      }
    }
    final mediaRaw = json['media'];
    final amenitiesRaw = json['amenities'];
    return PropertyModel(
      id: strOrNull(json['_id'] ?? json['id']) ?? '',
      propertyCode: strOrNull(json['propertyCode']),
      title: strOrNull(json['title']),
      description: strOrNull(json['description']),
      transactionType: strOrNull(json['transactionType']),
      price: numOrNull(json['price']),
      priceOnRequest: json['priceOnRequest'] == true,
      city: strOrNull(json['city']),
      locality: strOrNull(json['locality']),
      state: strOrNull(json['state']),
      addressLine: strOrNull(json['addressLine']),
      pincode: strOrNull(json['pincode']),
      area: numOrNull(json['specs'] is Map ? (json['specs'])['area'] : null),
      bedrooms: intOrNull(
        json['specs'] is Map ? (json['specs'])['bedrooms'] : null,
      ),
      bathrooms: intOrNull(
        json['specs'] is Map ? (json['specs'])['bathrooms'] : null,
      ),
      parking: intOrNull(
        json['specs'] is Map ? (json['specs'])['parking'] : null,
      ),
      amenities: amenitiesRaw is List
          ? amenitiesRaw.map((e) => e.toString()).toList()
          : const [],
      media: mediaRaw is List
          ? mediaRaw
                .where((m) => m is Map && m['url'] != null)
                .map((m) => (m as Map)['url'].toString())
                .toList()
          : const [],
      status: strOrNull(json['status']),
      availability: strOrNull(json['availability']),
      publishedAt: json['publishedAt'] is String
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      views: intOrNull(json['views']) ?? 0,
      enquiries: intOrNull(json['enquiries']) ?? 0,
      visits: intOrNull(json['visits']) ?? 0,
      verified: json['verifiedAt'] != null,
      projectName: strOrNull(json['projectName']),
      builderName: strOrNull(json['builderName']),
      latitude: lat,
      longitude: lng,
    );
  }

  /// Short display label for a listing — title if present, falls back to area + locality.
  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    final parts = <String>[];
    if (bedrooms != null && transactionType == 'BUY')
      parts.add('$bedrooms BHK');
    if (area != null) parts.add('${area!.toStringAsFixed(0)} sq.ft');
    return parts.isEmpty ? 'Property' : parts.join(' • ');
  }

  /// Formatted price with currency, or "Price on request".
  String get displayPrice {
    if (priceOnRequest) return 'Price on request';
    if (price == null) return '—';
    return '₹${formatIndianPrice(price!)}';
  }
}

/// Real Estate lead (an enquiry) model.
class LeadModel {
  final String id;
  final String? leadCode;
  final String? property;
  final String? propertySnapshot;
  final String status; // NEW, CONTACTED, VISIT_REQUESTED, ..., LOST, SALE
  final String source;
  final String? referrer;
  final String? message;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeadModel({
    required this.id,
    this.leadCode,
    this.property,
    this.propertySnapshot,
    this.status = 'NEW',
    this.source = 'ENQUIRY',
    this.referrer,
    this.message,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      leadCode: json['leadCode']?.toString(),
      property: json['property']?.toString(),
      propertySnapshot: json['propertySnapshot'] is Map
          ? (json['propertySnapshot'] as Map)['title']?.toString() ??
                (json['propertySnapshot'] as Map)['propertyCode']?.toString()
          : json['propertySnapshot']?.toString(),
      status: json['status']?.toString() ?? 'NEW',
      source: json['source']?.toString() ?? 'ENQUIRY',
      referrer: json['referrer']?.toString(),
      message: json['message']?.toString(),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

/// Real Estate lead activity (status change) entry.
class LeadActivityEntry {
  final String action;
  final DateTime? at;
  const LeadActivityEntry({required this.action, this.at});
  factory LeadActivityEntry.fromJson(Map<String, dynamic> json) {
    return LeadActivityEntry(
      action: json['action']?.toString() ?? '',
      at: json['at'] is String ? DateTime.tryParse(json['at'] as String) : null,
    );
  }
}

/// Real Estate property category. Plain categories from the public
/// endpoint. For grouping (RESIDENTIAL → Apartment, Villa …) the
/// client uses [CategoryGroup].
class PropertyCategory {
  final String key;
  final String name;
  final String? group;
  final String? icon;
  final List<String> amenityOptions;
  final int count;

  const PropertyCategory({
    required this.key,
    required this.name,
    this.group,
    this.icon,
    this.amenityOptions = const [],
    this.count = 0,
  });

  factory PropertyCategory.fromJson(Map<String, dynamic> json) {
    final amenities = json['amenityOptions'];
    return PropertyCategory(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString(),
      icon: json['icon']?.toString(),
      amenityOptions: amenities is List
          ? amenities.map((e) => e.toString()).toList()
          : const [],
      count: json['count'] is num ? (json['count'] as num).toInt() : 0,
    );
  }
}

/// A single category in the grouped response. The grouped endpoint
/// returns the lighter shape (id/key/name/icon/transactionTypes), so
/// this model mirrors that exactly and does not carry [count].
class GroupedCategory {
  final String? id;
  final String key;
  final String name;
  final String? icon;
  final List<String> transactionTypes;

  const GroupedCategory({
    required this.key,
    required this.name,
    this.id,
    this.icon,
    this.transactionTypes = const [],
  });

  factory GroupedCategory.fromJson(Map<String, dynamic> json) {
    final tts = json['transactionTypes'];
    return GroupedCategory(
      id: json['id']?.toString(),
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      transactionTypes: tts is List
          ? tts.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

/// A group of categories returned by /v1/realestate/public/categories/grouped.
/// The wire shape is `{ groups: { RESIDENTIAL: [...], COMMERCIAL: [...] } }`.
class CategoryGroups {
  /// `groupName → categories in that group`. Order of insertion is
  /// preserved — the backend orders groups by `sortOrder`.
  final Map<String, List<GroupedCategory>> byGroup;

  const CategoryGroups({required this.byGroup});

  factory CategoryGroups.fromJson(Map<String, dynamic> json) {
    final groups = json['groups'];
    final byGroup = <String, List<GroupedCategory>>{};
    if (groups is Map) {
      groups.forEach((key, value) {
        if (value is List) {
          byGroup[key.toString()] = value
              .whereType<Map<String, dynamic>>()
              .map(GroupedCategory.fromJson)
              .toList();
        }
      });
    }
    return CategoryGroups(byGroup: byGroup);
  }

  List<String> get groupNames => byGroup.keys.toList(growable: false);
}

/// Formats an Indian rupee price with lakh/crore grouping.
String formatIndianPrice(double v) {
  final n = v;
  if (n >= 10000000)
    return '${(n / 10000000).toStringAsFixed(n % 10000000 == 0 ? 0 : 2)} Cr';
  if (n >= 100000)
    return '${(n / 100000).toStringAsFixed(n % 100000 == 0 ? 0 : 2)} Lakh';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
  return n.toStringAsFixed(0);
}

/// Real Estate property hold (plan §6).
///
/// Customer money held in trust while a property is taken off-market for them.
/// `principal` is a liability, `serviceFee` is platform revenue (BR-13/BR-14).
/// `policySnapshot` is the frozen terms in force at creation (BR-15).
class HoldModel {
  final String id;
  final String? holdCode;
  final String? property;
  final String? propertySnapshot; // title/propertyCode if the backend joins it
  final String? lead;

  // Money, in RUPEES — the backend serves them through the moneyField getter.
  final double principal;
  final double serviceFee;
  final double total;

  final String
  status; // PENDING_PAYMENT | ACTIVE | EXPIRED | CANCELLED | CONVERTED_TO_SALE | REFUND_PENDING | REFUNDED | ADJUSTED
  final DateTime? placedAt;
  final DateTime? expiresAt;
  final DateTime? activatedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  /// The sale this hold converted into, when it did. A converted hold is
  /// a purchase: the principal became consideration (BR-13), and the
  /// purchase screen opens the sale by this id.
  final String? convertedSale;

  // The policy in force when this hold was created. The screen uses the
  // principal/service-fee/duration/refund matrix from this snapshot, not from
  // the live policy — a later admin edit never restates a live hold (BR-15).
  final HoldPolicySnapshot policySnapshot;

  const HoldModel({
    required this.id,
    this.holdCode,
    this.property,
    this.propertySnapshot,
    this.lead,
    this.principal = 0,
    this.serviceFee = 0,
    this.total = 0,
    this.status = 'PENDING_PAYMENT',
    this.placedAt,
    this.expiresAt,
    this.activatedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.convertedSale,
    this.policySnapshot = const HoldPolicySnapshot(),
  });

  factory HoldModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? dateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    String? strOrNull(dynamic v) => v == null
        ? null
        : v is String
        ? v
        : v.toString();

    return HoldModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      holdCode: strOrNull(json['holdCode']),
      property: strOrNull(json['property']),
      propertySnapshot: json['propertySnapshot'] is Map
          ? (json['propertySnapshot'] as Map)['title']?.toString() ??
                (json['propertySnapshot'] as Map)['propertyCode']?.toString()
          : strOrNull(json['propertySnapshot']),
      lead: strOrNull(json['lead']),
      principal: numOrNull(json['principal']) ?? 0,
      serviceFee: numOrNull(json['serviceFee']) ?? 0,
      total: numOrNull(json['total']) ?? 0,
      status: strOrNull(json['status']) ?? 'PENDING_PAYMENT',
      placedAt: dateOrNull(json['placedAt']),
      expiresAt: dateOrNull(json['expiresAt']),
      activatedAt: dateOrNull(json['activatedAt']),
      cancelledAt: dateOrNull(json['cancelledAt']),
      cancellationReason: strOrNull(json['cancellationReason']),
      convertedSale: strOrNull(json['convertedSale']),
      policySnapshot: json['policySnapshot'] is Map
          ? HoldPolicySnapshot.fromJson(
              json['policySnapshot'] as Map<String, dynamic>,
            )
          : HoldPolicySnapshot(),
    );
  }

  /// True for states where the customer is blocked from creating a new
  /// hold on the same property (BR-12) — there can be only one live hold.
  bool get isLive =>
      status == 'PENDING_PAYMENT' ||
      status == 'ACTIVE' ||
      status == 'REFUND_PENDING';

  /// True for terminal states the customer cannot act on.
  bool get isTerminal =>
      status == 'CANCELLED' ||
      status == 'CONVERTED_TO_SALE' ||
      status == 'REFUNDED' ||
      status == 'EXPIRED' ||
      status == 'ADJUSTED';

  /// True when the hold can be cancelled (BR-13 refund matrix).
  bool get canCancel => status == 'PENDING_PAYMENT' || status == 'ACTIVE';

  /// True when the hold is ready to convert to a sale (§6.2 sale row).
  bool get canConvertToSale => status == 'ACTIVE';

  /// Human label for the status enum, for the list/detail chips.
  String get statusLabel {
    switch (status) {
      case 'PENDING_PAYMENT':
        return 'Payment pending';
      case 'ACTIVE':
        return 'Active';
      case 'EXPIRED':
        return 'Expired';
      case 'CANCELLED':
        return 'Cancelled';
      case 'CONVERTED_TO_SALE':
        return 'Converted to sale';
      case 'REFUND_PENDING':
        return 'Refund pending';
      case 'REFUNDED':
        return 'Refunded';
      case 'ADJUSTED':
        return 'Adjusted';
      default:
        return status;
    }
  }
}

/// Frozen hold-policy terms at the moment a hold was created (BR-15).
/// The customer sees these on the terms screen and the detail screen.
class HoldPolicySnapshot {
  final double principalAmount;
  final double? serviceFeePercent;
  final double? serviceFeeMin;
  final double? serviceFeeMax;
  final int? durationDays;
  final int? gracePeriodHours;
  final bool cancellationRefundable;
  final bool expiryRefundable;
  final bool feeRefundableOnListingWithdrawal;
  final bool forfeitureRequiresDualControl;

  const HoldPolicySnapshot({
    this.principalAmount = 50000,
    this.serviceFeePercent,
    this.serviceFeeMin,
    this.serviceFeeMax,
    this.durationDays = 15,
    this.gracePeriodHours = 72,
    this.cancellationRefundable = true,
    this.expiryRefundable = true,
    this.feeRefundableOnListingWithdrawal = true,
    this.forfeitureRequiresDualControl = true,
  });

  factory HoldPolicySnapshot.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? intOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return HoldPolicySnapshot(
      principalAmount: numOrNull(json['principalAmount']) ?? 50000,
      serviceFeePercent: numOrNull(json['serviceFeePercent']),
      serviceFeeMin: numOrNull(json['serviceFeeMin']),
      serviceFeeMax: numOrNull(json['serviceFeeMax']),
      durationDays: intOrNull(json['durationDays']) ?? 15,
      gracePeriodHours: intOrNull(json['gracePeriodHours']) ?? 72,
      cancellationRefundable: json['cancellationRefundable'] != false,
      expiryRefundable: json['expiryRefundable'] != false,
      feeRefundableOnListingWithdrawal:
          json['feeRefundableOnListingWithdrawal'] != false,
      forfeitureRequiresDualControl:
          json['forfeitureRequiresDualControl'] != false,
    );
  }
}

/// A customer's site-visit request — the customer's view of a visit.
///
/// One row spans the whole lifecycle: it exists from creation
/// (`PENDING_ASSIGNMENT`) while the assignment engine is still picking
/// an executive, and carries the joined visit (status, scheduled time,
/// executive name/mobile) once one exists. The list screen splits
/// upcoming vs past off [isPast]; the detail screen renders everything.
class VisitRequestModel {
  final String id;

  // Lead — id when unpopulated, plus the populated join.
  final String? leadId;
  final String? leadCode;
  final String? leadStatus;

  // Property join (populated by the backend).
  final String? propertyId;
  final String? propertyTitle;
  final String? propertyLocality;
  final String? propertyCity;
  final double? propertyPrice;
  final String? propertyPricePeriod;
  final String? propertyTransactionType;
  final String? propertyAvailability;

  final String status; // PENDING_ASSIGNMENT | ASSIGNED | ... | CANCELLED
  final DateTime? preferredDate;
  final String? preferredTimeSlot; // MORNING | AFTERNOON | EVENING
  final String? cancellationReason;
  final DateTime? createdAt;

  // The joined visit — null until the assignment engine creates one.
  final String? visitId;
  final String? visitStatus;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String? visitCancellationReason;

  // Executive on the visit join — name/mobile for the detail screen.
  final String? executiveName;
  final String? executiveMobile;

  const VisitRequestModel({
    required this.id,
    this.leadId,
    this.leadCode,
    this.leadStatus,
    this.propertyId,
    this.propertyTitle,
    this.propertyLocality,
    this.propertyCity,
    this.propertyPrice,
    this.propertyPricePeriod,
    this.propertyTransactionType,
    this.propertyAvailability,
    this.status = 'PENDING_ASSIGNMENT',
    this.preferredDate,
    this.preferredTimeSlot,
    this.cancellationReason,
    this.createdAt,
    this.visitId,
    this.visitStatus,
    this.scheduledAt,
    this.completedAt,
    this.visitCancellationReason,
    this.executiveName,
    this.executiveMobile,
  });

  factory VisitRequestModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? dateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    String? strOrNull(dynamic v) => v == null
        ? null
        : v is String
        ? v
        : v.toString();

    // `property` / `lead` are populated objects on read and raw ids on
    // write-echoes — accept both shapes.
    final property = json['property'] is Map
        ? json['property'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final lead = json['lead'] is Map
        ? json['lead'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final visit = json['visit'] is Map
        ? json['visit'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final executive = visit['executive'] is Map
        ? visit['executive'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return VisitRequestModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      leadId: json['lead'] is Map
          ? strOrNull(lead['_id'])
          : strOrNull(json['lead']),
      leadCode: strOrNull(lead['leadCode']),
      leadStatus: strOrNull(lead['status']),
      propertyId: json['property'] is Map
          ? strOrNull(property['_id'])
          : strOrNull(json['property']),
      propertyTitle: strOrNull(property['title']),
      propertyLocality: strOrNull(property['locality']),
      propertyCity: strOrNull(property['city']),
      propertyPrice: numOrNull(property['price']),
      propertyPricePeriod: strOrNull(property['pricePeriod']),
      propertyTransactionType: strOrNull(property['transactionType']),
      propertyAvailability: strOrNull(property['availability']),
      status: strOrNull(json['status']) ?? 'PENDING_ASSIGNMENT',
      preferredDate: dateOrNull(json['preferredDate']),
      preferredTimeSlot: strOrNull(json['preferredTimeSlot']),
      cancellationReason: strOrNull(json['cancellationReason']),
      createdAt: dateOrNull(json['createdAt']),
      visitId: visit.isEmpty ? null : strOrNull(visit['_id']),
      visitStatus: strOrNull(visit['status']),
      scheduledAt: dateOrNull(visit['scheduledAt']),
      completedAt: dateOrNull(visit['completedAt']),
      visitCancellationReason: strOrNull(visit['cancellationReason']),
      executiveName: strOrNull(executive['name']),
      executiveMobile: strOrNull(executive['mobile']),
    );
  }

  /// The date the customer actually gets shown — the visit's schedule
  /// once one exists, the customer's preference before that.
  DateTime? get effectiveDate => scheduledAt ?? preferredDate;

  /// True while no executive has been assigned yet.
  bool get isPendingAssignment =>
      status == 'PENDING_ASSIGNMENT' && visitId == null;

  /// Terminal states the customer cannot act on.
  bool get isTerminal => status == 'CANCELLED' || visitStatus == 'COMPLETED';

  /// Past = completed or cancelled on a date before today; everything
  /// else reads as upcoming so the two tabs split cleanly.
  bool get isPast {
    if (visitStatus == 'COMPLETED' || status == 'CANCELLED') return true;
    final d = effectiveDate;
    if (d == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(d.year, d.month, d.day).isBefore(today);
  }

  /// Human label for the request/visit status, for chips.
  String get statusLabel {
    final s = visitStatus ?? status;
    switch (s) {
      case 'PENDING_ASSIGNMENT':
        return 'Awaiting assignment';
      case 'ASSIGNED':
        return 'Assigned';
      case 'ACCEPTED':
        return 'Accepted';
      case 'CHECK_IN':
        return 'Executive checked in';
      case 'IN_PROGRESS':
        return 'In progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return s;
    }
  }

  /// Human label for the time slot enum.
  String get slotLabel {
    switch (preferredTimeSlot) {
      case 'MORNING':
        return 'Morning';
      case 'AFTERNOON':
        return 'Afternoon';
      case 'EVENING':
        return 'Evening';
      default:
        return preferredTimeSlot ?? '';
    }
  }
}

// ---------------------------------------------------------------- Loans
// Flow 12 — a request fans out to one application per active bank, and
// each application may carry offers. All money arrives in RUPEES: the
// backend moneyField getters run on the wire.

/// One bank's offer against a loan application.
class BankOfferModel {
  final String id;
  final String? bankId;
  final String? bankName;
  final double? loanAmount;
  final int? tenureMonths;
  final double? interestRate; // percent per annum
  final double? processingFee;
  final String? otherTerms;
  final String status; // PENDING | ACCEPTED | REJECTED | WITHDRAWN
  final DateTime? createdAt;

  const BankOfferModel({
    required this.id,
    this.bankId,
    this.bankName,
    this.loanAmount,
    this.tenureMonths,
    this.interestRate,
    this.processingFee,
    this.otherTerms,
    this.status = 'PENDING',
    this.createdAt,
  });

  factory BankOfferModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    // bank is populated ({_id, name, code}) on read, a raw id otherwise.
    final bank = json['bank'] is Map
        ? json['bank'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return BankOfferModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      bankId: json['bank'] is Map
          ? bank['_id']?.toString()
          : json['bank']?.toString(),
      bankName: bank['name']?.toString(),
      loanAmount: numOrNull(json['loanAmount']),
      tenureMonths: (json['tenureMonths'] as num?)?.toInt(),
      interestRate: numOrNull(json['interestRate']),
      processingFee: numOrNull(json['processingFee']),
      otherTerms: json['otherTerms']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Sort keys for the compare screen. Nulls go last so an unpriced
  /// offer never wins a sort.
  double get rateSort => interestRate ?? double.infinity;
  double get amountSort => -(loanAmount ?? 0); // bigger amount first
  double get tenureSort => (tenureMonths ?? 999999).toDouble();

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isWithdrawn => status == 'WITHDRAWN';
}

/// One bank's application row under a loan request.
class LoanApplicationModel {
  final String id;
  final String? bankId;
  final String? bankName;
  final double? requestedAmount;
  final double? sanctionedAmount;
  final double? disbursedAmount;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? sanctionedAt;
  final DateTime? disbursedAt;
  final List<BankOfferModel> offers;

  const LoanApplicationModel({
    required this.id,
    this.bankId,
    this.bankName,
    this.requestedAmount,
    this.sanctionedAmount,
    this.disbursedAmount,
    this.status = 'LOAN_LEAD_CREATED',
    this.rejectionReason,
    this.createdAt,
    this.sanctionedAt,
    this.disbursedAt,
    this.offers = const [],
  });

  factory LoanApplicationModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final bank = json['bank'] is Map
        ? json['bank'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final offers = json['offers'] is List
        ? (json['offers'] as List)
              .whereType<Map>()
              .map((e) => BankOfferModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <BankOfferModel>[];

    return LoanApplicationModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      bankId: json['bank'] is Map
          ? bank['_id']?.toString()
          : json['bank']?.toString(),
      bankName: bank['name']?.toString(),
      requestedAmount: numOrNull(json['requestedAmount']),
      sanctionedAmount: numOrNull(json['sanctionedAmount']),
      disbursedAmount: numOrNull(json['disbursedAmount']),
      status: json['status']?.toString() ?? 'LOAN_LEAD_CREATED',
      rejectionReason: json['rejectionReason']?.toString(),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      sanctionedAt: json['sanctionedAt'] is String
          ? DateTime.tryParse(json['sanctionedAt'] as String)
          : null,
      disbursedAt: json['disbursedAt'] is String
          ? DateTime.tryParse(json['disbursedAt'] as String)
          : null,
      offers: offers,
    );
  }

  bool get isTerminal => status == 'REJECTED' || status == 'DISBURSED';

  String get statusLabel {
    switch (status) {
      case 'LOAN_LEAD_CREATED':
        return 'Sent to banks';
      case 'OFFERS_PENDING':
        return 'Offers incoming';
      case 'OFFERS_RECEIVED':
        return 'Offers received';
      case 'CUSTOMER_SELECTING':
        return 'Selecting';
      case 'BANK_SELECTED':
        return 'Bank selected';
      case 'APPLICATION_STARTED':
        return 'Application started';
      case 'DOCUMENTS_PENDING':
        return 'Documents pending';
      case 'UNDER_BANK_REVIEW':
        return 'Under review';
      case 'SANCTIONED':
        return 'Sanctioned';
      case 'DISBURSED':
        return 'Disbursed';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return status;
    }
  }
}

/// A customer's loan request, with applications + offers nested by the
/// backend so list, detail and compare are one call each.
class LoanRequestModel {
  final String id;
  final String? leadId;

  // Property join (populated by the backend).
  final String? propertyId;
  final String? propertyTitle;
  final String? propertyLocality;
  final String? propertyCity;
  final double? propertyPrice;
  final String? propertyPricePeriod;

  final double? requestedAmount;
  final int? tenureMonths;
  final String? employment; // SALARIED | SELF_EMPLOYED | BUSINESS | OTHER
  final double? monthlyIncome;
  final String status;
  final DateTime? createdAt;
  final List<LoanApplicationModel> applications;

  const LoanRequestModel({
    required this.id,
    this.leadId,
    this.propertyId,
    this.propertyTitle,
    this.propertyLocality,
    this.propertyCity,
    this.propertyPrice,
    this.propertyPricePeriod,
    this.requestedAmount,
    this.tenureMonths,
    this.employment,
    this.monthlyIncome,
    this.status = 'REQUIRED',
    this.createdAt,
    this.applications = const [],
  });

  factory LoanRequestModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final property = json['property'] is Map
        ? json['property'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final applications = json['applications'] is List
        ? (json['applications'] as List)
              .whereType<Map>()
              .map(
                (e) =>
                    LoanApplicationModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(growable: false)
        : const <LoanApplicationModel>[];

    return LoanRequestModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      leadId: json['lead'] is Map
          ? (json['lead'] as Map)['_id']?.toString()
          : json['lead']?.toString(),
      propertyId: json['property'] is Map
          ? property['_id']?.toString()
          : json['property']?.toString(),
      propertyTitle: property['title']?.toString(),
      propertyLocality: property['locality']?.toString(),
      propertyCity: property['city']?.toString(),
      propertyPrice: numOrNull(property['price']),
      propertyPricePeriod: property['pricePeriod']?.toString(),
      requestedAmount: numOrNull(json['requestedAmount']),
      tenureMonths: (json['tenureMonths'] as num?)?.toInt(),
      employment: json['employment']?.toString(),
      monthlyIncome: numOrNull(json['monthlyIncome']),
      status: json['status']?.toString() ?? 'REQUIRED',
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      applications: applications,
    );
  }

  /// Every offer across every application — the compare screen's input.
  List<BankOfferModel> get allOffers => [
    for (final app in applications) ...app.offers,
  ];

  int get offerCount => allOffers.length;

  bool get hasOffers => offerCount > 0;

  /// The offer the customer already selected, if any. Only one offer can
  /// be ACCEPTED across the whole request (backend enforces it).
  BankOfferModel? get acceptedOffer {
    for (final offer in allOffers) {
      if (offer.isAccepted) return offer;
    }
    return null;
  }

  bool get hasAcceptedOffer => acceptedOffer != null;

  /// True while the customer still has a choice to make. Once an offer is
  /// accepted the server closes the rest, so the buttons must disappear
  /// even if a stale list still shows PENDING rows.
  bool get canSelectOffer =>
      !isTerminal &&
      !hasAcceptedOffer &&
      const {
        'REQUIRED',
        'CUSTOMER_WILL_APPLY',
        'LOAN_LEAD_CREATED',
        'OFFERS_PENDING',
        'OFFERS_RECEIVED',
        'CUSTOMER_SELECTING',
      }.contains(status) &&
      allOffers.any((offer) => offer.isPending);

  bool isOfferSelectable(BankOfferModel offer) =>
      canSelectOffer && offer.isPending;

  bool get isTerminal =>
      status == 'WITHDRAWN' || status == 'REJECTED' || status == 'DISBURSED';

  String get employmentLabel {
    switch (employment) {
      case 'SALARIED':
        return 'Salaried';
      case 'SELF_EMPLOYED':
        return 'Self employed';
      case 'BUSINESS':
        return 'Business';
      case 'OTHER':
        return 'Other';
      default:
        return employment ?? '';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'REQUIRED':
        return 'Requested';
      case 'CUSTOMER_WILL_APPLY':
        return 'Applying yourself';
      case 'LOAN_LEAD_CREATED':
        return 'Sent to banks';
      case 'OFFERS_PENDING':
        return 'Offers incoming';
      case 'OFFERS_RECEIVED':
        return 'Offers received';
      case 'CUSTOMER_SELECTING':
        return 'Selecting';
      case 'BANK_SELECTED':
        return 'Bank selected';
      case 'APPLICATION_STARTED':
        return 'Application started';
      case 'DOCUMENTS_PENDING':
        return 'Documents pending';
      case 'UNDER_BANK_REVIEW':
        return 'Under review';
      case 'SANCTIONED':
        return 'Sanctioned';
      case 'DISBURSED':
        return 'Disbursed';
      case 'REJECTED':
        return 'Rejected';
      case 'WITHDRAWN':
        return 'Withdrawn';
      default:
        return status;
    }
  }
}

/// A recorded purchase (sale) the customer made on a property.
///
/// Created by the hold conversion (`POST /holds/:id/convert_to_sale`) or
/// by an operator - never by the customer, so this model is read-only in
/// the app.
///
/// Money is in RUPEES: the backend serves `saleValue` and
/// `holdPrincipalApplied` through the moneyField getter, so the client
/// never sees paise.
class PurchaseModel {
  final String id;
  final String? saleCode;

  /// Property id, whether or not the backend joined the property.
  final String? propertyId;
  final String? propertyTitle;
  final String? propertyCode;
  final String? propertyAddress;

  /// Hold this purchase converted, when it came from a hold.
  final String? holdId;
  final String? holdCode;

  final double saleValue;
  final double holdPrincipalApplied;

  /// BUY | RENT
  final String transactionType;

  /// COMPLETED | CANCELLED
  final String status;
  final DateTime? soldAt;

  const PurchaseModel({
    required this.id,
    this.saleCode,
    this.propertyId,
    this.propertyTitle,
    this.propertyCode,
    this.propertyAddress,
    this.holdId,
    this.holdCode,
    this.saleValue = 0,
    this.holdPrincipalApplied = 0,
    this.transactionType = 'BUY',
    this.status = 'COMPLETED',
    this.soldAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    double? numOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    String? strOrNull(dynamic v) =>
        v == null ? null : v is String ? v : v.toString();

    DateTime? dateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    // `property` is populated by the backend (title / propertyCode /
    // addressLine) but stays an id when the join is skipped.
    final property = json['property'];
    final propertyMap = property is Map
        ? Map<String, dynamic>.from(property)
        : const <String, dynamic>{};
    final hold = json['hold'];
    final holdMap = hold is Map ? Map<String, dynamic>.from(hold) : null;

    return PurchaseModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      saleCode: strOrNull(json['saleCode']),
      propertyId: propertyMap['_id']?.toString() ?? strOrNull(property),
      propertyTitle: strOrNull(propertyMap['title']),
      propertyCode: strOrNull(propertyMap['propertyCode']),
      propertyAddress: strOrNull(propertyMap['addressLine']),
      holdId: holdMap?['_id']?.toString() ?? strOrNull(json['hold']),
      holdCode: strOrNull(holdMap?['holdCode']),
      saleValue: numOrNull(json['saleValue']) ?? 0,
      holdPrincipalApplied: numOrNull(json['holdPrincipalApplied']) ?? 0,
      transactionType: strOrNull(json['transactionType']) ?? 'BUY',
      status: strOrNull(json['status']) ?? 'COMPLETED',
      soldAt: dateOrNull(json['soldAt']),
    );
  }

  /// True when the sale was cancelled - the customer sees the row, not a
  /// completed purchase.
  bool get isCancelled => status == 'CANCELLED';

  /// What the customer still has to pay: the consideration minus the hold
  /// principal that was applied against it (BR-13 - the principal is
  /// consideration, never revenue).
  double get balancePayable {
    final due = saleValue - holdPrincipalApplied;
    return due > 0 ? due : 0;
  }
}

/// Property verification metadata (BR-18).
///
/// The endpoint returns document TYPES only - never an id, never a file
/// url, never a filename. A customer is entitled to know that an
/// ownership document cleared; they are not entitled to the document.
class PropertyVerificationModel {
  final bool verified;
  final DateTime? verifiedAt;

  /// Document categories that cleared and are customer-visible, e.g.
  /// `OWNERSHIP`, `APPROVAL`.
  final List<String> documentsCleared;

  const PropertyVerificationModel({
    this.verified = false,
    this.verifiedAt,
    this.documentsCleared = const [],
  });

  factory PropertyVerificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? dateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    final docs = json['documentsCleared'];
    return PropertyVerificationModel(
      verified: json['verified'] == true,
      verifiedAt: dateOrNull(json['verifiedAt']),
      documentsCleared: docs is List
          ? docs.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }

  /// True when there is something to show - an empty list means the
  /// section stays hidden rather than rendering an empty card.
  bool get hasDocuments => documentsCleared.isNotEmpty;
}

/// A document a bank has asked the customer for (Flow 12 underwriting).
///
/// The request is created by the bank, answered by the customer with an
/// uploaded file, and reviewed by the bank. The customer's own paperwork
/// lives on this row - it is deliberately not a property document, which
/// is visible to the property's other parties.
class DocumentRequestModel {
  final String id;

  /// AADHAAR | PAN | SALARY_SLIP | ... | OTHER
  final String category;

  /// What the bank asked for, in the bank's words.
  final String title;
  final String? notes;

  /// REQUESTED | SUBMITTED | ACCEPTED | REJECTED | CANCELLED
  final String status;

  /// The bank member who asked.
  final String? requestedBy;

  /// The optional deadline the bank set.
  final DateTime? dueDate;

  /// When the customer answered.
  final DateTime? uploadedAt;

  /// Why the bank rejected the answer - the customer sees this.
  final String? reviewNote;

  /// The property the loan is against, for context.
  final String? propertyTitle;

  const DocumentRequestModel({
    required this.id,
    this.category = 'OTHER',
    this.title = '',
    this.notes,
    this.status = 'REQUESTED',
    this.requestedBy,
    this.dueDate,
    this.uploadedAt,
    this.reviewNote,
    this.propertyTitle,
  });

  factory DocumentRequestModel.fromJson(Map<String, dynamic> json) {
    DateTime? dateOrNull(dynamic v) =>
        v is String ? DateTime.tryParse(v) : null;

    String? strOrNull(dynamic v) =>
        v == null ? null : v is String ? v : v.toString();

    final property = json['property'];
    final propertyMap = property is Map
        ? Map<String, dynamic>.from(property)
        : const <String, dynamic>{};

    return DocumentRequestModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      category: strOrNull(json['category']) ?? 'OTHER',
      title: strOrNull(json['title']) ?? '',
      notes: strOrNull(json['notes']),
      status: strOrNull(json['status']) ?? 'REQUESTED',
      requestedBy: strOrNull(json['requestedBy']),
      dueDate: dateOrNull(json['dueDate']),
      uploadedAt: dateOrNull(json['uploadedAt']),
      reviewNote: strOrNull(json['reviewNote']),
      propertyTitle: strOrNull(propertyMap['title']),
    );
  }

  /// True when the customer still has to answer this request.
  bool get needsAnswer => status == 'REQUESTED' || status == 'REJECTED';

  /// True when the answer is with the bank, awaiting review.
  bool get isSubmitted => status == 'SUBMITTED';

  /// True when the bank accepted the answer.
  bool get isAccepted => status == 'ACCEPTED';
}
