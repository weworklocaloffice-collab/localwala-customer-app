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

import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/services/shared_pref.dart';

/// Real Estate customer repository — public browse + own-lead endpoints.
///
/// Public browse methods (search, detail, categories) need no auth; the
/// customer-leads methods rely on the same authorised session as the rest
/// of the app (token auto-attached by the Dio interceptor). All calls
/// return raw data; the calling bloc owns loading/error state.
class RealEstateRepository {
  final ApiRequestService _api = ApiRequestService();
  final SharedPreferencesManager _prefs = SharedPreferencesManager();

  // ---------------- Public (guest) browse ----------------

  Future<List<PropertyCategory>> listCategories() async {
    final res = await _api.get(ApiEndPoints.v1request.reCategories);
    final body = jsonDecode(res.body);
    final list = body is List
        ? body
        : body is Map && body['results'] is List
        ? body['results'] as List
        : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(PropertyCategory.fromJson)
        .toList();
  }

  /// Subcategory grouping. Backend returns
  /// `{ groups: { RESIDENTIAL: [...], COMMERCIAL: [...] } }` keyed by the
  /// [PropertyCategory.group] the categories share. Used by the home
  /// section to render "Browse by category" with secondary chips.
  Future<CategoryGroups> listGroupedCategories() async {
    final res = await _api.get(ApiEndPoints.v1request.reCategoriesGrouped);
    return CategoryGroups.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<List<PropertyModel>> listFeatured() async {
    final res = await _api.get(ApiEndPoints.v1request.reFeaturedProperties);
    return _parsePropertyList(res.body);
  }

  /// Total published listings, used by the Real Estate entry card.
  Future<int> countPublished() async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reSearchProperties}?page=1&limit=1',
    );
    final body = jsonDecode(res.body);
    if (body is Map<String, dynamic> && body['totalResults'] is num) {
      return (body['totalResults'] as num).toInt();
    }
    return 0;
  }

  Future<List<PropertyModel>> listRecent({int limit = 20}) async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reRecentProperties}?limit=$limit',
    );
    return _parsePropertyList(res.body);
  }

  Future<List<PropertyModel>> search({
    String? city,
    String? search,
    String? transactionType,
    String? category,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    bool? verifiedOnly,
    String? sortBy,
    double? lng,
    double? lat,
    double radiusMeters = 5000,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{};
    if (city != null && city.isNotEmpty) query['city'] = city;
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (lng != null && lat != null) {
      query['lng'] = lng.toString();
      query['lat'] = lat.toString();
      query['radiusMeters'] = radiusMeters.toStringAsFixed(0);
    }
    if (transactionType != null) query['transactionType'] = transactionType;
    // Backend resolves UPPER_SNAKE keys via `categoryKey`; the bare
    // `category` param must be a mongo id (unknown keys are rejected,
    // so the old `category=<KEY>` name 400d every chip tap).
    if (category != null) query['categoryKey'] = category;
    // Backend price bounds are `priceMin`/`priceMax` in rupees; the old
    // `minPrice`/`maxPrice` names were silently rejected.
    if (minPrice != null) query['priceMin'] = minPrice.toString();
    if (maxPrice != null) query['priceMax'] = maxPrice.toString();
    // Documented spec-filter wire format (`?spec_bedrooms=3`).
    if (bedrooms != null) query['spec_bedrooms'] = bedrooms.toString();
    if (verifiedOnly == true) query['verified'] = 'true';
    if (sortBy != null) query['sortBy'] = sortBy;
    query['page'] = page.toString();
    query['limit'] = limit.toString();
    final qs = query.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    final res = await _api.get(
      '${ApiEndPoints.v1request.reSearchProperties}?$qs',
    );
    return _parsePropertyList(res.body);
  }

  /// Most viewed properties — what the platform's catalogue says is
  /// the most-browsed in the chosen scope. Used by the home
  /// "Popular properties" rail.
  Future<List<PropertyModel>> listMostViewed({int limit = 10}) =>
      search(sortBy: 'views:desc', limit: limit);

  /// Most enquired properties — highest lead volume. Used by the home
  /// "Most enquired" rail.
  Future<List<PropertyModel>> listMostEnquired({int limit = 10}) =>
      search(sortBy: 'enquiries:desc', limit: limit);

  /// Recently published — newest first. Used by the home
  /// "Recently added" rail.
  Future<List<PropertyModel>> listRecentlyPublished({int limit = 10}) =>
      search(sortBy: 'publishedAt:desc', limit: limit);

  /// Premium sale listings — highest price first. Used by the home
  /// "Premium listings" rail.
  Future<List<PropertyModel>> listPremium({int limit = 10}) => search(
    transactionType: 'BUY',
    minPrice: 0,
    sortBy: 'price:desc',
    limit: limit,
  );

  /// Affordable sale listings — lowest price first. Used by the home
  /// "Affordable properties" rail.
  Future<List<PropertyModel>> listAffordable({int limit = 10}) => search(
    transactionType: 'BUY',
    minPrice: 0,
    sortBy: 'price:asc',
    limit: limit,
  );

  Future<PropertyModel> propertyById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.rePropertyById(id));
    return PropertyModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<PropertyModel>> similarProperties(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reSimilarProperties(id));
    return _parsePropertyList(res.body);
  }

  /// Properties within `radiusMeters` of (lng, lat), ordered by distance
  /// ascending. Backend's `nearby()` enforces a 50 km ceiling (BR §10.2,
  /// verified by `verify.realestate.search.js`) — we forward it as-is
  /// and the server caps.
  Future<List<PropertyModel>> nearbyProperties({
    required double lng,
    required double lat,
    int radiusMeters = 5000,
    String? category,
    String? transactionType,
    double? priceMin,
    double? priceMax,
    int limit = 20,
  }) async {
    final q = <String, String>{
      'lng': lng.toString(),
      'lat': lat.toString(),
      'radiusMeters': radiusMeters.toString(),
      'limit': limit.toString(),
    };
    if (category != null && category.isNotEmpty) q['categoryKey'] = category;
    if (transactionType != null) q['transactionType'] = transactionType;
    if (priceMin != null) q['priceMin'] = priceMin.toString();
    if (priceMax != null) q['priceMax'] = priceMax.toString();
    final qs = q.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _api.get(
      '${ApiEndPoints.v1request.reNearbyProperties}?$qs',
    );
    return _parsePropertyList(res.body);
  }

  // ---------------- Customer (auth) ----------------

  Future<LeadModel> createEnquiry({
    required String propertyId,
    required String message,
    String? referralCode,
  }) async {
    final res = await _api.post(
      '${ApiEndPoints.v1request.reCreateEnquiry}/$propertyId/enquiry',
      body: {
        'message': message,
        if (referralCode != null && referralCode.isNotEmpty)
          'referralCode': referralCode,
      },
    );
    return _parseLead(res.body);
  }

  Future<List<LeadModel>> myLeads({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) query['status'] = status;
    final qs = query.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _api.get('${ApiEndPoints.v1request.reMyLeads}?$qs');
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : const [];
    return list
        .map((e) => LeadModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeadModel> leadById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reMyLeadById(id));
    return _parseLead(res.body);
  }

  Future<List<LeadActivityEntry>> leadActivity(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reLeadActivity(id));
    final body = jsonDecode(res.body);
    final list = body is Map && body['data'] is List
        ? body['data'] as List
        : const [];
    return list
        .map((e) => LeadActivityEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LeadModel> withdrawLead(String id, {required String reason}) async {
    final res = await _api.patch(
      ApiEndPoints.v1request.reWithdrawLead(id),
      body: {'reason': reason},
    );
    return _parseLead(res.body);
  }

  // ---------------- Saved properties (auth) ----------------

  /// Toggles the saved state for a property. Returns `true` if the
  /// property is now saved, `false` if it was just removed. Backend
  /// returns `alreadySaved` to disambiguate, so the UI can show the
  /// right toast.
  Future<bool> toggleSavedProperty(String propertyId) async {
    final isSaved = await isPropertySaved(propertyId);
    if (isSaved) {
      await removeSavedProperty(propertyId);
      return false;
    }
    await saveProperty(propertyId);
    return true;
  }

  Future<bool> isPropertySaved(String propertyId) async {
    final res = await _api.get(
      ApiEndPoints.v1request.reSavedPropertyStatus(propertyId),
    );
    final body = jsonDecode(res.body);
    return body is Map && body['saved'] == true;
  }

  Future<void> saveProperty(String propertyId) async {
    await _api.post(
      ApiEndPoints.v1request.reSavedProperty(propertyId),
      body: const {},
    );
  }

  Future<void> removeSavedProperty(String propertyId) async {
    await _api.delete(ApiEndPoints.v1request.reSavedProperty(propertyId));
  }

  /// Paginated list of the customer's saved properties, newest first.
  /// Each entry is a full [PropertyModel] joined from the catalogue.
  Future<List<PropertyModel>> savedProperties({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reSavedProperties}?page=$page&limit=$limit',
    );
    final body = jsonDecode(res.body);
    final list = body is Map && body['items'] is List
        ? body['items'] as List
        : const [];
    return list
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  // ---------------- Holds (BR-13) ----------------

  /// Create a hold in `PENDING_PAYMENT`. The actual charge is taken by the
  /// shared `property_hold` payment branch — this endpoint only reserves
  /// the property on the partial unique index (BR-12) and snapshots the
  /// active policy (BR-15).
  Future<HoldModel> createHold({
    required String propertyId,
    String? leadId,
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reCreateHold,
      body: {
        'property': propertyId,
        if (leadId != null && leadId.isNotEmpty) 'lead': leadId,
      },
    );
    return _parseHold(res.body);
  }

  /// Customer's own holds, newest first. Limited to 50 by the backend.
  Future<List<HoldModel>> myHolds() async {
    final res = await _api.get(ApiEndPoints.v1request.reMyHolds);
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : body is List
        ? body
        : const [];
    return list
        .map((e) => HoldModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<HoldModel> holdById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reMyHoldById(id));
    return _parseHold(res.body);
  }

  /// Cancel a `PENDING_PAYMENT` or `ACTIVE` hold. Per §6.2 the principal
  /// is refunded 100% and the service fee is retained. The payout is
  /// completed by the `property_hold_refund` payment branch.
  Future<HoldModel> cancelHold(String id) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reCancelHold(id),
      body: const {},
    );
    return _parseHold(res.body);
  }

  /// Initiate gateway payment for a `PENDING_PAYMENT` hold. Returns the
  /// initiation id as `payLink` for the shared MakePayment screen
  /// (`makePaymentRoute`). On gateway confirm the hold becomes ACTIVE.
  /// Throws with the server message verbatim — including the OD-01
  /// custody-blocked message while live collection is disabled.
  Future<String> payHold(String id) async {
    final res = await _api.post(
      ApiEndPoints.v1request.rePayHold(id),
      body: const {},
    );
    final body = jsonDecode(res.body);
    final link = body is Map ? body['payLink']?.toString() ?? '' : '';
    if (link.isEmpty)
      throw Exception('Could not start payment. Please try again.');
    return link;
  }

  /// Convert an `ACTIVE` hold to a sale. `saleValue` is the agreed
  /// consideration; the principal is applied against it (BR-13, never
  /// revenue). `transactionType` is `BUY` or `RENT`.
  Future<Map<String, dynamic>> convertHoldToSale(
    String id, {
    required double saleValue,
    String transactionType = 'BUY',
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reConvertHoldToSale(id),
      body: {'saleValue': saleValue, 'transactionType': transactionType},
    );
    final body = jsonDecode(res.body);
    return body is Map<String, dynamic>
        ? body
        : <String, dynamic>{'data': body};
  }

  // ---------------- Site visits (Flow 11) ----------------

  /// Ask to visit a property behind one of the customer's own leads.
  ///
  /// `preferredDate` is sent as `yyyy-MM-dd`; the backend rejects past
  /// dates, duplicate open requests and SOLD/RENTED properties with a
  /// 4xx the calling screen surfaces verbatim.
  Future<VisitRequestModel> requestVisit({
    required String leadId,
    required DateTime preferredDate,
    required String preferredTimeSlot,
    String note = '',
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reRequestVisit,
      body: {
        'lead': leadId,
        'preferredDate':
            '${preferredDate.year.toString().padLeft(4, '0')}-'
            '${preferredDate.month.toString().padLeft(2, '0')}-'
            '${preferredDate.day.toString().padLeft(2, '0')}',
        'preferredTimeSlot': preferredTimeSlot,
        if (note.isNotEmpty) 'note': note,
      },
    );
    return _parseVisitRequest(res.body);
  }

  /// The customer's visit requests, newest preferred date first. One
  /// list serves upcoming and past: a request exists from creation
  /// (PENDING_ASSIGNMENT) through every visit state.
  Future<List<VisitRequestModel>> myVisits({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reMyVisits}?page=$page&limit=$limit',
    );
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : body is List
        ? body
        : const [];
    return list
        .map((e) => VisitRequestModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<VisitRequestModel> visitById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reMyVisitById(id));
    return _parseVisitRequest(res.body);
  }

  // ---------------- Loans (Flow 12) ----------------

  /// Request a loan against a property. The backend fans the request
  /// out to every active bank; a 409 means an open request already
  /// exists for this property, and a 403 means the admin turned the
  /// capability off — both surface verbatim.
  Future<LoanRequestModel> requestLoan({
    required String propertyId,
    String? leadId,
    required int requestedAmount,
    int? tenureMonths,
    required String employment,
    required int monthlyIncome,
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reRequestLoan,
      body: {
        'property': propertyId,
        if (leadId != null && leadId.isNotEmpty) 'lead': leadId,
        'requestedAmount': requestedAmount,
        if (tenureMonths != null) 'tenureMonths': tenureMonths,
        'employment': employment,
        'monthlyIncome': monthlyIncome,
      },
    );
    return _parseLoanRequest(res.body);
  }

  /// The customer's loan requests with applications + offers nested.
  Future<List<LoanRequestModel>> myLoans({int page = 1, int limit = 50}) async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reMyLoans}?page=$page&limit=$limit',
    );
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : body is List
        ? body
        : const [];
    return list
        .map((e) => LoanRequestModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// One request with its applications + offers — the compare screen
  /// sorts the nested offers itself (rate / amount / tenure).
  Future<LoanRequestModel> loanById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reMyLoanById(id));
    return _parseLoanRequest(res.body);
  }

  /// Accept one bank's offer. The server proves the request belongs to
  /// this customer, closes the other offers/applications, and returns
  /// the refreshed request with the winner at DOCUMENTS_PENDING.
  Future<LoanRequestModel> acceptLoanOffer({
    required String requestId,
    required String offerId,
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reAcceptLoanOffer(requestId, offerId),
      body: const {},
    );
    return _parseLoanRequest(res.body);
  }

  // ---------------- Purchases (sale history) ----------------

  /// The purchases recorded against this customer's account, newest
  /// first. A purchase is a recorded sale - created by the hold
  /// conversion or by an operator - so this list is read-only.
  Future<List<PurchaseModel>> myPurchases({int page = 1, int limit = 50}) async {
    final res = await _api.get(
      '${ApiEndPoints.v1request.reMyPurchases}?page=$page&limit=$limit',
    );
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : body is List
        ? body
        : const [];
    return list
        .map((e) => PurchaseModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// One purchase. A sale belonging to another customer is a 404, so the
  /// id cannot be probed.
  Future<PurchaseModel> purchaseById(String id) async {
    final res = await _api.get(ApiEndPoints.v1request.reMyPurchaseById(id));
    return _parsePurchase(res.body);
  }

  /// Property verification metadata: document TYPES only (BR-18). Never
  /// a file url, never a filename.
  Future<PropertyVerificationModel> propertyVerification(String id) async {
    final res = await _api.get(
      ApiEndPoints.v1request.rePropertyVerification(id),
    );
    final body = jsonDecode(res.body);
    final data = body is Map && body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body is Map
        ? Map<String, dynamic>.from(body)
        : <String, dynamic>{};
    return PropertyVerificationModel.fromJson(data);
  }

  // ---------------- Document requests (Flow 12 underwriting) ----------------

  /// What the banks have asked this customer for, newest first.
  Future<List<DocumentRequestModel>> myDocumentRequests() async {
    final res = await _api.get(ApiEndPoints.v1request.reMyDocumentRequests);
    final body = jsonDecode(res.body);
    final list = body is Map && body['results'] is List
        ? body['results'] as List
        : body is List
        ? body
        : const [];
    return list
        .map((e) => DocumentRequestModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Upload the answer to a document request.
  ///
  /// The file goes through the shared media upload first (the same
  /// endpoint the profile photo and the support chat use). That endpoint
  /// answers with a path relative to the media storage root, so the
  /// configured media base url is prepended here - the API stores an
  /// absolute url, and a bank must be able to open the file.
  Future<String> uploadDocumentFile(XFile file, String uid) async {
    final res = await _api.uploadImageFile(
      ApiEndPoints.v1request.uploadImageFile,
      uid,
      file,
    );
    final body = jsonDecode(res.body);
    final path = body is Map
        ? (body['path'] ?? body['imageUrl'] ?? body['url'])?.toString()
        : null;
    if (path == null || path.isEmpty) {
      throw Exception('Could not upload the document. Please try again.');
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final base = await _prefs.getString(
      SharedPreferencesKey.publicKeys.mediaUrl,
    ) ??
        '';
    if (base.isEmpty) {
      throw Exception('Could not upload the document. Please try again.');
    }
    return '$base$path';
  }

  /// Answer a document request with an already-uploaded file.
  Future<DocumentRequestModel> submitDocumentRequest(
    String id, {
    required String fileUrl,
    String fileName = '',
    String mimeType = '',
    int? sizeBytes,
  }) async {
    final res = await _api.post(
      ApiEndPoints.v1request.reSubmitDocumentRequest(id),
      body: {
        'fileUrl': fileUrl,
        if (fileName.isNotEmpty) 'fileName': fileName,
        if (mimeType.isNotEmpty) 'mimeType': mimeType,
        if (sizeBytes != null) 'sizeBytes': sizeBytes,
      },
    );
    final body = jsonDecode(res.body);
    final data = body is Map && body['data'] is Map
        ? Map<String, dynamic>.from(body['data'] as Map)
        : body as Map<String, dynamic>;
    return DocumentRequestModel.fromJson(data);
  }

  // ---------------- internals ----------------

  LeadModel _parseLead(String raw) {
    final body = jsonDecode(raw);
    final data = body is Map && body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return LeadModel.fromJson(data);
  }

  HoldModel _parseHold(String raw) {
    final body = jsonDecode(raw);
    final data = body is Map && body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return HoldModel.fromJson(data);
  }

  VisitRequestModel _parseVisitRequest(String raw) {
    final body = jsonDecode(raw);
    final data = body is Map && body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return VisitRequestModel.fromJson(data);
  }

  LoanRequestModel _parseLoanRequest(String raw) {
    final body = jsonDecode(raw);
    final data = body is Map && body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return LoanRequestModel.fromJson(data);
  }

  PurchaseModel _parsePurchase(String raw) {
    final body = jsonDecode(raw);
    final data = body is Map && body['data'] is Map
        ? body['data'] as Map<String, dynamic>
        : body as Map<String, dynamic>;
    return PurchaseModel.fromJson(data);
  }

  List<PropertyModel> _parsePropertyList(String raw) {
    final body = jsonDecode(raw);
    final list = body is List
        ? body
        : body is Map && body['results'] is List
        ? body['results'] as List
        : body is Map && body['data'] is List
        ? body['data'] as List
        : const [];
    return list
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }
}
