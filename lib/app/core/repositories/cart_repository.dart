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

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/cart_summary_model.dart';
import 'package:user/app/core/models/cart_summary_model.dart' as cart_summary_model;
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/order_settings_request_model.dart';
import 'package:user/app/core/models/request/place_order_request_model.dart';
import 'package:user/app/core/models/request/redeem_coupon_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_by_restaurant_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/request/user_coupon_request_model.dart';
import 'package:user/app/services/shared_pref.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CartRepository {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<String> trackingId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userTrackingId) ?? '';
  }

  Future<double> userLatitude() async {
    return await _sharedPreferencesManager.getDouble(SharedPreferencesKey.publicKeys.userLatitude) ?? 0;
  }

  Future<double> userLongitude() async {
    return await _sharedPreferencesManager.getDouble(SharedPreferencesKey.publicKeys.userLongitude) ?? 0;
  }

  Future<bool> isAuthorized() async {
    bool uid = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.uid);
    bool authToken = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
    if (uid && authToken) {
      return true;
    }
    return false;
  }

  Future<List<FoodInCartModel>> getByRestaurant(String restaurant) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      if (model.restaurant == restaurant) {
        double price = 0.0;
        double addonPrice = 0.0;
        double variationPrice = 0.0;

        double realPrice = 0.0;
        double addonRealPrice = 0.0;
        double variationRealPrice = 0.0;

        for (var element in model.addons!) {
          String realPriceOfAddon = (double.parse(addonRealPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
          addonRealPrice = double.parse(realPriceOfAddon);
          if (element.haveDiscount!) {
            String price = (double.parse(addonPrice.toString()) + (double.parse(element.discountPrice.toString()))).toStringAsFixed(2);
            addonPrice = double.parse(price);
          } else {
            String price = (double.parse(addonPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
            addonPrice = double.parse(price);
          }
        }

        for (var variation in model.variations!) {
          for (var options in variation.options!) {
            String realPriceOfVariation = (double.parse(variationRealPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
            variationRealPrice = double.parse(realPriceOfVariation);

            if (options.haveDiscount!) {
              String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
              variationPrice = double.parse(price);
            } else {
              String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
              variationPrice = double.parse(price);
            }
          }
        }

        String realTotalPrice = (double.parse(model.price.toString()) + (double.parse(addonRealPrice.toString())) + (double.parse(variationRealPrice.toString()))).toStringAsFixed(2);
        realPrice = double.parse(realTotalPrice);

        if (model.discount! > 0) {
          String totalPrice = (double.parse(model.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
          price = double.parse(totalPrice);
        } else {
          String totalPrice = (double.parse(model.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
          price = double.parse(totalPrice);
        }
        model.singleProductPrice = double.parse(double.parse(price.toString()).toStringAsFixed(2));
        String priceWithQuantity = (double.parse(price.toString()) * model.quantity!).toStringAsFixed(2);
        price = double.parse(priceWithQuantity);
        model.totalPrice = price;

        String realPriceWithQuantity = (double.parse(realPrice.toString()) * model.quantity!).toStringAsFixed(2);
        realPrice = double.parse(realPriceWithQuantity);
        model.realPrice = realPrice;
        String restItemDiscountString = (double.parse(model.realPrice.toString()) - double.parse(price.toString())).toStringAsFixed(2);
        double restItemDiscount = double.parse(restItemDiscountString);
        model.itemDiscount = restItemDiscount;

        rawResults.add(model);
      }
    }

    return rawResults;
  }

  Future<List<FoodInCartModel>> getRepeatList(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();

    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      if (model.id == id) {
        rawResults.add(model);
      }
    }

    return rawResults;
  }

  Future<List<CartSummaryModel>> getCartSummary() async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();

    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    List<CartSummaryModel> cartSummary = <CartSummaryModel>[];
    rawResults.clear();
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      double price = 0.0;
      double addonPrice = 0.0;
      double variationPrice = 0.0;

      double realPrice = 0.0;
      double addonRealPrice = 0.0;
      double variationRealPrice = 0.0;

      for (var element in model.addons!) {
        String realPriceOfAddon = (double.parse(addonRealPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
        addonRealPrice = double.parse(realPriceOfAddon);

        if (element.haveDiscount!) {
          String price = (double.parse(addonPrice.toString()) + (double.parse(element.discountPrice.toString()))).toStringAsFixed(2);
          addonPrice = double.parse(price);
        } else {
          String price = (double.parse(addonPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
          addonPrice = double.parse(price);
        }
      }

      for (var variation in model.variations!) {
        for (var options in variation.options!) {
          String realPriceOfVariation = (double.parse(variationRealPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
          variationRealPrice = double.parse(realPriceOfVariation);

          if (options.haveDiscount!) {
            String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
            variationPrice = double.parse(price);
          } else {
            String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
            variationPrice = double.parse(price);
          }
        }
      }

      String realTotalPrice = (double.parse(model.price.toString()) + double.parse(realPrice.toString()) + (double.parse(addonRealPrice.toString())) + (double.parse(variationRealPrice.toString()))).toStringAsFixed(2);
      realPrice = double.parse(realTotalPrice);

      if (model.discount! > 0) {
        String totalPrice = (double.parse(model.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
        price = double.parse(totalPrice);
      } else {
        String totalPrice = (double.parse(model.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
        price = double.parse(totalPrice);
      }

      String realPriceWithQuantity = (double.parse(realPrice.toString()) * model.quantity!).toStringAsFixed(2);
      realPrice = double.parse(realPriceWithQuantity);

      String priceWithQuantity = (double.parse(price.toString()) * model.quantity!).toStringAsFixed(2);
      price = double.parse(priceWithQuantity);
      model.totalPrice = price;

      model.realPrice = realPrice;

      cart_summary_model.FoodRestaurantInfo restInfo = cart_summary_model.FoodRestaurantInfo.fromJson(model.restaurantInfo!.toJson(), appLocale);
      rawResults.add(model);
      int savedRestIndex = cartSummary.indexWhere((element) => element.restId == model.restaurant);
      if (savedRestIndex == -1) {
        CartSummaryModel obj = CartSummaryModel(restId: model.restaurant, restaurantInfo: restInfo, summary: [], locale: appLocale);
        cartSummary.add(obj);
      }
    }
    for (var cartObj in cartSummary) {
      double restTotal = 0.0;

      double restRealTotal = 0.0;

      int totalItemInCart = 0;
      for (var foodObj in rawResults) {
        if (cartObj.restId == foodObj.restaurant) {
          totalItemInCart = (totalItemInCart + foodObj.quantity!);
          cartObj.totalItemInCart = totalItemInCart;
          String countTotal = (double.parse(restTotal.toString()) + double.parse(foodObj.totalPrice.toString())).toStringAsFixed(2);
          restTotal = double.parse(countTotal);

          String countRealTotal = (double.parse(restRealTotal.toString()) + double.parse(foodObj.realPrice.toString())).toStringAsFixed(2);
          restRealTotal = double.parse(countRealTotal);

          cart_summary_model.FoodInCartSummaryModel foodData = cart_summary_model.FoodInCartSummaryModel.fromJson(foodObj.toJson(), appLocale);
          cartObj.summary!.add(foodData);
        }
      }

      cartObj.totalRestPrice = restTotal;

      cartObj.realRestPrice = restRealTotal;
      String restItemDiscountString = (double.parse(restRealTotal.toString()) - double.parse(restTotal.toString())).toStringAsFixed(2);
      double restItemDiscount = double.parse(restItemDiscountString);
      cartObj.restItemDiscount = restItemDiscount;
    }

    return cartSummary;
  }

  Future<void> addToCartLocal(FoodInCartModel item) async {
    try {
      List<String>? rawList = <String>[];
      if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
        rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
      }
      final String appLocale = await getLocale();
      List<FoodInCartModel> rawResults = <FoodInCartModel>[];
      for (var element in rawList!) {
        var items = jsonDecode(element);
        FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
        rawResults.add(model);
      }
      rawResults.add(item);
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<DioApiResponse> addToCartServer(CartItemRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.addToCartServer, body: param);
  }

  Future<void> updateCartItemIdFromServer(String uuid, String cartItemId) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();

    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.uuid == uuid);
    if (index != -1) {
      rawResults[index].cartItemId = cartItemId;
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<void> updateProductQuantityInCartLocal(String id, int quantity) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.id == id);
    if (index != -1) {
      rawResults[index].quantity = quantity;
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<DioApiResponse> updateProductQuantityInCartServer(UpdateCartFoodQuantityRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.updateFoodQuantityServer, body: param);
  }

  Future<void> updateProductVariationInCartLocal(String uuid, String id, int quantity) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.uuid == uuid && element.id == id);
    if (index != -1) {
      rawResults[index].quantity = quantity;
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<void> syncProductWithServer(String uuid, String id, FoodInCartModel product) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.uuid == uuid && element.id == id);
    if (index != -1) {
      rawResults[index] = product;
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<DioApiResponse> updateProductVariationInCartServer(UpdateCartFoodVariationQuantityRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.updateFoodVariationQuantityServer, body: param);
  }

  Future<void> removeFromCartLocal(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.id == id);
    if (index != -1) {
      rawResults.removeAt(index);
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<DioApiResponse> removeFromCartServer(RemoveFromCartWithFoodIdRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeCartItemWithFoodIDServer, body: param);
  }

  Future<void> removeFromCartWithRestaurant(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    rawResults.removeWhere((element) => element.restaurant == id);
    List<String> cartInString = [];
    for (var element in rawResults) {
      cartInString.add(jsonEncode(element));
    }
    await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
  }

  Future<DioApiResponse> removeFromCartWithRestaurantServer(RemoveCartItemByRestaurantRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeCartItemByRestaurantServer, body: param);
  }

  Future<void> clearCartItems() async {
    await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, []);
  }

  Future<DioApiResponse> clearCartItemServer(String tracking) async {
    return await _apiRequestService.delete('${ApiEndPoints.v1request.removeCartItemByTrackingServer}$tracking');
  }

  Future<void> removeFromCartWithUuidLocal(String uuid, String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      rawResults.add(model);
    }
    int index = rawResults.indexWhere((element) => element.uuid == uuid && element.id == id);
    if (index != -1) {
      rawResults.removeAt(index);
      List<String> cartInString = [];
      for (var element in rawResults) {
        cartInString.add(jsonEncode(element));
      }
      await _sharedPreferencesManager.putStringList(SharedPreferencesKey.publicKeys.savedInCart, cartInString);
    }
  }

  Future<DioApiResponse> removeFromCartWithUuidServer(RemoveFromCartWithUuidRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.removeCartItemWithUUIDServer, body: param);
  }

  Future<bool> checkProductInCart(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      if (model.id == id) {
        rawResults.add(model);
      }
    }
    return rawResults.where((element) => element.id == id).isNotEmpty;
  }

  Future<int>? getQuantity(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      if (model.id == id) {
        rawResults.add(model);
      }
    }

    List<FoodInCartModel> listOfSavedItems = <FoodInCartModel>[];
    listOfSavedItems = rawResults.where((element) => element.id == id).toList();
    int totalCount = 0;
    for (var element in listOfSavedItems) {
      totalCount = (int.parse(totalCount.toString()) + int.parse(element.quantity.toString()));
    }
    return totalCount;
  }

  Future<String>? getProductCartEntity(String id) async {
    List<String>? rawList = <String>[];
    if (await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.savedInCart)) {
      rawList = await _sharedPreferencesManager.getStringList(SharedPreferencesKey.publicKeys.savedInCart);
    }
    final String appLocale = await getLocale();
    List<FoodInCartModel> rawResults = <FoodInCartModel>[];
    for (var element in rawList!) {
      var items = jsonDecode(element);
      FoodInCartModel model = FoodInCartModel.fromJson(items, appLocale);
      if (model.id == id) {
        rawResults.add(model);
      }
    }
    List<FoodInCartModel> listOfSavedItems = <FoodInCartModel>[];
    listOfSavedItems = rawResults.where((element) => element.id == id).toList();
    if (listOfSavedItems.length > 1) {
      return 'multiple';
    }
    return 'single';
  }

  Future<String> checkoutAddressId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.checkoutAddressId) ?? '';
  }

  Future<String> getAddressTitle() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userAddressTitle) ?? '';
  }

  Future<String> getFullAddress() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userAddress) ?? '';
  }

  Future<DioApiResponse> getOrderSettings(OrderSettingsRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getOrderSettings, body: param);
  }

  /// Coverage pre-check (Batch G-3): does this kitchen deliver to the pin?
  /// Advisory — the server enforces at order creation; this only warns early.
  Future<DioApiResponse> restaurantCovers({
    required String restaurant,
    required double latitude,
    required double longitude,
  }) async {
    return await _apiRequestService.get(
      '${ApiEndPoints.v1request.restaurantCovers}$restaurant?latitude=$latitude&longitude=$longitude',
    );
  }

  Future<DioApiResponse> getUserCoupon(UserCouponRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.userCoupon, body: param);
  }

  Future<DioApiResponse> redeemCoupon(RedeemCouponRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.redeemCoupon, body: param);
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<DioApiResponse> placeOrder(PlaceOrderRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.placeOrder, body: param);
  }

  /// Convert a Razorpay initiation to COD (payment screen COD row).
  Future<DioApiResponse> switchToCod(String paymentId) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.switchToCod, body: {'paymentId': paymentId});
  }
}

