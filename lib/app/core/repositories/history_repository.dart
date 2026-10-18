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
 * WeWorkLocal is a technology platform that connects
 * customers, vendors, service providers, and delivery
 * partners through a unified digital ecosystem.
 *
 * Core features include local commerce, food delivery,
 * service bookings, referral programs, wallet management,
 * real-time tracking, digital payments, and business
 * management solutions.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/request/cancel_my_order_request_model.dart';
import 'package:user/app/core/models/request/create_refund_request_model.dart';
import 'package:user/app/core/models/request/favourite_orders_list_request_model.dart';
import 'package:user/app/core/models/request/my_order_list_request_model.dart';
import 'package:user/app/core/models/request/order_review_request_model.dart';
import 'package:user/app/core/models/request/remove_favourite_order_request_model.dart';
import 'package:user/app/core/models/request/remove_image_file_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_order_request_model.dart';
import 'package:user/app/core/models/request/save_complaints_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_order_request_model.dart';
import 'package:user/app/core/models/request/user_order_transaction_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class HistoryRepository {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<DioApiResponse> getMyOrderList(MyOrderListRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getMyOrderList, body: param);
  }

  Future<DioApiResponse> getOrderDetails(String orderId, String userId) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getOrderDetails}$orderId/$userId');
  }

  Future<DioApiResponse> repayPendingOrder(RepayPendingOrderRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.repayPendingOrder, body: param);
  }

  Future<DioApiResponse> getCancellationReasons() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.cancellationReason);
  }

  Future<DioApiResponse> cancelMyOrder(CancelMyOrderRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.cancelMyOrder, body: param);
  }

  Future<DioApiResponse> getRefundReasonList() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getRefundReasonList);
  }

  Future<DioApiResponse> createRefundRequest(CreateRefundRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.createRefundRequest, body: param);
  }

  Future<DioApiResponse> getOrderDetailsForComplaints(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.orderDetailsForComplaints}$id');
  }

  Future<DioApiResponse> uploadMediaImage(XFile file, String uid) async {
    return await _apiRequestService.uploadImageFile(ApiEndPoints.v1request.uploadImageFile, uid, file);
  }

  Future<DioApiResponse> googleDirection(double latFirst, double lngFirst, double latSecond, double lngSecond) async {
    return await _apiRequestService.googleDirection(latFirst, lngFirst, latSecond, lngSecond);
  }

  Future<DioApiResponse> deleteMediaFile(RemoveImageFileRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeImageFile, body: param);
  }

  Future<DioApiResponse> saveComplaints(SaveComplaintsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveComplaints, body: param);
  }

  Future<DioApiResponse> saveOrderFavourite(SaveOrderFavouriteRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveFavouriteOrder, body: param);
  }

  Future<DioApiResponse> removeOrderFavourite(RemoveOrderFavouriteRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeFavouriteOrder, body: param);
  }

  Future<DioApiResponse> favouriteOrderList(FavouriteOrderListRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.favouriteOrdersList, body: param);
  }

  Future<DioApiResponse> getOrderDetailsForReview(String orderId, String userid) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.orderDetailsForReview}$orderId/$userid');
  }

  Future<DioApiResponse> saveOrderReview(OrderReviewRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveOrderReview, body: param);
  }

  Future<DioApiResponse> getUserOrderTransaction(UserOrderTransactionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.orderPaymentTransaction, body: param);
  }

  Future<DioApiResponse> fetchRestaurantCallNumber(String restaurant) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.fetchRestaurantPhoneNumber}$restaurant');
  }

  Future<DioApiResponse> fetchDriverCallNumber(String driver) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.fetchDriverPhoneNUmber}$driver');
  }

  Future<bool> orderSummary(String id, String locale, String path) async {
    final String user = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.download('${ApiEndPoints.v1request.orderSumary}/$id/$user/$locale', path);
  }

  Future<bool> orderInvoice(String id, String locale, String path) async {
    final String user = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    return await _apiRequestService.download('${ApiEndPoints.v1request.orderInvoice}/$id/$user/$locale', path);
  }
}

