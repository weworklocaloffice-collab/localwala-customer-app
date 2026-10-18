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

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/dining_campaign_request_model.dart';
import 'package:user/app/core/models/request/cancel_dining_booking_request_model.dart';
import 'package:user/app/core/models/request/create_dining_booking_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_confirm_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_detail_information_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_information_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_list_request_model.dart';
import 'package:user/app/core/models/request/dining_booking_refund_request_model.dart';
import 'package:user/app/core/models/request/dining_by_category_request_model.dart';
import 'package:user/app/core/models/request/global_search_initial_request_model.dart';
import 'package:user/app/core/models/request/global_search_request_model.dart';
import 'package:user/app/core/models/request/near_me_dining_restaurant_on_map_request_model.dart';
import 'package:user/app/core/models/request/dining_restaurant_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_booking_payment_request_model.dart';
import 'package:user/app/core/models/request/user_dining_transactions_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class DiningRepository {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<bool> isAuthorized() async {
    bool uid = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.uid);
    bool authToken = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
    String? userRole = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole);
    if (uid && authToken && userRole != null && userRole != '' && userRole.isNotEmpty && userRole == 'user') {
      return true;
    }
    return false;
  }

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<DioApiResponse> getDiningRestaurants(DiningRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningRestaurant, body: param);
  }

  Future<DioApiResponse> getDiningOnMaps(NearMeDiningRestaurantsOnMapRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningRestaurantOnMaps, body: param);
  }

  Future<DioApiResponse> googleDirection(double latFirst, double lngFirst, double latSecond, double lngSecond) async {
    return await _apiRequestService.googleDirection(latFirst, lngFirst, latSecond, lngSecond);
  }

  Future<DioApiResponse> getDiningCampaign(DiningCampaignRequestModel param) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.diningCampaignDetail}${param.campaignId}', body: param);
  }

  Future<DioApiResponse> getDiningByCategory(DiningByCategoryRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningByCategory, body: param);
  }

  Future<DioApiResponse> getGlobalDiningSearchInitial(GlobalSearchInitialRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.globalDiningSearchInitial, body: param);
  }

  Future<DioApiResponse> globalDiningSearch(GlobalSearchRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.globalDiningSearch, body: param);
  }

  Future<DioApiResponse> getDiningBookingInformation(DiningBookingInformationRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningBookingInformation, body: param);
  }

  Future<DioApiResponse> getDiningBookingConfirmation(DiningBookingConfirmRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningBookingConfirmation, body: param);
  }

  Future<DioApiResponse> createDiningBooking(CreateDiningBookingRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.createDiningBooking, body: param);
  }

  Future<DioApiResponse> getDiningBookingList(DiningBookingListRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getDiningBookingList, body: param);
  }

  Future<DioApiResponse> searchDiningBookingList(String user, String searchQuery) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.searchDiningBookingList}$user/$searchQuery');
  }

  Future<DioApiResponse> getDiningBookingDetailInformation(DiningBookingDetailInformationRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.diningBookingDetailInformation, body: param);
  }

  Future<DioApiResponse> repayPendingBookingPayment(RepayPendingBookingPaymentRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.repayPendingBookingPayment, body: param);
  }

  Future<DioApiResponse> getDiningBookingCancellationReasonList() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.diningBookingCancellationReasonList);
  }

  Future<DioApiResponse> cancelDiningBooking(CancelDiningBookingRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.cancelDiningBooking, body: param);
  }

  Future<DioApiResponse> getDiningBookingRefundReason() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.diningBookingRefundReason);
  }

  Future<DioApiResponse> createDiningBookingRefundRequest(DiningBookingRefundRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.diningBookingRefundRequest, body: param);
  }

  Future<DioApiResponse> verifyDiningCoupon(String user, String coupon) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.verifyDiningCoupon}$user/$coupon');
  }

  Future<DioApiResponse> getDiningTransaction(UserDiningTransactionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.diningPaymentTransaction, body: param);
  }

  Future<bool> downloadSummary(String bookingId, String path) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    final String locale = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? 'en';
    return await _apiRequestService.download('${ApiEndPoints.v1request.diningBookingSummary}/$bookingId/$userId/$locale', path);
  }

  Future<bool> downloadInvoice(String bookingId, String path) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    final String locale = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? 'en';
    return await _apiRequestService.download('${ApiEndPoints.v1request.diningBookingInvoice}/$bookingId/$userId/$locale', path);
  }
}

