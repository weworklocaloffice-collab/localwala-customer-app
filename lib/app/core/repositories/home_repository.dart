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

import 'dart:convert';

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/visited_campaign_detail_model.dart';
import 'package:user/app/core/models/global_search_history_model.dart';
import 'package:user/app/core/models/request/food_campaign_request_model.dart';
import 'package:user/app/core/models/request/global_search_initial_request_model.dart';
import 'package:user/app/core/models/request/global_search_request_model.dart';
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/home_restaurant_request_model.dart';
import 'package:user/app/core/models/request/notification_list_request_model.dart';
import 'package:user/app/core/models/request/restaurant_campaign_request_model.dart';
import 'package:user/app/core/models/request/restaurants_by_brands_request_model.dart';
import 'package:user/app/core/models/request/restaurants_by_category_request_model.dart';
import 'package:user/app/core/models/request/restaurants_by_cuisine_request_model.dart';
import 'package:user/app/core/models/request/restaurants_by_localities_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/request/single_food_info_request_model.dart';
import 'package:user/app/core/models/request/update_hide_restaurant_reason_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class HomeRepository {
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

  Future<DioApiResponse> getHomeData(HomeRestaurantRequest param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.nearMeRestaurant, body: param);
  }

  Future<DioApiResponse> getFoodCampaignDetails(String campaignId, FoodCampaignRequestModel param) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.foodCampaignDetails}$campaignId', body: param);
  }

  Future<DioApiResponse> getRestaurantCampaignDetails(String campaignId, RestaurantCampaignRequestModel param) async {
    return await _apiRequestService.post('${ApiEndPoints.v1request.restaurantCampaignDetails}$campaignId', body: param);
  }

  Future<DioApiResponse> getRestaurantsByCuisine(RestaurantsByCuisineRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantsByCuisine, body: param);
  }

  Future<DioApiResponse> getRestaurantsByCategory(RestaurantsByCategoryRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantsByCategory, body: param);
  }

  Future<DioApiResponse> getRestaurantsFoodsByCategory(RestaurantsByCategoryRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantsFoodsByCategory, body: param);
  }

  Future<DioApiResponse> getRestaurantsByBrands(RestaurantsByBrandsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantsByBrands, body: param);
  }

  Future<DioApiResponse> getRestaurantsByLocalities(RestaurantsByLocalitiesRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantsByLocalities, body: param);
  }

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> userRole() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole) ?? '';
  }

  Future<DioApiResponse> saveFavourite(SaveFavouriteRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveFavourite, body: param);
  }

  Future<DioApiResponse> getSingleFoodInfo(SingleFoodInfoRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getSingleFoodInfo, body: param);
  }

  Future<DioApiResponse> getGlobalSearchInitial(GlobalSearchInitialRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.globalSearchInitial, body: param);
  }

  Future<DioApiResponse> globalSearch(GlobalSearchRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.globalSearch, body: param);
  }

  Future<void> saveGlobalSearchHistory(List<GlobalSearchHistoryModel> searchItem) async {
    List<String> searchResults = <String>[];
    for (var element in searchItem) {
      searchResults.add(jsonEncode(element));
    }
    _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.globalSearchHistory, searchResults);
  }

  Future<List<GlobalSearchHistoryModel>> getLocalSearchHistory() async {
    List<String>? searchResults = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.globalSearchHistory)) {
      searchResults = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.globalSearchHistory);
    }

    List<GlobalSearchHistoryModel> searchItems = <GlobalSearchHistoryModel>[];
    for (var element in searchResults!) {
      var items = jsonDecode(element);
      searchItems.add(GlobalSearchHistoryModel.fromJson(items));
    }
    return searchItems;
  }

  Future<DioApiResponse> hideRestaurant(HideRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.hideRestaurant, body: param);
  }

  Future<DioApiResponse> showHiddenRestaurant(ShowHiddenRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.showHiddenRestaurant, body: param);
  }

  Future<DioApiResponse> getHideRestaurantReason() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.getHideRestaurantReasons);
  }

  Future<DioApiResponse> updateHideRestauantReason(UpdateHideRestaurantReasonRequestModel param) async {
    return await _apiRequestService.patch(ApiEndPoints.v1request.updateHideRestaurantReason, body: param);
  }

  Future<DioApiResponse> getNotificationCount(String user) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.notificationCount}$user');
  }

  Future<DioApiResponse> getNotificationList(NotificationListRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.notificationList, body: param);
  }

  Future<DioApiResponse> readAllNotification(String user) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.readAllNotification}$user');
  }

  Future<DioApiResponse> fetchRestaurantCallNumber(String restaurant) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.fetchRestaurantPhoneNumber}$restaurant');
  }

  Future<void> saveVisitCampaignDetail(String id, String type) async {
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.campaignId, id);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.campaignType, type);
  }

  Future<VisitedCampaignDetailModel> getVisitedCampaignDetail() async {
    VisitedCampaignDetailModel detail = VisitedCampaignDetailModel(id: '', type: '');
    final String id = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.campaignId) ?? '';
    final String type = await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.campaignType) ?? '';
    detail.id = id;
    detail.type = type;
    return detail;
  }

  Future<void> clearVisitedCampaignDetail() async {
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.publicKeys.campaignId);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.publicKeys.campaignType);
  }
}

