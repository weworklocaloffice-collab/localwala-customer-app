import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/gen/l10n/app_localizations_ar.dart';
import 'package:user/gen/l10n/app_localizations_en.dart';
import 'package:user/gen/l10n/app_localizations_es.dart';
import 'package:user/gen/l10n/app_localizations_hi.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();
  final es = AppLocalizationsEs();
  final hi = AppLocalizationsHi();

  test('maps backend status codes to localized labels', () {
    expect(en.holdStatus('PENDING_PAYMENT'), 'Payment pending');
    expect(en.holdStatus('CONVERTED_TO_SALE'), 'Converted to sale');
    expect(en.visitStatus('PENDING_ASSIGNMENT'), 'Awaiting assignment');
    expect(en.visitStatus('CHECK_IN'), 'Executive checked in');
    expect(en.loanStatus('CUSTOMER_WILL_APPLY'), 'Applying yourself');
    expect(en.loanStatus('UNDER_BANK_REVIEW'), 'Under review');
    expect(en.offerStatus('PENDING'), 'Pending');
    expect(en.offerStatus('ACCEPTED'), 'Accepted');
    expect(en.offerStatus('REJECTED'), 'Rejected');
    expect(en.offerStatus('WITHDRAWN'), 'Withdrawn');
    expect(en.leadStatus('VISIT_REQUESTED'), 'Visit requested');
    expect(en.leadStatus('SALE'), 'Sale');

    expect(ar.holdStatus('ACTIVE'), isNot('ACTIVE'));
    expect(ar.visitStatus('COMPLETED'), isNot('COMPLETED'));
    expect(es.loanStatus('SANCTIONED'), isNot('SANCTIONED'));
    expect(es.leadStatus('LOST'), isNot('LOST'));
  });

  test('keeps unknown backend status codes visible', () {
    expect(en.holdStatus('SOMETHING_NEW'), 'SOMETHING_NEW');
    expect(ar.visitStatus('SOMETHING_NEW'), 'SOMETHING_NEW');
    expect(en.offerStatus('SOMETHING_NEW'), 'SOMETHING_NEW');
  });

  test('offer acceptance copy includes the chosen bank', () {
    expect(en.re_loan_accept_body('HDFC Bank'), contains('HDFC Bank'));
    expect(ar.re_loan_accept_body('HDFC Bank'), contains('HDFC Bank'));
    expect(es.re_loan_select_offer, isNot(en.re_loan_select_offer));
    expect(hi.re_loan_select_offer, isNot(en.re_loan_select_offer));
  });

  test('maps visit slots and employment types', () {    expect(en.visitSlot('MORNING'), 'Morning');
    expect(en.visitSlotDetail('EVENING'), 'Evening · 4pm – 7pm');
    expect(en.employmentLabel('SELF_EMPLOYED'), 'Self employed');

    expect(ar.visitSlot('AFTERNOON'), isNot('AFTERNOON'));
    expect(ar.visitSlotDetail('MORNING'), contains('9'));
    expect(es.employmentLabel('BUSINESS'), isNot('BUSINESS'));
  });

  test('localizes property title, area and price fallbacks', () {
    const property = PropertyModel(
      id: 'p1',
      transactionType: 'BUY',
      area: 1200,
      bedrooms: 3,
      bathrooms: 2,
      price: 7500000,
    );

    expect(en.propertyTitle(property), '3 BHK • 1200 sq.ft');
    expect(ar.propertyTitle(property), contains('1200'));
    expect(ar.propertyTitle(property), isNot(en.propertyTitle(property)));
    expect(en.propertyPrice(property), '₹75 Lakh');
    expect(es.propertyPrice(property), en.propertyPrice(property));

    const priceOnRequest = PropertyModel(id: 'p2', priceOnRequest: true);
    expect(en.propertyTitle(priceOnRequest), 'Property');
    expect(ar.propertyTitle(priceOnRequest), ar.re_property);
    expect(en.propertyPrice(priceOnRequest), 'Price on request');
    expect(ar.propertyPrice(priceOnRequest), ar.re_price_on_request);
  });

  test('plural helpers preserve their counts', () {
    expect(en.re_bank_count(0), 'No banks');
    expect(en.re_bank_count(1), '1 bank');
    expect(en.re_bank_count(4), '4 banks');
    expect(ar.re_offer_count(3), contains('3'));
    expect(es.re_bank_count(2), contains('2'));
    expect(hi.re_bank_count(3), contains('3'));
    expect(hi.re_offer_count(1), contains('1'));
  });

  test('Hindi Real Estate copy is translated, not English fallback', () {
    expect(hi.re_saved_title, isNot(en.re_saved_title));
    expect(hi.re_hold_list_title, isNot(en.re_hold_list_title));
    expect(hi.re_status_active, isNot(en.re_status_active));
    expect(hi.re_loan_amount_question, isNot(en.re_loan_amount_question));
    expect(hi.re_slot_morning, isNot(en.re_slot_morning));
  });

  test('Real Estate keys exist for every supported locale', () {
    final Map<String, dynamic> english = _readArb('app_en.arb');
    final Set<String> required = english.keys
        .where((key) => key.startsWith('re_') && !key.startsWith('@'))
        .toSet();

    for (final locale in <String>['ar', 'es', 'hi']) {
      final Map<String, dynamic> localized = _readArb('app_$locale.arb');
      final missing =
          required.where((key) => !localized.containsKey(key)).toList()..sort();
      expect(
        missing,
        isEmpty,
        reason: '$locale is missing Real Estate keys: ${missing.join(', ')}',
      );
    }
  });

  test('maps purchase status, type and document categories', () {    expect(en.purchaseStatus('COMPLETED'), 'Completed');
    expect(en.purchaseStatus('CANCELLED'), 'Cancelled');
    expect(en.purchaseStatus('SOMETHING_NEW'), 'SOMETHING_NEW');
    expect(en.purchaseType('BUY'), 'Buy');
    expect(en.purchaseType('RENT'), 'Rent');
    expect(en.documentCategory('OWNERSHIP'), 'Ownership');
    expect(en.documentCategory('ENCUMBRANCE'), 'Encumbrance');
    expect(en.documentCategory('NEW_CATEGORY'), 'NEW_CATEGORY');

    expect(ar.purchaseStatus('COMPLETED'), isNot('COMPLETED'));
    expect(ar.documentCategory('OWNERSHIP'), isNot('OWNERSHIP'));
    expect(es.purchaseType('RENT'), isNot('RENT'));
    expect(hi.documentCategory('TAX'), isNot('TAX'));
  });

  test('maps document-request statuses', () {
    expect(en.documentRequestStatus('REQUESTED'), 'Needed');
    expect(en.documentRequestStatus('SUBMITTED'), 'Sent');
    expect(en.documentRequestStatus('ACCEPTED'), 'Accepted');
    expect(en.documentRequestStatus('REJECTED'), 'Rejected');
    expect(en.documentRequestStatus('CANCELLED'), 'Cancelled');
    expect(en.documentRequestStatus('SOMETHING_NEW'), 'SOMETHING_NEW');

    expect(ar.documentRequestStatus('REQUESTED'), isNot('REQUESTED'));
    expect(es.documentRequestStatus('ACCEPTED'), isNot('ACCEPTED'));
    expect(hi.documentRequestStatus('REJECTED'), isNot('REJECTED'));
  });
}

Map<String, dynamic> _readArb(String filename) {
  final file = File('lib/app/l10n/$filename');
  final contents = file.readAsStringSync().replaceFirst('\ufeff', '');
  return jsonDecode(contents) as Map<String, dynamic>;
}
