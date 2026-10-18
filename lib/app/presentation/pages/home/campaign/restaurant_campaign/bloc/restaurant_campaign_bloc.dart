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
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/restaurant_campaign_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/restaurant_campaign_detail_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'restaurant_campaign_event.dart';
part 'restaurant_campaign_state.dart';

class RestaurantCampaignBloc extends Bloc<RestaurantCampaignEvent, RestaurantCampaignState> {
  final HomeRepository _homeRepository = HomeRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final AuthRepository _authRepository = AuthRepository();
  RestaurantCampaignBloc() : super(RestaurantCampaignState(campaign: RestaurantCampaignDetailModel(locale: ''))) {
    on<RestaurantCampaignInitialEvent>(_onRestaurantCampaignInitialEvent);
    on<RestaurantCampaignFavouriteEvent>(_onRestaurantCampaignFavouriteEvent);
    on<RestaurantCampaignHideEvent>(_onRestaurantCampaignHideEvent);
    on<RestaurantCampaignRemoveRestaurantEvent>(_onRestaurantCampaignRemoveRestaurantEvent);
    on<RestaurantCampaignUndoHideActionEvent>(_onRestaurantCampaignUndoHideActionEvent);
    on<RestaurantCampaignNavigateEvent>(_onRestaurantCampaignNavigateEvent);
  }

  FutureOr<void> _onRestaurantCampaignInitialEvent(RestaurantCampaignInitialEvent event, Emitter<RestaurantCampaignState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_campaign", "id": event.id}, 'restaurant_campaign_${event.id}_screen', 'restaurant_campaign_${event.id}_screen');
      bool isAuthorized = await _homeRepository.isAuthorized();
      emit(state.copyWith(status: RestaurantCampaignStatus.loading, isAuthorized: isAuthorized));
      final String userId = await _homeRepository.userId();
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      RestaurantCampaignRequestModel param = RestaurantCampaignRequestModel(campaignId: event.id, latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, uid: userId);
      DioApiResponse response = await _homeRepository.getRestaurantCampaignDetails(event.id, param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        RestaurantCampaignDetailModel data = RestaurantCampaignDetailModel.fromJson(myMap, locale.toString());
        List<String> favIds = <String>[];
        for (var element in data.inCampaign!) {
          if (element.isFavourite!) {
            favIds.add(element.id!);
          }
        }
        emit(state.copyWith(status: RestaurantCampaignStatus.success, campaign: data, favIds: favIds));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantCampaignStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantCampaignStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantCampaignFavouriteEvent(RestaurantCampaignFavouriteEvent event, Emitter<RestaurantCampaignState> emit) async {
    final String userId = await _homeRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      updateFavouriteData(event.id);
      emit(state.copyWith(campaign: state.campaign));
      if (event.isFavourite == false) {
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'restaurant', restaurant: event.id, food: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              state.favIds.add(event.id);
              emit(state.copyWith(favIds: state.favIds, status: RestaurantCampaignStatus.favUpdate));
            }
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(campaign: state.campaign));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(campaign: state.campaign));
          emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
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
            emit(state.copyWith(favIds: state.favIds, status: RestaurantCampaignStatus.favUpdate));
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(campaign: state.campaign));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(campaign: state.campaign));
          emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  Future<void> updateFavouriteData(String id) async {
    int index = state.campaign.inCampaign!.indexWhere((element) => element.id == id);
    if (index != -1) {
      if (state.campaign.inCampaign![index].isFavourite == false) {
        state.campaign.inCampaign![index].isFavourite = true;
      } else {
        state.campaign.inCampaign![index].isFavourite = false;
      }
    }
  }

  FutureOr<void> _onRestaurantCampaignHideEvent(RestaurantCampaignHideEvent event, Emitter<RestaurantCampaignState> emit) async {
    try {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(campaign: state.campaign));
      final String userId = await _homeRepository.userId();
      HideRestaurantRequestModel param = HideRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.hideRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, false);
          emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(campaign: state.campaign));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: RestaurantCampaignStatus.hidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, false);
        emit(state.copyWith(campaign: state.campaign));
        emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(campaign: state.campaign));
      emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<void> hideUnhideRestaurant(String id, bool hideUnhide) async {
    int restaurantsIndex = state.campaign.inCampaign!.indexWhere((element) => element.id == id);

    if (restaurantsIndex != -1) {
      state.campaign.inCampaign![restaurantsIndex].isHidden = hideUnhide;
    }
  }

  FutureOr<void> _onRestaurantCampaignRemoveRestaurantEvent(RestaurantCampaignRemoveRestaurantEvent event, Emitter<RestaurantCampaignState> emit) async {
    int restaurantsIndex = state.campaign.inCampaign!.indexWhere((element) => element.id == event.id);
    if (restaurantsIndex != -1) {
      state.campaign.inCampaign!.removeAt(restaurantsIndex);
    }
    emit(state.copyWith(campaign: state.campaign));
  }

  FutureOr<void> _onRestaurantCampaignUndoHideActionEvent(RestaurantCampaignUndoHideActionEvent event, Emitter<RestaurantCampaignState> emit) async {
    try {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(campaign: state.campaign));
      final String userId = await _homeRepository.userId();
      ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, true);
          emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(campaign: state.campaign));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: RestaurantCampaignStatus.unhidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, true);
        emit(state.copyWith(campaign: state.campaign));
        emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(campaign: state.campaign));
      emit(state.copyWith(status: RestaurantCampaignStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantCampaignNavigateEvent(RestaurantCampaignNavigateEvent event, Emitter<RestaurantCampaignState> emit) async {
    await _homeRepository.saveVisitCampaignDetail(state.campaign.detail!.id!, 'restaurant');
  }
}

