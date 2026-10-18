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
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_variation_modal_response_model.dart';
import 'package:user/app/core/models/food_variation_modal_response_model.dart' as option_data;
import 'package:user/app/core/models/single_food_info_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'subscription_food_info_modal_event.dart';
part 'subscription_food_info_modal_state.dart';

class SubscriptionFoodInfoModalBloc extends Bloc<SubscriptionFoodInfoModalEvent, SubscriptionFoodInfoModalState> {
  final AuthRepository _authRepository = AuthRepository();
  SubscriptionFoodInfoModalBloc()
    : super(
        SubscriptionFoodInfoModalState(
          info: SingleFoodInfoModel(locale: ''),
          cartItem: FoodVariationModalResponseModel(locale: ''),
        ),
      ) {
    on<SubscriptionFoodInfoInitialEvent>(_onSubscriptionFoodInfoInitialEvent);
    on<SubscriptionFoodInfoModalAddonsEvent>(_onSubscriptionFoodInfoModalAddonsEvent);
    on<SubscriptionFoodInfoModalVariationOptionEvent>(_onSubscriptionFoodInfoModalVariationOptionEvent);
    on<SubscriptionFoodInfoModalSaveEvent>(_onSubscriptionFoodInfoModalSaveEvent);
    on<SubscriptionFoodInfoModalShaveEvent>(_onSubscriptionFoodInfoModalShaveEvent);
  }

  FutureOr<void> _onSubscriptionFoodInfoInitialEvent(SubscriptionFoodInfoInitialEvent event, Emitter<SubscriptionFoodInfoModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_food_detail"}, 'tiffin_food_detail_screen', 'tiffin_food_detail_screen');
      emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.loading, id: event.id));
      if (event.id.isNotEmpty && event.data.isNotEmpty) {
        Map<String, dynamic>? myMap = jsonDecode(event.data) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        SingleFoodInfoModel data = SingleFoodInfoModel.fromJson(myMap, locale.toString());
        data.quantity = event.totalOrders;
        for (var element in data.addons!) {
          if (data.discount! > 0 && data.discountType! == '%') {
            element.haveDiscount = true;
            final double discount = double.parse(data.discount!.toString());
            String discountValue = (double.parse(element.price.toString()) - (double.parse(element.price.toString()) * double.parse(discount.toString()) / 100)).toStringAsFixed(2);
            element.discountPrice = double.parse(discountValue);
          } else {
            element.haveDiscount = false;
            element.discountPrice = 0.0;
          }
        }

        for (var variationElement in data.variations!) {
          for (var optionElement in variationElement.options!) {
            if (data.discount! > 0 && data.discountType! == '%') {
              optionElement.haveDiscount = true;
              final double discount = double.parse(data.discount!.toString());
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
        state.cartItem.quantity = data.quantity;
        state.cartItem.variations = [];
        emit(
          state.copyWith(
            status: SubscriptionFoodInfoModalStatus.success,
            info: data,
            canAddAddons: event.canAddAddons,
            canAddVariations: event.canAddVariations,
            cartItem: state.cartItem,
            originalPrice: data.price!,
            discountPrice: data.offerPrice!,
          ),
        );
        double realPrice = state.info.price!;
        String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
        String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
        double originalPrice = double.parse(originalPriceString);
        double discountPrice = state.info.offerPrice!;
        if (state.info.discountType! == '%') {
          String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.info.discount!.toString())) / 100).toStringAsFixed(2);
          String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
          discountPrice = double.parse(discountedPriceString);
        } else {
          String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.info.discount!.toString())).toStringAsFixed(2);
          discountPrice = double.parse(discountPriceString);
        }
        String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
        originalPrice = double.parse(originalPriceStringFinal);
        String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
        discountPrice = double.parse(discountPriceStringFinal);
        emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice));
        if (event.inCart.isNotEmpty && event.inCart != '') {
          List<dynamic> jsonList = jsonDecode(event.inCart);
          final String locale = await _authRepository.getLocale();
          List<FoodInCartModel> foodInCart = jsonList.map((json) => FoodInCartModel.fromJson(json, locale.toString())).toList();
          for (var cartItem in foodInCart) {
            if (cartItem.id == state.info.id) {
              for (var cartAddon in cartItem.addons!) {
                for (var foodAddon in state.info.addons!) {
                  if (foodAddon.id! == cartAddon.id) {
                    foodAddon.checked = true;
                  }
                }
              }
              for (var cartVariation in cartItem.variations!) {
                for (var cartOptions in cartVariation.options!) {
                  for (var foodVariation in state.info.variations!) {
                    for (var foodOptions in foodVariation.options!) {
                      if (foodOptions.name! == cartOptions.name!) {
                        foodOptions.checked = true;
                      }
                    }
                  }
                }
              }
            }
          }
          emit(state.copyWith(info: state.info));
          double realPrice = state.info.price!;
          String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
          String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
          double originalPrice = double.parse(originalPriceString);
          double discountPrice = state.info.offerPrice!;
          if (state.info.discountType! == '%') {
            String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.info.discount!.toString())) / 100).toStringAsFixed(2);
            String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
            discountPrice = double.parse(discountedPriceString);
          } else {
            String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.info.discount!.toString())).toStringAsFixed(2);
            discountPrice = double.parse(discountPriceString);
          }
          String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
          originalPrice = double.parse(originalPriceStringFinal);
          String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
          discountPrice = double.parse(discountPriceStringFinal);
          emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice));
        }
      } else {
        emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSubscriptionFoodInfoModalAddonsEvent(SubscriptionFoodInfoModalAddonsEvent event, Emitter<SubscriptionFoodInfoModalState> emit) async {
    state.info.addons![event.index].checked = !state.info.addons![event.index].checked!;
    emit(state.copyWith(info: state.info, status: SubscriptionFoodInfoModalStatus.success));
    double realPrice = state.info.price!;
    String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
    String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
    double originalPrice = double.parse(originalPriceString);
    double discountPrice = state.info.offerPrice!;
    if (state.info.discountType! == '%') {
      String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.info.discount!.toString())) / 100).toStringAsFixed(2);
      String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
      discountPrice = double.parse(discountedPriceString);
    } else {
      String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.info.discount!.toString())).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceString);
    }
    String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
    originalPrice = double.parse(originalPriceStringFinal);
    String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
    discountPrice = double.parse(discountPriceStringFinal);
    emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: SubscriptionFoodInfoModalStatus.success));
  }

  FutureOr<void> _onSubscriptionFoodInfoModalVariationOptionEvent(SubscriptionFoodInfoModalVariationOptionEvent event, Emitter<SubscriptionFoodInfoModalState> emit) async {
    if (event.type == 'single') {
      int radioIndex = state.info.variations![event.vIndex].options!.indexWhere((element) => element.checked == true);
      if (radioIndex != -1) {
        state.info.variations![event.vIndex].options![radioIndex].checked = false;
        emit(state.copyWith(info: state.info, status: SubscriptionFoodInfoModalStatus.success));
      }

      state.info.variations![event.vIndex].options![event.oIndex].checked = true;
      emit(state.copyWith(info: state.info, status: SubscriptionFoodInfoModalStatus.success));
    } else {
      if (state.info.variations![event.vIndex].options![event.oIndex].checked! || state.info.variations![event.vIndex].options![event.oIndex].enable!) {
        state.info.variations![event.vIndex].options![event.oIndex].checked = !state.info.variations![event.vIndex].options![event.oIndex].checked!;
        emit(state.copyWith(info: state.info, status: SubscriptionFoodInfoModalStatus.success));
      }

      final totalChecked = state.info.variations![event.vIndex].options!.where((vOptions) => vOptions.checked == true);
      for (var vOptoins in state.info.variations![event.vIndex].options!) {
        if (!vOptoins.checked! && totalChecked.length >= state.info.variations![event.vIndex].max!) {
          vOptoins.enable = false;
        } else {
          vOptoins.enable = true;
        }
      }
      emit(state.copyWith(info: state.info, status: SubscriptionFoodInfoModalStatus.success));
    }

    double realPrice = state.info.price!;
    String extraPriceString = (double.parse(calculateAddons().toString()) + (double.parse(calculateVariations().toString()))).toStringAsFixed(2);
    String originalPriceString = (double.parse(realPrice.toString()) + double.parse(extraPriceString)).toStringAsFixed(2);
    double originalPrice = double.parse(originalPriceString);
    double discountPrice = state.info.offerPrice!;
    if (state.info.discountType! == '%') {
      String discountAmountString = ((double.parse(originalPrice.toString()) * double.parse(state.info.discount!.toString())) / 100).toStringAsFixed(2);
      String discountedPriceString = (double.parse(originalPrice.toString()) - double.parse(discountAmountString)).toStringAsFixed(2);
      discountPrice = double.parse(discountedPriceString);
    } else {
      String discountPriceString = (double.parse(originalPrice.toString()) - double.parse(state.info.discount!.toString())).toStringAsFixed(2);
      discountPrice = double.parse(discountPriceString);
    }
    String originalPriceStringFinal = (double.parse(originalPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
    originalPrice = double.parse(originalPriceStringFinal);
    String discountPriceStringFinal = (double.parse(discountPrice.toString()) * state.info.quantity!).toStringAsFixed(2);
    discountPrice = double.parse(discountPriceStringFinal);
    emit(state.copyWith(originalPrice: originalPrice, discountPrice: discountPrice, status: SubscriptionFoodInfoModalStatus.success));
  }

  double calculateAddons() {
    double addonPrice = 0.0;
    for (var element in state.info.addons!) {
      if (element.checked == true) {
        String price = (double.parse(addonPrice.toString()) + (double.parse(element.price.toString()))).toStringAsFixed(2);
        addonPrice = double.parse(price);
      }
    }
    return addonPrice;
  }

  double calculateVariations() {
    double variationPrice = 0.0;
    for (var variation in state.info.variations!) {
      for (var options in variation.options!) {
        if (options.checked == true) {
          String price = (double.parse(variationPrice.toString()) + (double.parse(options.price.toString()))).toStringAsFixed(2);
          variationPrice = double.parse(price);
        }
      }
    }
    return variationPrice;
  }

  FutureOr<void> _onSubscriptionFoodInfoModalSaveEvent(SubscriptionFoodInfoModalSaveEvent event, Emitter<SubscriptionFoodInfoModalState> emit) async {
    if (state.canAddVariations) {
      var items = state.info.variations!.where((element) => element.isRequired == true);
      bool requiredValidation = false;
      bool minMaxValidation = false;
      for (var variation in items) {
        int checkIndex = variation.options!.indexWhere((element) => element.checked == true);
        if (checkIndex == -1 && state.canAddVariations) {
          requiredValidation = true;
        }
      }
      for (var variation in state.info.variations!) {
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
        for (var element in state.info.addons!) {
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
        for (var variation in state.info.variations!) {
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
        state.cartItem.quantity = state.info.quantity;
        state.cartItem.variations = savedVariations;
        emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.saveClose, cartItem: state.cartItem));
      } else {
        emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.customError, statusCode: 0, alertMessage: 'Validation Failed, Please select required items', extraMessage: ''));
      }
    } else {
      state.cartItem.addons = [];
      state.cartItem.variations = [];
      emit(state.copyWith(cartItem: state.cartItem));
      emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.saveClose, cartItem: state.cartItem));
    }
  }

  FutureOr<void> _onSubscriptionFoodInfoModalShaveEvent(SubscriptionFoodInfoModalShaveEvent event, Emitter<SubscriptionFoodInfoModalState> emit) async {
    try {
      final String websiteURL = await _authRepository.websiteURL();
      final String restaurantSlug = state.info.restaurants!.slug!;
      final String restaurantURL = '$websiteURL/$restaurantSlug?source=app_sharing';
      final String shareText = "🍽️ ${state.info.name!} from ${state.info.restaurants!.name!} is a must-try! Order now and satisfy your cravings 😋 | $restaurantURL";
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SubscriptionFoodInfoModalStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

