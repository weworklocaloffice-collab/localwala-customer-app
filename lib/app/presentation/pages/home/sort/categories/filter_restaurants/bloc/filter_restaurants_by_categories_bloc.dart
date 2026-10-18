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
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/restaurants_by_category_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/restaurants_by_category_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'filter_restaurants_by_categories_event.dart';
part 'filter_restaurants_by_categories_state.dart';

class FilterRestaurantsByCategoriesBloc extends Bloc<FilterRestaurantsByCategoriesEvent, FilterRestaurantsByCategoriesState> {
  final LocationRepository _locationRepository = LocationRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final AuthRepository _authRepository = AuthRepository();
  FilterRestaurantsByCategoriesBloc()
    : super(
        FilterRestaurantsByCategoriesState(
          pageSize: ApiRequestService.pageSize,
          restaurants: RestaurantsByCategoryModel(locale: ''),
        ),
      ) {
    on<FilterRestaurantsByCategoriesInitialEvent>(_onFilterRestaurantsByCategoriesInitialEvent);
    on<FilterRestaurantsByCategoriesFavouriteEvent>(_onFilterRestaurantsByCategoriesFavouriteEvent);
    on<FilterRestaurantsByCategoriesLoadMoreEvent>(_onFilterRestaurantsByCategoriesLoadMoreEvent);
    on<FilterRestaurantsByCategoriesHideEvent>(_onFilterRestaurantsByCategoriesHideEvent);
    on<FilterRestaurantsByCategoriesRemoveRestaurantEvent>(_onFilterRestaurantsByCategoriesRemoveRestaurantEvent);
    on<FilterRestaurantsByCategoriesUndoHideActionEvent>(_onFilterRestaurantsByCategoriesUndoHideActionEvent);
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesInitialEvent(FilterRestaurantsByCategoriesInitialEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "filter_restaurants_with_category", "category": event.slug}, '${event.slug}_restaurant_category_screen', '${event.slug}_restaurant_category_screen');
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final String userId = await _homeRepository.userId();
      bool isAuthorized = await _homeRepository.isAuthorized();
      emit(state.copyWith(slug: event.slug, isAuthorized: isAuthorized));
      RestaurantsByCategoryRequestModel param = RestaurantsByCategoryRequestModel(
        category: event.slug,
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
        page: state.currentPage,
        limit: state.pageSize,
        uid: userId,
      );
      DioApiResponse response = await _homeRepository.getRestaurantsByCategory(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          RestaurantsByCategoryModel sortResponse = RestaurantsByCategoryModel.fromJson(myMap, locale.toString());
          sortResponse.restaurants!.sort((a, b) => b.promote! ? 1 : -1);
          List<String> favIds = <String>[];
          for (var element in sortResponse.restaurants!) {
            if (element.isFavourite! == true) {
              favIds.add(element.id!);
            }
          }
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.success, restaurants: sortResponse, favIds: favIds));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesFavouriteEvent(FilterRestaurantsByCategoriesFavouriteEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    final String userId = await _homeRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      updateFavouriteData(event.id);
      emit(state.copyWith(restaurants: state.restaurants));
      if (event.isFavourite == false) {
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'restaurant', restaurant: event.id, food: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              state.favIds.add(event.id);
              emit(state.copyWith(favIds: state.favIds, status: FilterRestaurantsByCategoriesStatus.favUpdate));
            }
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(restaurants: state.restaurants));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(restaurants: state.restaurants));
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        try {
          final String userId = await _favouriteRepository.userId();
          DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, event.id);
          if (response.errorType == NetErrorType.none) {
            state.favIds.removeWhere((element) => element == event.id);
            emit(state.copyWith(favIds: state.favIds, status: FilterRestaurantsByCategoriesStatus.favUpdate));
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(restaurants: state.restaurants));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(restaurants: state.restaurants));
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  Future<void> updateFavouriteData(String id) async {
    int index = state.restaurants.restaurants!.indexWhere((element) => element.id == id);
    if (index != -1) {
      if (state.restaurants.restaurants![index].isFavourite == false) {
        state.restaurants.restaurants![index].isFavourite = true;
      } else {
        state.restaurants.restaurants![index].isFavourite = false;
      }
    }
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesLoadMoreEvent(FilterRestaurantsByCategoriesLoadMoreEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    if (state.restaurants.restaurants!.length < state.restaurants.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        final String userId = await _homeRepository.userId();
        RestaurantsByCategoryRequestModel param = RestaurantsByCategoryRequestModel(
          category: state.slug,
          latitude: userLatitude != 0 ? userLatitude : 0,
          longitude: userLongitude != 0 ? userLongitude : 0,
          page: state.currentPage,
          limit: state.pageSize * 2,
          uid: userId,
        );
        DioApiResponse response = await _homeRepository.getRestaurantsByCategory(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.empty, loadMore: false));
          } else {
            final String locale = await _authRepository.getLocale();
            RestaurantsByCategoryModel sortResponse = RestaurantsByCategoryModel.fromJson(myMap, locale.toString());
            List<String> favIds = <String>[];
            for (var element in sortResponse.restaurants!) {
              if (element.isFavourite! == true) {
                favIds.add(element.id!);
              }
            }
            emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.success, restaurants: sortResponse, favIds: favIds, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesHideEvent(FilterRestaurantsByCategoriesHideEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    try {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(restaurants: state.restaurants));
      final String userId = await _homeRepository.userId();
      HideRestaurantRequestModel param = HideRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.hideRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, false);
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(restaurants: state.restaurants));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: FilterRestaurantsByCategoriesStatus.hidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, false);
        emit(state.copyWith(restaurants: state.restaurants));
        emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(restaurants: state.restaurants));
      emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesRemoveRestaurantEvent(FilterRestaurantsByCategoriesRemoveRestaurantEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    int restaurantsIndex = state.restaurants.restaurants!.indexWhere((element) => element.id == event.id);
    if (restaurantsIndex != -1) {
      state.restaurants.restaurants!.removeAt(restaurantsIndex);
    }
    emit(state.copyWith(restaurants: state.restaurants));
  }

  FutureOr<void> _onFilterRestaurantsByCategoriesUndoHideActionEvent(FilterRestaurantsByCategoriesUndoHideActionEvent event, Emitter<FilterRestaurantsByCategoriesState> emit) async {
    try {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(restaurants: state.restaurants));
      final String userId = await _homeRepository.userId();
      ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, true);
          emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(restaurants: state.restaurants));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: FilterRestaurantsByCategoriesStatus.unhidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, true);
        emit(state.copyWith(restaurants: state.restaurants));
        emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(restaurants: state.restaurants));
      emit(state.copyWith(status: FilterRestaurantsByCategoriesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<void> hideUnhideRestaurant(String id, bool hideUnhide) async {
    int restaurantsIndex = state.restaurants.restaurants!.indexWhere((element) => element.id == id);

    if (restaurantsIndex != -1) {
      state.restaurants.restaurants![restaurantsIndex].isHidden = hideUnhide;
    }
  }
}

