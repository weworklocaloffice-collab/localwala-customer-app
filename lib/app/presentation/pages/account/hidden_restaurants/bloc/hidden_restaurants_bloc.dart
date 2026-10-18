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
import 'package:user/app/core/models/hidden_restaurants_list_model.dart';
import 'package:user/app/core/models/request/hidden_restaurants_list_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'hidden_restaurants_event.dart';
part 'hidden_restaurants_state.dart';

class HiddenRestaurantsBloc extends Bloc<HiddenRestaurantsEvent, HiddenRestaurantsState> {
  final HomeRepository _homeRepository = HomeRepository();
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  HiddenRestaurantsBloc()
    : super(
        HiddenRestaurantsState(
          list: HiddenRestaurantListModel(restaurants: [], success: false, locale: ''),
        ),
      ) {
    on<HiddenRestaurantsInitialEvent>(_onHiddenRestaurantsInitialEvent);
    on<HiddenRestaurantChangeEvent>(_onHiddenRestaurantChangeEvent);
  }

  FutureOr<void> _onHiddenRestaurantsInitialEvent(HiddenRestaurantsInitialEvent event, Emitter<HiddenRestaurantsState> emit) async {
    try {
      emit(state.copyWith(status: HiddenRestaurantsStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "hidden_restaurants"}, 'hidden_restaurant_screen', 'hidden_restaurant_screen');
      final String userId = await _homeRepository.userId();
      if (userId.isNotEmpty) {
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        HiddenRestaurantListRequestModel param = HiddenRestaurantListRequestModel(uid: userId, latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0);
        DioApiResponse response = await _restaurantRepository.getMyHiddenRestaurantList(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          HiddenRestaurantListModel data = HiddenRestaurantListModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(list: data, status: data.restaurants!.isEmpty ? HiddenRestaurantsStatus.empty : HiddenRestaurantsStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: HiddenRestaurantsStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: HiddenRestaurantsStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HiddenRestaurantsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHiddenRestaurantChangeEvent(HiddenRestaurantChangeEvent event, Emitter<HiddenRestaurantsState> emit) async {
    try {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(list: state.list));
      final String userId = await _homeRepository.userId();
      ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, true);
          emit(state.copyWith(status: HiddenRestaurantsStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(list: state.list));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, true);
        emit(state.copyWith(list: state.list));
        emit(state.copyWith(status: HiddenRestaurantsStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(list: state.list));
      emit(state.copyWith(status: HiddenRestaurantsStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<void> hideUnhideRestaurant(String id, bool hideUnhide) async {
    int restaurantIndex = state.list.restaurants!.indexWhere((element) => element.id == id);
    if (restaurantIndex != -1) {
      state.list.restaurants![restaurantIndex].isHidden = hideUnhide;
    }
  }
}

