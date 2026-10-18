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
import 'package:user/app/core/models/request/food_review_request_model.dart';
import 'package:user/app/core/models/request/food_search_initial_request_model.dart';
import 'package:user/app/core/models/request/food_search_request_model.dart';
import 'package:user/app/core/models/request/hidden_restaurants_list_request_model.dart';
import 'package:user/app/core/models/request/remove_image_file_request_model.dart';
import 'package:user/app/core/models/request/report_issue_restaurat_request_model.dart';
import 'package:user/app/core/models/request/restaurant_detail_information_request_model.dart';
import 'package:user/app/core/models/request/restaurant_info_request_model.dart';
import 'package:user/app/core/models/request/restaurant_review_request_model.dart';
import 'package:user/app/core/models/request/save_direct_restaurant_review_request_model.dart';
import 'package:user/app/core/models/request/search_restaurant_for_reviews_request_model.dart';
import 'package:user/app/core/models/request/single_food_info_request_model.dart';
import 'package:user/app/services/shared_pref.dart';

class RestaurantRepository {
  final ApiRequestService _apiRequestService = ApiRequestService();
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> websiteURL() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.websiteUrl) ?? '';
  }

  Future<bool> isAuthorized() async {
    bool uid = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.uid);
    bool authToken = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
    String? userRole = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.userRole);
    if (uid && authToken && userRole != null && userRole != '' && userRole.isNotEmpty && userRole == 'user') {
      return true;
    }
    return false;
  }

  Future<DioApiResponse> getRestaurantInfo(RestaurantInfoRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.restaurantInfo, body: param);
  }

  Future<DioApiResponse> getSingleFoodInfo(SingleFoodInfoRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getSingleFoodInfo, body: param);
  }

  Future<DioApiResponse> getFoodSearchInitialData(FoodSearchInitialRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.foodSearchInitial, body: param);
  }

  Future<DioApiResponse> getFoodSearchResult(FoodSearchRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.foodSearch, body: param);
  }

  Future<DioApiResponse> getReportIssueRestaurantReasons() async {
    return await _apiRequestService.get(ApiEndPoints.v1request.reportIssueReasonList);
  }

  Future<DioApiResponse> saveReportIssueRestaurant(ReportIssueRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.reportIssueRestaurant, body: param);
  }

  Future<DioApiResponse> getMyHiddenRestaurantList(HiddenRestaurantListRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getMyHiddenRestaurantList, body: param);
  }

  Future<DioApiResponse> getRestaurantReviews(RestaurantReviewsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getRestaurantReview, body: param);
  }

  Future<DioApiResponse> getFoodReview(FoodReviewsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getFoodReview, body: param);
  }

  Future<DioApiResponse> getRestaurantDetailInformation(RestaurantDetailInformationRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getRestaurantDetailInformation, body: param);
  }

  Future<DioApiResponse> getRestaurantInfoForDirectReview(String restaurant) async {
    return await _apiRequestService.get('${ApiEndPoints.v1request.getRestaurantInfoForDirectReview}$restaurant');
  }

  Future<DioApiResponse> deleteMediaFile(RemoveImageFileRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeImageFile, body: param);
  }

  Future<DioApiResponse> uploadMediaImage(XFile file, String uid) async {
    return await _apiRequestService.uploadImageFile(ApiEndPoints.v1request.uploadImageFile, uid, file);
  }

  Future<DioApiResponse> saveDirectRestaurantReview(SaveDirectRestaurantReviewRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.saveDirectRestaurantReview, body: param);
  }

  Future<DioApiResponse> searchRestaurantForReview(SearchRestaurantForReviewRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.searchRestaurantForReview, body: param);
  }
}

