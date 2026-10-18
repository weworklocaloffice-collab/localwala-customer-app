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
import 'package:user/app/core/models/request/tiffin_subscription_list_from_restaurant_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/tiffin_subscription_list_from_restaurant_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'restaurant_tiffin_subscription_packages_event.dart';
part 'restaurant_tiffin_subscription_packages_state.dart';

class RestaurantTiffinSubscriptionPackagesBloc extends Bloc<RestaurantTiffinSubscriptionPackagesEvent, RestaurantTiffinSubscriptionPackagesState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  RestaurantTiffinSubscriptionPackagesBloc()
    : super(
        RestaurantTiffinSubscriptionPackagesState(
          pageSize: ApiRequestService.pageSize,
          list: TiffinSubscriptionFromListRestaurantResponseModel(results: [], locale: ''),
        ),
      ) {
    on<RestaurantTiffinSubscriptionPackagesInitialEvent>(_onRestaurantTiffinSubscriptionPackagesInitialEvent);
    on<RestaurantTiffinSubscriptionPackagesLoadMoreEvent>(_onRestaurantTiffinSubscriptionPackagesLoadMoreEvent);
  }

  FutureOr<void> _onRestaurantTiffinSubscriptionPackagesInitialEvent(RestaurantTiffinSubscriptionPackagesInitialEvent event, Emitter<RestaurantTiffinSubscriptionPackagesState> emit) async {
    try {
      await _authRepository.saveEvent(
        'visited_screen',
        {"screen": "restaurant_tiffin_packages", "restaurant": event.restaurant, "name": event.restaurantName},
        '${event.restaurantName}_tiffin_packages_screen',
        '${event.restaurantName}_tiffin_packages_screen',
      );
      emit(state.copyWith(status: RestaurantTiffinSubscriptionPackagesStatus.loading, restaurant: event.restaurant, restaurantName: event.restaurantName));
      TiffinSubscriptionFromListRestaurantRequestModel param = TiffinSubscriptionFromListRestaurantRequestModel(restaurant: event.restaurant, page: state.currentPage, limit: state.pageSize);
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.getTiffinSubscriptionListFromRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        TiffinSubscriptionFromListRestaurantResponseModel data = TiffinSubscriptionFromListRestaurantResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.results!.isNotEmpty ? RestaurantTiffinSubscriptionPackagesStatus.success : RestaurantTiffinSubscriptionPackagesStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantTiffinSubscriptionPackagesStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantTiffinSubscriptionPackagesStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantTiffinSubscriptionPackagesLoadMoreEvent(RestaurantTiffinSubscriptionPackagesLoadMoreEvent event, Emitter<RestaurantTiffinSubscriptionPackagesState> emit) async {
    if (state.list.results!.length < state.list.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        TiffinSubscriptionFromListRestaurantRequestModel param = TiffinSubscriptionFromListRestaurantRequestModel(restaurant: state.restaurant, page: state.currentPage, limit: state.pageSize * 2);
        DioApiResponse response = await _subscriptionTiffinPackagesRepository.getTiffinSubscriptionListFromRestaurant(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          TiffinSubscriptionFromListRestaurantResponseModel data = TiffinSubscriptionFromListRestaurantResponseModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(status: data.results!.isNotEmpty ? RestaurantTiffinSubscriptionPackagesStatus.success : RestaurantTiffinSubscriptionPackagesStatus.empty, list: data, loadMore: false, pageSize: state.pageSize * 2));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: RestaurantTiffinSubscriptionPackagesStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: RestaurantTiffinSubscriptionPackagesStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

