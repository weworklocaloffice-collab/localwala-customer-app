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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/models/cart_item_response_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/guest_account_status_response_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/restaurant_info_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/restaurant_info_response_model.dart';
import 'package:user/app/core/models/restaurant_modal_category_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/models/visited_campaign_detail_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:share_plus/share_plus.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final CartRepository _cartRepository = CartRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  RestaurantBloc() : super(RestaurantState(info: RestaurantInfoResponseModel(locale: ''))) {
    on<RestaurantInitialEvent>(_onRestaurantInitialEvent);
    on<RestaurantFavouriteEvent>(_onRestaurantFavouriteEvent);
    on<RestaurantShareEvent>(_onRestaurantShareEvent);
    on<RestaurantVariationModalResponseEvent>(_onRestaurantVariationModalResponseEvent);
    on<RestaurantFoodQuantityDecreaseEvent>(_onRestaurantFoodQuantityDecreaseEvent);
    on<RestaurantFoodQuantityIncreaseEvent>(_onRestaurantFoodQuantityIncreaseEvent);
    on<RestaurantAddCartEvent>(_onRestaurantAddCartEvent);
    on<RestaurantRepeatFoodOrderResponseEvent>(_onRestaurantRepeatFoodOrderResponseEvent);
    on<RestaurantFoodVariationModalRepeatResponseEvent>(_onRestaurantFoodVariationModalRepeatResponseEvent);
    on<RestaurantFoodModalResponseEvent>(_onRestaurantFoodModalResponseEvent);
    on<RestaurantToggleRecommendedViewEvent>(_onRestaurantToggleRecommendedViewEvent);
    on<RestaurantToggleCustomCategoryViewEvent>(_onRestaurantToggleCustomCategoryViewEvent);
    on<RestaurantToggleMainCategoryViewEvent>(_onRestaurantToggleMainCategoryViewEvent);
    on<RestaurantScrollToCategory>(_onRestaurantScrollToCategory);
    on<RestaurantRefreshCartEvent>(_onRestaurantRefreshCartEvent);
    on<RestaurantRefreshFoodFavEvent>(_onRestaurantRefreshFoodFavEvent);
    on<RestaurantHideEvent>(_onRestaurantHideEvent);
    on<RestaurantRefreshFavEvent>(_onRestaurantRefreshFavEvent);
    on<RestaurantRefreshCartDataEvent>(_onRestaurantRefreshCartDataEvent);
    on<RestaurantCheckoutEvent>(_onRestaurantCheckoutEvent);
    on<RestaurantChangeInitialEvent>(_onRestaurantChangeInitialEvent);
    on<RestaurantGuestCheckoutEvent>(_onRestaurantGuestCheckoutEvent);
    on<RestaurantClearCampaignEvent>(_onRestaurantClearCampaignEvent);
  }

  FutureOr<void> _onRestaurantInitialEvent(RestaurantInitialEvent event, Emitter<RestaurantState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_detail", "slug": event.slug, "name": event.name}, '${event.slug}_screen', '${event.slug}_screen');
      bool isAuthorized = await _restaurantRepository.isAuthorized();
      emit(state.copyWith(status: RestaurantStatus.loading, slug: event.slug, name: event.name, isAuthorized: isAuthorized, category: []));
      final String userId = await _restaurantRepository.userId();
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final VisitedCampaignDetailModel visitedCampaign = await _homeRepository.getVisitedCampaignDetail();
      RestaurantInfoRequestModel param = RestaurantInfoRequestModel(slug: event.slug, latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, uid: userId);
      DioApiResponse response = await _restaurantRepository.getRestaurantInfo(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: RestaurantStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          RestaurantInfoResponseModel data = RestaurantInfoResponseModel.fromJson(myMap, locale.toString());
          List<RestaurantModalCategoryModel> categoryList = <RestaurantModalCategoryModel>[];
          categoryList.clear();
          if (data.recommended!.isNotEmpty) {
            RestaurantModalCategoryModel recommended = RestaurantModalCategoryModel(id: 'recommended', name: 'Recommended', count: data.recommended!.length);
            categoryList.add(recommended);
          }
          final Map<String, GlobalKey> tempGlobalMainCategoriesKey = {};
          tempGlobalMainCategoriesKey['main_recommended'] = GlobalKey();
          for (var element in data.custom!) {
            RestaurantModalCategoryModel custom = RestaurantModalCategoryModel(id: element.categoryId, name: element.categoryName, count: element.foods!.length);
            categoryList.add(custom);
            tempGlobalMainCategoriesKey['main_${element.categoryId}'] = GlobalKey();
          }
          for (var element in data.main!) {
            RestaurantModalCategoryModel main = RestaurantModalCategoryModel(id: element.categoryId, name: element.categoryName, count: element.foods!.length);
            categoryList.add(main);
            tempGlobalMainCategoriesKey['main_${element.categoryId}'] = GlobalKey();
          }
          List<String> favIds = <String>[];
          for (var mainLoop in data.custom!) {
            for (var foodLoop in mainLoop.foods!) {
              if (foodLoop.isFavourite! == true) {
                favIds.add(foodLoop.id!);
              }
            }
          }
          for (var mainLoop in data.main!) {
            for (var foodLoop in mainLoop.foods!) {
              if (foodLoop.isFavourite! == true) {
                favIds.add(foodLoop.id!);
              }
            }
          }
          for (var foodLoop in data.recommended!) {
            if (foodLoop.isFavourite! == true) {
              favIds.add(foodLoop.id!);
            }
          }
          for (var main in data.custom!) {
            for (var element in main.foods!) {
              if (await _cartRepository.checkProductInCart(element.id!)) {
                final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
                element.quantity = quantityPromise;
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
                element.cartEntity = cartEntityPromise;
              } else {
                element.quantity = 0;
                element.cartEntity = 'single';
              }
            }
          }

          for (var main in data.main!) {
            for (var element in main.foods!) {
              if (await _cartRepository.checkProductInCart(element.id!)) {
                final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
                element.quantity = quantityPromise;
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
                element.cartEntity = cartEntityPromise;
              } else {
                element.quantity = 0;
                element.cartEntity = 'single';
              }
            }
          }

          for (var element in data.recommended!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          favIds = favIds.toSet().toList();
          if (categoryList.isNotEmpty) {
            emit(state.copyWith(categoryInView: categoryList[0].id));
          }
          for (var element in data.coupons!) {
            if (element.couponType! == 'default' || element.couponType! == 'restaurant' || element.couponType! == 'firstorder') {
              if (element.discountType == 'amount') {
                element.promoLbl = 'coupon_title_one';
                element.tExtraOne = kAppPriceFormat(element.minDiscount!);
              } else {
                element.promoLbl = element.maxDiscount! > 0 ? 'coupon_title_two' : 'coupon_title_two_half';
                element.tExtraOne = '${element.minDiscount!}%';
                element.tExtraTwo = element.maxDiscount! > 0 ? '${element.maxDiscount!}%' : '';
              }
            } else if (element.couponType! == 'loyality') {
              element.promoLbl = 'coupon_title_three';
              element.tExtraOne = '${element.loyalityPoints}';
            } else if (element.couponType! == 'bogo') {
              element.promoLbl = 'coupon_title_four';
            } else if (element.couponType! == 'freedelivery') {
              element.promoLbl = 'coupon_title_five';
            }
          }
          bool? guestCheckout = await _authRepository.isGuestCheckout();
          if (data.details!.temporaryClosed!) {
            emit(
              state.copyWith(status: RestaurantStatus.closed, guestCheckout: guestCheckout, info: data, category: categoryList, favIds: favIds, globalMainCategoriesKey: tempGlobalMainCategoriesKey, campaignId: visitedCampaign.id),
            );
            add(RestaurantRefreshCartDataEvent());
          } else {
            emit(
              state.copyWith(
                status: data.haveData! ? RestaurantStatus.success : RestaurantStatus.empty,
                guestCheckout: guestCheckout,
                info: data,
                category: categoryList,
                favIds: favIds,
                globalMainCategoriesKey: tempGlobalMainCategoriesKey,
                campaignId: visitedCampaign.id,
                appLocale: locale.toString(),
              ),
            );
            add(RestaurantRefreshCartDataEvent());
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantFavouriteEvent(RestaurantFavouriteEvent event, Emitter<RestaurantState> emit) async {
    final String userId = await _favouriteRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      if (state.info.details!.isFavourite == true) {
        state.info.details!.isFavourite = !state.info.details!.isFavourite!;
        emit(state.copyWith(info: state.info));
        try {
          DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, state.info.details!.id!);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: RestaurantStatus.favRemove));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            state.info.details!.isFavourite = !state.info.details!.isFavourite!;
            emit(state.copyWith(status: RestaurantStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), info: state.info));
          }
        } catch (e, stacktrace) {
          state.info.details!.isFavourite = !state.info.details!.isFavourite!;
          emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', info: state.info));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        state.info.details!.isFavourite = !state.info.details!.isFavourite!;
        emit(state.copyWith(info: state.info));
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'restaurant', restaurant: state.info.details!.id!, food: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              emit(state.copyWith(status: RestaurantStatus.favAdd));
            }
          } else {
            state.info.details!.isFavourite = !state.info.details!.isFavourite!;
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: RestaurantStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), info: state.info));
          }
        } catch (e, stacktrace) {
          state.info.details!.isFavourite = !state.info.details!.isFavourite!;
          emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', info: state.info));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  FutureOr<void> _onRestaurantShareEvent(RestaurantShareEvent event, Emitter<RestaurantState> emit) async {
    try {
      final String websiteURL = await _restaurantRepository.websiteURL();
      final String restaurantURL = '$websiteURL/${state.info.details!.slug!}?source=app_sharing';
      final String shareText = "Hello, I bet you’ll appreciate ordering from ${state.info.details!.name!} | ${state.info.details!.address!} $restaurantURL";
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantVariationModalResponseEvent(RestaurantVariationModalResponseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.info.recommended![index].quantity = event.data.cartItem!.quantity;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.recommended![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.recommended![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.recommended![index].name,
            shortDescription: state.info.recommended![index].shortDescription,
            image: state.info.recommended![index].image,
            restaurant: state.info.details!.id!,
            foodType: state.info.recommended![index].foodType,
            price: state.info.recommended![index].price,
            discountType: state.info.recommended![index].discountType,
            discount: state.info.recommended![index].discount,
            offerPrice: state.info.recommended![index].offerPrice,
            purchaseLimit: state.info.recommended![index].purchaseLimit,
            stockNumber: state.info.recommended![index].stockNumber,
            stockType: state.info.recommended![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.info.recommended![index].status,
            inStock: state.info.recommended![index].inStock,
            startTime: state.info.recommended![index].startTime,
            endTime: state.info.recommended![index].endTime,
            taxationEnable: state.info.recommended![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.recommended![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            state.info.recommended![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          state.info.custom![event.categoryIndex].foods![index].quantity = event.data.cartItem!.quantity;
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.custom![event.categoryIndex].foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.custom![event.categoryIndex].foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.custom![event.categoryIndex].foods![index].name,
            shortDescription: state.info.custom![event.categoryIndex].foods![index].shortDescription,
            image: state.info.custom![event.categoryIndex].foods![index].image,
            restaurant: state.info.details!.id,
            foodType: state.info.custom![event.categoryIndex].foods![index].foodType,
            price: state.info.custom![event.categoryIndex].foods![index].price,
            discountType: state.info.custom![event.categoryIndex].foods![index].discountType,
            discount: state.info.custom![event.categoryIndex].foods![index].discount,
            offerPrice: state.info.custom![event.categoryIndex].foods![index].offerPrice,
            purchaseLimit: state.info.custom![event.categoryIndex].foods![index].purchaseLimit,
            stockNumber: state.info.custom![event.categoryIndex].foods![index].stockNumber,
            stockType: state.info.custom![event.categoryIndex].foods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.info.custom![event.categoryIndex].foods![index].status,
            inStock: state.info.custom![event.categoryIndex].foods![index].inStock,
            startTime: state.info.custom![event.categoryIndex].foods![index].startTime,
            endTime: state.info.custom![event.categoryIndex].foods![index].endTime,
            taxationEnable: state.info.custom![event.categoryIndex].foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            state.info.custom![event.categoryIndex].foods![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.info.main![event.categoryIndex].foods![index].quantity = event.data.cartItem!.quantity;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.main![event.categoryIndex].foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.main![event.categoryIndex].foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.main![event.categoryIndex].foods![index].name,
            shortDescription: state.info.main![event.categoryIndex].foods![index].shortDescription,
            image: state.info.main![event.categoryIndex].foods![index].image,
            restaurant: state.info.details!.id,
            foodType: state.info.main![event.categoryIndex].foods![index].foodType,
            price: state.info.main![event.categoryIndex].foods![index].price,
            discountType: state.info.main![event.categoryIndex].foods![index].discountType,
            discount: state.info.main![event.categoryIndex].foods![index].discount,
            offerPrice: state.info.main![event.categoryIndex].foods![index].offerPrice,
            purchaseLimit: state.info.main![event.categoryIndex].foods![index].purchaseLimit,
            stockNumber: state.info.main![event.categoryIndex].foods![index].stockNumber,
            stockType: state.info.main![event.categoryIndex].foods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.info.main![event.categoryIndex].foods![index].status,
            inStock: state.info.main![event.categoryIndex].foods![index].inStock,
            startTime: state.info.main![event.categoryIndex].foods![index].startTime,
            endTime: state.info.main![event.categoryIndex].foods![index].endTime,
            taxationEnable: state.info.main![event.categoryIndex].foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            state.info.main![event.categoryIndex].foods![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantFoodQuantityDecreaseEvent(RestaurantFoodQuantityDecreaseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.recommended![index].quantity! > 1) {
            state.info.recommended![index].quantity = state.info.recommended![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.recommended![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.info.recommended![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.info.recommended![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.custom![event.categoryIndex].foods![index].quantity! > 1) {
            state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.custom![event.categoryIndex].foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              id: event.id,
              quantity: state.info.custom![event.categoryIndex].foods![index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.info.custom![event.categoryIndex].foods![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.main![event.categoryIndex].foods![index].quantity! > 1) {
            state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.main![event.categoryIndex].foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              id: event.id,
              quantity: state.info.main![event.categoryIndex].foods![index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.info.main![event.categoryIndex].foods![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantFoodQuantityIncreaseEvent(RestaurantFoodQuantityIncreaseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.recommended![index].quantity! < state.info.recommended![index].purchaseLimit!) {
            if (state.info.recommended![index].stockType! == 'unlimited') {
              state.info.recommended![index].quantity = state.info.recommended![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.recommended![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.info.recommended![index].quantity!);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.info.recommended![index].quantity! < state.info.recommended![index].stockNumber!) {
              state.info.recommended![index].quantity = state.info.recommended![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.recommended![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.info.recommended![index].quantity!);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.info.recommended![index].stockNumber!}'));
            }
          } else {
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.info.recommended![index].purchaseLimit}'));
          }
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.custom![event.categoryIndex].foods![index].quantity! < state.info.custom![event.categoryIndex].foods![index].purchaseLimit!) {
            if (state.info.custom![event.categoryIndex].foods![index].stockType! == 'unlimited') {
              state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.custom![event.categoryIndex].foods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.info.custom![event.categoryIndex].foods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.info.custom![event.categoryIndex].foods![index].quantity! < state.info.custom![event.categoryIndex].foods![index].stockNumber!) {
              state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.custom![event.categoryIndex].foods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.info.custom![event.categoryIndex].foods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(
                state.copyWith(
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                  extraMessage: '${state.info.custom![event.categoryIndex].foods![index].stockNumber!}',
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: RestaurantStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.info.custom![event.categoryIndex].foods![index].purchaseLimit}',
              ),
            );
          }
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.info.main![event.categoryIndex].foods![index].quantity! < state.info.main![event.categoryIndex].foods![index].purchaseLimit!) {
            if (state.info.main![event.categoryIndex].foods![index].stockType! == 'unlimited') {
              state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.main![event.categoryIndex].foods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.info.main![event.categoryIndex].foods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.info.main![event.categoryIndex].foods![index].quantity! < state.info.main![event.categoryIndex].foods![index].stockNumber!) {
              state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.info.main![event.categoryIndex].foods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.info.main![event.categoryIndex].foods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(
                state.copyWith(
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                  extraMessage: '${state.info.main![event.categoryIndex].foods![index].stockNumber!}',
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: RestaurantStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.info.main![event.categoryIndex].foods![index].purchaseLimit}',
              ),
            );
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantAddCartEvent(RestaurantAddCartEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.info.recommended![index].quantity = 1;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.recommended![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.recommended![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.recommended![index].name,
            shortDescription: state.info.recommended![index].shortDescription,
            image: state.info.recommended![index].image,
            restaurant: state.info.details!.id,
            foodType: state.info.recommended![index].foodType,
            price: state.info.recommended![index].price,
            discountType: state.info.recommended![index].discountType,
            discount: state.info.recommended![index].discount,
            offerPrice: state.info.recommended![index].offerPrice,
            purchaseLimit: state.info.recommended![index].purchaseLimit,
            stockNumber: state.info.recommended![index].stockNumber,
            stockType: state.info.recommended![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.info.recommended![index].status,
            inStock: state.info.recommended![index].inStock,
            startTime: state.info.recommended![index].startTime,
            endTime: state.info.recommended![index].endTime,
            taxationEnable: state.info.recommended![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.recommended![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            state.info.recommended![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.info.custom![event.categoryIndex].foods![index].quantity = 1;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.custom![event.categoryIndex].foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.custom![event.categoryIndex].foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.custom![event.categoryIndex].foods![index].name,
            shortDescription: state.info.custom![event.categoryIndex].foods![index].shortDescription,
            image: state.info.custom![event.categoryIndex].foods![index].image,
            restaurant: state.info.details!.id,
            foodType: state.info.custom![event.categoryIndex].foods![index].foodType,
            price: state.info.custom![event.categoryIndex].foods![index].price,
            discountType: state.info.custom![event.categoryIndex].foods![index].discountType,
            discount: state.info.custom![event.categoryIndex].foods![index].discount,
            offerPrice: state.info.custom![event.categoryIndex].foods![index].offerPrice,
            purchaseLimit: state.info.custom![event.categoryIndex].foods![index].purchaseLimit,
            stockNumber: state.info.custom![event.categoryIndex].foods![index].stockNumber,
            stockType: state.info.custom![event.categoryIndex].foods![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.info.custom![event.categoryIndex].foods![index].status,
            inStock: state.info.custom![event.categoryIndex].foods![index].inStock,
            startTime: state.info.custom![event.categoryIndex].foods![index].startTime,
            endTime: state.info.custom![event.categoryIndex].foods![index].endTime,
            taxationEnable: state.info.custom![event.categoryIndex].foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            state.info.custom![event.categoryIndex].foods![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.info.main![event.categoryIndex].foods![index].quantity = 1;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.info.main![event.categoryIndex].foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.info.main![event.categoryIndex].foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.info.main![event.categoryIndex].foods![index].name,
            shortDescription: state.info.main![event.categoryIndex].foods![index].shortDescription,
            image: state.info.main![event.categoryIndex].foods![index].image,
            restaurant: state.info.details!.id,
            foodType: state.info.main![event.categoryIndex].foods![index].foodType,
            price: state.info.main![event.categoryIndex].foods![index].price,
            discountType: state.info.main![event.categoryIndex].foods![index].discountType,
            discount: state.info.main![event.categoryIndex].foods![index].discount,
            offerPrice: state.info.main![event.categoryIndex].foods![index].offerPrice,
            purchaseLimit: state.info.main![event.categoryIndex].foods![index].purchaseLimit,
            stockNumber: state.info.main![event.categoryIndex].foods![index].stockNumber,
            stockType: state.info.main![event.categoryIndex].foods![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.info.main![event.categoryIndex].foods![index].status,
            inStock: state.info.main![event.categoryIndex].foods![index].inStock,
            startTime: state.info.main![event.categoryIndex].foods![index].startTime,
            endTime: state.info.main![event.categoryIndex].foods![index].endTime,
            taxationEnable: state.info.main![event.categoryIndex].foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
          add(RestaurantRefreshCartDataEvent());

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            campaignId: state.campaignId,
            campaignType: 'restaurant',
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            state.info.main![event.categoryIndex].foods![index].quantity = 0;
            emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantRepeatFoodOrderResponseEvent(RestaurantRepeatFoodOrderResponseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.info.recommended!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
        emit(state.copyWith(info: state.info, status: RestaurantStatus.cartUpdate));
        add(RestaurantRefreshCartDataEvent());
      } else if (event.from == 'custom') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.info.custom![event.categoryIndex].foods!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
        emit(state.copyWith(info: state.info, status: RestaurantStatus.cartUpdate));
        add(RestaurantRefreshCartDataEvent());
      } else if (event.from == 'main') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.info.main![event.categoryIndex].foods!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
        emit(state.copyWith(info: state.info, status: RestaurantStatus.cartUpdate));
        add(RestaurantRefreshCartDataEvent());
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantFoodVariationModalRepeatResponseEvent(RestaurantFoodVariationModalRepeatResponseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.recommended![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.info.recommended![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.recommended![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.recommended![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.recommended![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (state.info.recommended![index].quantity! < state.info.recommended![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.recommended![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.recommended![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.recommended![index].quantity = state.info.recommended![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.recommended![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.recommended![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.recommended![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.recommended![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.recommended![index].quantity = state.info.recommended![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.recommended![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.recommended![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.recommended![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.recommended![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.recommended![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.recommended![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.recommended![index].name,
              shortDescription: state.info.recommended![index].shortDescription,
              image: state.info.recommended![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.recommended![index].foodType,
              price: state.info.recommended![index].price,
              discountType: state.info.recommended![index].discountType,
              discount: state.info.recommended![index].discount,
              offerPrice: state.info.recommended![index].offerPrice,
              purchaseLimit: state.info.recommended![index].purchaseLimit,
              stockNumber: state.info.recommended![index].stockNumber,
              stockType: state.info.recommended![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.recommended![index].status,
              inStock: state.info.recommended![index].inStock,
              startTime: state.info.recommended![index].startTime,
              endTime: state.info.recommended![index].endTime,
              taxationEnable: state.info.recommended![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.info.recommended![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              state.info.recommended![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.custom![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.info.custom![event.categoryIndex].foods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.custom![event.categoryIndex].foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.info.custom![event.categoryIndex].foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.custom![event.categoryIndex].foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.custom![event.categoryIndex].foods![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.custom![event.categoryIndex].foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.custom![event.categoryIndex].foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.custom![event.categoryIndex].foods![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.custom![event.categoryIndex].foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.custom![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.custom![event.categoryIndex].foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.custom![event.categoryIndex].foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.custom![event.categoryIndex].foods![index].name,
              shortDescription: state.info.custom![event.categoryIndex].foods![index].shortDescription,
              image: state.info.custom![event.categoryIndex].foods![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.custom![event.categoryIndex].foods![index].foodType,
              price: state.info.custom![event.categoryIndex].foods![index].price,
              discountType: state.info.custom![event.categoryIndex].foods![index].discountType,
              discount: state.info.custom![event.categoryIndex].foods![index].discount,
              offerPrice: state.info.custom![event.categoryIndex].foods![index].offerPrice,
              purchaseLimit: state.info.custom![event.categoryIndex].foods![index].purchaseLimit,
              stockNumber: state.info.custom![event.categoryIndex].foods![index].stockNumber,
              stockType: state.info.custom![event.categoryIndex].foods![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.custom![event.categoryIndex].foods![index].status,
              inStock: state.info.custom![event.categoryIndex].foods![index].inStock,
              startTime: state.info.custom![event.categoryIndex].foods![index].startTime,
              endTime: state.info.custom![event.categoryIndex].foods![index].endTime,
              taxationEnable: state.info.custom![event.categoryIndex].foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              state.info.custom![event.categoryIndex].foods![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();

          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.main![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.info.main![event.categoryIndex].foods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.main![event.categoryIndex].foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.main![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.info.main![event.categoryIndex].foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.main![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.main![event.categoryIndex].foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.main![event.categoryIndex].foods![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.main![event.categoryIndex].foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.main![event.categoryIndex].foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.main![event.categoryIndex].foods![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.main![event.categoryIndex].foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.main![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.main![event.categoryIndex].foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.main![event.categoryIndex].foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.main![event.categoryIndex].foods![index].name,
              shortDescription: state.info.main![event.categoryIndex].foods![index].shortDescription,
              image: state.info.main![event.categoryIndex].foods![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.main![event.categoryIndex].foods![index].foodType,
              price: state.info.main![event.categoryIndex].foods![index].price,
              discountType: state.info.main![event.categoryIndex].foods![index].discountType,
              discount: state.info.main![event.categoryIndex].foods![index].discount,
              offerPrice: state.info.main![event.categoryIndex].foods![index].offerPrice,
              purchaseLimit: state.info.main![event.categoryIndex].foods![index].purchaseLimit,
              stockNumber: state.info.main![event.categoryIndex].foods![index].stockNumber,
              stockType: state.info.main![event.categoryIndex].foods![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.main![event.categoryIndex].foods![index].status,
              inStock: state.info.main![event.categoryIndex].foods![index].inStock,
              startTime: state.info.main![event.categoryIndex].foods![index].startTime,
              endTime: state.info.main![event.categoryIndex].foods![index].endTime,
              taxationEnable: state.info.main![event.categoryIndex].foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.info.main![event.categoryIndex].foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              state.info.main![event.categoryIndex].foods![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantFoodModalResponseEvent(RestaurantFoodModalResponseEvent event, Emitter<RestaurantState> emit) async {
    try {
      if (event.from == 'recommended') {
        int index = state.info.recommended!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.recommended![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.info.recommended![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.recommended![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.recommended![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.recommended![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.info.recommended![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.recommended![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.recommended![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.recommended![index].quantity = state.info.recommended![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.recommended![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.recommended![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.recommended![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.recommended![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.recommended![index].quantity = state.info.recommended![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.recommended![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.recommended![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.recommended![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.recommended![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.recommended![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.recommended![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.recommended![index].name,
              shortDescription: state.info.recommended![index].shortDescription,
              image: state.info.recommended![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.recommended![index].foodType,
              price: state.info.recommended![index].price,
              discountType: state.info.recommended![index].discountType,
              discount: state.info.recommended![index].discount,
              offerPrice: state.info.recommended![index].offerPrice,
              purchaseLimit: state.info.recommended![index].purchaseLimit,
              stockNumber: state.info.recommended![index].stockNumber,
              stockType: state.info.recommended![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.recommended![index].status,
              inStock: state.info.recommended![index].inStock,
              startTime: state.info.recommended![index].startTime,
              endTime: state.info.recommended![index].endTime,
              taxationEnable: state.info.recommended![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.info.recommended![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.recommended![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.recommended![index].cartEntity = cartEntityPromise;
              state.info.recommended![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.info.recommended![index].isFavourite! != event.response.isFavourite) {
          state.info.recommended![index].isFavourite = !state.info.recommended![index].isFavourite!;
          if (state.info.recommended![index].isFavourite == true) {
            state.favIds.add(event.id);
          } else {
            state.favIds.removeWhere((element) => element == event.id);
          }
          emit(state.copyWith(status: RestaurantStatus.favFoodUpdate, info: state.info, favIds: state.favIds));
        }
      } else if (event.from == 'custom') {
        int index = state.info.custom![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.custom![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.info.custom![event.categoryIndex].foods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.custom![event.categoryIndex].foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.info.custom![event.categoryIndex].foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.custom![event.categoryIndex].foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.custom![event.categoryIndex].foods![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.custom![event.categoryIndex].foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.custom![event.categoryIndex].foods![index].quantity = state.info.custom![event.categoryIndex].foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.custom![event.categoryIndex].foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.custom![event.categoryIndex].foods![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.custom![event.categoryIndex].foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.custom![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.custom![event.categoryIndex].foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.custom![event.categoryIndex].foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.custom![event.categoryIndex].foods![index].name,
              shortDescription: state.info.custom![event.categoryIndex].foods![index].shortDescription,
              image: state.info.custom![event.categoryIndex].foods![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.custom![event.categoryIndex].foods![index].foodType,
              price: state.info.custom![event.categoryIndex].foods![index].price,
              discountType: state.info.custom![event.categoryIndex].foods![index].discountType,
              discount: state.info.custom![event.categoryIndex].foods![index].discount,
              offerPrice: state.info.custom![event.categoryIndex].foods![index].offerPrice,
              purchaseLimit: state.info.custom![event.categoryIndex].foods![index].purchaseLimit,
              stockNumber: state.info.custom![event.categoryIndex].foods![index].stockNumber,
              stockType: state.info.custom![event.categoryIndex].foods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.custom![event.categoryIndex].foods![index].status,
              inStock: state.info.custom![event.categoryIndex].foods![index].inStock,
              startTime: state.info.custom![event.categoryIndex].foods![index].startTime,
              endTime: state.info.custom![event.categoryIndex].foods![index].endTime,
              taxationEnable: state.info.custom![event.categoryIndex].foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.info.custom![event.categoryIndex].foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.custom![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              state.info.custom![event.categoryIndex].foods![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.info.custom![event.categoryIndex].foods![index].isFavourite! != event.response.isFavourite) {
          state.info.custom![event.categoryIndex].foods![index].isFavourite = !state.info.custom![event.categoryIndex].foods![index].isFavourite!;
          if (state.info.custom![event.categoryIndex].foods![index].isFavourite == true) {
            state.favIds.add(event.id);
          } else {
            state.favIds.removeWhere((element) => element == event.id);
          }
          emit(state.copyWith(status: RestaurantStatus.favFoodUpdate, info: state.info, favIds: state.favIds));
        }
      } else if (event.from == 'main') {
        int index = state.info.main![event.categoryIndex].foods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.info.details!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.info.details!.id!;
          restaurantInfo.slug = state.info.details!.slug!;
          restaurantInfo.name = state.info.details!.name!;
          restaurantInfo.cover = state.info.details!.cover!;
          restaurantInfo.logo = state.info.details!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.info.main![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.info.main![event.categoryIndex].foods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.info.main![event.categoryIndex].foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.main![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.info.main![event.categoryIndex].foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.info.main![event.categoryIndex].foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
                add(RestaurantRefreshCartDataEvent());
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.main![event.categoryIndex].foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      info: state.info,
                      status: RestaurantStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.info.main![event.categoryIndex].foods![index].stockNumber!}',
                    ),
                  );
                  add(RestaurantRefreshCartDataEvent());
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.info.main![event.categoryIndex].foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.info.main![event.categoryIndex].foods![index].quantity = state.info.main![event.categoryIndex].foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.info.main![event.categoryIndex].foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  info: state.info,
                  status: RestaurantStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.info.main![event.categoryIndex].foods![index].purchaseLimit!}',
                ),
              );
              add(RestaurantRefreshCartDataEvent());
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.info.main![event.categoryIndex].foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.info.main![event.categoryIndex].foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.info.main![event.categoryIndex].foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.info.main![event.categoryIndex].foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.info.main![event.categoryIndex].foods![index].name,
              shortDescription: state.info.main![event.categoryIndex].foods![index].shortDescription,
              image: state.info.main![event.categoryIndex].foods![index].image,
              restaurant: state.info.details!.id,
              foodType: state.info.main![event.categoryIndex].foods![index].foodType,
              price: state.info.main![event.categoryIndex].foods![index].price,
              discountType: state.info.main![event.categoryIndex].foods![index].discountType,
              discount: state.info.main![event.categoryIndex].foods![index].discount,
              offerPrice: state.info.main![event.categoryIndex].foods![index].offerPrice,
              purchaseLimit: state.info.main![event.categoryIndex].foods![index].purchaseLimit,
              stockNumber: state.info.main![event.categoryIndex].foods![index].stockNumber,
              stockType: state.info.main![event.categoryIndex].foods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.info.main![event.categoryIndex].foods![index].status,
              inStock: state.info.main![event.categoryIndex].foods![index].inStock,
              startTime: state.info.main![event.categoryIndex].foods![index].startTime,
              endTime: state.info.main![event.categoryIndex].foods![index].endTime,
              taxationEnable: state.info.main![event.categoryIndex].foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.info.main![event.categoryIndex].foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: RestaurantStatus.cartUpdate, info: state.info));
            add(RestaurantRefreshCartDataEvent());

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              campaignId: state.campaignId,
              campaignType: 'restaurant',
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.info.main![event.categoryIndex].foods![index].cartEntity = cartEntityPromise;
              state.info.main![event.categoryIndex].foods![index].quantity = 0;
              emit(state.copyWith(status: RestaurantStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.info.main![event.categoryIndex].foods![index].isFavourite! != event.response.isFavourite) {
          state.info.main![event.categoryIndex].foods![index].isFavourite = !state.info.main![event.categoryIndex].foods![index].isFavourite!;
          if (state.info.main![event.categoryIndex].foods![index].isFavourite == true) {
            state.favIds.add(event.id);
          } else {
            state.favIds.removeWhere((element) => element == event.id);
          }
          emit(state.copyWith(status: RestaurantStatus.favFoodUpdate, info: state.info, favIds: state.favIds));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantToggleRecommendedViewEvent(RestaurantToggleRecommendedViewEvent event, Emitter<RestaurantState> emit) async {
    bool toggleView = !state.isRecommendedOpen;
    emit(state.copyWith(isRecommendedOpen: toggleView, status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantToggleCustomCategoryViewEvent(RestaurantToggleCustomCategoryViewEvent event, Emitter<RestaurantState> emit) async {
    state.info.custom![event.categoryIndex].isOpen = !state.info.custom![event.categoryIndex].isOpen;
    emit(state.copyWith(info: state.info, status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantToggleMainCategoryViewEvent(RestaurantToggleMainCategoryViewEvent event, Emitter<RestaurantState> emit) async {
    state.info.main![event.categoryIndex].isOpen = !state.info.main![event.categoryIndex].isOpen;
    emit(state.copyWith(info: state.info, status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantScrollToCategory(RestaurantScrollToCategory event, Emitter<RestaurantState> emit) async {
    emit(state.copyWith(categoryInView: event.categoryId, status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantRefreshCartEvent(RestaurantRefreshCartEvent event, Emitter<RestaurantState> emit) async {
    for (var main in state.info.custom!) {
      for (var element in main.foods!) {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      }
    }

    for (var main in state.info.main!) {
      for (var element in main.foods!) {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      }
    }

    for (var element in state.info.recommended!) {
      if (await _cartRepository.checkProductInCart(element.id!)) {
        final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
        element.quantity = quantityPromise;
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
        element.cartEntity = cartEntityPromise;
      } else {
        element.quantity = 0;
        element.cartEntity = 'single';
      }
    }
    emit(state.copyWith(status: RestaurantStatus.success, info: state.info));
    add(RestaurantRefreshCartDataEvent());
  }

  FutureOr<void> _onRestaurantRefreshFoodFavEvent(RestaurantRefreshFoodFavEvent event, Emitter<RestaurantState> emit) async {
    for (var food in state.info.custom!) {
      for (var element in food.foods!) {
        if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
          element.isFavourite = true;
        } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
          element.isFavourite = false;
        } else if (event.inFavList.contains(element.id)) {
          element.isFavourite = true;
        }
      }
    }

    for (var food in state.info.main!) {
      for (var element in food.foods!) {
        if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
          element.isFavourite = true;
        } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
          element.isFavourite = false;
        } else if (event.inFavList.contains(element.id)) {
          element.isFavourite = true;
        }
      }
    }

    for (var element in state.info.recommended!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    emit(state.copyWith(status: RestaurantStatus.success, info: state.info));
  }

  FutureOr<void> _onRestaurantHideEvent(RestaurantHideEvent event, Emitter<RestaurantState> emit) async {
    if (state.info.details!.isHidden! == false) {
      try {
        emit(state.copyWith(status: RestaurantStatus.startHide));
        final String userId = await _restaurantRepository.userId();
        HideRestaurantRequestModel param = HideRestaurantRequestModel(user: userId, restaurant: state.info.details!.id!);
        DioApiResponse response = await _homeRepository.hideRestaurant(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: RestaurantStatus.hideRequestFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            state.info.details!.isHidden = !state.info.details!.isHidden!;
            emit(state.copyWith(status: RestaurantStatus.hideSuccess, info: state.info));
            emit(state.copyWith(status: state.info.haveData! ? RestaurantStatus.success : RestaurantStatus.empty));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RestaurantStatus.hideRequestFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RestaurantStatus.hideRequestFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      try {
        emit(state.copyWith(status: RestaurantStatus.startUnhide));
        final String userId = await _homeRepository.userId();
        ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: state.info.details!.id!);
        DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: RestaurantStatus.unHideRequestFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            state.info.details!.isHidden = !state.info.details!.isHidden!;
            emit(state.copyWith(status: RestaurantStatus.unHideSuccess, info: state.info));
            emit(state.copyWith(status: state.info.haveData! ? RestaurantStatus.success : RestaurantStatus.empty));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RestaurantStatus.unHideRequestFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RestaurantStatus.unHideRequestFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onRestaurantRefreshFavEvent(RestaurantRefreshFavEvent event, Emitter<RestaurantState> emit) async {
    state.info.details!.isFavourite = !state.info.details!.isFavourite!;
    emit(state.copyWith(info: state.info, status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantRefreshCartDataEvent(RestaurantRefreshCartDataEvent event, Emitter<RestaurantState> emit) async {
    for (var main in state.info.custom!) {
      // ignore: avoid_function_literals_in_foreach_calls
      main.foods!.forEach((element) async {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      });
    }

    for (var main in state.info.main!) {
      // ignore: avoid_function_literals_in_foreach_calls
      main.foods!.forEach((element) async {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      });
    }

    // ignore: avoid_function_literals_in_foreach_calls
    state.info.recommended!.forEach((element) async {
      if (await _cartRepository.checkProductInCart(element.id!)) {
        final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
        element.quantity = quantityPromise;
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
        element.cartEntity = cartEntityPromise;
      } else {
        element.quantity = 0;
        element.cartEntity = 'single';
      }
    });

    double cartTotalAmount = 0;
    int cartTotalItem = 0;
    await _cartRepository.getByRestaurant(state.info.details!.id!).then((value) {
      for (var element in value) {
        cartTotalItem = cartTotalItem + element.quantity!;
        String countTotal = (double.parse(cartTotalAmount.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
        cartTotalAmount = double.parse(countTotal);
      }
    });
    String cartSubTitleText = '';
    String cartHelpOne = '';
    String cartHelpTwo = '';
    String cartHelpThree = '';
    if (cartTotalAmount >= state.info.businessSettings!.freeDelivery! && state.info.businessSettings!.haveFreeDeliveryInTotal!) {
      cartSubTitleText = 'cart_help_one';
    }
    if (cartSubTitleText.isEmpty) {
      for (var coupon in state.info.coupons!) {
        if (cartTotalAmount >= coupon.minCartTotal!) {
          if (coupon.couponType! == 'default' || coupon.couponType! == 'restaurant' || coupon.couponType! == 'firstorder') {
            if (coupon.discountType == 'amount') {
              cartSubTitleText = 'cart_help_two';
              cartHelpOne = coupon.code!;
              cartHelpTwo = kAppPriceFormat(coupon.minDiscount!);
            } else {
              if (coupon.maxDiscount! > 0) {
                cartSubTitleText = 'cart_help_three';
                cartHelpOne = coupon.code!;
                cartHelpTwo = '${coupon.minDiscount!}%';
                cartHelpThree = '${coupon.maxDiscount!}%';
              } else {
                cartSubTitleText = 'cart_help_two';
                cartHelpOne = coupon.code!;
                cartHelpTwo = '${coupon.minDiscount!}%';
              }
            }
          } else if (coupon.couponType! == 'loyality') {
            cartSubTitleText = 'cart_help_four';
            cartHelpOne = coupon.code!;
            cartHelpTwo = '${coupon.loyalityPoints!}';
          } else if (coupon.couponType! == 'bogo') {
            cartSubTitleText = 'cart_help_five';
            cartHelpOne = coupon.code!;
          } else if (coupon.couponType! == 'freedelivery') {
            cartSubTitleText = 'cart_help_six';
            cartHelpOne = coupon.code!;
          }
        }
      }
    }
    if (cartSubTitleText.isEmpty) {
      cartSubTitleText = 'cart_help_seven';
    }
    emit(state.copyWith(cartTotalItem: cartTotalItem, cartTotalAmount: cartTotalAmount, cartSubTitle: cartSubTitleText, cartHelpOne: cartHelpOne, cartHelpTwo: cartHelpTwo, cartHelpThree: cartHelpThree));
  }

  FutureOr<void> _onRestaurantCheckoutEvent(RestaurantCheckoutEvent event, Emitter<RestaurantState> emit) async {
    bool isAuthorized = await _cartRepository.isAuthorized();
    emit(state.copyWith(status: isAuthorized ? RestaurantStatus.authorized : RestaurantStatus.unauthorized));
  }

  FutureOr<void> _onRestaurantChangeInitialEvent(RestaurantChangeInitialEvent event, Emitter<RestaurantState> emit) async {
    emit(state.copyWith(status: RestaurantStatus.success));
  }

  FutureOr<void> _onRestaurantGuestCheckoutEvent(RestaurantGuestCheckoutEvent event, Emitter<RestaurantState> emit) async {
    try {
      emit(state.copyWith(status: RestaurantStatus.guestCheckoutStart));
      String userAgent = 'unknown';
      if (kIsWeb) {
        userAgent = 'browser';
      } else if (Platform.isAndroid) {
        userAgent = 'android';
      } else if (Platform.isIOS) {
        userAgent = 'ios';
      }
      final String appLocale = await _authRepository.getLocale();
      DioApiResponse response = await _authRepository.registerGuestAccount(userAgent, appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        GuestAccountStatusResponseModel initialResponse = GuestAccountStatusResponseModel.fromJson(myMap);
        if (!initialResponse.signup!) {
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveLoginResponse(data);
          emit(state.copyWith(status: RestaurantStatus.guestCheckoutSuccess));
        } else {
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          emit(state.copyWith(status: RestaurantStatus.guestCheckoutSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantStatus.guestCheckoutFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantStatus.guestCheckoutFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantClearCampaignEvent(RestaurantClearCampaignEvent event, Emitter<RestaurantState> emit) async {
    await _homeRepository.clearVisitedCampaignDetail();
  }
}

