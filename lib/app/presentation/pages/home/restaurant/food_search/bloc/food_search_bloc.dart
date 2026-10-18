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
import 'package:user/app/core/models/cart_item_response_model.dart';
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/models/food_search_initial_response_model.dart';
import 'package:user/app/core/models/food_search_result_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/request/food_search_initial_request_model.dart';
import 'package:user/app/core/models/request/food_search_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_search_event.dart';
part 'food_search_state.dart';

class FoodSearchBloc extends Bloc<FoodSearchEvent, FoodSearchState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  Timer? _debounce;

  FoodSearchBloc()
    : super(
        FoodSearchState(
          initialData: FoodSearchInitialResponseModel(foods: [], success: false, locale: ''),
          response: FoodSearchResultResponseModel(foods: [], success: false, locale: ''),
        ),
      ) {
    on<FoodSearchInitialEvent>(_onFoodSearchInitialEvent);
    on<FoodSearchFindResultEvent>(_onFoodSearchFindResultEvent);
    on<FoodSearchModalResponseEvent>(_onFoodSearchModalResponseEvent);
    on<FoodSearchVariationModalResponseEvent>(_onFoodSearchVariationModalResponseEvent);
    on<FoodSearchAddCartEvent>(_onFoodSearchAddCartEvent);
    on<FoodSearchRepeatFoodOrderResponseEvent>(_onFoodSearchRepeatFoodOrderResponseEvent);
    on<FoodSearchFoodQuantityDecreaseEvent>(_onFoodSearchFoodQuantityDecreaseEvent);
    on<FoodSearchFoodVariationModalRepeatResponseEvent>(_onFoodSearchFoodVariationModalRepeatResponseEvent);
    on<FoodSearchFoodQuantityIncreaseEvent>(_onFoodSearchFoodQuantityIncreaseEvent);
    on<FoodSearchExecuteEvent>(_onFoodSearchExecuteEvent);
  }

  FutureOr<void> _onFoodSearchInitialEvent(FoodSearchInitialEvent event, Emitter<FoodSearchState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "food_search", "id": event.id, "name": event.name}, '${event.name}_search_screen', '${event.name}_search_screen');
      final String userId = await _restaurantRepository.userId();
      emit(state.copyWith(id: event.id, name: event.name, uid: userId, status: FoodSearchStatus.initial));
      FoodSearchInitialRequestModel param = FoodSearchInitialRequestModel(id: event.id, uid: userId);
      DioApiResponse response = await _restaurantRepository.getFoodSearchInitialData(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        FoodSearchInitialResponseModel initialResponse = FoodSearchInitialResponseModel.fromJson(myMap, locale.toString());
        List<String> initialFavIds = <String>[];
        for (var foodLoop in initialResponse.foods!) {
          if (foodLoop.isFavourite! == true) {
            initialFavIds.add(foodLoop.id!);
          }
        }
        for (var element in initialResponse.foods!) {
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
        emit(state.copyWith(status: FoodSearchStatus.initial, appLocale: locale.toString(), initialData: initialResponse, initialFavIds: initialFavIds));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchFindResultEvent(FoodSearchFindResultEvent event, Emitter<FoodSearchState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      add(FoodSearchExecuteEvent(query: event.searchQuery));
    });
  }

  FutureOr<void> _onFoodSearchModalResponseEvent(FoodSearchModalResponseEvent event, Emitter<FoodSearchState> emit) async {
    try {
      if (event.collection == 'initial') {
        int index = state.initialData.foods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.initialData.foods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.initialData.foods![index].restaurants!.id!;
          restaurantInfo.slug = state.initialData.foods![index].restaurants!.slug!;
          restaurantInfo.name = state.initialData.foods![index].restaurants!.name!;
          restaurantInfo.cover = state.initialData.foods![index].restaurants!.cover!;
          restaurantInfo.logo = state.initialData.foods![index].restaurants!.logo!;
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
            int quantity = (int.parse(state.initialData.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.initialData.foods![index].purchaseLimit!) {
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
              if (state.initialData.foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.initialData.foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.initialData.foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: FoodSearchStatus.initialCartUpdate, initialData: state.initialData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.initialData.foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.initialData.foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.initialData.foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: FoodSearchStatus.initialCartUpdate, initialData: state.initialData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      initialData: state.initialData,
                      status: FoodSearchStatus.initialCartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.initialData.foods![index].quantity = state.initialData.foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.initialData.foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.initialData.foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      initialData: state.initialData,
                      status: FoodSearchStatus.initialCartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.initialData.foods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.initialData.foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.initialData.foods![index].quantity = state.initialData.foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.initialData.foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.initialData.foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  initialData: state.initialData,
                  status: FoodSearchStatus.initialCartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.initialData.foods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.initialData.foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.initialData.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.initialData.foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.initialData.foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.initialData.foods![index].name,
              shortDescription: state.initialData.foods![index].shortDescription,
              image: state.initialData.foods![index].image,
              restaurant: state.initialData.foods![index].restaurant,
              foodType: state.initialData.foods![index].foodType,
              price: state.initialData.foods![index].price,
              discountType: state.initialData.foods![index].discountType,
              discount: state.initialData.foods![index].discount,
              offerPrice: state.initialData.foods![index].offerPrice,
              purchaseLimit: state.initialData.foods![index].purchaseLimit,
              stockNumber: state.initialData.foods![index].stockNumber,
              stockType: state.initialData.foods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.initialData.foods![index].status,
              inStock: state.initialData.foods![index].inStock,
              startTime: state.initialData.foods![index].startTime,
              endTime: state.initialData.foods![index].endTime,
              taxationEnable: state.initialData.foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.initialData.foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.initialData.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodSearchStatus.initialCartUpdate, initialData: state.initialData));

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
              state.initialData.foods![index].cartEntity = cartEntityPromise;
              state.initialData.foods![index].quantity = 0;
              emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.initialData.foods![index].isFavourite! != event.response.isFavourite) {
          state.initialData.foods![index].isFavourite = !state.initialData.foods![index].isFavourite!;
          if (state.initialData.foods![index].isFavourite == true) {
            state.initialFavIds.add(event.id);
          } else {
            state.initialFavIds.removeWhere((element) => element == event.id);
          }
          emit(state.copyWith(status: FoodSearchStatus.initialFoodFav, initialData: state.initialData, initialFavIds: state.initialFavIds));
        }
      } else if (event.collection == 'result') {
        int index = state.response.foods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.response.foods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.response.foods![index].restaurants!.id!;
          restaurantInfo.slug = state.response.foods![index].restaurants!.slug!;
          restaurantInfo.name = state.response.foods![index].restaurants!.name!;
          restaurantInfo.cover = state.response.foods![index].restaurants!.cover!;
          restaurantInfo.logo = state.response.foods![index].restaurants!.logo!;
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
            int quantity = (int.parse(state.response.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.response.foods![index].purchaseLimit!) {
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
              if (state.response.foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.response.foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.response.foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.response.foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.response.foods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.response.foods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      response: state.response,
                      status: FoodSearchStatus.searchCartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.response.foods![index].quantity = state.response.foods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.response.foods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.response.foods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      response: state.response,
                      status: FoodSearchStatus.searchCartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.response.foods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.response.foods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.response.foods![index].quantity = state.response.foods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.response.foods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.response.foods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  response: state.response,
                  status: FoodSearchStatus.searchCartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.response.foods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.response.foods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.response.foods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.response.foods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.response.foods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.response.foods![index].name,
              shortDescription: state.response.foods![index].shortDescription,
              image: state.response.foods![index].image,
              restaurant: state.response.foods![index].restaurant,
              foodType: state.response.foods![index].foodType,
              price: state.response.foods![index].price,
              discountType: state.response.foods![index].discountType,
              discount: state.response.foods![index].discount,
              offerPrice: state.response.foods![index].offerPrice,
              purchaseLimit: state.response.foods![index].purchaseLimit,
              stockNumber: state.response.foods![index].stockNumber,
              stockType: state.response.foods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.response.foods![index].status,
              inStock: state.response.foods![index].inStock,
              startTime: state.response.foods![index].startTime,
              endTime: state.response.foods![index].endTime,
              taxationEnable: state.response.foods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.response.foods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.response.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));

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
              state.response.foods![index].cartEntity = cartEntityPromise;
              state.response.foods![index].quantity = 0;
              emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.response.foods![index].isFavourite! != event.response.isFavourite) {
          state.response.foods![index].isFavourite = !state.response.foods![index].isFavourite!;
          if (state.response.foods![index].isFavourite == true) {
            state.resultFavIds.add(event.id);
          } else {
            state.resultFavIds.removeWhere((element) => element == event.id);
          }
          emit(state.copyWith(status: FoodSearchStatus.searchFoodFav, response: state.response, resultFavIds: state.resultFavIds));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchVariationModalResponseEvent(FoodSearchVariationModalResponseEvent event, Emitter<FoodSearchState> emit) async {
    try {
      int index = state.response.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        state.response.foods![index].quantity = event.data.cartItem!.quantity;
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.response.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.response.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.response.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.response.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.response.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.response.foods![index].restaurants!.logo!;
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
        for (var element in state.response.foods![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.response.foods![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.response.foods![index].name,
          shortDescription: state.response.foods![index].shortDescription,
          image: state.response.foods![index].image,
          restaurant: state.response.foods![index].restaurant,
          foodType: state.response.foods![index].foodType,
          price: state.response.foods![index].price,
          discountType: state.response.foods![index].discountType,
          discount: state.response.foods![index].discount,
          offerPrice: state.response.foods![index].offerPrice,
          purchaseLimit: state.response.foods![index].purchaseLimit,
          stockNumber: state.response.foods![index].stockNumber,
          stockType: state.response.foods![index].stockType,
          quantity: event.data.cartItem!.quantity,
          id: event.id,
          addons: savedAddon,
          variations: savedVariations,
          restaurantInfo: restaurantInfo,
          translations: savedFoodTranslation,
          status: state.response.foods![index].status,
          inStock: state.response.foods![index].inStock,
          startTime: state.response.foods![index].startTime,
          endTime: state.response.foods![index].endTime,
          taxationEnable: state.response.foods![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: event.data.instruction!,
          locale: locale.toString(),
        );

        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.response.foods![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));

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
          state.response.foods![index].cartEntity = cartEntityPromise;
          state.response.foods![index].quantity = 0;
          emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchAddCartEvent(FoodSearchAddCartEvent event, Emitter<FoodSearchState> emit) async {
    try {
      int index = state.response.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final String locale = await _authRepository.getLocale();
        state.response.foods![index].quantity = 1;
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.response.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.response.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.response.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.response.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.response.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.response.foods![index].restaurants!.logo!;
        restaurantInfo.translations = restaurantTranslation;

        List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
        savedFoodTranslation.clear();

        for (var element in state.response.foods![index].translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
          savedFoodTranslation.add(savedData);
        }

        List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
        foodTaxation.clear();
        for (var element in state.response.foods![index].foodtaxations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
          foodTaxation.add(savedData);
        }

        FoodInCartModel foodInCartInfo = FoodInCartModel(
          uuid: Uuid().generateV4(),
          name: state.response.foods![index].name,
          shortDescription: state.response.foods![index].shortDescription,
          image: state.response.foods![index].image,
          restaurant: state.response.foods![index].restaurant,
          foodType: state.response.foods![index].foodType,
          price: state.response.foods![index].price,
          discountType: state.response.foods![index].discountType,
          discount: state.response.foods![index].discount,
          offerPrice: state.response.foods![index].offerPrice,
          purchaseLimit: state.response.foods![index].purchaseLimit,
          stockNumber: state.response.foods![index].stockNumber,
          stockType: state.response.foods![index].stockType,
          quantity: 1,
          id: event.id,
          addons: [],
          variations: [],
          translations: savedFoodTranslation,
          restaurantInfo: restaurantInfo,
          status: state.response.foods![index].status,
          inStock: state.response.foods![index].inStock,
          startTime: state.response.foods![index].startTime,
          endTime: state.response.foods![index].endTime,
          taxationEnable: state.response.foods![index].taxationEnable!,
          foodtaxations: foodTaxation,
          instruction: '',
          locale: locale.toString(),
        );
        await _cartRepository.addToCartLocal(foodInCartInfo);
        final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
        state.response.foods![index].cartEntity = cartEntityPromise;
        emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
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
          state.response.foods![index].cartEntity = cartEntityPromise;
          state.response.foods![index].quantity = 0;
          emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchRepeatFoodOrderResponseEvent(FoodSearchRepeatFoodOrderResponseEvent event, Emitter<FoodSearchState> emit) async {
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
            emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id, quantity: element.quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      for (var element in state.response.foods!) {
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
      emit(state.copyWith(response: state.response, status: FoodSearchStatus.searchCartUpdate));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchFoodQuantityDecreaseEvent(FoodSearchFoodQuantityDecreaseEvent event, Emitter<FoodSearchState> emit) async {
    try {
      int index = state.response.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.response.foods![index].quantity! > 1) {
          state.response.foods![index].quantity = state.response.foods![index].quantity! - 1;
          await _cartRepository.updateProductQuantityInCartLocal(event.id, state.response.foods![index].quantity!);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.response.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
          UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.response.foods![index].quantity!);
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          state.response.foods![index].quantity = 0;
          await _cartRepository.removeFromCartLocal(event.id);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.response.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
          RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchFoodVariationModalRepeatResponseEvent(FoodSearchFoodVariationModalRepeatResponseEvent event, Emitter<FoodSearchState> emit) async {
    try {
      int index = state.response.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        final String locale = await _authRepository.getLocale();
        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.response.foods![index].restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.response.foods![index].restaurants!.id!;
        restaurantInfo.slug = state.response.foods![index].restaurants!.slug!;
        restaurantInfo.name = state.response.foods![index].restaurants!.name!;
        restaurantInfo.cover = state.response.foods![index].restaurants!.cover!;
        restaurantInfo.logo = state.response.foods![index].restaurants!.logo!;
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
          int quantity = (int.parse(state.response.foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          if (quantity < state.response.foods![index].purchaseLimit!) {
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
            if (state.response.foods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.response.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.response.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (quantity < state.response.foods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.response.foods![index].quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.response.foods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: event.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    response: state.response,
                    status: FoodSearchStatus.searchCartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.response.foods![index].quantity = state.response.foods![index].stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.response.foods![index].stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.response.foods![index].cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    response: state.response,
                    status: FoodSearchStatus.searchCartError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.response.foods![index].stockNumber!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: state.response.foods![index].stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            state.response.foods![index].quantity = state.response.foods![index].purchaseLimit!;
            await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.response.foods![index].purchaseLimit!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.response.foods![index].cartEntity = cartEntityPromise;
            emit(
              state.copyWith(
                response: state.response,
                status: FoodSearchStatus.searchCartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.response.foods![index].purchaseLimit!}',
              ),
            );
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: sameUuid,
              id: event.id,
              quantity: state.response.foods![index].purchaseLimit!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        } else {
          int quantity = (int.parse(state.response.foods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.response.foods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }
          final String locale = await _authRepository.getLocale();
          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.response.foods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.response.foods![index].name,
            shortDescription: state.response.foods![index].shortDescription,
            image: state.response.foods![index].image,
            restaurant: state.response.foods![index].restaurant,
            foodType: state.response.foods![index].foodType,
            price: state.response.foods![index].price,
            discountType: state.response.foods![index].discountType,
            discount: state.response.foods![index].discount,
            offerPrice: state.response.foods![index].offerPrice,
            purchaseLimit: state.response.foods![index].purchaseLimit,
            stockNumber: state.response.foods![index].stockNumber,
            stockType: state.response.foods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.response.foods![index].status,
            inStock: state.response.foods![index].inStock,
            startTime: state.response.foods![index].startTime,
            endTime: state.response.foods![index].endTime,
            taxationEnable: state.response.foods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );
          state.response.foods![index].quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.response.foods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));

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
            state.response.foods![index].cartEntity = cartEntityPromise;
            state.response.foods![index].quantity = 0;
            emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchFoodQuantityIncreaseEvent(FoodSearchFoodQuantityIncreaseEvent event, Emitter<FoodSearchState> emit) async {
    try {
      int index = state.response.foods!.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        if (state.response.foods![index].quantity! < state.response.foods![index].purchaseLimit!) {
          if (state.response.foods![index].stockType! == 'unlimited') {
            state.response.foods![index].quantity = state.response.foods![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.response.foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.response.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.response.foods![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else if (state.response.foods![index].quantity! < state.response.foods![index].stockNumber!) {
            state.response.foods![index].quantity = state.response.foods![index].quantity! + 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.response.foods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.response.foods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: FoodSearchStatus.searchCartUpdate, response: state.response));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id, quantity: state.response.foods![index].quantity!);
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: FoodSearchStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            emit(state.copyWith(status: FoodSearchStatus.searchCartError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.response.foods![index].stockNumber!}'));
          }
        } else {
          emit(state.copyWith(status: FoodSearchStatus.searchCartError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.response.foods![index].purchaseLimit}'));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSearchStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSearchExecuteEvent(FoodSearchExecuteEvent event, Emitter<FoodSearchState> emit) async {
    if (event.query.length >= 3) {
      try {
        FoodSearchRequestModel param = FoodSearchRequestModel(id: state.id, searchQuery: event.query, uid: state.uid);
        DioApiResponse response = await _restaurantRepository.getFoodSearchResult(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          FoodSearchResultResponseModel searchResult = FoodSearchResultResponseModel.fromJson(myMap, locale.toString());
          List<String> resultFavId = <String>[];
          for (var foodLoop in searchResult.foods!) {
            if (foodLoop.isFavourite! == true) {
              resultFavId.add(foodLoop.id!);
            }
          }
          for (var element in searchResult.foods!) {
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
          emit(state.copyWith(status: searchResult.foods!.isEmpty ? FoodSearchStatus.empty : FoodSearchStatus.success, response: searchResult, resultFavIds: resultFavId));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FoodSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(state.copyWith(status: FoodSearchStatus.initial));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

