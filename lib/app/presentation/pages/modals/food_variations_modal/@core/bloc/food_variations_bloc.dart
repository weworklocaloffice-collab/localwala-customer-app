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
import 'package:user/app/core/models/food_variation_modal_response_model.dart';
import 'package:user/app/core/models/food_variation_modal_response_model.dart' as option_data;
import 'package:user/app/core/models/food_variations_options_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'food_variations_event.dart';
part 'food_variations_state.dart';

class FoodVariationsBloc extends Bloc<FoodVariationsEvent, FoodVariationsState> {
  final AuthRepository _authRepository = AuthRepository();
  FoodVariationsBloc()
    : super(
        FoodVariationsState(
          options: FoodVariationOptionsModel(locale: ''),
          cartItem: FoodVariationModalResponseModel(locale: ''),
        ),
      ) {
    on<FoodVariationsInitialEvent>(_onFoodVariationsInitialEvent);
    on<FoodVariationsAddonsEvent>(_onFoodVariationsAddonsEvent);
    on<FoodVariationOptionEvent>(_onFoodVariationOptionEvent);
    on<FoodVariationQuantityEvent>(_onFoodVariationQuantityEvent);
    on<FoodVariationInstructionChangeEvent>(_onFoodVariationInstructionChangeEvent);
    on<FoodVariationSaveEvent>(_onFoodVariationSaveEvent);
  }

  FutureOr<void> _onFoodVariationsInitialEvent(FoodVariationsInitialEvent event, Emitter<FoodVariationsState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "food_variations"}, 'food_variations_screen', 'food_variations_screen');
      Map<String, dynamic>? myMap = jsonDecode(event.options) as Map<String, dynamic>;
      final String locale = await _authRepository.getLocale();
      FoodVariationOptionsModel data = FoodVariationOptionsModel.fromJson(myMap, locale.toString());
      for (var element in data.addons!) {
        if (element.stockNumber == 0) {
          element.inStock = false;
        }
        if (event.discount > 0 && event.discountType == '%') {
          element.haveDiscount = true;
          final double discount = double.parse(event.discount.toString());
          String discountValue = (double.parse(element.price.toString()) - (double.parse(element.price.toString()) * double.parse(discount.toString()) / 100)).toStringAsFixed(2);
          element.discountPrice = double.parse(discountValue);
        } else {
          element.haveDiscount = false;
          element.discountPrice = 0.0;
        }
      }
      for (var variationElement in data.variations!) {
        for (var optionElement in variationElement.options!) {
          if (optionElement.stock == 0) {
            optionElement.inStock = false;
          }
          if (event.discount > 0 && event.discountType == '%') {
            optionElement.haveDiscount = true;
            final double discount = double.parse(event.discount.toString());
            String discountValue = (double.parse(optionElement.price.toString()) - (double.parse(optionElement.price.toString()) * double.parse(discount.toString()) / 100)).toStringAsFixed(2);
            optionElement.discountPrice = double.parse(discountValue);
          } else {
            optionElement.haveDiscount = false;
            optionElement.discountPrice = 0.0;
          }
        }
      }
      data.variations!.sort((a, b) => b.isRequired! ? 1 : -1);
      state.cartItem.addons = [];
      state.cartItem.quantity = state.quantity;
      state.cartItem.variations = [];
      emit(
        state.copyWith(
          options: data,
          cartItem: state.cartItem,
          id: event.id,
          name: event.name,
          image: event.image,
          price: event.price,
          offerPrice: event.offerPrice,
          discountType: event.discountType,
          discount: event.discount,
          originalPrice: event.price,
          discountPrice: event.offerPrice,
          purchaseLimit: event.purchaseLimit,
          stockNumber: event.stockNumber,
          stockType: event.stockType,
          quantity: 1,
          status: FoodVariationsStatus.success,
        ),
      );
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodVariationsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodVariationsAddonsEvent(FoodVariationsAddonsEvent event, Emitter<FoodVariationsState> emit) async {
    if (state.options.addons![event.index].inStock!) {
      state.options.addons![event.index].checked = !state.options.addons![event.index].checked!;
      for (var addon in state.options.addons!) {
        addon.limitCrossed = false;
      }
      for (var variation in state.options.variations!) {
        for (var options in variation.options!) {
          options.limitCrossed = false;
        }
      }
      emit(state.copyWith(options: state.options, quantity: 1, status: FoodVariationsStatus.success));
      double realPrice = state.price;
      String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
      String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
      double originalPrice = double.parse(originalPriceString);
      double discountPrice = state.offerPrice;
      if (state.discountType == '%') {
        String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.discount.toString())) / 100).toStringAsFixed(2);
        String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
        discountPrice = double.parse(discountedPriceString);
      } else {
        String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.discount.toString())).toStringAsFixed(2);
        discountPrice = double.parse(discountPriceString);
      }
      String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.quantity).toStringAsFixed(2);
      originalPrice = double.parse(originalPriceStringFinal);
      String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.quantity).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceStringFinal);
      emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: FoodVariationsStatus.success));
    }
  }

  FutureOr<void> _onFoodVariationOptionEvent(FoodVariationOptionEvent event, Emitter<FoodVariationsState> emit) async {
    if (state.options.variations![event.vIndex].options![event.oIndex].inStock!) {
      for (var addon in state.options.addons!) {
        addon.limitCrossed = false;
      }
      if (event.type == 'single') {
        int radioIndex = state.options.variations![event.vIndex].options!.indexWhere((element) => element.checked == true);
        if (radioIndex != -1) {
          state.options.variations![event.vIndex].options![radioIndex].checked = false;
          for (var variation in state.options.variations!) {
            for (var options in variation.options!) {
              options.limitCrossed = false;
            }
          }
          emit(state.copyWith(options: state.options, quantity: 1, status: FoodVariationsStatus.success));
        }

        state.options.variations![event.vIndex].options![event.oIndex].checked = true;
        for (var variation in state.options.variations!) {
          for (var options in variation.options!) {
            options.limitCrossed = false;
          }
        }
        emit(state.copyWith(options: state.options, quantity: 1, status: FoodVariationsStatus.success));
      } else {
        if (state.options.variations![event.vIndex].options![event.oIndex].checked! || state.options.variations![event.vIndex].options![event.oIndex].enable!) {
          state.options.variations![event.vIndex].options![event.oIndex].checked = !state.options.variations![event.vIndex].options![event.oIndex].checked!;
          for (var variation in state.options.variations!) {
            for (var options in variation.options!) {
              options.limitCrossed = false;
            }
          }
          emit(state.copyWith(options: state.options, quantity: 1, status: FoodVariationsStatus.success));
        }

        final totalChecked = state.options.variations![event.vIndex].options!.where((vOptions) => vOptions.checked == true);
        for (var vOptoins in state.options.variations![event.vIndex].options!) {
          if (!vOptoins.checked! && totalChecked.length >= state.options.variations![event.vIndex].max!) {
            vOptoins.enable = false;
          } else {
            vOptoins.enable = true;
          }
        }
        for (var variation in state.options.variations!) {
          for (var options in variation.options!) {
            options.limitCrossed = false;
          }
        }
        emit(state.copyWith(options: state.options, quantity: 1, status: FoodVariationsStatus.success));
      }
      double realPrice = state.price;
      String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
      String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
      double originalPrice = double.parse(originalPriceString);
      double discountPrice = state.offerPrice;
      if (state.discountType == '%') {
        String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.discount.toString())) / 100).toStringAsFixed(2);
        String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
        discountPrice = double.parse(discountedPriceString);
      } else {
        String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.discount.toString())).toStringAsFixed(2);
        discountPrice = double.parse(discountPriceString);
      }
      String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.quantity).toStringAsFixed(2);
      originalPrice = double.parse(originalPriceStringFinal);
      String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.quantity).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceStringFinal);
      emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: FoodVariationsStatus.success));
    }
  }

  FutureOr<void> _onFoodVariationQuantityEvent(FoodVariationQuantityEvent event, Emitter<FoodVariationsState> emit) async {
    if (state.quantity == 1 && event.action == 'decrease') {
      emit(state.copyWith(status: FoodVariationsStatus.emptyClose, cartItem: state.cartItem));
    } else if (event.action == 'decrease') {
      emit(state.copyWith(quantity: state.quantity - 1, status: FoodVariationsStatus.success));
    } else if (event.action == 'increase') {
      if (state.quantity < state.purchaseLimit) {
        bool checkAddonHaveStock = true;
        bool checkVariationHaveStock = true;
        int outOfStockLimitNumber = 0;
        for (var addon in state.options.addons!) {
          if (addon.checked! && state.quantity >= addon.stockNumber!) {
            addon.limitCrossed = true;
            checkAddonHaveStock = false;
            outOfStockLimitNumber = addon.stockNumber!;
          }
        }
        for (var variation in state.options.variations!) {
          for (var options in variation.options!) {
            if (options.checked! && state.quantity >= options.stock!) {
              options.limitCrossed = true;
              checkVariationHaveStock = false;
              outOfStockLimitNumber = options.stock!;
            }
          }
        }
        if (state.stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
          emit(state.copyWith(quantity: state.quantity + 1, status: FoodVariationsStatus.success));
        } else if (state.quantity < state.stockNumber && checkAddonHaveStock && checkVariationHaveStock) {
          emit(state.copyWith(quantity: state.quantity + 1, status: FoodVariationsStatus.success));
        } else {
          if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
            emit(state.copyWith(status: FoodVariationsStatus.failure, statusCode: 0, alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.', extraMessage: '$outOfStockLimitNumber'));
          } else {
            emit(state.copyWith(status: FoodVariationsStatus.failure, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.stockNumber}'));
          }
        }
      } else {
        emit(state.copyWith(status: FoodVariationsStatus.failure, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.purchaseLimit}'));
      }
    }
    double realPrice = state.price;
    String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
    String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
    double originalPrice = double.parse(originalPriceString);
    double discountPrice = state.offerPrice;
    if (state.discountType == '%') {
      String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.discount.toString())) / 100).toStringAsFixed(2);
      String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
      discountPrice = double.parse(discountedPriceString);
    } else {
      String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.discount.toString())).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceString);
    }
    String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.quantity).toStringAsFixed(2);
    originalPrice = double.parse(originalPriceStringFinal);
    String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.quantity).toStringAsFixed(2);
    discountPrice = double.parse(discountPriceStringFinal);
    emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: FoodVariationsStatus.success));
  }

  FutureOr<void> _onFoodVariationInstructionChangeEvent(FoodVariationInstructionChangeEvent event, Emitter<FoodVariationsState> emit) async {
    emit(state.copyWith(instruction: event.instruction, status: FoodVariationsStatus.success));
  }

  FutureOr<void> _onFoodVariationSaveEvent(FoodVariationSaveEvent event, Emitter<FoodVariationsState> emit) async {
    var items = state.options.variations!.where((element) => element.isRequired == true);
    bool requiredValidation = false;
    bool minMaxValidation = false;
    for (var variation in items) {
      int checkIndex = variation.options!.indexWhere((element) => element.checked == true);
      if (checkIndex == -1) {
        requiredValidation = true;
      }
    }
    for (var variation in state.options.variations!) {
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
      List<option_data.AddonModelConfigModel> savedAddon = <option_data.AddonModelConfigModel>[];
      savedAddon.clear();
      for (var element in state.options.addons!) {
        if (element.checked == true) {
          var convertedItem = jsonEncode(element).toString();
          Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
          option_data.AddonModelConfigModel savedData = option_data.AddonModelConfigModel.fromJson(myMap, locale.toString());
          savedAddon.add(savedData);
        }
      }
      List<option_data.VariationOptionConfigModel> savedOptions = <option_data.VariationOptionConfigModel>[];
      List<option_data.VariationConfigModel> savedVariations = <option_data.VariationConfigModel>[];
      savedVariations.clear();
      for (var variation in state.options.variations!) {
        savedOptions.clear();
        for (var option in variation.options!) {
          if (option.checked == true) {
            var convertedItem = jsonEncode(option).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            option_data.VariationOptionConfigModel savedData = option_data.VariationOptionConfigModel.fromJson(myMap);
            savedOptions.add(savedData);
          }
        }
        if (savedOptions.isNotEmpty) {
          option_data.VariationConfigModel variationsData = option_data.VariationConfigModel(
            isRequired: variation.isRequired,
            title: variation.title,
            type: variation.type,
            min: variation.min,
            max: variation.max,
            options: [...savedOptions],
          );
          savedVariations.add(variationsData);
        }
      }
      state.cartItem.addons = savedAddon;
      state.cartItem.quantity = state.quantity;
      state.cartItem.variations = savedVariations;
      emit(state.copyWith(status: FoodVariationsStatus.successClose, cartItem: state.cartItem));
    } else {
      emit(state.copyWith(status: FoodVariationsStatus.failure, statusCode: 0, alertMessage: 'Validation Failed, Please select required items', extraMessage: ''));
    }
  }

  double calculateAddons() {
    double addonPrice = 0.0;
    for (var element in state.options.addons!) {
      if (element.checked == true) {
        String price = (double.parse(addonPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
        addonPrice = double.parse(price);
      }
    }
    return addonPrice;
  }

  double calculateVariations() {
    double variationPrice = 0.0;
    for (var variation in state.options.variations!) {
      for (var options in variation.options!) {
        if (options.checked == true) {
          String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
          variationPrice = double.parse(price);
        }
      }
    }
    return variationPrice;
  }
}

