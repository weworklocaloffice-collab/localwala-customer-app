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
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.categories,
    );
  }

  Future<DioApiResponse> services({String? categoryId}) {
    return _apiRequestService.get(
      categoryId == null || categoryId.isEmpty
          ? LocalServicesCustomerEndpoints.services
          : '${LocalServicesCustomerEndpoints.services}?category=$categoryId',
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

  Future<DioApiResponse> bookings() {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.bookings,
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

  Future<DioApiResponse> recurring() {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.recurring,
    );
  }

  Future<DioApiResponse> leads() {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.leads,
    );
  }

  Future<DioApiResponse> occurrences() {
    return _apiRequestService.get(
      LocalServicesCustomerEndpoints.recurring,
    );
  }
}
