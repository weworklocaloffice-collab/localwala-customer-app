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

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/repeat_quantity_list_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_variation_modal_repeat_event.dart';
part 'food_variation_modal_repeat_state.dart';

class FoodVariationModalRepeatBloc extends Bloc<FoodVariationModalRepeatEvent, FoodVariationModalRepeatState> {
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  FoodVariationModalRepeatBloc() : super(FoodVariationModalRepeatState(quantityList: RepeatQuantityListModal())) {
    on<FoodVariationModalRepeatInitialEvent>(_onFoodVariationModalRepeatInitialEvent);
    on<FoodVariationModalRepeatIncreaseEvent>(_onFoodVariationModalRepeatIncreaseEvent);
    on<FoodVariationModalRepeatDecreaseEvent>(_onFoodVariationModalRepeatDecreaseEvent);
  }

  FutureOr<void> _onFoodVariationModalRepeatInitialEvent(FoodVariationModalRepeatInitialEvent event, Emitter<FoodVariationModalRepeatState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "food_variation_repeat"}, 'food_variation_repeat_screen', 'food_variation_repeat_screen');
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
        emit(state.copyWith(list: value, quantityList: quantityList, status: FoodVariationModalRepeatStatus.success));
      });
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodVariationModalRepeatStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodVariationModalRepeatIncreaseEvent(FoodVariationModalRepeatIncreaseEvent event, Emitter<FoodVariationModalRepeatState> emit) async {
    if (state.list[event.index].quantity! < state.list[event.index].purchaseLimit!) {
      bool checkAddonHaveStock = true;
      bool checkVariationHaveStock = true;
      int outOfStockLimitNumber = 0;
      for (var addon in state.list[event.index].addons!) {
        if (state.list[event.index].quantity! >= addon.stockNumber!) {
          checkAddonHaveStock = false;
          outOfStockLimitNumber = addon.stockNumber!;
        }
      }
      for (var variation in state.list[event.index].variations!) {
        for (var options in variation.options!) {
          if (state.list[event.index].quantity! >= options.stock!) {
            checkVariationHaveStock = false;
            outOfStockLimitNumber = options.stock!;
          }
        }
      }
      if (state.list[event.index].stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
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
          }
        }
        emit(state.copyWith(list: state.list, status: FoodVariationModalRepeatStatus.success));
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
          }
        }
        emit(state.copyWith(list: state.list, status: FoodVariationModalRepeatStatus.success));
      } else {
        if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
          emit(state.copyWith(status: FoodVariationModalRepeatStatus.customError, statusCode: 0, alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.', extraMessage: '$outOfStockLimitNumber'));
        } else {
          emit(
            state.copyWith(status: FoodVariationModalRepeatStatus.customError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.list[event.index].stockNumber!}'),
          );
        }
      }
    } else {
      emit(state.copyWith(status: FoodVariationModalRepeatStatus.customError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.list[event.index].purchaseLimit!}'));
    }
  }

  FutureOr<void> _onFoodVariationModalRepeatDecreaseEvent(FoodVariationModalRepeatDecreaseEvent event, Emitter<FoodVariationModalRepeatState> emit) async {
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
      }
    }
    bool allZero = allItemsQuantity.every((element) => element == 0);
    emit(state.copyWith(list: state.list, status: allZero ? FoodVariationModalRepeatStatus.successClose : FoodVariationModalRepeatStatus.success));
  }
}

