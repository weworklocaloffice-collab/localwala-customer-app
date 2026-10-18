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
import 'package:user/app/core/models/favourite_foods_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/models/request/favourite_foods_request_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'favourite_foods_event.dart';
part 'favourite_foods_state.dart';

class FavouriteFoodsBloc extends Bloc<FavouriteFoodsEvent, FavouriteFoodsState> {
  final LocationRepository _locationRepository = LocationRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  FavouriteFoodsBloc()
    : super(
        FavouriteFoodsState(
          pageSize: ApiRequestService.pageSize,
          foods: FavouriteFoodListModel(foods: [], page: 0, limit: 0, totalPages: 0, totalResults: 0, success: false, locale: ''),
        ),
      ) {
    on<FavouriteFoodsInitialEvent>(_onFavouriteFoodsInitialEvent);
    on<FavouriteFoodsLoadMoreEvent>(_onFavouriteFoodsLoadMoreEvent);
    on<FavouriteFoodsDeleteFoodEvent>(_onFavouriteFoodsDeleteFoodEvent);
    on<FavouriteFoodsVariationModalResponseEvent>(_onFavouriteFoodsVariationModalResponseEvent);
    on<FavouriteFoodsFoodQuantityDecreaseEvent>(_onFavouriteFoodsFoodQuantityDecreaseEvent);
    on<FavouriteFoodsFoodQuantityIncreaseEvent>(_onFavouriteFoodsFoodQuantityIncreaseEvent);
    on<FavouriteFoodsAddCartEvent>(_onFavouriteFoodsAddCartEvent);
    on<FavouriteFoodsRepeatFoodOrderResponseEvent>(_onFavouriteFoodsRepeatFoodOrderResponseEvent);
    on<FavouriteFoodsFoodVariationModalRepeatResponseEvent>(_onFavouriteFoodsFoodVariationModalRepeatResponseEvent);
    on<FavouriteFoodsRefreshCartEvent>(_onFavouriteFoodsRefreshCartEvent);
    on<FavouriteFoodsSilenceEvent>(_onFavouriteFoodsSilenceEvent);
    on<FavouriteFoodModalResponseEvent>(_onFavouriteFoodModalResponseEvent);
  }

  FutureOr<void> _onFavouriteFoodsInitialEvent(FavouriteFoodsInitialEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "favourite_food_items"}, 'favourite_food_item_screen', 'favourite_food_item_screen');
      final String userId = await _favouriteRepository.userId();
      final String userRole = await _favouriteRepository.userRole();
      if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        FavouriteFoodsRequestModel param = FavouriteFoodsRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _favouriteRepository.getFavouriteFoods(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FavouriteFoodsStatus.empty));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            final String locale = await _authRepository.getLocale();
            FavouriteFoodListModel data = FavouriteFoodListModel.fromJson(myMap, locale.toString());
            for (var element in data.foods!) {
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
            emit(state.copyWith(status: FavouriteFoodsStatus.success, appLocale: locale.toString(), foods: data));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FavouriteFoodsStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: FavouriteFoodsStatus.unAuthorized, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsLoadMoreEvent(FavouriteFoodsLoadMoreEvent event, Emitter<FavouriteFoodsState> emit) async {
    if (state.foods.foods!.length < state.foods.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _favouriteRepository.userId();
        if (userId.isNotEmpty) {
          final double userLatitude = await _locationRepository.userLatitude();
          final double userLongitude = await _locationRepository.userLongitude();
          FavouriteFoodsRequestModel param = FavouriteFoodsRequestModel(
            latitude: userLatitude != 0 ? userLatitude : 0,
            longitude: userLongitude != 0 ? userLongitude : 0,
            page: state.currentPage,
            limit: state.pageSize * 2,
            uid: userId,
          );
          DioApiResponse response = await _favouriteRepository.getFavouriteFoods(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (!initialResponse.success!) {
              emit(state.copyWith(status: FavouriteFoodsStatus.empty, loadMore: false));
            } else {
              Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
              final String locale = await _authRepository.getLocale();
              FavouriteFoodListModel data = FavouriteFoodListModel.fromJson(myMap, locale.toString());
              for (var element in data.foods!) {
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
              emit(state.copyWith(status: FavouriteFoodsStatus.success, foods: data, loadMore: false, pageSize: state.pageSize * 2));
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FavouriteFoodsStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
          }
        } else {
          emit(state.copyWith(status: FavouriteFoodsStatus.unAuthorized, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: '', loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FavouriteFoodsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsDeleteFoodEvent(FavouriteFoodsDeleteFoodEvent event, Emitter<FavouriteFoodsState> emit) async {
    emit(state.copyWith(status: FavouriteFoodsStatus.removeFavStart));
    try {
      final String userId = await _favouriteRepository.userId();
      DioApiResponse response = await _favouriteRepository.deleteFavouriteFood(userId, event.foodId);
      if (response.errorType == NetErrorType.none) {
        state.foods.foods!.removeWhere((element) => element.id == event.foodId);
        state.foods.foodIds!.removeWhere((element) => element == event.foodId);
        emit(state.copyWith(foods: state.foods, status: FavouriteFoodsStatus.removeFavDone));
        if (state.foods.foods!.isEmpty) {
          emit(state.copyWith(status: FavouriteFoodsStatus.empty));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FavouriteFoodsStatus.removeFavFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.removeFavFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsVariationModalResponseEvent(FavouriteFoodsVariationModalResponseEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        state.foods.foods![index].quantity = event.data.cartItem!.quantity;
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.foods.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.foods.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.foods.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.foods.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.foods.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.foods.foods![index].restaurants!.logo!;
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
        for (var element in state.foods.foods![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.foods.foods![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.foods.foods![index].name,
          shortDescription: state.foods.foods![index].shortDescription,
          image: state.foods.foods![index].image,
          restaurant: state.foods.foods![index].restaurant,
          foodType: state.foods.foods![index].foodType,
          price: state.foods.foods![index].price,
          discountType: state.foods.foods![index].discountType,
          discount: state.foods.foods![index].discount,
          offerPrice: state.foods.foods![index].offerPrice,
          purchaseLimit: state.foods.foods![index].purchaseLimit,
          stockNumber: state.foods.foods![index].stockNumber,
          stockType: state.foods.foods![index].stockType,
          quantity: event.data.cartItem!.quantity,
          id: event.id,
          addons: savedAddon,
          variations: savedVariations,
          restaurantInfo: restaurantInfo,
          translations: savedFoodTranslation,
          status: state.foods.foods![index].status,
          inStock: state.foods.foods![index].inStock,
          startTime: state.foods.foods![index].startTime,
          endTime: state.foods.foods![index].endTime,
          taxationEnable: state.foods.foods![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: event.data.instruction!,
          locale: locale.toString(),
        );

        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.foods.foods![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));

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
          state.foods.foods![index].cartEntity = cartEntityPromise;
          state.foods.foods![index].quantity = 0;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsFoodQuantityDecreaseEvent(FavouriteFoodsFoodQuantityDecreaseEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.foods.foods![index].quantity! > 1) {
          state.foods.foods![index].quantity = state.foods.foods![index].quantity! - 1;
          await _cartRepository.updateProductQuantityInCartLocal(event.id, state.foods.foods![index].quantity!);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.foods.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
          UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.foods.foods![index].quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          state.foods.foods![index].quantity = 0;
          await _cartRepository.removeFromCartLocal(event.id);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.foods.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
          RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsFoodQuantityIncreaseEvent(FavouriteFoodsFoodQuantityIncreaseEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.foods.foods![index].quantity! < state.foods.foods![index].purchaseLimit!) {
          if (state.foods.foods![index].stockType! == 'unlimited') {
            state.foods.foods![index].quantity = state.foods.foods![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.foods.foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.foods.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.foods.foods![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else if (state.foods.foods![index].quantity! < state.foods.foods![index].stockNumber!) {
            state.foods.foods![index].quantity = state.foods.foods![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.foods.foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.foods.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.foods.foods![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.foods.foods![index].stockNumber!}'));
          }
        } else {
          emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.foods.foods![index].purchaseLimit}'));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsAddCartEvent(FavouriteFoodsAddCartEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        state.foods.foods![index].quantity = 1;
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.foods.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.foods.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.foods.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.foods.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.foods.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.foods.foods![index].restaurants!.logo!;
        restaurantInfo.translations = restaurantTranslation;

        List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
        savedFoodTranslation.clear();

        for (var element in state.foods.foods![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.foods.foods![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.foods.foods![index].name,
          shortDescription: state.foods.foods![index].shortDescription,
          image: state.foods.foods![index].image,
          restaurant: state.foods.foods![index].restaurant,
          foodType: state.foods.foods![index].foodType,
          price: state.foods.foods![index].price,
          discountType: state.foods.foods![index].discountType,
          discount: state.foods.foods![index].discount,
          offerPrice: state.foods.foods![index].offerPrice,
          purchaseLimit: state.foods.foods![index].purchaseLimit,
          stockNumber: state.foods.foods![index].stockNumber,
          stockType: state.foods.foods![index].stockType,
          quantity: 1,
          id: event.id,
          addons: [],
          variations: [],
          translations: savedFoodTranslation,
          restaurantInfo: restaurantInfo,
          status: state.foods.foods![index].status,
          inStock: state.foods.foods![index].inStock,
          startTime: state.foods.foods![index].startTime,
          endTime: state.foods.foods![index].endTime,
          taxationEnable: state.foods.foods![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: '',
          locale: locale.toString(),
        );
        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.foods.foods![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));

        CartItemRequestModel onlineCartParam = CartItemRequestModel(
          user: await _cartRepository.userId(),
          trackingId: await _cartRepository.trackingId(),
          uuid: foodInCartInfo.uuid,
          addons: '',
          food: foodInCartInfo.id,
          restaurant: foodInCartInfo.restaurant,
          quantity: foodInCartInfo.quantity,
          variations: [],
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
          state.foods.foods![index].cartEntity = cartEntityPromise;
          state.foods.foods![index].quantity = 0;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsRepeatFoodOrderResponseEvent(FavouriteFoodsRepeatFoodOrderResponseEvent event, Emitter<FavouriteFoodsState> emit) async {
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
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id, quantity: element.quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      for (var element in state.foods.foods!) {
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
      emit(state.copyWith(foods: state.foods, status: FavouriteFoodsStatus.cartUpdate));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsFoodVariationModalRepeatResponseEvent(FavouriteFoodsFoodVariationModalRepeatResponseEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.foods.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.foods.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.foods.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.foods.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.foods.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.foods.foods![index].restaurants!.logo!;
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
          int quantity = (int.parse(state.foods.foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          if (quantity < state.foods.foods![index].purchaseLimit!) {
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
            if (state.foods.foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.foods.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.foods.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (quantity < state.foods.foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.foods.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.foods.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    foods: state.foods,
                    status: FavouriteFoodsStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.foods.foods![index].quantity = state.foods.foods![index].stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.foods.foods![index].stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.foods.foods![index].cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    foods: state.foods,
                    status: FavouriteFoodsStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.foods.foods![index].stockNumber}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: state.foods.foods![index].stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            state.foods.foods![index].quantity = state.foods.foods![index].purchaseLimit!;
            await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.foods.foods![index].purchaseLimit!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.foods.foods![index].cartEntity = cartEntityPromise;
            emit(
              state.copyWith(
                foods: state.foods,
                status: FavouriteFoodsStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.foods.foods![index].purchaseLimit}',
              ),
            );
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: sameUuid,
              id: event.id,
              quantity: state.foods.foods![index].purchaseLimit!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        } else {
          int quantity = (int.parse(state.foods.foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.foods.foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }
          final String locale = await _authRepository.getLocale();

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.foods.foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }
          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.foods.foods![index].name,
            shortDescription: state.foods.foods![index].shortDescription,
            image: state.foods.foods![index].image,
            restaurant: state.foods.foods![index].restaurant,
            foodType: state.foods.foods![index].foodType,
            price: state.foods.foods![index].price,
            discountType: state.foods.foods![index].discountType,
            discount: state.foods.foods![index].discount,
            offerPrice: state.foods.foods![index].offerPrice,
            stockNumber: state.foods.foods![index].stockNumber,
            stockType: state.foods.foods![index].stockType,
            purchaseLimit: state.foods.foods![index].purchaseLimit,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.foods.foods![index].status,
            inStock: state.foods.foods![index].inStock,
            startTime: state.foods.foods![index].startTime,
            endTime: state.foods.foods![index].endTime,
            taxationEnable: state.foods.foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );
          state.foods.foods![index].quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.foods.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));

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
            state.foods.foods![index].cartEntity = cartEntityPromise;
            state.foods.foods![index].quantity = 0;
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsRefreshCartEvent(FavouriteFoodsRefreshCartEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      if (state.foods.foods!.isNotEmpty) {
        for (var element in state.foods.foods!) {
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
        emit(state.copyWith(status: FavouriteFoodsStatus.success, foods: state.foods));
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodsSilenceEvent(FavouriteFoodsSilenceEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      final String userId = await _favouriteRepository.userId();
      if (userId.isNotEmpty) {
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        FavouriteFoodsRequestModel param = FavouriteFoodsRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _favouriteRepository.getFavouriteFoods(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FavouriteFoodsStatus.empty));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            final String locale = await _authRepository.getLocale();
            FavouriteFoodListModel data = FavouriteFoodListModel.fromJson(myMap, locale.toString());
            for (var element in data.foods!) {
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
            emit(state.copyWith(status: FavouriteFoodsStatus.success, foods: data));
          }
        }
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteFoodModalResponseEvent(FavouriteFoodModalResponseEvent event, Emitter<FavouriteFoodsState> emit) async {
    try {
      int index = state.foods.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1 && event.response.action! == true) {
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.foods.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.foods.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.foods.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.foods.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.foods.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.foods.foods![index].restaurants!.logo!;
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
          int quantity = (int.parse(state.foods.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
          if (quantity < state.foods.foods![index].purchaseLimit!) {
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
            if (state.foods.foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.foods.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.foods.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (quantity < state.foods.foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.foods.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.foods.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    foods: state.foods,
                    status: FavouriteFoodsStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.foods.foods![index].quantity = state.foods.foods![index].stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.foods.foods![index].stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.foods.foods![index].cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    foods: state.foods,
                    status: FavouriteFoodsStatus.cartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.foods.foods![index].stockNumber!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: state.foods.foods![index].stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            state.foods.foods![index].quantity = state.foods.foods![index].purchaseLimit!;
            await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.foods.foods![index].purchaseLimit!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.foods.foods![index].cartEntity = cartEntityPromise;
            emit(
              state.copyWith(
                foods: state.foods,
                status: FavouriteFoodsStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.foods.foods![index].purchaseLimit}',
              ),
            );
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: sameUuid,
              id: event.id,
              quantity: state.foods.foods![index].purchaseLimit!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        } else {
          int quantity = (int.parse(state.foods.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.foods.foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          final String locale = await _authRepository.getLocale();
          for (var element in state.foods.foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.foods.foods![index].name,
            shortDescription: state.foods.foods![index].shortDescription,
            image: state.foods.foods![index].image,
            restaurant: state.foods.foods![index].restaurant,
            foodType: state.foods.foods![index].foodType,
            price: state.foods.foods![index].price,
            discountType: state.foods.foods![index].discountType,
            discount: state.foods.foods![index].discount,
            offerPrice: state.foods.foods![index].offerPrice,
            purchaseLimit: state.foods.foods![index].purchaseLimit,
            stockNumber: state.foods.foods![index].stockNumber,
            stockType: state.foods.foods![index].stockType,
            quantity: event.response.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.foods.foods![index].status,
            inStock: state.foods.foods![index].inStock,
            startTime: state.foods.foods![index].startTime,
            endTime: state.foods.foods![index].endTime,
            taxationEnable: state.foods.foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.response.instruction!,
            locale: locale.toString(),
          );
          state.foods.foods![index].quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.foods.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FavouriteFoodsStatus.cartUpdate, foods: state.foods));

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
            state.foods.foods![index].cartEntity = cartEntityPromise;
            state.foods.foods![index].quantity = 0;
            emit(state.copyWith(status: FavouriteFoodsStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      if (event.response.isFavourite == false) {
        state.foods.foods!.removeWhere((element) => element.id == event.id);
        state.foods.foodIds!.removeWhere((element) => element == event.id);
        emit(state.copyWith(foods: state.foods, status: FavouriteFoodsStatus.removeSilence));
        if (state.foods.foods!.isEmpty) {
          emit(state.copyWith(status: FavouriteFoodsStatus.empty));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteFoodsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

