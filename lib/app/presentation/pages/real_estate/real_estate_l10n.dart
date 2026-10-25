import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/gen/l10n/app_localizations.dart';

extension RealEstateStatusLabels on AppLocalizations {
  String holdStatus(String status) => switch (status) {
    'PENDING_PAYMENT' => re_status_payment_pending,
    'ACTIVE' => re_status_active,
    'EXPIRED' => re_status_expired,
    'CANCELLED' => cancelled,
    'CONVERTED_TO_SALE' => re_status_converted_to_sale,
    'REFUND_PENDING' => re_status_refund_pending,
    'REFUNDED' => refunded,
    'ADJUSTED' => re_status_adjusted,
    _ => status,
  };

  String visitStatus(String status) => switch (status) {
    'PENDING_ASSIGNMENT' => re_status_awaiting_assignment,
    'ASSIGNED' => re_status_assigned,
    'ACCEPTED' => re_status_accepted,
    'CHECK_IN' => re_status_checked_in,
    'IN_PROGRESS' => re_status_in_progress,
    'COMPLETED' => completed,
    'CANCELLED' => cancelled,
    _ => status,
  };

  String loanStatus(String status) => switch (status) {
    'REQUIRED' => re_status_requested,
    'CUSTOMER_WILL_APPLY' => re_status_applying_yourself,
    'LOAN_LEAD_CREATED' => re_status_sent_to_banks,
    'OFFERS_PENDING' => re_status_offers_incoming,
    'OFFERS_RECEIVED' => re_status_offers_received,
    'CUSTOMER_SELECTING' => re_status_selecting,
    'BANK_SELECTED' => re_status_bank_selected,
    'APPLICATION_STARTED' => re_status_application_started,
    'DOCUMENTS_PENDING' => re_status_documents_pending,
    'UNDER_BANK_REVIEW' => re_status_under_review,
    'SANCTIONED' => re_status_sanctioned,
    'DISBURSED' => re_status_disbursed,
    'REJECTED' => re_status_rejected,
    'WITHDRAWN' => re_status_withdrawn,
    _ => status,
  };

  String offerStatus(String status) => switch (status) {
    'PENDING' => re_offer_status_pending,
    'ACCEPTED' => re_offer_status_accepted,
    'REJECTED' => re_offer_status_rejected,
    'WITHDRAWN' => re_offer_status_withdrawn,
    _ => status,
  };

  /// A recorded sale. `COMPLETED` is the finished purchase; `CANCELLED`
  /// is a sale that was undone.
  String purchaseStatus(String status) => switch (status) {
    'COMPLETED' => completed,
    'CANCELLED' => cancelled,
    _ => status,
  };

  /// A document the bank asked the customer for.
  String documentRequestStatus(String status) => switch (status) {
    'REQUESTED' => re_doc_request_status_requested,
    'SUBMITTED' => re_doc_request_status_submitted,
    'ACCEPTED' => re_doc_request_status_accepted,
    'REJECTED' => re_doc_request_status_rejected,
    'CANCELLED' => re_doc_request_status_cancelled,
    _ => status,
  };

  /// BUY | RENT - how the customer transacted with the property.
  String purchaseType(String type) => switch (type) {
    'BUY' => re_purchase_type_buy,
    'RENT' => re_purchase_type_rent,
    _ => type,
  };

  /// A document category that cleared verification (BR-18). The backend
  /// sends the category enum; an unknown category stays visible rather
  /// than being swallowed.
  String documentCategory(String category) => switch (category) {
    'OWNERSHIP' => re_doc_ownership,
    'APPROVAL' => re_doc_approval,
    'TAX' => re_doc_tax,
    'ENCUMBRANCE' => re_doc_encumbrance,
    'PROJECT' => re_doc_project,
    'SELLER' => re_doc_seller,
    'OTHER' => re_doc_other,
    _ => category,
  };

  String leadStatus(String status) => switch (status) {
    'NEW' => re_status_new,
    'CONTACTED' => re_status_contacted,
    'VISIT_REQUESTED' => re_status_visit_requested,
    'VISIT_SCHEDULED' => re_status_visit_scheduled,
    'VISIT_COMPLETED' => re_status_visit_completed,
    'FOLLOW_UP' => re_status_follow_up,
    'OFFERS_RECEIVED' => re_status_offers_received,
    'CUSTOMER_SELECTING' => re_status_selecting,
    'HOLD' => re_status_hold,
    'SALE' => re_status_sale,
    'LOST' => re_status_lost,
    _ => status,
  };

  String visitSlot(String? slot) => switch (slot) {
    'MORNING' => re_morning,
    'AFTERNOON' => re_afternoon,
    'EVENING' => re_evening,
    _ => slot ?? '',
  };

  String visitSlotDetail(String slot) => switch (slot) {
    'MORNING' => re_slot_morning,
    'AFTERNOON' => re_slot_afternoon,
    'EVENING' => re_slot_evening,
    _ => slot,
  };

  String employmentLabel(String? employment) => switch (employment) {
    'SALARIED' => re_employment_salaried,
    'SELF_EMPLOYED' => re_employment_self_employed,
    'BUSINESS' => re_employment_business,
    'OTHER' => re_employment_other,
    _ => employment ?? '',
  };

  String propertyTitle(PropertyModel property) {
    if (property.title != null && property.title!.isNotEmpty) {
      return property.title!;
    }
    final parts = <String>[];
    if (property.bedrooms != null && property.transactionType == 'BUY') {
      parts.add(re_bhk(property.bedrooms!));
    }
    if (property.area != null) {
      parts.add(re_area_sqft(property.area!.toStringAsFixed(0)));
    }
    return parts.isEmpty ? re_property : parts.join(' • ');
  }

  String propertyPrice(PropertyModel property) {
    if (property.priceOnRequest) return re_price_on_request;
    if (property.price == null) return '—';
    return '₹${formatIndianPrice(property.price!)}';
  }
}
