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

import 'dart:typed_data';

import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/local_services/local_services_customer_endpoints.dart';

/// Customer-side Local Services calls.
///
/// Two rules the screens rely on, both enforced server side:
/// - totals are computed by the backend (`pricing` block is input only);
/// - quote-based services show "quote needed", never a fake fixed price.
class LocalServicesCustomerService {
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<DioApiResponse> categories() {
    return _apiRequestService.get(LocalServicesCustomerEndpoints.categories);
  }

  Future<DioApiResponse> subcategories(String parentId) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.categorySubcategories,
        <String, String>{'id': parentId},
      ),
    );
  }

  Future<DioApiResponse> services({
    String? categoryId,
    int page = 1,
    int limit = 50,
  }) {
    final String categoryQuery = categoryId == null || categoryId.isEmpty
        ? ''
        : '&category=$categoryId';
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.services}?page=$page&limit=$limit$categoryQuery',
    );
  }

  Future<DioApiResponse> serviceDetail(String id) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.serviceDetail,
        <String, String>{'id': id},
      ),
    );
  }

  Future<DioApiResponse> offerings({
    required String serviceId,
    String? variantId,
  }) {
    final String variant = variantId == null || variantId.isEmpty
        ? ''
        : '&variant=$variantId';
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.offerings}?service=$serviceId$variant',
    );
  }

  Future<DioApiResponse> availability({
    required String serviceId,
    required String startAt,
    required String endAt,
  }) {
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.availability}?service=$serviceId&startAt=${Uri.encodeComponent(startAt)}&endAt=${Uri.encodeComponent(endAt)}',
    );
  }

  Future<DioApiResponse> createBooking(Map<String, dynamic> payload) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.bookings,
      body: payload,
    );
  }

  Future<DioApiResponse> payBooking(String id, {String? paymentConfigId}) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingPay,
        <String, String>{'id': id},
      ),
      body: <String, dynamic>{
        if (paymentConfigId != null && paymentConfigId.isNotEmpty)
          'payment': paymentConfigId,
      },
    );
  }

  Future<DioApiResponse> bookingPayment(String id) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingPayment,
        <String, String>{'id': id},
      ),
    );
  }

  Future<DioApiResponse> bookings() {
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.bookings}'
      '?limit=50&sortBy=createdAt:desc',
    );
  }

  Future<DioApiResponse> booking(String id) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.booking,
        <String, String>{'id': id},
      ),
    );
  }

  Future<DioApiResponse> transitionBooking(
    String id,
    String status, [
    Map<String, dynamic>? body,
  ]) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingTransition,
        <String, String>{'id': id, 'status': status},
      ),
      body: body ?? <String, dynamic>{},
    );
  }

  Future<DioApiResponse> confirmCompletion(String id, [String? reason]) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingCompleteConfirmation,
        <String, String>{'id': id},
      ),
      body: <String, dynamic>{
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  Future<DioApiResponse> acceptQuote(String quoteId) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.quoteAccept,
        <String, String>{'id': quoteId},
      ),
    );
  }

  Future<DioApiResponse> review(String id, int rating, [String? comment]) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingReview,
        <String, String>{'id': id},
      ),
      body: <String, dynamic>{
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  Future<DioApiResponse> invoice(String id) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingInvoice,
        <String, String>{'id': id},
      ),
    );
  }

  Future<bool> invoicePdf(String id, String path) {
    return _apiRequestService.download(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingInvoicePdf,
        <String, String>{'id': id},
      ),
      path,
    );
  }

  Future<Uint8List?> invoicePdfBytes(String id) {
    return _apiRequestService.downloadBytes(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.bookingInvoicePdf,
        <String, String>{'id': id},
      ),
    );
  }

  Future<DioApiResponse> recurring() {
    return _apiRequestService.get(LocalServicesCustomerEndpoints.recurring);
  }

  Future<DioApiResponse> createRecurring(Map<String, dynamic> payload) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.recurring,
      body: payload,
    );
  }

  Future<DioApiResponse> setRecurringStatus(String id, String status) {
    return _apiRequestService.post(
      '${LocalServicesCustomerEndpoints.recurring}/$id/$status',
    );
  }

  Future<DioApiResponse> leads() {
    return _apiRequestService.get(LocalServicesCustomerEndpoints.leads);
  }

  Future<DioApiResponse> occurrences() {
    return _apiRequestService.get(LocalServicesCustomerEndpoints.occurrences);
  }

  Future<DioApiResponse> createComplaint(Map<String, dynamic> payload) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.complaints,
      body: payload,
    );
  }

  Future<DioApiResponse> myComplaints() {
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.complaints}'
      '?limit=50&sortBy=createdAt:desc',
    );
  }

  Future<DioApiResponse> reviews() {
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.myReviews}'
      '?limit=50&sortBy=createdAt:desc',
    );
  }

  Future<DioApiResponse> favorites({int page = 1, int limit = 20}) {
    return _apiRequestService.get(
      '${LocalServicesCustomerEndpoints.favorites}?page=$page&limit=$limit',
    );
  }

  Future<DioApiResponse> isFavorite(String serviceId) {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.serviceFavorite,
        <String, String>{'service': serviceId},
      ),
    );
  }

  Future<DioApiResponse> addFavorite(String serviceId) {
    return _apiRequestService.post(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.serviceFavorite,
        <String, String>{'service': serviceId},
      ),
    );
  }

  Future<DioApiResponse> removeFavorite(String serviceId) {
    return _apiRequestService.delete(
      LocalServicesCustomerEndpoints.resolve(
        LocalServicesCustomerEndpoints.serviceFavorite,
        <String, String>{'service': serviceId},
      ),
    );
  }
}
