// Real Estate model parser tests.
//
// These are pure unit tests: the JSON shapes below mirror the backend
// responses and validate that PropertyModel, LeadModel,
// LeadActivityEntry and PropertyCategory parse what the
// /v1/realestate endpoints actually return. No Flutter binding needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/core/models/real_estate_property_model.dart';

void main() {
  group('PropertyModel.fromJson', () {
    test('parses a full PUBLISHED listing', () {
      final json = {
        '_id': '507f1f77bcf86cd799439011',
        'propertyCode': 'RE-HYD-000123',
        'title': '3 BHK Apartment in Madhapur',
        'description': 'Spacious flat, ready to move.',
        'transactionType': 'BUY',
        'price': 8500000,
        'priceOnRequest': false,
        'city': 'Hyderabad',
        'locality': 'Madhapur',
        'state': 'Telangana',
        'addressLine': 'Plot 21, Layout A',
        'pincode': '500081',
        'specs': {'area': 1450, 'bedrooms': 3, 'bathrooms': 2, 'parking': 1},
        'media': [
          {
            'type': 'IMAGE',
            'url': 'https://example.com/p1.jpg',
            'thumbUrl': 'https://example.com/p1-thumb.jpg'
          }
        ],
        'amenities': ['LIFT', 'SECURITY', 'POWER_BACKUP'],
        'status': 'PUBLISHED',
        'availability': 'AVAILABLE',
        'publishedAt': '2026-01-15T10:30:00.000Z',
        'views': 142,
        'enquiries': 23,
        'visits': 4,
        'verifiedAt': '2026-01-10T08:00:00.000Z',
        'projectName': 'Skyline Heights',
        'location': {'type': 'Point', 'coordinates': [78.3868, 17.4486]},
      };
      final p = PropertyModel.fromJson(json);
      expect(p.id, '507f1f77bcf86cd799439011');
      expect(p.propertyCode, 'RE-HYD-000123');
      expect(p.title, '3 BHK Apartment in Madhapur');
      expect(p.transactionType, 'BUY');
      expect(p.price, 8500000.0);
      expect(p.priceOnRequest, false);
      expect(p.city, 'Hyderabad');
      expect(p.area, 1450.0);
      expect(p.bedrooms, 3);
      expect(p.bathrooms, 2);
      expect(p.parking, 1);
      expect(p.media.length, 1);
      expect(p.media.first, 'https://example.com/p1.jpg');
      expect(p.amenities, ['LIFT', 'SECURITY', 'POWER_BACKUP']);
      expect(p.status, 'PUBLISHED');
      expect(p.availability, 'AVAILABLE');
      expect(p.verified, true);
      expect(p.latitude, 17.4486);
      expect(p.longitude, 78.3868);
    });

    test('handles priceOnRequest with no price', () {
      final p = PropertyModel.fromJson({
        '_id': 'p1',
        'priceOnRequest': true,
      });
      expect(p.priceOnRequest, true);
      expect(p.price, null);
      expect(p.displayPrice, 'Price on request');
    });

    test('handles missing optional fields without throwing', () {
      final p = PropertyModel.fromJson({'_id': 'p2'});
      expect(p.id, 'p2');
      expect(p.title, null);
      expect(p.bedrooms, null);
      expect(p.media, isEmpty);
      expect(p.amenities, isEmpty);
    });

    test('displayTitle falls back to area + bedrooms when title missing', () {
      final p = PropertyModel.fromJson({
        '_id': 'p3',
        'transactionType': 'BUY',
        'specs': {'area': 1200, 'bedrooms': 2},
      });
      expect(p.displayTitle, '2 BHK • 1200 sq.ft');
    });
  });

  group('formatIndianPrice', () {
    test('lakhs under 1 crore', () {
      expect(formatIndianPrice(8500000), '85 Lakh');
      expect(formatIndianPrice(125000), '1.25 Lakh');
      expect(formatIndianPrice(50000), '50K');
    });
    test('crores', () {
      expect(formatIndianPrice(10000000), '1 Cr');
      expect(formatIndianPrice(150000000), '15 Cr');

      // Was `formatIndianPrice(100000005)` expecting '1 Cr'. That input is 10.0000005
      // crore, so '10.00 Cr' was the correct answer and the expectation was the bug —
      // off by a factor of ten. The intent looks like "a hair over a crore still reads as
      // one crore", which is one crore plus five: 10000005 / 10000000 = 1.0000005, and a
      // non-round value gets two decimals, hence '1.00 Cr' rather than '1 Cr'.
      expect(formatIndianPrice(10000005), '1.00 Cr');
      expect(formatIndianPrice(100000005), '10.00 Cr');
    });
  });

  group('LeadModel.fromJson', () {
    test('parses a customer enquiry with property snapshot', () {
      final lead = LeadModel.fromJson({
        '_id': '507f1f77bcf86cd799439099',
        'leadCode': 'LEAD-1700000000000',
        'property': '507f1f77bcf86cd799439011',
        'propertySnapshot': {
          'title': '3 BHK Apartment in Madhapur',
          'propertyCode': 'RE-HYD-000123'
        },
        'status': 'NEW',
        'source': 'ENQUIRY',
        'message': 'Interested in a visit next weekend',
        'createdAt': '2026-01-20T12:00:00.000Z',
        'updatedAt': '2026-01-20T12:00:00.000Z',
      });
      expect(lead.id, '507f1f77bcf86cd799439099');
      expect(lead.leadCode, 'LEAD-1700000000000');
      expect(lead.propertySnapshot, '3 BHK Apartment in Madhapur');
      expect(lead.status, 'NEW');
      expect(lead.message, 'Interested in a visit next weekend');
      expect(lead.createdAt, isNotNull);
    });

    test('handles string propertySnapshot', () {
      final lead = LeadModel.fromJson({
        '_id': 'l1',
        'propertySnapshot': 'Just a code',
      });
      expect(lead.propertySnapshot, 'Just a code');
    });
  });

  group('LeadActivityEntry.fromJson', () {
    test('parses action + timestamp', () {
      final e = LeadActivityEntry.fromJson({
        'action': 'CREATED',
        'at': '2026-01-20T12:00:00.000Z',
      });
      expect(e.action, 'CREATED');
      expect(e.at, isNotNull);
    });

    test('defaults action to empty string when missing', () {
      final e = LeadActivityEntry.fromJson({});
      expect(e.action, '');
      expect(e.at, null);
    });
  });

  group('PropertyCategory.fromJson', () {
    test('parses group + amenityOptions + count', () {
      final c = PropertyCategory.fromJson({
        'key': 'APARTMENT',
        'name': 'Apartments',
        'group': 'RESIDENTIAL',
        'icon': 'apartment',
        'amenityOptions': ['LIFT', 'SECURITY'],
        'count': 42,
      });
      expect(c.key, 'APARTMENT');
      expect(c.group, 'RESIDENTIAL');
      expect(c.amenityOptions, ['LIFT', 'SECURITY']);
      expect(c.count, 42);
    });
  });

  group('GroupedCategory.fromJson', () {
    test('parses the lighter grouped-endpoint shape', () {
      final c = GroupedCategory.fromJson({
        'id': '507f1f77bcf86cd799439099',
        'key': 'APARTMENT',
        'name': 'Apartments',
        'icon': 'apartment',
        'transactionTypes': ['BUY', 'RENT'],
      });
      expect(c.id, '507f1f77bcf86cd799439099');
      expect(c.key, 'APARTMENT');
      expect(c.transactionTypes, ['BUY', 'RENT']);
    });

    test('handles missing optional fields', () {
      final c = GroupedCategory.fromJson({'key': 'VILLA', 'name': 'Villas'});
      expect(c.transactionTypes, isEmpty);
      expect(c.icon, isNull);
    });
  });

  group('CategoryGroups.fromJson', () {
    test('parses the grouped wrapper response', () {
      final g = CategoryGroups.fromJson({
        'groups': {
          'RESIDENTIAL': [
            {'key': 'APARTMENT', 'name': 'Apartments', 'transactionTypes': ['BUY', 'RENT']},
            {'key': 'VILLA', 'name': 'Villas', 'transactionTypes': ['BUY']},
          ],
          'COMMERCIAL': [
            {'key': 'OFFICE', 'name': 'Offices', 'transactionTypes': ['RENT']},
          ],
        },
      });
      expect(g.groupNames, ['RESIDENTIAL', 'COMMERCIAL']);
      expect(g.byGroup['RESIDENTIAL']!.length, 2);
      expect(g.byGroup['COMMERCIAL']!.length, 1);
      expect(g.byGroup['RESIDENTIAL']![0].key, 'APARTMENT');
    });

    test('handles missing groups', () {
      final g = CategoryGroups.fromJson({});
      expect(g.groupNames, isEmpty);
    });
  });
}
