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
import 'package:user/app/core/models/request/buy_tiffin_subscription_request_model.dart';
import 'package:user/app/core/models/request/purchased_tiffin_subscription_info_request_model.dart';
import 'package:user/app/core/models/request/purchased_tiffin_subscription_package_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_tiffin_subscription_package_request_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_list_from_restaurant_request_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_refund_request_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_request_off_day_request_model.dart';
import 'package:user/app/core/models/request/user_cancel_tiffin_subscription_package_rquest_model.dart';
import 'package:user/app/core/models/request/user_food_subscription_transaction_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class SubscriptionTiffinPackagesRepository {
  final ApiRequestService _apiRequestService = ApiRequestService();
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();

  Future<bool> isAuthorized() async {
    bool uid = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.uid);
    bool authToken = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
    String? userRole = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole);
    if (uid && authToken && userRole != null && userRole != '' && userRole.isNotEmpty && userRole == 'user') {
      return true;
    }
    return false;
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<DioApiResponse> getSubscriptionPackageDetail(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getSubscriptionTiffinInfo}$id');
  }

  Future<DioApiResponse> buySubscriptionPackageDetail(String id) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.buySubscriptionTiffinInfo}$id');
  }

  Future<DioApiResponse> buyTiffinSubscriptionPackage(BuyTiffinSubscriptionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.purchaseTiffinSubscription, body: param);
  }

  Future<DioApiResponse> getPurchasedSubscriptionPackage(PurchasedTiffinSubscriptionPackageRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.purchasedSubscriptionList, body: param);
  }

  Future<DioApiResponse> getPurchasedSubscriptionPackageInfo(PurchasedTiffinSubscriptionPackageInfoRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.purchasedSubscriptionInfo, body: param);
  }

  Future<DioApiResponse> repayPendingSubscriptionTiffinPackage(RepayPendingTiffinSubscriptionPackageRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.repayTiffinSubscriptionPackage, body: param);
  }

  Future<DioApiResponse> getCancellationReasonList() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.tiffinSubscriptionCancellationReason);
  }

  Future<DioApiResponse> userCancelTiffinSubscriptionPackage(UserCancelTiffinSubscriptionPackageRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userCancelTiffinSubscriptionPackage, body: param);
  }

  Future<DioApiResponse> getTiffinSubscriptionRefundReason() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.tiffinSubscriptionRefundReason);
  }

  Future<DioApiResponse> sendTiffinSubscriptionRefundRequest(TiffinSubscriptionRefundRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.tiffinSubscriptionRefundRequest, body: param);
  }

  Future<DioApiResponse> tiffinSubscriptionRequestOffDay(TiffinSubscriptionRequestOffDayRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.tiffinSubscriptionRequestOffDay, body: param);
  }

  Future<DioApiResponse> getTiffinSubscriptionListFromRestaurant(TiffinSubscriptionFromListRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.tiffinSubscriptionListFromRestaurant, body: param);
  }

  Future<DioApiResponse> getFoodSubscriptionTransaction(UserFoodSubscriptionTransactionRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.foodSubscriptionPaymentTransaction, body: param);
  }

  Future<DioApiResponse> fetchRestaurantCallNumber(String restaurant) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.fetchRestaurantPhoneNumber}$restaurant');
  }

  Future<bool> downloadSummary(String bookingId, String path) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    final String locale = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? 'en';
    return await _apiRequestService.download('${ApiEndPoints.v1request.tiffinSubscriptionDownloadSummary}/$bookingId/$userId/$locale', path);
  }

  Future<bool> downloadInvoice(String bookingId, String path) async {
    final String userId = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
    final String locale = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? 'en';
    return await _apiRequestService.download('${ApiEndPoints.v1request.tiffinSubscriptionDownloadInvoice}/$bookingId/$userId/$locale', path);
  }
}

