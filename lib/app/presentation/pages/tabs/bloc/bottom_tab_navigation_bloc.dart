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
import 'package:user/app/core/models/request/remove_cart_item_by_restaurant_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/env.dart';

part 'bottom_tab_navigation_event.dart';
part 'bottom_tab_navigation_state.dart';

class BottomTabNavigationBloc extends Bloc<BottomTabNavigationEvent, BottomTabNavigationState> {
  final LocationRepository _locationRepository = LocationRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  BottomTabNavigationBloc() : super(const BottomTabNavigationState(tabIndex: 2, canActivate: true)) {
    on<BottomNavigationTabInitialEvent>(_onBottomNavigationTabInitialEvent);
    on<BottomNavigationTabChange>(_onBottomNavigationTabChange);
    on<BottomNavigationRefreshCartEvent>(_onBottomNavigationRefreshCartEvent);
    on<BottomNavigationRemoveCartItemByRestaurant>(_onBottomNavigationRemoveCartItemByRestaurant);
    on<BottomTabNavigationOnCheckoutEvent>(_onBottomTabNavigationOnCheckoutEvent);
    on<BottomTabNavigationGuestCheckoutEvent>(_onBottomTabNavigationGuestCheckoutEvent);
    on<BottomTabNavigationChangeInitialEvent>(_onBottomTabNavigationChangeInitialEvent);
  }

  FutureOr<void> _onBottomNavigationTabInitialEvent(BottomNavigationTabInitialEvent event, Emitter<BottomTabNavigationState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "tabs"}, 'tabs_screen', 'tabs_screen');
    final bool haveLocation = await _locationRepository.haveLocation();
    if (!haveLocation) {
      emit(state.copyWith(tabIndex: event.tabIndex, canActivate: false, status: BottomTabNavigationStatus.initial));
    } else {
      emit(state.copyWith(tabIndex: event.tabIndex, canActivate: true, status: BottomTabNavigationStatus.initial));
    }
    try {
      bool? guestCheckout = await _authRepository.isGuestCheckout();
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, guestCheckout: guestCheckout, status: BottomTabNavigationStatus.initial));
      });
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onBottomNavigationTabChange(BottomNavigationTabChange event, Emitter<BottomTabNavigationState> emit) async {
    emit(state.copyWith(tabIndex: event.tabIndex, canActivate: true));
  }

  FutureOr<void> _onBottomNavigationRefreshCartEvent(BottomNavigationRefreshCartEvent event, Emitter<BottomTabNavigationState> emit) async {
    try {
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, status: BottomTabNavigationStatus.initial));
      });
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onBottomNavigationRemoveCartItemByRestaurant(BottomNavigationRemoveCartItemByRestaurant event, Emitter<BottomTabNavigationState> emit) async {
    try {
      await _cartRepository.removeFromCartWithRestaurant(event.restaurantId);
      emit(state.copyWith(status: BottomTabNavigationStatus.updateCart));
      await _cartRepository.getCartSummary().then((value) {
        emit(state.copyWith(summary: value, status: BottomTabNavigationStatus.initial));
      });
      RemoveCartItemByRestaurantRequestModel onlineRemoveParam = RemoveCartItemByRestaurantRequestModel(trackingId: await _cartRepository.trackingId(), restaurant: event.restaurantId);
      DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithRestaurantServer(onlineRemoveParam);
      if (cartOnlineResponse.errorType == NetErrorType.none) {
      } else {
        Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: BottomTabNavigationStatus.updateCartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onBottomTabNavigationOnCheckoutEvent(BottomTabNavigationOnCheckoutEvent event, Emitter<BottomTabNavigationState> emit) async {
    bool isAuthorized = await _cartRepository.isAuthorized();
    emit(state.copyWith(checkoutName: event.name, checkoutRestaurant: event.restaurant, status: isAuthorized ? BottomTabNavigationStatus.authorized : BottomTabNavigationStatus.unauthorized));
  }

  FutureOr<void> _onBottomTabNavigationGuestCheckoutEvent(BottomTabNavigationGuestCheckoutEvent event, Emitter<BottomTabNavigationState> emit) async {
    try {
      emit(state.copyWith(status: BottomTabNavigationStatus.guestCheckoutStart));
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
          emit(state.copyWith(status: BottomTabNavigationStatus.guestCheckoutSuccess));
        } else {
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          emit(state.copyWith(status: BottomTabNavigationStatus.guestCheckoutSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: BottomTabNavigationStatus.guestCheckoutFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: BottomTabNavigationStatus.guestCheckoutFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onBottomTabNavigationChangeInitialEvent(BottomTabNavigationChangeInitialEvent event, Emitter<BottomTabNavigationState> emit) async {
    emit(state.copyWith(status: BottomTabNavigationStatus.initial));
  }
}

