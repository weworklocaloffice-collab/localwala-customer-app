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
import 'package:user/app/core/models/request/make_wallet_payment_request_model.dart';
import 'package:user/app/core/models/request/reedem_loyalty_point_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class WalletRepositry {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<DioApiResponse> getWalletPaymentList() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getWalletPaymentList);
  }

  Future<DioApiResponse> getWalletInfo(String user, int? limit, int? page) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getWalletInfo}$user?limit=$limit&page=$page');
  }

  Future<DioApiResponse> getWalletPaymentLink(MakeWalletPaymentRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getWalletPaymentLink, body: param);
  }

  Future<DioApiResponse> getLoyaltyPoints(String user) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getLoyaltyPoints}$user');
  }

  Future<DioApiResponse> redeemLoyaltyPoints(RedeemLoyaltyPointRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.redeemLoyaltyPoints, body: param);
  }
}

