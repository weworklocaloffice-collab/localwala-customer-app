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
import 'package:user/app/core/models/favourite_restaurants_model.dart';
import 'package:user/app/core/models/request/favourite_restaurants_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'favourite_restaurants_event.dart';
part 'favourite_restaurants_state.dart';

class FavouriteRestaurantsBloc extends Bloc<FavouriteRestaurantsEvent, FavouriteRestaurantsState> {
  final LocationRepository _locationRepository = LocationRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final AuthRepository _authRepository = AuthRepository();
  FavouriteRestaurantsBloc()
    : super(
        FavouriteRestaurantsState(
          pageSize: ApiRequestService.pageSize,
          restaurants: FavouriteRestaurantModal(locale: ''),
        ),
      ) {
    on<FavouriteRestaurantsInitialEvent>(_onFavouriteRestaurantsInitialEvent);
    on<FavouriteRestaurantsLoadMoreEvent>(_onFavouriteRestaurantsLoadMoreEvent);
    on<FavouriteDeleteRestaurantEvent>(_onFavouriteDeleteRestaurantEvent);
    on<FavouriteRestaurantsSilenceEvent>(_onFavouriteRestaurantsSilenceEvent);
  }

  FutureOr<void> _onFavouriteRestaurantsInitialEvent(FavouriteRestaurantsInitialEvent event, Emitter<FavouriteRestaurantsState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "favourite_restaurants"}, 'favourite_restaurant_screen', 'favourite_restaurant_screen');
      final String userId = await _favouriteRepository.userId();
      final String userRole = await _favouriteRepository.userRole();
      if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        FavouriteRestaurantRequestModel param = FavouriteRestaurantRequestModel(
          latitude: userLatitude != 0 ? userLatitude : 0,
          longitude: userLongitude != 0 ? userLongitude : 0,
          page: state.currentPage,
          limit: state.pageSize,
          uid: userId,
        );
        DioApiResponse response = await _favouriteRepository.getFavouriteRestaurants(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FavouriteRestaurantsStatus.empty));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            final String locale = await _authRepository.getLocale();
            FavouriteRestaurantModal data = FavouriteRestaurantModal.fromJson(myMap, locale.toString());
            emit(state.copyWith(status: FavouriteRestaurantsStatus.success, restaurants: data));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FavouriteRestaurantsStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: FavouriteRestaurantsStatus.unAuthorized, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteRestaurantsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteRestaurantsLoadMoreEvent(FavouriteRestaurantsLoadMoreEvent event, Emitter<FavouriteRestaurantsState> emit) async {
    if (state.restaurants.restaurants!.length < state.restaurants.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _favouriteRepository.userId();
        if (userId.isNotEmpty) {
          final double userLatitude = await _locationRepository.userLatitude();
          final double userLongitude = await _locationRepository.userLongitude();
          FavouriteRestaurantRequestModel param = FavouriteRestaurantRequestModel(
            latitude: userLatitude != 0 ? userLatitude : 0,
            longitude: userLongitude != 0 ? userLongitude : 0,
            page: state.currentPage,
            limit: state.pageSize * 2,
            uid: userId,
          );
          DioApiResponse response = await _favouriteRepository.getFavouriteRestaurants(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (!initialResponse.success!) {
              emit(state.copyWith(status: FavouriteRestaurantsStatus.empty, loadMore: false));
            } else {
              Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
              final String locale = await _authRepository.getLocale();
              FavouriteRestaurantModal data = FavouriteRestaurantModal.fromJson(myMap, locale.toString());
              emit(state.copyWith(status: FavouriteRestaurantsStatus.success, restaurants: data, loadMore: false, pageSize: state.pageSize * 2));
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FavouriteRestaurantsStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
          }
        } else {
          emit(state.copyWith(status: FavouriteRestaurantsStatus.unAuthorized, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: '', loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FavouriteRestaurantsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onFavouriteDeleteRestaurantEvent(FavouriteDeleteRestaurantEvent event, Emitter<FavouriteRestaurantsState> emit) async {
    emit(state.copyWith(status: FavouriteRestaurantsStatus.removeFavStart));
    try {
      final String userId = await _favouriteRepository.userId();
      DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, event.restaurantId);
      if (response.errorType == NetErrorType.none) {
        state.restaurants.restaurants!.removeWhere((element) => element.id == event.restaurantId);
        state.restaurants.restaurantIds!.removeWhere((element) => element == event.restaurantId);
        emit(state.copyWith(restaurants: state.restaurants, status: FavouriteRestaurantsStatus.removeFavDone));
        if (state.restaurants.restaurants!.isEmpty) {
          emit(state.copyWith(status: FavouriteRestaurantsStatus.empty));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FavouriteRestaurantsStatus.removeFavFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FavouriteRestaurantsStatus.removeFavFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFavouriteRestaurantsSilenceEvent(FavouriteRestaurantsSilenceEvent event, Emitter<FavouriteRestaurantsState> emit) async {
    try {
      final String userId = await _favouriteRepository.userId();
      if (userId.isNotEmpty) {
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        FavouriteRestaurantRequestModel param = FavouriteRestaurantRequestModel(
          latitude: userLatitude != 0 ? userLatitude : 0,
          longitude: userLongitude != 0 ? userLongitude : 0,
          page: state.currentPage,
          limit: state.pageSize,
          uid: userId,
        );
        DioApiResponse response = await _favouriteRepository.getFavouriteRestaurants(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FavouriteRestaurantsStatus.empty));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            final String locale = await _authRepository.getLocale();
            FavouriteRestaurantModal data = FavouriteRestaurantModal.fromJson(myMap, locale.toString());
            emit(state.copyWith(status: FavouriteRestaurantsStatus.success, restaurants: data));
          }
        }
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

