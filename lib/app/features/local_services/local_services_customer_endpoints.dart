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

/// Customer Local Services endpoints, mounted at `/v1/local-services`.
///
/// Verified against `API/src/modules/local-services/index.js`. Public
/// catalogue needs no token; everything under `/customer` scopes by the
/// access token — no customer id is ever sent.
class LocalServicesCustomerEndpoints {
  const LocalServicesCustomerEndpoints._();

  //// Public catalogue (guest) ////
  static const String categories = 'v1/local-services/public/categories';
  static const String services = 'v1/local-services/public/services';
  static const String serviceDetail = 'v1/local-services/public/services/{id}';
  static const String offerings = 'v1/local-services/public/offerings';
  static const String availability = 'v1/local-services/public/availability';
  static const String reviews = 'v1/local-services/customer/reviews';

  //// Bookings ////
  static const String bookings = 'v1/local-services/customer/bookings';
  static const String booking = 'v1/local-services/customer/bookings/{id}';
  static const String bookingPay =
      'v1/local-services/customer/bookings/{id}/pay';
  static const String bookingPayment =
      'v1/local-services/customer/bookings/{id}/payment';
  static const String bookingTransition =
      'v1/local-services/customer/bookings/{id}/{status}';
  static const String bookingQuote =
      'v1/local-services/customer/bookings/{id}/quote';
  static const String quoteAccept =
      'v1/local-services/customer/quotes/{id}/accept';
  static const String bookingReschedule =
      'v1/local-services/customer/bookings/{id}/reschedule';
  static const String bookingDispute =
      'v1/local-services/customer/bookings/{id}/dispute';
  static const String bookingReview =
      'v1/local-services/customer/bookings/{id}/review';
  static const String bookingInvoice =
      'v1/local-services/customer/bookings/{id}/invoice';

  //// Recurring + leads ////
  static const String recurring = 'v1/local-services/recurring';
  static const String leads = 'v1/local-services/leads';
  static const String complaints = 'v1/local-services/customer/complaints';

  static String resolve(String template, Map<String, String> values) {
    return template.replaceAllMapped(RegExp(r'\{(\w+)\}'), (Match match) {
      final String? value = values[match.group(1)];
      if (value == null || value.isEmpty) {
        throw ArgumentError(
          'Missing "${match.group(1)}" for endpoint $template',
        );
      }
      return Uri.encodeComponent(value);
    });
  }
}
