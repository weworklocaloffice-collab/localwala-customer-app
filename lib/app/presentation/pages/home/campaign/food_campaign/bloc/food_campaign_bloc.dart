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

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/cart_item_response_model.dart';
import 'package:user/app/core/models/food_campaign_detail_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/models/request/food_campaign_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_campaign_event.dart';
part 'food_campaign_state.dart';

class FoodCampaignBloc extends Bloc<FoodCampaignEvent, FoodCampaignState> {
  final HomeRepository _homeRepository = HomeRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  FoodCampaignBloc() : super(FoodCampaignState(campaign: FoodCampaignDetailModel(locale: ''))) {
    on<FoodCampaignInitialEvent>(_onFoodCampaignInitialEvent);
    on<FoodCampaignFavouriteEvent>(_onFoodCampaignFavouriteEvent);
    on<FoodCampaignVariationModalResponseEvent>(_onFoodCampaignVariationModalResponseEvent);
    on<FoodCampaignFoodQuantityDecreaseEvent>(_onFoodCampaignFoodQuantityDecreaseEvent);
    on<FoodCampaignFoodQuantityIncreaseEvent>(_onFoodCampaignFoodQuantityIncreaseEvent);
    on<FoodCampaignAddCartEvent>(_onFoodCampaignAddCartEvent);
    on<FoodCampaignRepeatFoodOrderResponseEvent>(_onFoodCampaignRepeatFoodOrderResponseEvent);
    on<FoodCampaignFoodVariationModalRepeatResponseEvent>(_onFoodCampaignFoodVariationModalRepeatResponseEvent);
    on<FoodCampaignFoodModalResponseEvent>(_onFoodCampaignFoodModalResponseEvent);
  }

  FutureOr<void> _onFoodCampaignInitialEvent(FoodCampaignInitialEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "food_campaign", "id": event.id}, 'food_campaign_${event.id}_screen', 'food_campaign_${event.id}_screen');
      emit(state.copyWith(status: FoodCampaignStatus.loading));
      final String userId = await _homeRepository.userId();
      FoodCampaignRequestModel param = FoodCampaignRequestModel(campaignId: event.id, uid: userId);
      DioApiResponse response = await _homeRepository.getFoodCampaignDetails(event.id, param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        FoodCampaignDetailModel data = FoodCampaignDetailModel.fromJson(myMap, locale.toString());
        List<String> favIds = <String>[];
        for (var element in data.inCampaign!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
          if (element.isFavourite!) {
            favIds.add(element.id!);
          }
        }

        emit(state.copyWith(status: FoodCampaignStatus.success, appLocale: locale.toString(), campaign: data, favIds: favIds));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FoodCampaignStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignFavouriteEvent(FoodCampaignFavouriteEvent event, Emitter<FoodCampaignState> emit) async {
    final String userId = await _homeRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      updateFavouriteData(event.id);
      emit(state.copyWith(campaign: state.campaign));
      if (event.isFavourite == false) {
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'food', food: event.id, restaurant: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              state.favIds.add(event.id);
              emit(state.copyWith(status: FoodCampaignStatus.favUpdate, favIds: state.favIds));
            }
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(campaign: state.campaign));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(campaign: state.campaign));
          emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        try {
          final String userId = await _favouriteRepository.userId();
          DioApiResponse response = await _favouriteRepository.deleteFavouriteFood(userId, event.id);
          if (response.errorType == NetErrorType.none) {
            state.favIds.removeWhere((element) => element == event.id);
            emit(state.copyWith(status: FoodCampaignStatus.favUpdate, favIds: state.favIds));
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(campaign: state.campaign));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(campaign: state.campaign));
          emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  Future<void> updateFavouriteData(String id) async {
    int index = state.campaign.inCampaign!.indexWhere((element) => element.id == id);
    if (index != -1) {
      if (state.campaign.inCampaign![index].isFavourite == false) {
        state.campaign.inCampaign![index].isFavourite = true;
      } else {
        state.campaign.inCampaign![index].isFavourite = false;
      }
    }
  }

  FutureOr<void> _onFoodCampaignVariationModalResponseEvent(FoodCampaignVariationModalResponseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final String locale = await _authRepository.getLocale();
        state.campaign.inCampaign![index].quantity = event.data.cartItem!.quantity;
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.campaign.inCampaign![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.campaign.inCampaign![index].restaurants!.id!;
        restaurantInfo.slug = state.campaign.inCampaign![index].restaurants!.slug!;
        restaurantInfo.name = state.campaign.inCampaign![index].restaurants!.name!;
        restaurantInfo.cover = state.campaign.inCampaign![index].restaurants!.cover!;
        restaurantInfo.logo = state.campaign.inCampaign![index].restaurants!.logo!;
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
        for (var element in state.campaign.inCampaign![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.campaign.inCampaign![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.campaign.inCampaign![index].name,
          shortDescription: state.campaign.inCampaign![index].shortDescription,
          image: state.campaign.inCampaign![index].image,
          restaurant: state.campaign.inCampaign![index].restaurant,
          foodType: state.campaign.inCampaign![index].foodType,
          price: state.campaign.inCampaign![index].price,
          discountType: state.campaign.inCampaign![index].discountType,
          discount: state.campaign.inCampaign![index].discount,
          offerPrice: state.campaign.inCampaign![index].offerPrice,
          purchaseLimit: state.campaign.inCampaign![index].purchaseLimit,
          stockNumber: state.campaign.inCampaign![index].stockNumber,
          stockType: state.campaign.inCampaign![index].stockType,
          quantity: event.data.cartItem!.quantity,
          id: event.id,
          addons: savedAddon,
          variations: savedVariations,
          restaurantInfo: restaurantInfo,
          translations: savedFoodTranslation,
          status: state.campaign.inCampaign![index].status,
          inStock: state.campaign.inCampaign![index].inStock,
          startTime: state.campaign.inCampaign![index].startTime,
          endTime: state.campaign.inCampaign![index].endTime,
          taxationEnable: state.campaign.inCampaign![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: event.data.instruction!,
          locale: locale.toString(),
        );

        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));

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
          campaignId: state.campaign.detail!.id!,
          campaignType: 'food',
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
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          state.campaign.inCampaign![index].quantity = 0;
          emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignFoodQuantityDecreaseEvent(FoodCampaignFoodQuantityDecreaseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.campaign.inCampaign![index].quantity! > 1) {
          state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].quantity! - 1;
          await _cartRepository.updateProductQuantityInCartLocal(event.id, state.campaign.inCampaign![index].quantity!);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
          UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.campaign.inCampaign![index].quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          state.campaign.inCampaign![index].quantity = 0;
          await _cartRepository.removeFromCartLocal(event.id);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
          RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignFoodQuantityIncreaseEvent(FoodCampaignFoodQuantityIncreaseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.campaign.inCampaign![index].quantity! < state.campaign.inCampaign![index].purchaseLimit!) {
          if (state.campaign.inCampaign![index].stockType! == 'unlimited') {
            state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.campaign.inCampaign![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.campaign.inCampaign![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else if (state.campaign.inCampaign![index].quantity! < state.campaign.inCampaign![index].stockNumber!) {
            state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.campaign.inCampaign![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.campaign.inCampaign![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.campaign.inCampaign![index].stockNumber!}'));
          }
        } else {
          emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.campaign.inCampaign![index].purchaseLimit}'));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignAddCartEvent(FoodCampaignAddCartEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        state.campaign.inCampaign![index].quantity = 1;
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.campaign.inCampaign![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.campaign.inCampaign![index].restaurants!.id!;
        restaurantInfo.slug = state.campaign.inCampaign![index].restaurants!.slug!;
        restaurantInfo.name = state.campaign.inCampaign![index].restaurants!.name!;
        restaurantInfo.cover = state.campaign.inCampaign![index].restaurants!.cover!;
        restaurantInfo.logo = state.campaign.inCampaign![index].restaurants!.logo!;
        restaurantInfo.translations = restaurantTranslation;

        List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
        savedFoodTranslation.clear();

        for (var element in state.campaign.inCampaign![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.campaign.inCampaign![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.campaign.inCampaign![index].name,
          shortDescription: state.campaign.inCampaign![index].shortDescription,
          image: state.campaign.inCampaign![index].image,
          restaurant: state.campaign.inCampaign![index].restaurant,
          foodType: state.campaign.inCampaign![index].foodType,
          price: state.campaign.inCampaign![index].price,
          discountType: state.campaign.inCampaign![index].discountType,
          discount: state.campaign.inCampaign![index].discount,
          offerPrice: state.campaign.inCampaign![index].offerPrice,
          purchaseLimit: state.campaign.inCampaign![index].purchaseLimit,
          stockNumber: state.campaign.inCampaign![index].stockNumber,
          stockType: state.campaign.inCampaign![index].stockType,
          quantity: 1,
          id: event.id,
          addons: [],
          variations: [],
          translations: savedFoodTranslation,
          restaurantInfo: restaurantInfo,
          status: state.campaign.inCampaign![index].status,
          inStock: state.campaign.inCampaign![index].inStock,
          startTime: state.campaign.inCampaign![index].startTime,
          endTime: state.campaign.inCampaign![index].endTime,
          taxationEnable: state.campaign.inCampaign![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: '',
          locale: locale.toString(),
        );
        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));

        CartItemRequestModel onlineCartParam = CartItemRequestModel(
          user: await _cartRepository.userId(),
          trackingId: await _cartRepository.trackingId(),
          uuid: foodInCartInfo.uuid,
          addons: '',
          food: foodInCartInfo.id,
          restaurant: foodInCartInfo.restaurant,
          quantity: foodInCartInfo.quantity,
          variations: [],
          campaignId: state.campaign.detail!.id!,
          campaignType: 'food',
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
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          state.campaign.inCampaign![index].quantity = 0;
          emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignRepeatFoodOrderResponseEvent(FoodCampaignRepeatFoodOrderResponseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      for (var element in event.data.data!.list!) {
        if (element.quantity == 0) {
          await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
          RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id, quantity: element.quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      for (var element in state.campaign.inCampaign!) {
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
      emit(state.copyWith(campaign: state.campaign, status: FoodCampaignStatus.cartUpdate));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignFoodVariationModalRepeatResponseEvent(FoodCampaignFoodVariationModalRepeatResponseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.campaign.inCampaign![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.campaign.inCampaign![index].restaurants!.id!;
        restaurantInfo.slug = state.campaign.inCampaign![index].restaurants!.slug!;
        restaurantInfo.name = state.campaign.inCampaign![index].restaurants!.name!;
        restaurantInfo.cover = state.campaign.inCampaign![index].restaurants!.cover!;
        restaurantInfo.logo = state.campaign.inCampaign![index].restaurants!.logo!;
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
          int quantity = (int.parse(state.campaign.inCampaign![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          if (quantity < state.campaign.inCampaign![index].purchaseLimit!) {
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
            if (state.campaign.inCampaign![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.campaign.inCampaign![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.campaign.inCampaign![index].quantity! < state.campaign.inCampaign![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.campaign.inCampaign![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    campaign: state.campaign,
                    status: FoodCampaignStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.campaign.inCampaign![index].stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    campaign: state.campaign,
                    status: FoodCampaignStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.campaign.inCampaign![index].stockNumber!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: state.campaign.inCampaign![index].stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].purchaseLimit!;
            await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.campaign.inCampaign![index].purchaseLimit!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            emit(
              state.copyWith(
                campaign: state.campaign,
                status: FoodCampaignStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.campaign.inCampaign![index].purchaseLimit}',
              ),
            );
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: sameUuid,
              id: event.id,
              quantity: state.campaign.inCampaign![index].purchaseLimit!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        } else {
          int quantity = (int.parse(state.campaign.inCampaign![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.campaign.inCampaign![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }
          final String locale = await _authRepository.getLocale();
          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.campaign.inCampaign![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.campaign.inCampaign![index].name,
            shortDescription: state.campaign.inCampaign![index].shortDescription,
            image: state.campaign.inCampaign![index].image,
            restaurant: state.campaign.inCampaign![index].restaurant,
            foodType: state.campaign.inCampaign![index].foodType,
            price: state.campaign.inCampaign![index].price,
            discountType: state.campaign.inCampaign![index].discountType,
            discount: state.campaign.inCampaign![index].discount,
            offerPrice: state.campaign.inCampaign![index].offerPrice,
            purchaseLimit: state.campaign.inCampaign![index].purchaseLimit,
            stockNumber: state.campaign.inCampaign![index].stockNumber,
            stockType: state.campaign.inCampaign![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.campaign.inCampaign![index].status,
            inStock: state.campaign.inCampaign![index].inStock,
            startTime: state.campaign.inCampaign![index].startTime,
            endTime: state.campaign.inCampaign![index].endTime,
            taxationEnable: state.campaign.inCampaign![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );
          state.campaign.inCampaign![index].quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));

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
            campaignId: state.campaign.detail!.id!,
            campaignType: 'food',
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
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            state.campaign.inCampaign![index].quantity = 0;
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodCampaignFoodModalResponseEvent(FoodCampaignFoodModalResponseEvent event, Emitter<FoodCampaignState> emit) async {
    try {
      int index = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
      if (index != -1 && event.response.action! == true) {
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.campaign.inCampaign![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.campaign.inCampaign![index].restaurants!.id!;
        restaurantInfo.slug = state.campaign.inCampaign![index].restaurants!.slug!;
        restaurantInfo.name = state.campaign.inCampaign![index].restaurants!.name!;
        restaurantInfo.cover = state.campaign.inCampaign![index].restaurants!.cover!;
        restaurantInfo.logo = state.campaign.inCampaign![index].restaurants!.logo!;
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
          int quantity = (int.parse(state.campaign.inCampaign![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
          if (quantity < state.campaign.inCampaign![index].purchaseLimit!) {
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
            if (state.campaign.inCampaign![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.campaign.inCampaign![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.campaign.inCampaign![index].quantity! < state.campaign.inCampaign![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.campaign.inCampaign![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    campaign: state.campaign,
                    status: FoodCampaignStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.campaign.inCampaign![index].stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    campaign: state.campaign,
                    status: FoodCampaignStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.campaign.inCampaign![index].stockNumber!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: state.campaign.inCampaign![index].stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            state.campaign.inCampaign![index].quantity = state.campaign.inCampaign![index].purchaseLimit!;
            await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.campaign.inCampaign![index].purchaseLimit!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            emit(
              state.copyWith(
                campaign: state.campaign,
                status: FoodCampaignStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.campaign.inCampaign![index].purchaseLimit}',
              ),
            );
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: sameUuid,
              id: event.id,
              quantity: state.campaign.inCampaign![index].purchaseLimit!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        } else {
          int quantity = (int.parse(state.campaign.inCampaign![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.campaign.inCampaign![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }
          final String locale = await _authRepository.getLocale();
          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.campaign.inCampaign![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.campaign.inCampaign![index].name,
            shortDescription: state.campaign.inCampaign![index].shortDescription,
            image: state.campaign.inCampaign![index].image,
            restaurant: state.campaign.inCampaign![index].restaurant,
            foodType: state.campaign.inCampaign![index].foodType,
            price: state.campaign.inCampaign![index].price,
            discountType: state.campaign.inCampaign![index].discountType,
            discount: state.campaign.inCampaign![index].discount,
            offerPrice: state.campaign.inCampaign![index].offerPrice,
            purchaseLimit: state.campaign.inCampaign![index].purchaseLimit,
            stockNumber: state.campaign.inCampaign![index].stockNumber,
            stockType: state.campaign.inCampaign![index].stockType,
            quantity: event.response.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.campaign.inCampaign![index].status,
            inStock: state.campaign.inCampaign![index].inStock,
            startTime: state.campaign.inCampaign![index].startTime,
            endTime: state.campaign.inCampaign![index].endTime,
            taxationEnable: state.campaign.inCampaign![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.response.instruction!,
            locale: locale.toString(),
          );
          state.campaign.inCampaign![index].quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodCampaignStatus.cartUpdate, campaign: state.campaign));

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
            campaignId: state.campaign.detail!.id!,
            campaignType: 'food',
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
            state.campaign.inCampaign![index].cartEntity = cartEntityPromise;
            state.campaign.inCampaign![index].quantity = 0;
            emit(state.copyWith(status: FoodCampaignStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }

      if (index != -1 && state.campaign.inCampaign![index].isFavourite! != event.response.isFavourite) {
        state.campaign.inCampaign![index].isFavourite = !state.campaign.inCampaign![index].isFavourite!;
        if (state.campaign.inCampaign![index].isFavourite == true) {
          state.favIds.add(event.id);
        } else {
          state.favIds.removeWhere((element) => element == event.id);
        }
        emit(state.copyWith(status: FoodCampaignStatus.favUpdate, campaign: state.campaign, favIds: state.favIds));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

