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
import 'package:user/app/core/models/dining_response_model.dart';
import 'package:user/app/core/models/request/dining_restaurant_request_model.dart';
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_event.dart';
part 'dining_state.dart';

class DiningBloc extends Bloc<DiningEvent, DiningState> {
  final LocationRepository _locationRepository = LocationRepository();
  final DiningRepository _diningRepository = DiningRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBloc()
    : super(
        DiningState(
          pageSize: ApiRequestService.pageSize,
          model: DiningResponseModel(locale: ''),
        ),
      ) {
    on<DiningInitialEvent>(_onDiningInitialEvent);
    on<DiningLoadMoreEvent>(_onDiningLoadMoreEvent);
    on<DiningFavouriteEvent>(_onDiningFavouriteEvent);
    on<DiningRefreshFavouriteEvent>(_onDiningRefreshFavouriteEvent);
    on<DiningPullRefreshEvent>(_onDiningPullRefreshEvent);
    on<DiningHideEvent>(_onDiningHideEvent);
    on<DiningRemoveRestaurantFromListEvent>(_onDiningRemoveRestaurantFromListEvent);
    on<DiningUndoHideActionEvent>(_onDiningUndoHideActionEvent);
    on<DiningSilentHideEvent>(_onDiningSilentHideEvent);
    on<DiningSilentUnHideEvent>(_onDiningSilentUnHideEvent);
  }

  FutureOr<void> _onDiningInitialEvent(DiningInitialEvent event, Emitter<DiningState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_list"}, 'dining_restaurant_screen', 'dining_restaurant_screen');
      final String addressTitle = await _locationRepository.getAddressTitle();
      final String fullAddress = await _locationRepository.getFullAddress();
      bool isAuthorized = await _diningRepository.isAuthorized();
      String? locale = await _diningRepository.getLocale();
      emit(state.copyWith(addressTitle: addressTitle, addressSubTitle: fullAddress, isAuthorized: isAuthorized, locale: locale.isNotEmpty ? locale : Environments.defaultLanguage, status: DiningStatus.loading));
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final String userId = await _diningRepository.userId();
      DiningRestaurantRequestModel param = DiningRestaurantRequestModel(
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
        page: state.currentPage,
        limit: state.pageSize,
        uid: userId,
      );
      DioApiResponse response = await _diningRepository.getDiningRestaurants(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DiningStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          DiningResponseModel diningResponse = DiningResponseModel.fromJson(myMap, locale.toString());
          diningResponse.newArrivals!.sort((a, b) => b.promote! ? 1 : -1);
          diningResponse.dinings!.sort((a, b) => b.promote! ? 1 : -1);

          List<String> favIds = <String>[];
          for (var element in diningResponse.dinings!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in diningResponse.newArrivals!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in diningResponse.popularDining!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }

          emit(state.copyWith(status: DiningStatus.success, favIds: favIds, model: diningResponse));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningLoadMoreEvent(DiningLoadMoreEvent event, Emitter<DiningState> emit) async {
    if (state.model.dinings!.length < state.model.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        final String userId = await _diningRepository.userId();
        DiningRestaurantRequestModel param = DiningRestaurantRequestModel(
          latitude: userLatitude != 0 ? userLatitude : 0,
          longitude: userLongitude != 0 ? userLongitude : 0,
          page: state.currentPage,
          limit: state.pageSize * 2,
          uid: userId,
        );
        DioApiResponse response = await _diningRepository.getDiningRestaurants(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: DiningStatus.empty, loadMore: false));
          } else {
            final String locale = await _authRepository.getLocale();
            DiningResponseModel diningResponse = DiningResponseModel.fromJson(myMap, locale.toString());
            emit(state.copyWith(status: DiningStatus.success, model: diningResponse, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DiningStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: DiningStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onDiningFavouriteEvent(DiningFavouriteEvent event, Emitter<DiningState> emit) async {
    final String userId = await _diningRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      updateFavouriteData(event.id);
      emit(state.copyWith(model: state.model));
      if (event.isFavourite == false) {
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'restaurant', restaurant: event.id, food: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              state.favIds.add(event.id);
              emit(state.copyWith(status: DiningStatus.restaurantFav, favIds: state.favIds));
            }
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(model: state.model));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: DiningStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(model: state.model));
          emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        try {
          DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, event.id);
          if (response.errorType == NetErrorType.none) {
            state.favIds.removeWhere((element) => element == event.id);
            emit(state.copyWith(favIds: state.favIds, status: DiningStatus.restaurantFav));
          } else {
            updateFavouriteData(event.id);
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: DiningStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    }
  }

  Future<void> updateFavouriteData(String id) async {
    int newArrivalsIndex = state.model.newArrivals!.indexWhere((element) => element.id == id);
    if (newArrivalsIndex != -1) {
      if (state.model.newArrivals![newArrivalsIndex].isFavourite == false) {
        state.model.newArrivals![newArrivalsIndex].isFavourite = true;
      } else {
        state.model.newArrivals![newArrivalsIndex].isFavourite = false;
      }
    }

    int diningIndex = state.model.dinings!.indexWhere((element) => element.id == id);
    if (diningIndex != -1) {
      if (state.model.dinings![diningIndex].isFavourite == false) {
        state.model.dinings![diningIndex].isFavourite = true;
      } else {
        state.model.dinings![diningIndex].isFavourite = false;
      }
    }

    int popularRestaurantIndex = state.model.popularDining!.indexWhere((element) => element.id == id);
    if (popularRestaurantIndex != -1) {
      if (state.model.popularDining![popularRestaurantIndex].isFavourite == false) {
        state.model.popularDining![popularRestaurantIndex].isFavourite = true;
      } else {
        state.model.popularDining![popularRestaurantIndex].isFavourite = false;
      }
    }
  }

  FutureOr<void> _onDiningRefreshFavouriteEvent(DiningRefreshFavouriteEvent event, Emitter<DiningState> emit) async {
    for (var element in state.model.newArrivals!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    for (var element in state.model.dinings!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    for (var element in state.model.popularDining!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    emit(state.copyWith(status: DiningStatus.success, model: state.model));
  }

  FutureOr<void> _onDiningPullRefreshEvent(DiningPullRefreshEvent event, Emitter<DiningState> emit) async {
    try {
      final String addressTitle = await _locationRepository.getAddressTitle();
      final String fullAddress = await _locationRepository.getFullAddress();
      bool isAuthorized = await _diningRepository.isAuthorized();
      String? locale = await _diningRepository.getLocale();
      emit(
        state.copyWith(
          addressTitle: addressTitle,
          addressSubTitle: fullAddress,
          isAuthorized: isAuthorized,
          locale: locale.isNotEmpty ? locale : Environments.defaultLanguage,
          pageSize: ApiRequestService.pageSize,
          status: DiningStatus.loading,
        ),
      );
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final String userId = await _diningRepository.userId();
      DiningRestaurantRequestModel param = DiningRestaurantRequestModel(
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
        page: state.currentPage,
        limit: state.pageSize,
        uid: userId,
      );
      DioApiResponse response = await _diningRepository.getDiningRestaurants(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DiningStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          DiningResponseModel diningResponse = DiningResponseModel.fromJson(myMap, locale.toString());
          diningResponse.newArrivals!.sort((a, b) => b.promote! ? 1 : -1);
          diningResponse.dinings!.sort((a, b) => b.promote! ? 1 : -1);

          List<String> favIds = <String>[];
          for (var element in diningResponse.dinings!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in diningResponse.newArrivals!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in diningResponse.popularDining!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }

          emit(state.copyWith(status: DiningStatus.success, favIds: favIds, model: diningResponse));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningHideEvent(DiningHideEvent event, Emitter<DiningState> emit) async {
    try {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(model: state.model));
      final String userId = await _homeRepository.userId();
      HideRestaurantRequestModel param = HideRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.hideRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, false);
          emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(model: state.model));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: DiningStatus.hidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, false);
        emit(state.copyWith(model: state.model));
        emit(state.copyWith(status: DiningStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(model: state.model));
      emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<void> hideUnhideRestaurant(String id, bool hideUnhide) async {
    int newArrivalsIndex = state.model.newArrivals!.indexWhere((element) => element.id == id);

    int diningIndex = state.model.dinings!.indexWhere((element) => element.id == id);

    int popularRestaurantIndex = state.model.popularDining!.indexWhere((element) => element.id == id);

    if (newArrivalsIndex != -1) {
      state.model.newArrivals![newArrivalsIndex].isHidden = hideUnhide;
    }

    if (diningIndex != -1) {
      state.model.dinings![diningIndex].isHidden = hideUnhide;
    }

    if (popularRestaurantIndex != -1) {
      state.model.popularDining![popularRestaurantIndex].isHidden = hideUnhide;
    }
  }

  FutureOr<void> _onDiningRemoveRestaurantFromListEvent(DiningRemoveRestaurantFromListEvent event, Emitter<DiningState> emit) async {
    int newArrivalsIndex = state.model.newArrivals!.indexWhere((element) => element.id == event.id);

    int diningIndex = state.model.dinings!.indexWhere((element) => element.id == event.id);

    int popularRestaurantIndex = state.model.popularDining!.indexWhere((element) => element.id == event.id);

    if (newArrivalsIndex != -1) {
      state.model.newArrivals!.removeAt(newArrivalsIndex);
    }

    if (diningIndex != -1) {
      state.model.dinings!.removeAt(diningIndex);
    }

    if (popularRestaurantIndex != -1) {
      state.model.popularDining!.removeAt(popularRestaurantIndex);
    }

    emit(state.copyWith(model: state.model));
  }

  FutureOr<void> _onDiningUndoHideActionEvent(DiningUndoHideActionEvent event, Emitter<DiningState> emit) async {
    try {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(model: state.model));
      final String userId = await _homeRepository.userId();
      ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, true);
          emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(model: state.model));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: DiningStatus.unhidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, true);
        emit(state.copyWith(model: state.model));
        emit(state.copyWith(status: DiningStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(model: state.model));
      emit(state.copyWith(status: DiningStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningSilentHideEvent(DiningSilentHideEvent event, Emitter<DiningState> emit) async {
    hideUnhideRestaurant(event.id, true);
    emit(state.copyWith(model: state.model));
  }

  FutureOr<void> _onDiningSilentUnHideEvent(DiningSilentUnHideEvent event, Emitter<DiningState> emit) async {
    hideUnhideRestaurant(event.id, false);
    emit(state.copyWith(model: state.model));
  }
}

