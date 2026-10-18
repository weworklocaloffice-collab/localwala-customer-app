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
import 'package:share_plus/share_plus.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/cart_item_response_model.dart';
import 'package:user/app/core/models/repeat_quantity_list_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/single_food_info_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/single_food_info_from_banner_model.dart';
import 'package:user/app/core/models/single_food_info_from_banner_model.dart' as option_data;
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'single_food_from_banner_modal_event.dart';
part 'single_food_from_banner_modal_state.dart';

class SingleFoodFromBannerModalBloc extends Bloc<SingleFoodFromBannerModalEvent, SingleFoodFromBannerModalState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  SingleFoodFromBannerModalBloc()
    : super(
        SingleFoodFromBannerModalState(
          detail: SingleFoodInfoFromBannerModel(locale: ''),
          quantityList: RepeatQuantityListModal(),
        ),
      ) {
    on<SingleFoodFromBannerModalInitialEvent>(_onSingleFoodFromBannerModalInitialEvent);
    on<SingleFoodFromBannerModalQuantityEvent>(_onSingleFoodFromBannerModalQuantityEvent);
    on<SingleFoodFromBannerModalSaveEvent>(_onSingleFoodFromBannerModalSaveEvent);
    on<SingleFoodFromBannerModalFavouriteEvent>(_onSingleFoodFromBannerModalFavouriteEvent);
    on<SingleFoodFromBannerModalAddonsEvent>(_onSingleFoodFromBannerModalAddonsEvent);
    on<SingleFoodFromBannerModalVariationOptionEvent>(_onSingleFoodFromBannerModalVariationOptionEvent);
    on<SingleFoodFromBannerModalRepeatIncreaseEvent>(_onSingleFoodFromBannerModalRepeatIncreaseEvent);
    on<SingleFoodFromBannerModalRepeatDecreaseEvent>(_onSingleFoodFromBannerModalRepeatDecreaseEvent);
    on<SingleFoodFromBannerModalNewItemEvent>(_onSingleFoodFromBannerModalNewItemEvent);
    on<SingleFoodFromBannerModalNewItemSaveEvent>(_onSingleFoodFromBannerModalNewItemSaveEvent);
    on<SingleFoodInstructionChangeEvent>(_onSingleFoodInstructionChangeEvent);
    on<SingleFoodShareEvent>(_onSingleFoodShareEvent);
  }

  FutureOr<void> _onSingleFoodFromBannerModalInitialEvent(SingleFoodFromBannerModalInitialEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "food_detail_from_banner"}, 'food_detail_from_banner_screen', 'food_detail_from_banner_screen');
      final String userId = await _restaurantRepository.userId();
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.loading, id: event.id, name: event.name));
      SingleFoodInfoRequestModel param = SingleFoodInfoRequestModel(foodId: event.id, uid: userId);
      DioApiResponse response = await _restaurantRepository.getSingleFoodInfo(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          SingleFoodInfoFromBannerModel detail = SingleFoodInfoFromBannerModel.fromJson(myMap, locale.toString());
          for (var element in detail.info!.addons!) {
            if (element.stockNumber == 0) {
              element.inStock = false;
            }
            if (detail.info!.discount! > 0 && detail.info!.discountType! == '%') {
              element.haveDiscount = true;
              final double discount = double.parse(detail.info!.discount!.toString());
              String discountValue = (double.parse(element.price.toString()) - (double.parse(element.price.toString()) * double.parse(discount.toString()) / 100)).toStringAsFixed(2);
              element.discountPrice = double.parse(discountValue);
            } else {
              element.haveDiscount = false;
              element.discountPrice = 0.0;
            }
          }

          for (var variationElement in detail.info!.variations!) {
            for (var optionElement in variationElement.options!) {
              if (optionElement.stock == 0) {
                optionElement.inStock = false;
              }
              if (detail.info!.discount! > 0 && detail.info!.discountType! == '%') {
                optionElement.haveDiscount = true;
                final double discount = double.parse(detail.info!.discount!.toString());
                String discountValue = (double.parse(optionElement.price.toString()) - (double.parse(optionElement.price.toString()) * double.parse(discount.toString()) / 100)).toStringAsFixed(2);
                optionElement.discountPrice = double.parse(discountValue);
              } else {
                optionElement.haveDiscount = false;
                optionElement.discountPrice = 0.0;
              }
            }
          }

          detail.info!.variations!.sort((a, b) => b.isRequired! ? 1 : -1);
          if (await _cartRepository.checkProductInCart(event.id)) {
            if (detail.info!.addons!.isEmpty && detail.info!.variations!.isEmpty) {
              final int? quantityPromise = await _cartRepository.getQuantity(event.id);
              detail.info!.quantity = quantityPromise;
              emit(state.copyWith(isRepeated: true));
            } else {
              emit(state.copyWith(isFromCart: true));
              await _cartRepository.getRepeatList(event.id).then((value) async {
                List<FoodUuidAndQuantity> quantityListItem = <FoodUuidAndQuantity>[];
                quantityListItem.clear();
                for (var element in value) {
                  FoodUuidAndQuantity quantityData = FoodUuidAndQuantity(quantity: element.quantity, uuid: element.uuid);
                  quantityListItem.add(quantityData);
                  double price = 0.0;
                  double addonPrice = 0.0;
                  for (var addon in element.addons!) {
                    if (addon.haveDiscount!) {
                      String price = (double.parse(addonPrice.toString()) + (double.parse(addon.discountPrice.toString()))).toStringAsFixed(2);
                      addonPrice = double.parse(price);
                    } else {
                      String price = (double.parse(addonPrice.toString()) + (double.parse(addon.price.toString()))).toStringAsFixed(2);
                      addonPrice = double.parse(price);
                    }
                  }

                  double variationPrice = 0.0;
                  for (var variation in element.variations!) {
                    for (var options in variation.options!) {
                      if (options.haveDiscount!) {
                        String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
                        variationPrice = double.parse(price);
                      } else {
                        String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
                        variationPrice = double.parse(price);
                      }
                    }
                  }

                  if (element.discount! > 0) {
                    String totalPrice = (double.parse(element.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
                    price = double.parse(totalPrice);
                  } else {
                    String totalPrice = (double.parse(element.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
                    price = double.parse(totalPrice);
                  }
                  String priceWithQuantity = (double.parse(price.toString()) * element.quantity!).toStringAsFixed(2);
                  price = double.parse(priceWithQuantity);
                  element.totalPrice = price;
                }
                RepeatQuantityListModal quantityList = RepeatQuantityListModal(id: event.id, list: quantityListItem);
                emit(state.copyWith(list: value, quantityList: quantityList, status: SingleFoodFromBannerModalStatus.success, isFromCart: true, newItem: false));
              });
            }
          } else {
            emit(state.copyWith(isRepeated: false, isFromCart: false, newItem: false));
            detail.info!.quantity = 1;
          }
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.success, detail: detail, originalPrice: detail.info!.price!, discountPrice: detail.info!.offerPrice!));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SingleFoodFromBannerModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalQuantityEvent(SingleFoodFromBannerModalQuantityEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    if (state.detail.info!.quantity == 1 && event.action == 'decrease') {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.success));
    } else if (event.action == 'decrease') {
      state.detail.info!.quantity = state.detail.info!.quantity! - 1;
      emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
    } else if (event.action == 'increase') {
      if (state.detail.info!.quantity! < state.detail.info!.purchaseLimit!) {
        bool checkAddonHaveStock = true;
        bool checkVariationHaveStock = true;
        int addonOutOfStockLimitNumber = 0;
        int variationOutOfStockLimitNumber = 0;
        for (var addon in state.detail.info!.addons!) {
          if (addon.checked! && state.detail.info!.quantity! >= addon.stockNumber!) {
            addon.limitCrossed = true;
            checkAddonHaveStock = false;
            if (addonOutOfStockLimitNumber == 0) {
              addonOutOfStockLimitNumber = addon.stockNumber!;
            }
          }
        }
        for (var variation in state.detail.info!.variations!) {
          for (var options in variation.options!) {
            if (options.checked! && state.detail.info!.quantity! >= options.stock!) {
              options.limitCrossed = true;
              checkVariationHaveStock = false;
              if (variationOutOfStockLimitNumber == 0) {
                variationOutOfStockLimitNumber = options.stock!;
              }
            }
          }
        }
        if (state.detail.info!.stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
          state.detail.info!.quantity = state.detail.info!.quantity! + 1;
          emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        } else if (state.detail.info!.quantity! < state.detail.info!.stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
          state.detail.info!.quantity = state.detail.info!.quantity! + 1;
          emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        } else {
          if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
            emit(
              state.copyWith(
                status: SingleFoodFromBannerModalStatus.customError,
                statusCode: 0,
                alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
              ),
            );
          } else {
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.detail.info!.stockNumber!}'));
          }
        }
      } else {
        emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.detail.info!.purchaseLimit!}'));
      }
    }
    double realPrice = state.detail.info!.price!;
    String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
    String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
    double originalPrice = double.parse(originalPriceString);
    double discountPrice = state.detail.info!.offerPrice!;
    if (state.detail.info!.discountType! == '%') {
      String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.detail.info!.discount!.toString())) / 100).toStringAsFixed(2);
      String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
      discountPrice = double.parse(discountedPriceString);
    } else {
      String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.detail.info!.discount!.toString())).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceString);
    }
    String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
    originalPrice = double.parse(originalPriceStringFinal);
    String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
    discountPrice = double.parse(discountPriceStringFinal);
    emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: SingleFoodFromBannerModalStatus.success));
  }

  FutureOr<void> _onSingleFoodFromBannerModalSaveEvent(SingleFoodFromBannerModalSaveEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    try {
      final String locale = await _authRepository.getLocale();
      if (state.isRepeated == false) {
        var items = state.detail.info!.variations!.where((element) => element.isRequired == true);
        bool requiredValidation = false;
        bool minMaxValidation = false;
        for (var variation in items) {
          int checkIndex = variation.options!.indexWhere((element) => element.checked == true);
          if (checkIndex == -1) {
            requiredValidation = true;
          }
        }
        for (var variation in state.detail.info!.variations!) {
          int minOption = variation.min!;
          final selectedOptions = variation.options!.where((vOption) => vOption.checked == true);
          if (selectedOptions.isEmpty && variation.isRequired! == false) {
            minMaxValidation = false;
          } else if (selectedOptions.length < minOption) {
            minMaxValidation = true;
          }
        }

        if (requiredValidation == false && minMaxValidation == false) {
          List<option_data.AddonConfigModel> savedFoodAddon = <option_data.AddonConfigModel>[];
          savedFoodAddon.clear();
          for (var element in state.detail.info!.addons!) {
            if (element.checked == true) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              option_data.AddonConfigModel savedData = option_data.AddonConfigModel.fromJson(myMap, locale.toString());
              savedFoodAddon.add(savedData);
            }
          }
          List<option_data.VariationOptionConfigModel> savedFoodOptions = <option_data.VariationOptionConfigModel>[];
          List<option_data.VariationConfigModel> savedFoodVariations = <option_data.VariationConfigModel>[];
          savedFoodVariations.clear();
          for (var variation in state.detail.info!.variations!) {
            savedFoodOptions.clear();
            for (var option in variation.options!) {
              if (option.checked == true) {
                var convertedItem = jsonEncode(option).toString();
                Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
                option_data.VariationOptionConfigModel savedData = option_data.VariationOptionConfigModel.fromJson(myMap);
                savedFoodOptions.add(savedData);
              }
            }
            if (savedFoodOptions.isNotEmpty) {
              option_data.VariationConfigModel variationsData = option_data.VariationConfigModel(
                isRequired: variation.isRequired,
                title: variation.title,
                type: variation.type,
                min: variation.min,
                max: variation.max,
                options: [...savedFoodOptions],
              );
              savedFoodVariations.add(variationsData);
            }
          }

          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.detail.info!.restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.detail.info!.restaurants!.id!;
          restaurantInfo.slug = state.detail.info!.restaurants!.slug!;
          restaurantInfo.name = state.detail.info!.restaurants!.name!;
          restaurantInfo.cover = state.detail.info!.restaurants!.cover!;
          restaurantInfo.logo = state.detail.info!.restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in savedFoodAddon) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in savedFoodVariations) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.detail.info!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.detail.info!.foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.detail.info!.name,
            shortDescription: state.detail.info!.shortDescription,
            image: state.detail.info!.image,
            restaurant: state.detail.info!.restaurant,
            foodType: state.detail.info!.foodType,
            price: state.detail.info!.price,
            discountType: state.detail.info!.discountType,
            discount: state.detail.info!.discount,
            offerPrice: state.detail.info!.offerPrice,
            purchaseLimit: state.detail.info!.purchaseLimit,
            stockNumber: state.detail.info!.stockNumber,
            stockType: state.detail.info!.stockType,
            quantity: state.detail.info!.quantity,
            id: state.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.detail.info!.status,
            inStock: state.detail.info!.inStock,
            startTime: state.detail.info!.startTime,
            endTime: state.detail.info!.endTime,
            taxationEnable: state.detail.info!.taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: state.instruction,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.saveClose));

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
            cookingInstruction: state.instruction,
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
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Validation Failed, Please select required items', extraMessage: ''));
        }
      } else {
        await _cartRepository.updateProductQuantityInCartLocal(state.id, state.detail.info!.quantity!);
        UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(trackingId: await _cartRepository.trackingId(), id: state.id, quantity: state.detail.info!.quantity!);
        DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
        if (cartOnlineResponse.errorType == NetErrorType.none) {
        } else {
          Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
        emit(state.copyWith(status: SingleFoodFromBannerModalStatus.saveClose));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalFavouriteEvent(SingleFoodFromBannerModalFavouriteEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    final String userId = await _restaurantRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      if (state.detail.info!.isFavourite == false) {
        state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
        emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'food', food: state.detail.info!.id, restaurant: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              emit(state.copyWith(status: SingleFoodFromBannerModalStatus.favAdd));
            }
          } else {
            state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
        emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        try {
          final String userId = await _favouriteRepository.userId();
          DioApiResponse response = await _favouriteRepository.deleteFavouriteFood(userId, state.detail.info!.id!);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.favRemove));
          } else {
            state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          state.detail.info!.isFavourite = !state.detail.info!.isFavourite!;
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalAddonsEvent(SingleFoodFromBannerModalAddonsEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    if (state.detail.info!.addons![event.index].inStock!) {
      state.detail.info!.addons![event.index].checked = !state.detail.info!.addons![event.index].checked!;
      for (var addon in state.detail.info!.addons!) {
        addon.limitCrossed = false;
      }
      for (var variation in state.detail.info!.variations!) {
        for (var options in variation.options!) {
          options.limitCrossed = false;
        }
      }
      state.detail.info!.quantity = 1;
      emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
      double realPrice = state.detail.info!.price!;
      String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
      String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
      double originalPrice = double.parse(originalPriceString);
      double discountPrice = state.detail.info!.offerPrice!;
      if (state.detail.info!.discountType! == '%') {
        String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.detail.info!.discount!.toString())) / 100).toStringAsFixed(2);
        String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
        discountPrice = double.parse(discountedPriceString);
      } else {
        String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.detail.info!.discount!.toString())).toStringAsFixed(2);
        discountPrice = double.parse(discountPriceString);
      }
      String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
      originalPrice = double.parse(originalPriceStringFinal);
      String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceStringFinal);
      emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: SingleFoodFromBannerModalStatus.success));
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalVariationOptionEvent(SingleFoodFromBannerModalVariationOptionEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    if (state.detail.info!.variations![event.vIndex].options![event.oIndex].inStock!) {
      for (var addon in state.detail.info!.addons!) {
        addon.limitCrossed = false;
      }
      if (event.type == 'single') {
        int radioIndex = state.detail.info!.variations![event.vIndex].options!.indexWhere((element) => element.checked == true);
        if (radioIndex != -1) {
          state.detail.info!.variations![event.vIndex].options![radioIndex].checked = false;
          for (var variation in state.detail.info!.variations!) {
            for (var options in variation.options!) {
              options.limitCrossed = false;
            }
          }
          state.detail.info!.quantity = 1;
          emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        }

        state.detail.info!.variations![event.vIndex].options![event.oIndex].checked = true;
        for (var variation in state.detail.info!.variations!) {
          for (var options in variation.options!) {
            options.limitCrossed = false;
          }
        }
        state.detail.info!.quantity = 1;
        emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
      } else {
        if (state.detail.info!.variations![event.vIndex].options![event.oIndex].checked! || state.detail.info!.variations![event.vIndex].options![event.oIndex].enable!) {
          state.detail.info!.variations![event.vIndex].options![event.oIndex].checked = !state.detail.info!.variations![event.vIndex].options![event.oIndex].checked!;
          for (var variations in state.detail.info!.variations!) {
            for (var options in variations.options!) {
              options.limitCrossed = false;
            }
          }
          state.detail.info!.quantity = 1;
          emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
        }

        final totalChecked = state.detail.info!.variations![event.vIndex].options!.where((vOptions) => vOptions.checked == true);
        for (var vOptoins in state.detail.info!.variations![event.vIndex].options!) {
          if (!vOptoins.checked! && totalChecked.length >= state.detail.info!.variations![event.vIndex].max!) {
            vOptoins.enable = false;
          } else {
            vOptoins.enable = true;
          }
        }
        for (var variation in state.detail.info!.variations!) {
          for (var options in variation.options!) {
            options.limitCrossed = false;
          }
        }
        state.detail.info!.quantity = 1;
        emit(state.copyWith(detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
      }
      double realPrice = state.detail.info!.price!;
      String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
      String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
      double originalPrice = double.parse(originalPriceString);
      double discountPrice = state.detail.info!.offerPrice!;
      if (state.detail.info!.discountType! == '%') {
        String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.detail.info!.discount!.toString())) / 100).toStringAsFixed(2);
        String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
        discountPrice = double.parse(discountedPriceString);
      } else {
        String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.detail.info!.discount!.toString())).toStringAsFixed(2);
        discountPrice = double.parse(discountPriceString);
      }
      String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
      originalPrice = double.parse(originalPriceStringFinal);
      String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.detail.info!.quantity!).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceStringFinal);
      emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: SingleFoodFromBannerModalStatus.success));
    }
  }

  double calculateAddons() {
    double addonPrice = 0.0;
    for (var element in state.detail.info!.addons!) {
      if (element.checked == true) {
        String price = (double.parse(addonPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
        addonPrice = double.parse(price);
      }
    }
    return addonPrice;
  }

  double calculateVariations() {
    double variationPrice = 0.0;
    for (var variation in state.detail.info!.variations!) {
      for (var options in variation.options!) {
        if (options.checked == true) {
          String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
          variationPrice = double.parse(price);
        }
      }
    }
    return variationPrice;
  }

  FutureOr<void> _onSingleFoodFromBannerModalRepeatIncreaseEvent(SingleFoodFromBannerModalRepeatIncreaseEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    if (state.list[event.index].quantity! < state.list[event.index].purchaseLimit!) {
      try {
        bool checkAddonHaveStock = true;
        bool checkVariationHaveStock = true;
        int addonOutOfStockLimitNumber = 0;
        int variationOutOfStockLimitNumber = 0;
        for (var addon in state.list[event.index].addons!) {
          if (state.list[event.index].quantity! >= addon.stockNumber!) {
            checkAddonHaveStock = false;
            if (addonOutOfStockLimitNumber == 0) {
              addonOutOfStockLimitNumber = addon.stockNumber!;
            }
          }
        }
        for (var variation in state.list[event.index].variations!) {
          for (var options in variation.options!) {
            if (state.list[event.index].quantity! >= options.stock!) {
              checkVariationHaveStock = false;
              if (variationOutOfStockLimitNumber == 0) {
                variationOutOfStockLimitNumber = options.stock!;
              }
            }
          }
        }
        if (state.list[event.index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
          state.list[event.index].quantity = state.list[event.index].quantity! + 1;
          for (var element in state.list) {
            double price = 0.0;
            double addonPrice = 0.0;
            for (var addon in element.addons!) {
              if (addon.haveDiscount!) {
                String price = (double.parse(addonPrice.toString()) + (double.parse(addon.discountPrice.toString()))).toStringAsFixed(2);
                addonPrice = double.parse(price);
              } else {
                String price = (double.parse(addonPrice.toString()) + (double.parse(addon.price.toString()))).toStringAsFixed(2);
                addonPrice = double.parse(price);
              }
            }

            double variationPrice = 0.0;
            for (var variation in element.variations!) {
              for (var options in variation.options!) {
                if (options.haveDiscount!) {
                  String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
                  variationPrice = double.parse(price);
                } else {
                  String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
                  variationPrice = double.parse(price);
                }
              }
            }

            if (element.discount! > 0) {
              String totalPrice = (double.parse(element.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
              price = double.parse(totalPrice);
            } else {
              String totalPrice = (double.parse(element.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
              price = double.parse(totalPrice);
            }
            String priceWithQuantity = (double.parse(price.toString()) * element.quantity!).toStringAsFixed(2);
            price = double.parse(priceWithQuantity);
            element.totalPrice = price;
            int index = state.quantityList.list!.indexWhere((element) => element.uuid == event.uuid);
            if (index != -1) {
              state.quantityList.list![index].quantity = state.list[event.index].quantity;
              await _cartRepository.updateProductVariationInCartLocal(event.uuid, state.id, state.quantityList.list![index].quantity!);
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: event.uuid,
                id: state.id,
                quantity: state.quantityList.list![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          }
          emit(state.copyWith(list: state.list, status: SingleFoodFromBannerModalStatus.cartUpdate));
        } else if (state.list[event.index].quantity! < state.list[event.index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
          state.list[event.index].quantity = state.list[event.index].quantity! + 1;
          for (var element in state.list) {
            double price = 0.0;
            double addonPrice = 0.0;
            for (var addon in element.addons!) {
              if (addon.haveDiscount!) {
                String price = (double.parse(addonPrice.toString()) + (double.parse(addon.discountPrice.toString()))).toStringAsFixed(2);
                addonPrice = double.parse(price);
              } else {
                String price = (double.parse(addonPrice.toString()) + (double.parse(addon.price.toString()))).toStringAsFixed(2);
                addonPrice = double.parse(price);
              }
            }

            double variationPrice = 0.0;
            for (var variation in element.variations!) {
              for (var options in variation.options!) {
                if (options.haveDiscount!) {
                  String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
                  variationPrice = double.parse(price);
                } else {
                  String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
                  variationPrice = double.parse(price);
                }
              }
            }

            if (element.discount! > 0) {
              String totalPrice = (double.parse(element.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
              price = double.parse(totalPrice);
            } else {
              String totalPrice = (double.parse(element.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
              price = double.parse(totalPrice);
            }
            String priceWithQuantity = (double.parse(price.toString()) * element.quantity!).toStringAsFixed(2);
            price = double.parse(priceWithQuantity);
            element.totalPrice = price;
            int index = state.quantityList.list!.indexWhere((element) => element.uuid == event.uuid);
            if (index != -1) {
              state.quantityList.list![index].quantity = state.list[event.index].quantity;
              await _cartRepository.updateProductVariationInCartLocal(event.uuid, state.id, state.quantityList.list![index].quantity!);
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: event.uuid,
                id: state.id,
                quantity: state.quantityList.list![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          }
          emit(state.copyWith(list: state.list, status: SingleFoodFromBannerModalStatus.cartUpdate));
        } else {
          if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
            emit(
              state.copyWith(
                status: SingleFoodFromBannerModalStatus.customError,
                statusCode: 0,
                alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: SingleFoodFromBannerModalStatus.customError,
                statusCode: 0,
                alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                extraMessage: '${state.list[event.index].stockNumber!}',
              ),
            );
          }
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(
        state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.list[event.index].purchaseLimit!}'),
      );
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalRepeatDecreaseEvent(SingleFoodFromBannerModalRepeatDecreaseEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    try {
      state.list[event.index].quantity = state.list[event.index].quantity! - 1;
      List<int> allItemsQuantity = <int>[];
      allItemsQuantity.clear();
      for (var element in state.list) {
        allItemsQuantity.add(int.parse(element.quantity.toString()));
        double price = 0.0;
        double addonPrice = 0.0;
        for (var addon in element.addons!) {
          if (addon.haveDiscount!) {
            String price = (double.parse(addonPrice.toString()) + (double.parse(addon.discountPrice.toString()))).toStringAsFixed(2);
            addonPrice = double.parse(price);
          } else {
            String price = (double.parse(addonPrice.toString()) + (double.parse(addon.price.toString()))).toStringAsFixed(2);
            addonPrice = double.parse(price);
          }
        }

        double variationPrice = 0.0;
        for (var variation in element.variations!) {
          for (var options in variation.options!) {
            if (options.haveDiscount!) {
              String price = (double.parse(variationPrice.toString()) + (double.parse(options.discountPrice.toString()))).toStringAsFixed(2);
              variationPrice = double.parse(price);
            } else {
              String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
              variationPrice = double.parse(price);
            }
          }
        }

        if (element.discount! > 0) {
          String totalPrice = (double.parse(element.offerPrice.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
          price = double.parse(totalPrice);
        } else {
          String totalPrice = (double.parse(element.price.toString()) + double.parse(price.toString()) + (double.parse(addonPrice.toString())) + (double.parse(variationPrice.toString()))).toStringAsFixed(2);
          price = double.parse(totalPrice);
        }
        String priceWithQuantity = (double.parse(price.toString()) * element.quantity!).toStringAsFixed(2);
        price = double.parse(priceWithQuantity);
        element.totalPrice = price;
        int index = state.quantityList.list!.indexWhere((element) => element.uuid == event.uuid);
        if (index != -1) {
          state.quantityList.list![index].quantity = state.list[event.index].quantity;
          await _cartRepository.updateProductVariationInCartLocal(event.uuid, state.id, state.quantityList.list![index].quantity!);
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
            trackingId: await _cartRepository.trackingId(),
            uuid: event.uuid,
            id: state.id,
            quantity: state.quantityList.list![index].quantity!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      bool allZero = allItemsQuantity.every((element) => element == 0);
      for (var element in state.list) {
        if (element.quantity == 0) {
          await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, state.id);
          RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: state.id);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      emit(state.copyWith(list: state.list, status: allZero ? SingleFoodFromBannerModalStatus.saveClose : SingleFoodFromBannerModalStatus.cartUpdate));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSingleFoodFromBannerModalNewItemEvent(SingleFoodFromBannerModalNewItemEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    state.detail.info!.quantity = 1;
    emit(state.copyWith(isFromCart: false, newItem: true, detail: state.detail, status: SingleFoodFromBannerModalStatus.success));
  }

  FutureOr<void> _onSingleFoodFromBannerModalNewItemSaveEvent(SingleFoodFromBannerModalNewItemSaveEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    try {
      var items = state.detail.info!.variations!.where((element) => element.isRequired == true);
      bool requiredValidation = false;
      bool minMaxValidation = false;
      for (var variation in items) {
        int checkIndex = variation.options!.indexWhere((element) => element.checked == true);
        if (checkIndex == -1) {
          requiredValidation = true;
        }
      }
      for (var variation in state.detail.info!.variations!) {
        int minOption = variation.min!;
        final selectedOptions = variation.options!.where((vOption) => vOption.checked == true);
        if (selectedOptions.isEmpty && variation.isRequired! == false) {
          minMaxValidation = false;
        } else if (selectedOptions.length < minOption) {
          minMaxValidation = true;
        }
      }
      final String locale = await _authRepository.getLocale();
      if (requiredValidation == false && minMaxValidation == false) {
        List<option_data.AddonConfigModel> savedFoodAddon = <option_data.AddonConfigModel>[];
        savedFoodAddon.clear();
        for (var element in state.detail.info!.addons!) {
          if (element.checked == true) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            option_data.AddonConfigModel savedData = option_data.AddonConfigModel.fromJson(myMap, locale.toString());
            savedFoodAddon.add(savedData);
          }
        }
        List<option_data.VariationOptionConfigModel> savedFoodOptions = <option_data.VariationOptionConfigModel>[];
        List<option_data.VariationConfigModel> savedFoodVariations = <option_data.VariationConfigModel>[];
        savedFoodVariations.clear();
        for (var variation in state.detail.info!.variations!) {
          savedFoodOptions.clear();
          for (var option in variation.options!) {
            if (option.checked == true) {
              var convertedItem = jsonEncode(option).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              option_data.VariationOptionConfigModel savedData = option_data.VariationOptionConfigModel.fromJson(myMap);
              savedFoodOptions.add(savedData);
            }
          }
          if (savedFoodOptions.isNotEmpty) {
            option_data.VariationConfigModel variationsData = option_data.VariationConfigModel(
              isRequired: variation.isRequired,
              title: variation.title,
              type: variation.type,
              min: variation.min,
              max: variation.max,
              options: [...savedFoodOptions],
            );
            savedFoodVariations.add(variationsData);
          }
        }

        food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
        List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
        restaurantTranslation.clear();
        for (var element in state.detail.info!.restaurants!.translations!) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
          restaurantTranslation.add(savedData);
        }
        restaurantInfo.id = state.detail.info!.restaurants!.id!;
        restaurantInfo.slug = state.detail.info!.restaurants!.slug!;
        restaurantInfo.name = state.detail.info!.restaurants!.name!;
        restaurantInfo.cover = state.detail.info!.restaurants!.cover!;
        restaurantInfo.logo = state.detail.info!.restaurants!.logo!;
        restaurantInfo.translations = restaurantTranslation;

        List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
        savedAddon.clear();
        List<String> newAddonIds = <String>[];
        newAddonIds.clear();
        for (var element in savedFoodAddon) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
          newAddonIds.add(savedData.id!);
          savedAddon.add(savedData);
        }

        List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
        savedVariations.clear();
        List<String> newVariationIds = <String>[];
        for (var element in savedFoodVariations) {
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
        await _cartRepository.getRepeatList(state.id).then((value) {
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
          int quantity = (int.parse(state.detail.info!.quantity.toString()) + int.parse(state.detail.info!.quantity.toString()));
          if (quantity < state.detail.info!.purchaseLimit!) {
            bool checkAddonHaveStock = true;
            bool checkVariationHaveStock = true;
            int addonOutOfStockLimitNumber = 0;
            int variationOutOfStockLimitNumber = 0;
            for (var addon in state.detail.info!.addons!) {
              if (quantity >= addon.stockNumber!) {
                checkAddonHaveStock = false;
                if (addonOutOfStockLimitNumber == 0) {
                  addonOutOfStockLimitNumber = addon.stockNumber!;
                }
              }
            }
            for (var variation in state.detail.info!.variations!) {
              for (var options in variation.options!) {
                if (quantity >= options.stock!) {
                  checkVariationHaveStock = false;
                  if (variationOutOfStockLimitNumber == 0) {
                    variationOutOfStockLimitNumber = options.stock!;
                  }
                }
              }
            }
            if (state.detail.info!.stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.detail.info!.quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
              state.detail.info!.cartEntity = cartEntityPromise;
              emit(state.copyWith(status: SingleFoodFromBannerModalStatus.saveClose, detail: state.detail));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: state.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.detail.info!.quantity! < state.detail.info!.stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.detail.info!.quantity = quantity;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, quantity);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
              state.detail.info!.cartEntity = cartEntityPromise;
              emit(state.copyWith(status: SingleFoodFromBannerModalStatus.saveClose, detail: state.detail));
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(trackingId: await _cartRepository.trackingId(), uuid: sameUuid, id: state.id, quantity: quantity);
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    detail: state.detail,
                    status: SingleFoodFromBannerModalStatus.customError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.detail.info!.quantity = state.detail.info!.stockNumber!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, state.detail.info!.stockNumber!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
                state.detail.info!.cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    detail: state.detail,
                    status: SingleFoodFromBannerModalStatus.customError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                    extraMessage: '${state.detail.info!.stockNumber!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: state.id,
                  quantity: state.detail.info!.stockNumber!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          } else {
            bool checkAddonHaveStock = true;
            bool checkVariationHaveStock = true;
            int addonOutOfStockLimitNumber = 0;
            int variationOutOfStockLimitNumber = 0;
            for (var addon in state.detail.info!.addons!) {
              if (quantity >= addon.stockNumber!) {
                checkAddonHaveStock = false;
                if (addonOutOfStockLimitNumber == 0) {
                  addonOutOfStockLimitNumber = addon.stockNumber!;
                }
              }
            }
            for (var variation in state.detail.info!.variations!) {
              for (var options in variation.options!) {
                if (quantity >= options.stock!) {
                  checkVariationHaveStock = false;
                  if (variationOutOfStockLimitNumber == 0) {
                    variationOutOfStockLimitNumber = options.stock!;
                  }
                }
              }
            }
            if (state.detail.info!.stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
              state.detail.info!.quantity = state.detail.info!.purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, state.detail.info!.purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
              state.detail.info!.cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  detail: state.detail,
                  status: SingleFoodFromBannerModalStatus.customError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.detail.info!.purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: state.id,
                quantity: state.detail.info!.purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.detail.info!.quantity! < state.detail.info!.stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
              state.detail.info!.quantity = state.detail.info!.purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, state.detail.info!.purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
              state.detail.info!.cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  detail: state.detail,
                  status: SingleFoodFromBannerModalStatus.customError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.detail.info!.purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: state.id,
                quantity: state.detail.info!.purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                emit(
                  state.copyWith(
                    detail: state.detail,
                    status: SingleFoodFromBannerModalStatus.customError,
                    statusCode: 0,
                    alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                    extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                  ),
                );
              } else {
                state.detail.info!.quantity = state.detail.info!.purchaseLimit!;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, state.id, state.detail.info!.purchaseLimit!);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
                state.detail.info!.cartEntity = cartEntityPromise;
                emit(
                  state.copyWith(
                    detail: state.detail,
                    status: SingleFoodFromBannerModalStatus.customError,
                    statusCode: 0,
                    alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                    extraMessage: '${state.detail.info!.purchaseLimit!}',
                  ),
                );
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: state.id,
                  quantity: state.detail.info!.purchaseLimit!,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              }
            }
          }
        } else {
          int quantity = (int.parse(state.detail.info!.quantity.toString()) + int.parse(state.detail.info!.quantity.toString()));
          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.detail.info!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }
          final String locale = await _authRepository.getLocale();
          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.detail.info!.foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.detail.info!.name,
            shortDescription: state.detail.info!.shortDescription,
            image: state.detail.info!.image,
            restaurant: state.detail.info!.restaurant,
            foodType: state.detail.info!.foodType,
            price: state.detail.info!.price,
            discountType: state.detail.info!.discountType,
            discount: state.detail.info!.discount,
            offerPrice: state.detail.info!.offerPrice,
            purchaseLimit: state.detail.info!.purchaseLimit,
            stockNumber: state.detail.info!.stockNumber,
            stockType: state.detail.info!.stockType,
            quantity: state.detail.info!.quantity,
            id: state.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.detail.info!.status,
            inStock: state.detail.info!.inStock,
            startTime: state.detail.info!.startTime,
            endTime: state.detail.info!.endTime,
            taxationEnable: state.detail.info!.taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: state.instruction,
            locale: locale.toString(),
          );
          state.detail.info!.quantity = quantity;
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(state.id);
          state.detail.info!.cartEntity = cartEntityPromise;
          emit(state.copyWith(status: SingleFoodFromBannerModalStatus.saveClose, detail: state.detail));

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
            cookingInstruction: state.instruction,
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
            emit(state.copyWith(status: SingleFoodFromBannerModalStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else {
        emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: 'Validation Failed, Please select required items', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSingleFoodInstructionChangeEvent(SingleFoodInstructionChangeEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    emit(state.copyWith(instruction: event.instruction, status: SingleFoodFromBannerModalStatus.success));
  }

  FutureOr<void> _onSingleFoodShareEvent(SingleFoodShareEvent event, Emitter<SingleFoodFromBannerModalState> emit) async {
    try {
      final String websiteURL = await _authRepository.websiteURL();
      final String restaurantSlug = state.detail.info!.restaurants!.slug!;
      final String restaurantURL = '$websiteURL/$restaurantSlug?source=app_sharing';
      final String shareText = "🍽️ ${state.detail.info!.name!} from ${state.detail.info!.restaurants!.name!} is a must-try! Order now and satisfy your cravings 😋 | $restaurantURL";
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SingleFoodFromBannerModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

