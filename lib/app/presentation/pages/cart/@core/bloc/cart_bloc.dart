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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/cart_summary_model.dart';
import 'package:user/app/core/models/guest_account_status_response_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/env.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  CartBloc() : super(const CartState()) {
    on<CartInitialEvent>(_onCartInitialEvent);
    on<CartRefreshEvent>(_onCartRefreshEvent);
    on<CartQuantityEvent>(_onCartQuantityEvent);
    on<CartOnCheckoutEvent>(_onCartOnCheckoutEvent);
    on<CartGuestCheckoutEvent>(_onCartGuestCheckoutEvent);
  }

  FutureOr<void> _onCartInitialEvent(CartInitialEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    await _authRepository.saveEvent('visited_screen', {"screen": "cart"}, 'cart_screen', 'cart_screen');
    try {
      bool? guestCheckout = await _authRepository.isGuestCheckout();
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, guestCheckout: guestCheckout, status: value.isEmpty ? CartStatus.empty : CartStatus.success));
      });
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CartStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCartRefreshEvent(CartRefreshEvent event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, status: value.isEmpty ? CartStatus.empty : CartStatus.success));
      });
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CartStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCartQuantityEvent(CartQuantityEvent event, Emitter<CartState> emit) async {
    if (event.action == 'decrease') {
      if (state.summary[event.summaryIndex].summary![event.foodIndex].quantity! == 1) {
        await _cartRepository.removeFromCartWithUuidLocal(state.summary[event.summaryIndex].summary![event.foodIndex].uuid!, state.summary[event.summaryIndex].summary![event.foodIndex].id!);
        RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(
          trackingId: await _cartRepository.trackingId(),
          uuid: state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
          id: state.summary[event.summaryIndex].summary![event.foodIndex].id!,
        );
        DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
        if (cartOnlineResponse.errorType == NetErrorType.none) {
        } else {
          Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: CartStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        state.summary[event.summaryIndex].summary![event.foodIndex].quantity = state.summary[event.summaryIndex].summary![event.foodIndex].quantity! - 1;
        await _cartRepository.updateProductVariationInCartLocal(
          state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
          state.summary[event.summaryIndex].summary![event.foodIndex].id!,
          state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
        );
        UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
          trackingId: await _cartRepository.trackingId(),
          uuid: state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
          id: state.summary[event.summaryIndex].summary![event.foodIndex].id!,
          quantity: state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
        );
        DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
        if (cartOnlineResponse.errorType == NetErrorType.none) {
        } else {
          Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: CartStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
      emit(state.copyWith(status: CartStatus.cartUpdate));
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, status: value.isEmpty ? CartStatus.empty : CartStatus.success));
      });
    } else if (event.action == 'increase') {
      if (state.summary[event.summaryIndex].summary![event.foodIndex].quantity! < state.summary[event.summaryIndex].summary![event.foodIndex].purchaseLimit!) {
        bool checkAddonHaveStock = true;
        bool checkVariationHaveStock = true;
        int addonOutOfStockLimitNumber = 0;
        int variationOutOfStockLimitNumber = 0;
        for (var addon in state.summary[event.summaryIndex].summary![event.foodIndex].addons!) {
          if (state.summary[event.summaryIndex].summary![event.foodIndex].quantity! >= addon.stockNumber!) {
            checkAddonHaveStock = false;
            if (addonOutOfStockLimitNumber == 0) {
              addonOutOfStockLimitNumber = addon.stockNumber!;
            }
          }
        }
        for (var variation in state.summary[event.summaryIndex].summary![event.foodIndex].variations!) {
          for (var options in variation.options!) {
            if (state.summary[event.summaryIndex].summary![event.foodIndex].quantity! >= options.stock!) {
              checkVariationHaveStock = false;
              if (variationOutOfStockLimitNumber == 0) {
                variationOutOfStockLimitNumber = options.stock!;
              }
            }
          }
        }
        if (state.summary[event.summaryIndex].summary![event.foodIndex].stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
          state.summary[event.summaryIndex].summary![event.foodIndex].quantity = state.summary[event.summaryIndex].summary![event.foodIndex].quantity! + 1;
          await _cartRepository.updateProductVariationInCartLocal(
            state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
            state.summary[event.summaryIndex].summary![event.foodIndex].id!,
            state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
          );
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
            trackingId: await _cartRepository.trackingId(),
            uuid: state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
            id: state.summary[event.summaryIndex].summary![event.foodIndex].id!,
            quantity: state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: CartStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else if (state.summary[event.summaryIndex].summary![event.foodIndex].quantity! < state.summary[event.summaryIndex].summary![event.foodIndex].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
          state.summary[event.summaryIndex].summary![event.foodIndex].quantity = state.summary[event.summaryIndex].summary![event.foodIndex].quantity! + 1;
          await _cartRepository.updateProductVariationInCartLocal(
            state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
            state.summary[event.summaryIndex].summary![event.foodIndex].id!,
            state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
          );
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
            trackingId: await _cartRepository.trackingId(),
            uuid: state.summary[event.summaryIndex].summary![event.foodIndex].uuid!,
            id: state.summary[event.summaryIndex].summary![event.foodIndex].id!,
            quantity: state.summary[event.summaryIndex].summary![event.foodIndex].quantity!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: CartStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
            emit(
              state.copyWith(
                status: CartStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
              ),
            );
          } else {
            emit(
              state.copyWith(
                status: CartStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                extraMessage: '${state.summary[event.summaryIndex].summary![event.foodIndex].stockNumber!}',
              ),
            );
          }
        }
      } else {
        emit(
          state.copyWith(
            status: CartStatus.cartError,
            statusCode: 0,
            alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
            extraMessage: '${state.summary[event.summaryIndex].summary![event.foodIndex].purchaseLimit}',
          ),
        );
      }
      emit(state.copyWith(status: CartStatus.cartUpdate));
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, status: value.isEmpty ? CartStatus.empty : CartStatus.success));
      });
    }
  }

  FutureOr<void> _onCartOnCheckoutEvent(CartOnCheckoutEvent event, Emitter<CartState> emit) async {
    bool isAuthorized = await _cartRepository.isAuthorized();
    emit(state.copyWith(checkoutName: event.name, checkoutRestaurant: event.restaurant, status: isAuthorized ? CartStatus.authorized : CartStatus.unauthorized));
  }

  FutureOr<void> _onCartGuestCheckoutEvent(CartGuestCheckoutEvent event, Emitter<CartState> emit) async {
    try {
      emit(state.copyWith(status: CartStatus.guestCheckoutStart));
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
          emit(state.copyWith(status: CartStatus.guestCheckoutSuccess));
        } else {
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          emit(state.copyWith(status: CartStatus.guestCheckoutSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CartStatus.guestCheckoutFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CartStatus.guestCheckoutFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

