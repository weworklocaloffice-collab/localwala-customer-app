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
import 'package:user/app/core/models/request/favourite_foods_request_model.dart';
import 'package:user/app/core/models/request/favourite_restaurants_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class FavouriteRepository {
  final ApiRequestService _apiRequestService = ApiRequestService();
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<DioApiResponse> getFavouriteRestaurants(FavouriteRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.favouriteRestaurants, body: param);
  }

  Future<DioApiResponse> getFavouriteFoods(FavouriteFoodsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.favouriteFoods, body: param);
  }

  Future<DioApiResponse> deleteFavouriteRestaurant(String userId, String restaurantId) async {
    return await _apiRequestService.delete('${ApiEndPoints.v1request.deleteFavouriteRestaurant}$restaurantId/$userId');
  }

  Future<DioApiResponse> deleteFavouriteFood(String userId, String foodId) async {
    return await _apiRequestService.delete('${ApiEndPoints.v1request.deleteFavouriteFood}$foodId/$userId');
  }
}

