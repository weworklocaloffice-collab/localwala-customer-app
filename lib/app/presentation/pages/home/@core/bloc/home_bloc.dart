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
import 'package:user/app/core/models/campaign_list_model.dart';
import 'package:user/app/core/models/cart_item_response_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/request/cart_item_request_model.dart';
import 'package:user/app/core/models/request/cart_item_request_model.dart' as online_food_cart_model;
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/food_variations_response_data_modal_model.dart';
import 'package:user/app/core/models/notification_count_response_model.dart';
import 'package:user/app/core/models/repeat_quantity_modal_response_model.dart';
import 'package:user/app/core/models/request/hide_restaurant_request_model.dart';
import 'package:user/app/core/models/request/remove_cart_item_with_food_id_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/home_response_model.dart';
import 'package:user/app/core/models/request/home_restaurant_request_model.dart';
import 'package:user/app/core/models/request/show_hidden_restaurant_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_quantity_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/env.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LocationRepository _locationRepository = LocationRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  HomeBloc()
    : super(
        HomeState(
          pageSize: ApiRequestService.pageSize,
          homeData: HomeResponseModel(locale: ''),
        ),
      ) {
    on<HomeInitialEvent>(_onHomeInitialEvent);
    on<HomeLoadMoreEvent>(_onHomeLoadMoreEvent);
    on<HomeFavouriteEvent>(_onHomeFavouriteEvent);
    on<HomeFoodVariationModalResponseEvent>(_onHomeFoodVariationModalResponseEvent);
    on<HomeFoodQuantityDecreaseEvent>(_onHomeFoodQuantityDecreaseEvent);
    on<HomeFoodQuantityIncreaseEvent>(_onHomeFoodQuantityIncreaseEvent);
    on<HomeAddCartEvent>(_onHomeAddCartEvent);
    on<HomeRepeatFoodOrderResponseEvent>(_onHomeRepeatFoodOrderResponseEvent);
    on<HomeFoodVariationModalRepeatResponseEvent>(_onHomeFoodVariationModalRepeatResponseEvent);
    on<HomeRefreshCartEvent>(_onHomeRefreshCartEvent);
    on<HomeRefreshFoodFavEvent>(_onHomeRefreshFoodFavEvent);
    on<HomeRefreshRestaurantFavEvent>(_onHomeRefreshRestaurantFavEvent);
    on<HomeFoodModalResponseEvent>(_onHomeFoodModalResponseEvent);
    on<HomeHideRestaurantEvent>(_onHomeHideRestaurantEvent);
    on<HomeRemoveRestaurantFromListEvent>(_onHomeRemoveRestaurantFromListEvent);
    on<HomeUndoHideActionEvent>(_onHomeUndoHideActionEvent);
    on<HomeSilentHideEvent>(_onHomeSilentHideEvent);
    on<HomeSilentUnHideEvent>(_onHomeSilentUnHideEvent);
    on<HomeSilentNotificationEvent>(_onHomeSilentNotificationEvent);
    on<HomeNotificationListClickEvent>(_onHomeNotificationListClickEvent);
    on<HomePullRefreshEvent>(_onHomePullRefreshEvent);
  }

  FutureOr<void> _onHomeInitialEvent(HomeInitialEvent event, Emitter<HomeState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "home"}, 'home_screen', 'home_screen');
      final String addressTitle = await _locationRepository.getAddressTitle();
      final String fullAddress = await _locationRepository.getFullAddress();
      bool isAuthorized = await _homeRepository.isAuthorized();
      final String locale = await _homeRepository.getLocale();
      emit(
        state.copyWith(
          addressTitle: addressTitle,
          addressSubTitle: fullAddress,
          isAuthorized: isAuthorized,
          locale: locale.isNotEmpty ? locale.toString() : Environments.defaultLanguage,
          status: HomeStatus.loading,
        ),
      );
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final String userId = await _homeRepository.userId();
      HomeRestaurantRequest param = HomeRestaurantRequest(
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
        page: state.currentPage,
        limit: state.pageSize,
        uid: userId,
      );
      DioApiResponse response = await _homeRepository.getHomeData(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: HomeStatus.empty));
        } else {
          HomeResponseModel homeResponse = HomeResponseModel.fromJson(myMap, locale.toString());
          List<CampaignListModel> campaignCombine = <CampaignListModel>[];
          campaignCombine.clear();
          for (var element in homeResponse.foodCampaign!) {
            CampaignListModel data = CampaignListModel(
              title: element.title,
              shortDescription: element.shortDescription,
              image: element.image,
              startDate: element.startDate,
              endDate: element.endDate,
              startTime: element.startTime,
              endTime: element.endTime,
              type: 'food',
              id: element.id,
              locale: locale.toString(),
            );
            campaignCombine.add(data);
          }

          for (var element in homeResponse.restaurantCampaign!) {
            CampaignListModel data = CampaignListModel(
              title: element.title,
              shortDescription: element.shortDescription,
              image: element.image,
              startDate: element.startDate,
              endDate: element.endDate,
              startTime: element.startTime,
              endTime: element.endTime,
              type: 'restaurant',
              id: element.id,
              locale: locale.toString(),
            );
            campaignCombine.add(data);
          }
          for (var element in homeResponse.mostReviewedFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          for (var element in homeResponse.trendingFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          for (var element in homeResponse.popularFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          homeResponse.newArrivals!.sort((a, b) => b.promote! ? 1 : -1);
          homeResponse.restaurants!.sort((a, b) => b.promote! ? 1 : -1);

          List<String> favIds = <String>[];
          for (var element in homeResponse.restaurants!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in homeResponse.newArrivals!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in homeResponse.popularRestaurant!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }

          emit(state.copyWith(status: HomeStatus.success, favRestIds: favIds, appLocale: locale.toString(), homeData: homeResponse, campaignList: campaignCombine));
          if (state.homeData.restaurants!.isEmpty && state.homeData.popularRestaurant!.isEmpty && state.homeData.newArrivals!.isEmpty) {
            emit(state.copyWith(status: HomeStatus.empty));
          }
        }
        if (isAuthorized && userId.isNotEmpty) {
          add(HomeSilentNotificationEvent());
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HomeStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeLoadMoreEvent(HomeLoadMoreEvent event, Emitter<HomeState> emit) async {
    if (state.homeData.restaurants!.length < state.homeData.totalResults! && !state.loadMore) {
      try {
        final String locale = await _homeRepository.getLocale();
        emit(state.copyWith(loadMore: true));
        final double userLatitude = await _locationRepository.userLatitude();
        final double userLongitude = await _locationRepository.userLongitude();
        final String userId = await _homeRepository.userId();
        HomeRestaurantRequest param = HomeRestaurantRequest(
          latitude: userLatitude != 0 ? userLatitude : 0,
          longitude: userLongitude != 0 ? userLongitude : 0,
          page: state.currentPage,
          uid: userId,
          limit: state.pageSize * 2,
        );
        DioApiResponse response = await _homeRepository.getHomeData(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: HomeStatus.empty, loadMore: false));
          } else {
            HomeResponseModel homeResponse = HomeResponseModel.fromJson(myMap, state.locale);
            List<CampaignListModel> campaignCombine = <CampaignListModel>[];
            campaignCombine.clear();
            for (var element in homeResponse.foodCampaign!) {
              CampaignListModel data = CampaignListModel(
                title: element.title,
                shortDescription: element.shortDescription,
                image: element.image,
                startDate: element.startDate,
                endDate: element.endDate,
                startTime: element.startTime,
                endTime: element.endTime,
                type: 'food',
                id: element.id,
                locale: locale.toString(),
              );
              campaignCombine.add(data);
            }

            for (var element in homeResponse.restaurantCampaign!) {
              CampaignListModel data = CampaignListModel(
                title: element.title,
                shortDescription: element.shortDescription,
                image: element.image,
                startDate: element.startDate,
                endDate: element.endDate,
                startTime: element.startTime,
                endTime: element.endTime,
                type: 'restaurant',
                id: element.id,
                locale: locale.toString(),
              );
              campaignCombine.add(data);
            }
            for (var element in homeResponse.mostReviewedFoods!) {
              if (await _cartRepository.checkProductInCart(element.id!)) {
                final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
                element.quantity = quantityPromise;
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
                element.cartEntity = cartEntityPromise;
              } else {
                element.quantity = 0;
                element.cartEntity = 'single';
              }
            }
            for (var element in homeResponse.trendingFoods!) {
              if (await _cartRepository.checkProductInCart(element.id!)) {
                final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
                element.quantity = quantityPromise;
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
                element.cartEntity = cartEntityPromise;
              } else {
                element.quantity = 0;
                element.cartEntity = 'single';
              }
            }
            for (var element in homeResponse.popularFoods!) {
              if (await _cartRepository.checkProductInCart(element.id!)) {
                final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
                element.quantity = quantityPromise;
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
                element.cartEntity = cartEntityPromise;
              } else {
                element.quantity = 0;
                element.cartEntity = 'single';
              }
            }
            // Removed For Loading More to push to bottom
            // homeResponse.newArrivals!.sort((a, b) => b.promote! ? 1 : -1);
            // homeResponse.restaurants!.sort((a, b) => b.promote! ? 1 : -1);

            for (var element in homeResponse.restaurants!) {
              if (element.isFavourite! && !state.favRestIds.contains(element.id)) {
                state.favRestIds.add(element.id!);
              }
            }
            for (var element in homeResponse.newArrivals!) {
              if (element.isFavourite! && !state.favRestIds.contains(element.id)) {
                state.favRestIds.add(element.id!);
              }
            }
            for (var element in homeResponse.popularRestaurant!) {
              if (element.isFavourite! && !state.favRestIds.contains(element.id)) {
                state.favRestIds.add(element.id!);
              }
            }

            emit(state.copyWith(status: HomeStatus.success, homeData: homeResponse, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: HomeStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: HomeStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onHomeFavouriteEvent(HomeFavouriteEvent event, Emitter<HomeState> emit) async {
    final String userId = await _homeRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      updateFavouriteData(event.id);
      emit(state.copyWith(homeData: state.homeData));
      if (event.isFavourite == false) {
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(
            user: userId,
            type: event.type,
            restaurant: event.type == 'restaurant' ? event.id : '',
            food: event.type == 'food' ? event.id : '',
          );
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              if (event.type == 'restaurant') {
                state.favRestIds.add(event.id);
              }
              emit(state.copyWith(favRestIds: state.favRestIds, status: event.type == 'restaurant' ? HomeStatus.restaurantFav : HomeStatus.foodFav));
            }
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(homeData: state.homeData));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: HomeStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(homeData: state.homeData));
          emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else if (event.type == 'restaurant' && event.isFavourite == true) {
        try {
          DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, event.id);
          if (response.errorType == NetErrorType.none) {
            state.favRestIds.removeWhere((element) => element == event.id);
            emit(state.copyWith(favRestIds: state.favRestIds, status: event.type == 'restaurant' ? HomeStatus.restaurantFav : HomeStatus.foodFav));
          } else {
            updateFavouriteData(event.id);
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: HomeStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else if (event.type == 'food' && event.isFavourite == true) {
        try {
          final String userId = await _favouriteRepository.userId();
          DioApiResponse response = await _favouriteRepository.deleteFavouriteFood(userId, event.id);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: event.type == 'restaurant' ? HomeStatus.restaurantFav : HomeStatus.foodFav));
          } else {
            updateFavouriteData(event.id);
            emit(state.copyWith(homeData: state.homeData));
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: HomeStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
          }
        } catch (e, stacktrace) {
          updateFavouriteData(event.id);
          emit(state.copyWith(homeData: state.homeData));
          emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  Future<void> updateFavouriteData(String id) async {
    int newArrivalsIndex = state.homeData.newArrivals!.indexWhere((element) => element.id == id);
    if (newArrivalsIndex != -1) {
      if (state.homeData.newArrivals![newArrivalsIndex].isFavourite == false) {
        state.homeData.newArrivals![newArrivalsIndex].isFavourite = true;
      } else {
        state.homeData.newArrivals![newArrivalsIndex].isFavourite = false;
      }
    }

    int restaurantsIndex = state.homeData.restaurants!.indexWhere((element) => element.id == id);
    if (restaurantsIndex != -1) {
      if (state.homeData.restaurants![restaurantsIndex].isFavourite == false) {
        state.homeData.restaurants![restaurantsIndex].isFavourite = true;
      } else {
        state.homeData.restaurants![restaurantsIndex].isFavourite = false;
      }
    }

    int mostReviewedFoodsIndex = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == id);
    if (mostReviewedFoodsIndex != -1) {
      if (state.homeData.mostReviewedFoods![mostReviewedFoodsIndex].isFavourite == false) {
        state.homeData.mostReviewedFoods![mostReviewedFoodsIndex].isFavourite = true;
      } else {
        state.homeData.mostReviewedFoods![mostReviewedFoodsIndex].isFavourite = false;
      }
    }

    int popularFoodsIndex = state.homeData.popularFoods!.indexWhere((element) => element.id == id);
    if (popularFoodsIndex != -1) {
      if (state.homeData.popularFoods![popularFoodsIndex].isFavourite == false) {
        state.homeData.popularFoods![popularFoodsIndex].isFavourite = true;
      } else {
        state.homeData.popularFoods![popularFoodsIndex].isFavourite = false;
      }
    }

    int trendingFoodsIndex = state.homeData.trendingFoods!.indexWhere((element) => element.id == id);
    if (trendingFoodsIndex != -1) {
      if (state.homeData.trendingFoods![trendingFoodsIndex].isFavourite == false) {
        state.homeData.trendingFoods![trendingFoodsIndex].isFavourite = true;
      } else {
        state.homeData.trendingFoods![trendingFoodsIndex].isFavourite = false;
      }
    }

    int popularRestaurantIndex = state.homeData.popularRestaurant!.indexWhere((element) => element.id == id);
    if (popularRestaurantIndex != -1) {
      if (state.homeData.popularRestaurant![popularRestaurantIndex].isFavourite == false) {
        state.homeData.popularRestaurant![popularRestaurantIndex].isFavourite = true;
      } else {
        state.homeData.popularRestaurant![popularRestaurantIndex].isFavourite = false;
      }
    }
  }

  FutureOr<void> _onHomeFoodVariationModalResponseEvent(HomeFoodVariationModalResponseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          state.homeData.mostReviewedFoods![index].quantity = event.data.cartItem!.quantity;
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.mostReviewedFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.mostReviewedFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.mostReviewedFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.mostReviewedFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.mostReviewedFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.mostReviewedFoods![index].name,
            shortDescription: state.homeData.mostReviewedFoods![index].shortDescription,
            image: state.homeData.mostReviewedFoods![index].image,
            restaurant: state.homeData.mostReviewedFoods![index].restaurant,
            foodType: state.homeData.mostReviewedFoods![index].foodType,
            price: state.homeData.mostReviewedFoods![index].price,
            discountType: state.homeData.mostReviewedFoods![index].discountType,
            discount: state.homeData.mostReviewedFoods![index].discount,
            offerPrice: state.homeData.mostReviewedFoods![index].offerPrice,
            purchaseLimit: state.homeData.mostReviewedFoods![index].purchaseLimit,
            stockNumber: state.homeData.mostReviewedFoods![index].stockNumber,
            stockType: state.homeData.mostReviewedFoods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.homeData.mostReviewedFoods![index].status,
            inStock: state.homeData.mostReviewedFoods![index].inStock,
            startTime: state.homeData.mostReviewedFoods![index].startTime,
            endTime: state.homeData.mostReviewedFoods![index].endTime,
            taxationEnable: state.homeData.mostReviewedFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            state.homeData.mostReviewedFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          state.homeData.trendingFoods![index].quantity = event.data.cartItem!.quantity;
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.trendingFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.trendingFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.trendingFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.trendingFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.trendingFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.trendingFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }

          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.homeData.trendingFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.trendingFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.trendingFoods![index].name,
            shortDescription: state.homeData.trendingFoods![index].shortDescription,
            image: state.homeData.trendingFoods![index].image,
            restaurant: state.homeData.trendingFoods![index].restaurant,
            foodType: state.homeData.trendingFoods![index].foodType,
            price: state.homeData.trendingFoods![index].price,
            discountType: state.homeData.trendingFoods![index].discountType,
            discount: state.homeData.trendingFoods![index].discount,
            offerPrice: state.homeData.trendingFoods![index].offerPrice,
            purchaseLimit: state.homeData.trendingFoods![index].purchaseLimit,
            stockNumber: state.homeData.trendingFoods![index].stockNumber,
            stockType: state.homeData.trendingFoods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.homeData.trendingFoods![index].status,
            inStock: state.homeData.trendingFoods![index].inStock,
            startTime: state.homeData.trendingFoods![index].startTime,
            endTime: state.homeData.trendingFoods![index].endTime,
            taxationEnable: state.homeData.trendingFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            state.homeData.trendingFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.homeData.popularFoods![index].quantity = event.data.cartItem!.quantity;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.popularFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.popularFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.popularFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.popularFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.popularFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.popularFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in state.homeData.popularFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.popularFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.popularFoods![index].name,
            shortDescription: state.homeData.popularFoods![index].shortDescription,
            image: state.homeData.popularFoods![index].image,
            restaurant: state.homeData.popularFoods![index].restaurant,
            foodType: state.homeData.popularFoods![index].foodType,
            price: state.homeData.popularFoods![index].price,
            discountType: state.homeData.popularFoods![index].discountType,
            discount: state.homeData.popularFoods![index].discount,
            offerPrice: state.homeData.popularFoods![index].offerPrice,
            purchaseLimit: state.homeData.popularFoods![index].purchaseLimit,
            stockNumber: state.homeData.popularFoods![index].stockNumber,
            stockType: state.homeData.popularFoods![index].stockType,
            quantity: event.data.cartItem!.quantity,
            id: event.id,
            addons: savedAddon,
            variations: savedVariations,
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: state.homeData.popularFoods![index].status,
            inStock: state.homeData.popularFoods![index].inStock,
            startTime: state.homeData.popularFoods![index].startTime,
            endTime: state.homeData.popularFoods![index].endTime,
            taxationEnable: state.homeData.popularFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: event.data.instruction!,
            locale: locale.toString(),
          );

          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
          serverVariations.clear();
          for (var variation in savedVariations) {
            List<String> selectedOptions = <String>[];
            for (var options in variation.options!) {
              selectedOptions.add(options.name!);
            }
            online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
            serverVariations.add(saveIt);
          }

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: newAddonIds.join(','),
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: serverVariations,
            cookingInstruction: event.data.instruction!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            state.homeData.popularFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeFoodQuantityDecreaseEvent(HomeFoodQuantityDecreaseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.mostReviewedFoods![index].quantity! > 1) {
            state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.mostReviewedFoods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              id: event.id,
              quantity: state.homeData.mostReviewedFoods![index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.homeData.mostReviewedFoods![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.trendingFoods![index].quantity! > 1) {
            state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.trendingFoods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              id: event.id,
              quantity: state.homeData.trendingFoods![index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.homeData.trendingFoods![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.popularFoods![index].quantity! > 1) {
            state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].quantity! - 1;
            await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.popularFoods![index].quantity!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              id: event.id,
              quantity: state.homeData.popularFoods![index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            state.homeData.popularFoods![index].quantity = 0;
            await _cartRepository.removeFromCartLocal(event.id);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
            RemoveFromCartWithFoodIdRequestModel onlineRemoveParam = RemoveFromCartWithFoodIdRequestModel(trackingId: await _cartRepository.trackingId(), id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeFoodQuantityIncreaseEvent(HomeFoodQuantityIncreaseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.mostReviewedFoods![index].quantity! < state.homeData.mostReviewedFoods![index].purchaseLimit!) {
            if (state.homeData.mostReviewedFoods![index].stockType! == 'unlimited') {
              state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.mostReviewedFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.mostReviewedFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.homeData.mostReviewedFoods![index].quantity! < state.homeData.mostReviewedFoods![index].stockNumber!) {
              state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.mostReviewedFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.mostReviewedFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(
                state.copyWith(
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                  extraMessage: '${state.homeData.mostReviewedFoods![index].stockNumber!}',
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: HomeStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.homeData.mostReviewedFoods![index].purchaseLimit}',
              ),
            );
          }
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.trendingFoods![index].quantity! < state.homeData.trendingFoods![index].purchaseLimit!) {
            if (state.homeData.trendingFoods![index].stockType! == 'unlimited') {
              state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.trendingFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.trendingFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.homeData.trendingFoods![index].quantity! < state.homeData.trendingFoods![index].stockNumber!) {
              state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.trendingFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.trendingFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(
                state.copyWith(
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                  extraMessage: '${state.homeData.trendingFoods![index].stockNumber!}',
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: HomeStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.homeData.trendingFoods![index].purchaseLimit}',
              ),
            );
          }
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          if (state.homeData.popularFoods![index].quantity! < state.homeData.popularFoods![index].purchaseLimit!) {
            if (state.homeData.popularFoods![index].stockType! == 'unlimited') {
              state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.popularFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.popularFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else if (state.homeData.popularFoods![index].quantity! < state.homeData.popularFoods![index].stockNumber!) {
              state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].quantity! + 1;
              await _cartRepository.updateProductQuantityInCartLocal(event.id, state.homeData.popularFoods![index].quantity!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
              UpdateCartFoodQuantityRequestModel onlineUpdateParam = UpdateCartFoodQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                id: event.id,
                quantity: state.homeData.popularFoods![index].quantity!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductQuantityInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            } else {
              emit(
                state.copyWith(
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                  extraMessage: '${state.homeData.popularFoods![index].stockNumber!}',
                ),
              );
            }
          } else {
            emit(
              state.copyWith(
                status: HomeStatus.cartError,
                statusCode: 0,
                alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                extraMessage: '${state.homeData.popularFoods![index].purchaseLimit}',
              ),
            );
          }
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeAddCartEvent(HomeAddCartEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.homeData.mostReviewedFoods![index].quantity = 1;

          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.mostReviewedFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.mostReviewedFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.mostReviewedFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.mostReviewedFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.mostReviewedFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();

          for (var element in state.homeData.mostReviewedFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.mostReviewedFoods![index].name,
            shortDescription: state.homeData.mostReviewedFoods![index].shortDescription,
            image: state.homeData.mostReviewedFoods![index].image,
            restaurant: state.homeData.mostReviewedFoods![index].restaurant,
            foodType: state.homeData.mostReviewedFoods![index].foodType,
            price: state.homeData.mostReviewedFoods![index].price,
            discountType: state.homeData.mostReviewedFoods![index].discountType,
            discount: state.homeData.mostReviewedFoods![index].discount,
            offerPrice: state.homeData.mostReviewedFoods![index].offerPrice,
            purchaseLimit: state.homeData.mostReviewedFoods![index].purchaseLimit,
            stockNumber: state.homeData.mostReviewedFoods![index].stockNumber,
            stockType: state.homeData.mostReviewedFoods![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.homeData.mostReviewedFoods![index].status,
            inStock: state.homeData.mostReviewedFoods![index].inStock,
            startTime: state.homeData.mostReviewedFoods![index].startTime,
            endTime: state.homeData.mostReviewedFoods![index].endTime,
            taxationEnable: state.homeData.mostReviewedFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            state.homeData.mostReviewedFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.homeData.trendingFoods![index].quantity = 1;

          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.trendingFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.trendingFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.trendingFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.trendingFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.trendingFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.trendingFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();

          for (var element in state.homeData.trendingFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.trendingFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.trendingFoods![index].name,
            shortDescription: state.homeData.trendingFoods![index].shortDescription,
            image: state.homeData.trendingFoods![index].image,
            restaurant: state.homeData.trendingFoods![index].restaurant,
            foodType: state.homeData.trendingFoods![index].foodType,
            price: state.homeData.trendingFoods![index].price,
            discountType: state.homeData.trendingFoods![index].discountType,
            discount: state.homeData.trendingFoods![index].discount,
            offerPrice: state.homeData.trendingFoods![index].offerPrice,
            purchaseLimit: state.homeData.trendingFoods![index].purchaseLimit,
            stockNumber: state.homeData.trendingFoods![index].stockNumber,
            stockType: state.homeData.trendingFoods![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.homeData.trendingFoods![index].status,
            inStock: state.homeData.trendingFoods![index].inStock,
            startTime: state.homeData.trendingFoods![index].startTime,
            endTime: state.homeData.trendingFoods![index].endTime,
            taxationEnable: state.homeData.trendingFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            state.homeData.trendingFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          state.homeData.popularFoods![index].quantity = 1;
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.popularFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.popularFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.popularFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.popularFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.popularFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.popularFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();

          for (var element in state.homeData.popularFoods![index].translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
          foodTaxation.clear();
          for (var element in state.homeData.popularFoods![index].foodtaxations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
            foodTaxation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: state.homeData.popularFoods![index].name,
            shortDescription: state.homeData.popularFoods![index].shortDescription,
            image: state.homeData.popularFoods![index].image,
            restaurant: state.homeData.popularFoods![index].restaurant,
            foodType: state.homeData.popularFoods![index].foodType,
            price: state.homeData.popularFoods![index].price,
            discountType: state.homeData.popularFoods![index].discountType,
            discount: state.homeData.popularFoods![index].discount,
            offerPrice: state.homeData.popularFoods![index].offerPrice,
            purchaseLimit: state.homeData.popularFoods![index].purchaseLimit,
            stockNumber: state.homeData.popularFoods![index].stockNumber,
            stockType: state.homeData.popularFoods![index].stockType,
            quantity: 1,
            id: event.id,
            addons: [],
            variations: [],
            translations: savedFoodTranslation,
            restaurantInfo: restaurantInfo,
            status: state.homeData.popularFoods![index].status,
            inStock: state.homeData.popularFoods![index].inStock,
            startTime: state.homeData.popularFoods![index].startTime,
            endTime: state.homeData.popularFoods![index].endTime,
            taxationEnable: state.homeData.popularFoods![index].taxationEnable!,
            foodtaxations: foodTaxation,
            instruction: '',
            locale: locale.toString(),
          );
          await _cartRepository.addToCartLocal(foodInCartInfo);
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
          state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
          emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

          CartItemRequestModel onlineCartParam = CartItemRequestModel(
            user: await _cartRepository.userId(),
            trackingId: await _cartRepository.trackingId(),
            uuid: foodInCartInfo.uuid,
            addons: '',
            food: foodInCartInfo.id,
            restaurant: foodInCartInfo.restaurant,
            quantity: foodInCartInfo.quantity,
            variations: [],
            cookingInstruction: '',
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
            await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            state.homeData.popularFoods![index].quantity = 0;
            emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeRepeatFoodOrderResponseEvent(HomeRepeatFoodOrderResponseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.homeData.mostReviewedFoods!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
      } else if (event.collection == 'trendingFoods') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.homeData.trendingFoods!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
      } else if (event.collection == 'popularFoods') {
        for (var element in event.data.data!.list!) {
          if (element.quantity == 0) {
            await _cartRepository.removeFromCartWithUuidLocal(element.uuid!, event.id);
            RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: element.uuid!, id: event.id);
            DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            await _cartRepository.updateProductVariationInCartLocal(element.uuid!, event.id, element.quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: element.uuid!,
              id: event.id,
              quantity: element.quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
        for (var element in state.homeData.popularFoods!) {
          if (await _cartRepository.checkProductInCart(element.id!)) {
            final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
            element.quantity = quantityPromise;
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
            element.cartEntity = cartEntityPromise;
          } else {
            element.quantity = 0;
            element.cartEntity = 'single';
          }
        }
      }
      add(HomeRefreshCartEvent());
      emit(state.copyWith(homeData: state.homeData, status: HomeStatus.cartUpdate));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeFoodVariationModalRepeatResponseEvent(HomeFoodVariationModalRepeatResponseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.mostReviewedFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.mostReviewedFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.mostReviewedFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.mostReviewedFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.mostReviewedFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.mostReviewedFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.homeData.mostReviewedFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.mostReviewedFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.mostReviewedFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.mostReviewedFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.mostReviewedFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.mostReviewedFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.mostReviewedFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.mostReviewedFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.mostReviewedFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.mostReviewedFoods![index].purchaseLimit}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.mostReviewedFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.mostReviewedFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.mostReviewedFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.mostReviewedFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.mostReviewedFoods![index].name,
              shortDescription: state.homeData.mostReviewedFoods![index].shortDescription,
              image: state.homeData.mostReviewedFoods![index].image,
              restaurant: state.homeData.mostReviewedFoods![index].restaurant,
              foodType: state.homeData.mostReviewedFoods![index].foodType,
              price: state.homeData.mostReviewedFoods![index].price,
              discountType: state.homeData.mostReviewedFoods![index].discountType,
              discount: state.homeData.mostReviewedFoods![index].discount,
              offerPrice: state.homeData.mostReviewedFoods![index].offerPrice,
              purchaseLimit: state.homeData.mostReviewedFoods![index].purchaseLimit,
              stockNumber: state.homeData.mostReviewedFoods![index].stockNumber,
              stockType: state.homeData.mostReviewedFoods![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.mostReviewedFoods![index].status,
              inStock: state.homeData.mostReviewedFoods![index].inStock,
              startTime: state.homeData.mostReviewedFoods![index].startTime,
              endTime: state.homeData.mostReviewedFoods![index].endTime,
              taxationEnable: state.homeData.mostReviewedFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.homeData.mostReviewedFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              state.homeData.mostReviewedFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.trendingFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.trendingFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.trendingFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.trendingFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.trendingFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.trendingFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();

          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.trendingFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.homeData.trendingFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.trendingFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.trendingFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.trendingFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.trendingFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.trendingFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.trendingFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.trendingFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.trendingFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.trendingFoods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.trendingFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.trendingFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.trendingFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }

            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.trendingFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.trendingFoods![index].name,
              shortDescription: state.homeData.trendingFoods![index].shortDescription,
              image: state.homeData.trendingFoods![index].image,
              restaurant: state.homeData.trendingFoods![index].restaurant,
              foodType: state.homeData.trendingFoods![index].foodType,
              price: state.homeData.trendingFoods![index].price,
              discountType: state.homeData.trendingFoods![index].discountType,
              discount: state.homeData.trendingFoods![index].discount,
              offerPrice: state.homeData.trendingFoods![index].offerPrice,
              purchaseLimit: state.homeData.trendingFoods![index].purchaseLimit,
              stockNumber: state.homeData.trendingFoods![index].stockNumber,
              stockType: state.homeData.trendingFoods![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.trendingFoods![index].status,
              inStock: state.homeData.trendingFoods![index].inStock,
              startTime: state.homeData.trendingFoods![index].startTime,
              endTime: state.homeData.trendingFoods![index].endTime,
              taxationEnable: state.homeData.trendingFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.homeData.trendingFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              state.homeData.trendingFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.popularFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.popularFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.popularFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.popularFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.popularFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.popularFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.data.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.data.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.popularFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            if (quantity < state.homeData.popularFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.popularFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.popularFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.popularFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.popularFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.popularFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.popularFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.popularFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.popularFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.popularFoods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.popularFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.popularFoods![index].quantity.toString()) + int.parse(event.data.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.popularFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.popularFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.popularFoods![index].name,
              shortDescription: state.homeData.popularFoods![index].shortDescription,
              image: state.homeData.popularFoods![index].image,
              restaurant: state.homeData.popularFoods![index].restaurant,
              foodType: state.homeData.popularFoods![index].foodType,
              price: state.homeData.popularFoods![index].price,
              discountType: state.homeData.popularFoods![index].discountType,
              discount: state.homeData.popularFoods![index].discount,
              offerPrice: state.homeData.popularFoods![index].offerPrice,
              purchaseLimit: state.homeData.popularFoods![index].purchaseLimit,
              stockNumber: state.homeData.popularFoods![index].stockNumber,
              stockType: state.homeData.popularFoods![index].stockType,
              quantity: event.data.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.popularFoods![index].status,
              inStock: state.homeData.popularFoods![index].inStock,
              startTime: state.homeData.popularFoods![index].startTime,
              endTime: state.homeData.popularFoods![index].endTime,
              taxationEnable: state.homeData.popularFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.data.instruction!,
              locale: locale.toString(),
            );
            state.homeData.popularFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.data.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              state.homeData.popularFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeRefreshCartEvent(HomeRefreshCartEvent event, Emitter<HomeState> emit) async {
    try {
      for (var element in state.homeData.mostReviewedFoods!) {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      }
      for (var element in state.homeData.trendingFoods!) {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      }
      for (var element in state.homeData.popularFoods!) {
        if (await _cartRepository.checkProductInCart(element.id!)) {
          final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
          element.quantity = quantityPromise;
          final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
          element.cartEntity = cartEntityPromise;
        } else {
          element.quantity = 0;
          element.cartEntity = 'single';
        }
      }
      emit(state.copyWith(status: HomeStatus.success, homeData: state.homeData));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeRefreshFoodFavEvent(HomeRefreshFoodFavEvent event, Emitter<HomeState> emit) async {
    for (var element in state.homeData.mostReviewedFoods!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }
    for (var element in state.homeData.trendingFoods!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }
    for (var element in state.homeData.popularFoods!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }
    emit(state.copyWith(status: HomeStatus.success, homeData: state.homeData));
  }

  FutureOr<void> _onHomeRefreshRestaurantFavEvent(HomeRefreshRestaurantFavEvent event, Emitter<HomeState> emit) async {
    for (var element in state.homeData.newArrivals!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    for (var element in state.homeData.restaurants!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    for (var element in state.homeData.popularRestaurant!) {
      if (event.inFavList.contains(element.id!) && element.isFavourite! == false) {
        element.isFavourite = true;
      } else if (!event.inFavList.contains(element.id) && element.isFavourite! == true) {
        element.isFavourite = false;
      } else if (event.inFavList.contains(element.id)) {
        element.isFavourite = true;
      }
    }

    emit(state.copyWith(status: HomeStatus.success, homeData: state.homeData));
  }

  FutureOr<void> _onHomeFoodModalResponseEvent(HomeFoodModalResponseEvent event, Emitter<HomeState> emit) async {
    try {
      if (event.collection == 'mostReviewedFoods') {
        int index = state.homeData.mostReviewedFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.mostReviewedFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.mostReviewedFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.mostReviewedFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.mostReviewedFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.mostReviewedFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.mostReviewedFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            List<String> selectedOptions = <String>[];
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
              selectedOptions.add(op.name!);
            }
            selectedOptions.clear();
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.mostReviewedFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.homeData.mostReviewedFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.mostReviewedFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.mostReviewedFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.mostReviewedFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.mostReviewedFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.mostReviewedFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.mostReviewedFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.mostReviewedFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.mostReviewedFoods![index].quantity = state.homeData.mostReviewedFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.mostReviewedFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.mostReviewedFoods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.mostReviewedFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.mostReviewedFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.mostReviewedFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.mostReviewedFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.mostReviewedFoods![index].name,
              shortDescription: state.homeData.mostReviewedFoods![index].shortDescription,
              image: state.homeData.mostReviewedFoods![index].image,
              restaurant: state.homeData.mostReviewedFoods![index].restaurant,
              foodType: state.homeData.mostReviewedFoods![index].foodType,
              price: state.homeData.mostReviewedFoods![index].price,
              discountType: state.homeData.mostReviewedFoods![index].discountType,
              discount: state.homeData.mostReviewedFoods![index].discount,
              offerPrice: state.homeData.mostReviewedFoods![index].offerPrice,
              purchaseLimit: state.homeData.mostReviewedFoods![index].purchaseLimit,
              stockNumber: state.homeData.mostReviewedFoods![index].stockNumber,
              stockType: state.homeData.mostReviewedFoods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.mostReviewedFoods![index].status,
              inStock: state.homeData.mostReviewedFoods![index].inStock,
              startTime: state.homeData.mostReviewedFoods![index].startTime,
              endTime: state.homeData.mostReviewedFoods![index].endTime,
              taxationEnable: state.homeData.mostReviewedFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.homeData.mostReviewedFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.mostReviewedFoods![index].cartEntity = cartEntityPromise;
              state.homeData.mostReviewedFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.homeData.mostReviewedFoods![index].isFavourite! != event.response.isFavourite) {
          updateFavouriteData(event.id);
          emit(state.copyWith(status: HomeStatus.foodFav, homeData: state.homeData));
        }
      } else if (event.collection == 'trendingFoods') {
        int index = state.homeData.trendingFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.trendingFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.trendingFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.trendingFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.trendingFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.trendingFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.trendingFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.trendingFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.homeData.trendingFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.trendingFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.trendingFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.trendingFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.trendingFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.trendingFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.trendingFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.trendingFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.trendingFoods![index].quantity = state.homeData.trendingFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.trendingFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.trendingFoods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.trendingFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.trendingFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.trendingFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.trendingFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.trendingFoods![index].name,
              shortDescription: state.homeData.trendingFoods![index].shortDescription,
              image: state.homeData.trendingFoods![index].image,
              restaurant: state.homeData.trendingFoods![index].restaurant,
              foodType: state.homeData.trendingFoods![index].foodType,
              price: state.homeData.trendingFoods![index].price,
              discountType: state.homeData.trendingFoods![index].discountType,
              discount: state.homeData.trendingFoods![index].discount,
              offerPrice: state.homeData.trendingFoods![index].offerPrice,
              purchaseLimit: state.homeData.trendingFoods![index].purchaseLimit,
              stockNumber: state.homeData.trendingFoods![index].stockNumber,
              stockType: state.homeData.trendingFoods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.trendingFoods![index].status,
              inStock: state.homeData.trendingFoods![index].inStock,
              startTime: state.homeData.trendingFoods![index].startTime,
              endTime: state.homeData.trendingFoods![index].endTime,
              taxationEnable: state.homeData.trendingFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.homeData.trendingFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.trendingFoods![index].cartEntity = cartEntityPromise;
              state.homeData.trendingFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.homeData.trendingFoods![index].isFavourite! != event.response.isFavourite) {
          updateFavouriteData(event.id);
          emit(state.copyWith(status: HomeStatus.foodFav, homeData: state.homeData));
        }
      } else if (event.collection == 'popularFoods') {
        int index = state.homeData.popularFoods!.indexWhere((element) => element.id == event.id);
        if (index != -1 && event.response.action! == true) {
          final String locale = await _authRepository.getLocale();
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in state.homeData.popularFoods![index].restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = state.homeData.popularFoods![index].restaurants!.id!;
          restaurantInfo.slug = state.homeData.popularFoods![index].restaurants!.slug!;
          restaurantInfo.name = state.homeData.popularFoods![index].restaurants!.name!;
          restaurantInfo.cover = state.homeData.popularFoods![index].restaurants!.cover!;
          restaurantInfo.logo = state.homeData.popularFoods![index].restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
          savedAddon.clear();
          List<String> newAddonIds = <String>[];
          newAddonIds.clear();
          for (var element in event.response.cartItem!.addons!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
            newAddonIds.add(savedData.id!);
            savedAddon.add(savedData);
          }

          List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
          savedVariations.clear();
          List<String> newVariationIds = <String>[];
          for (var element in event.response.cartItem!.variations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
            for (var op in savedData.options!) {
              newVariationIds.add('${savedData.title}-${op.name}');
            }
            savedVariations.add(savedData);
          }
          newAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
          newVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));

          bool isSameProduct = false;
          String sameUuid = '';
          await _cartRepository.getRepeatList(event.id).then((value) {
            List<String> existingAddonIds = <String>[];
            existingAddonIds.clear();
            List<String> existingVariationIds = <String>[];
            existingVariationIds.clear();
            for (var element in value) {
              for (var addn in element.addons!) {
                existingAddonIds.add(addn.id!);
              }
              for (var variant in element.variations!) {
                for (var ops in variant.options!) {
                  existingVariationIds.add('${variant.title}-${ops.name}');
                }
              }
              existingAddonIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              existingVariationIds.sort((a, b) => a.toLowerCase().toString().compareTo(b.toLowerCase().toString()));
              if (element.restaurant == restaurantInfo.id && newAddonIds.join('') == existingAddonIds.join('') && newVariationIds.join('') == existingVariationIds.join('')) {
                sameUuid = element.uuid!;
                isSameProduct = true;
              }
            }
          });
          if (isSameProduct && sameUuid.isNotEmpty && sameUuid != '') {
            int quantity = (int.parse(state.homeData.popularFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            if (quantity < state.homeData.popularFoods![index].purchaseLimit!) {
              bool checkAddonHaveStock = true;
              bool checkVariationHaveStock = true;
              int addonOutOfStockLimitNumber = 0;
              int variationOutOfStockLimitNumber = 0;
              for (var addon in savedAddon) {
                if (quantity >= addon.stockNumber!) {
                  checkAddonHaveStock = false;
                  if (addonOutOfStockLimitNumber == 0) {
                    addonOutOfStockLimitNumber = addon.stockNumber!;
                  }
                }
              }
              for (var variation in savedVariations) {
                for (var options in variation.options!) {
                  if (quantity >= options.stock!) {
                    checkVariationHaveStock = false;
                    if (variationOutOfStockLimitNumber == 0) {
                      variationOutOfStockLimitNumber = options.stock!;
                    }
                  }
                }
              }
              if (state.homeData.popularFoods![index].stockType! == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.popularFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else if (quantity < state.homeData.popularFoods![index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
                state.homeData.popularFoods![index].quantity = quantity;
                await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, quantity);
                final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));
                UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                  trackingId: await _cartRepository.trackingId(),
                  uuid: sameUuid,
                  id: event.id,
                  quantity: quantity,
                );
                DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                if (cartOnlineResponse.errorType == NetErrorType.none) {
                } else {
                  Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                  ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                  emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                }
              } else {
                if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                      extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                    ),
                  );
                } else {
                  state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].stockNumber!;
                  await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.popularFoods![index].stockNumber!);
                  final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
                  state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
                  emit(
                    state.copyWith(
                      homeData: state.homeData,
                      status: HomeStatus.cartError,
                      statusCode: 0,
                      alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.',
                      extraMessage: '${state.homeData.popularFoods![index].stockNumber!}',
                    ),
                  );
                  UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                    trackingId: await _cartRepository.trackingId(),
                    uuid: sameUuid,
                    id: event.id,
                    quantity: state.homeData.popularFoods![index].stockNumber!,
                  );
                  DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
                  if (cartOnlineResponse.errorType == NetErrorType.none) {
                  } else {
                    Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                    ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                    emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
                  }
                }
              }
            } else {
              state.homeData.popularFoods![index].quantity = state.homeData.popularFoods![index].purchaseLimit!;
              await _cartRepository.updateProductVariationInCartLocal(sameUuid, event.id, state.homeData.popularFoods![index].purchaseLimit!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              emit(
                state.copyWith(
                  homeData: state.homeData,
                  status: HomeStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food',
                  extraMessage: '${state.homeData.popularFoods![index].purchaseLimit!}',
                ),
              );
              UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
                trackingId: await _cartRepository.trackingId(),
                uuid: sameUuid,
                id: event.id,
                quantity: state.homeData.popularFoods![index].purchaseLimit!,
              );
              DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
              if (cartOnlineResponse.errorType == NetErrorType.none) {
              } else {
                Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
                ServerErrorModel data = ServerErrorModel.fromJson(myMap);
                emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
              }
            }
          } else {
            int quantity = (int.parse(state.homeData.popularFoods![index].quantity.toString()) + int.parse(event.response.cartItem!.quantity.toString()));
            List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
            savedFoodTranslation.clear();
            for (var element in state.homeData.popularFoods![index].translations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
              savedFoodTranslation.add(savedData);
            }
            final String locale = await _authRepository.getLocale();
            List<food_in_cart_model.TaxationConfigModel> foodTaxation = <food_in_cart_model.TaxationConfigModel>[];
            foodTaxation.clear();
            for (var element in state.homeData.popularFoods![index].foodtaxations!) {
              var convertedItem = jsonEncode(element).toString();
              Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
              food_in_cart_model.TaxationConfigModel savedData = food_in_cart_model.TaxationConfigModel.fromJson(myMap, locale.toString());
              foodTaxation.add(savedData);
            }

            FoodInCartModel foodInCartInfo = FoodInCartModel(
              uuid: Uuid().generateV4(),
              name: state.homeData.popularFoods![index].name,
              shortDescription: state.homeData.popularFoods![index].shortDescription,
              image: state.homeData.popularFoods![index].image,
              restaurant: state.homeData.popularFoods![index].restaurant,
              foodType: state.homeData.popularFoods![index].foodType,
              price: state.homeData.popularFoods![index].price,
              discountType: state.homeData.popularFoods![index].discountType,
              discount: state.homeData.popularFoods![index].discount,
              offerPrice: state.homeData.popularFoods![index].offerPrice,
              purchaseLimit: state.homeData.popularFoods![index].purchaseLimit,
              stockNumber: state.homeData.popularFoods![index].stockNumber,
              stockType: state.homeData.popularFoods![index].stockType,
              quantity: event.response.cartItem!.quantity,
              id: event.id,
              addons: savedAddon,
              variations: savedVariations,
              restaurantInfo: restaurantInfo,
              translations: savedFoodTranslation,
              status: state.homeData.popularFoods![index].status,
              inStock: state.homeData.popularFoods![index].inStock,
              startTime: state.homeData.popularFoods![index].startTime,
              endTime: state.homeData.popularFoods![index].endTime,
              taxationEnable: state.homeData.popularFoods![index].taxationEnable!,
              foodtaxations: foodTaxation,
              instruction: event.response.instruction!,
              locale: locale.toString(),
            );
            state.homeData.popularFoods![index].quantity = quantity;
            await _cartRepository.addToCartLocal(foodInCartInfo);
            final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
            state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
            emit(state.copyWith(status: HomeStatus.cartUpdate, homeData: state.homeData));

            List<online_food_cart_model.ServerSavedVariationOptionModel> serverVariations = <online_food_cart_model.ServerSavedVariationOptionModel>[];
            serverVariations.clear();
            for (var variation in savedVariations) {
              List<String> selectedOptions = <String>[];
              for (var options in variation.options!) {
                selectedOptions.add(options.name!);
              }
              online_food_cart_model.ServerSavedVariationOptionModel saveIt = online_food_cart_model.ServerSavedVariationOptionModel(variation: variation.title!, selected: selectedOptions);
              serverVariations.add(saveIt);
            }

            CartItemRequestModel onlineCartParam = CartItemRequestModel(
              user: await _cartRepository.userId(),
              trackingId: await _cartRepository.trackingId(),
              uuid: foodInCartInfo.uuid,
              addons: newAddonIds.join(','),
              food: foodInCartInfo.id,
              restaurant: foodInCartInfo.restaurant,
              quantity: foodInCartInfo.quantity,
              variations: serverVariations,
              cookingInstruction: event.response.instruction!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.addToCartServer(onlineCartParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              CartItemResponseModel cartItemResponse = CartItemResponseModel.fromJson(myMap);
              await _cartRepository.updateCartItemIdFromServer(foodInCartInfo.uuid!, cartItemResponse.cartId!);
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              await _cartRepository.removeFromCartWithUuidLocal(foodInCartInfo.uuid!, foodInCartInfo.id!);
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(event.id);
              state.homeData.popularFoods![index].cartEntity = cartEntityPromise;
              state.homeData.popularFoods![index].quantity = 0;
              emit(state.copyWith(status: HomeStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          }
        }

        if (index != -1 && state.homeData.popularFoods![index].isFavourite! != event.response.isFavourite) {
          updateFavouriteData(event.id);
          emit(state.copyWith(status: HomeStatus.foodFav, homeData: state.homeData));
        }
      }
      add(HomeRefreshCartEvent());
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeHideRestaurantEvent(HomeHideRestaurantEvent event, Emitter<HomeState> emit) async {
    try {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(homeData: state.homeData));
      final String userId = await _homeRepository.userId();
      HideRestaurantRequestModel param = HideRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.hideRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, false);
          emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(homeData: state.homeData));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: HomeStatus.hidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, false);
        emit(state.copyWith(homeData: state.homeData));
        emit(state.copyWith(status: HomeStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(homeData: state.homeData));
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeRemoveRestaurantFromListEvent(HomeRemoveRestaurantFromListEvent event, Emitter<HomeState> emit) async {
    int newArrivalsIndex = state.homeData.newArrivals!.indexWhere((element) => element.id == event.id);

    int restaurantsIndex = state.homeData.restaurants!.indexWhere((element) => element.id == event.id);

    int popularRestaurantIndex = state.homeData.popularRestaurant!.indexWhere((element) => element.id == event.id);

    if (newArrivalsIndex != -1) {
      state.homeData.newArrivals!.removeAt(newArrivalsIndex);
    }

    if (restaurantsIndex != -1) {
      state.homeData.restaurants!.removeAt(restaurantsIndex);
    }

    if (popularRestaurantIndex != -1) {
      state.homeData.popularRestaurant!.removeAt(popularRestaurantIndex);
    }

    emit(state.copyWith(homeData: state.homeData));
  }

  FutureOr<void> _onHomeUndoHideActionEvent(HomeUndoHideActionEvent event, Emitter<HomeState> emit) async {
    try {
      hideUnhideRestaurant(event.id, false);
      emit(state.copyWith(homeData: state.homeData));
      final String userId = await _homeRepository.userId();
      ShowHiddenRestaurantRequestModel param = ShowHiddenRestaurantRequestModel(user: userId, restaurant: event.id);
      DioApiResponse response = await _homeRepository.showHiddenRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          hideUnhideRestaurant(event.id, true);
          emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          emit(state.copyWith(homeData: state.homeData));
        } else {
          emit(state.copyWith(hideUnhideId: event.id, status: HomeStatus.unhidden));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        hideUnhideRestaurant(event.id, true);
        emit(state.copyWith(homeData: state.homeData));
        emit(state.copyWith(status: HomeStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      hideUnhideRestaurant(event.id, true);
      emit(state.copyWith(homeData: state.homeData));
      emit(state.copyWith(status: HomeStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  Future<void> hideUnhideRestaurant(String id, bool hideUnhide) async {
    int newArrivalsIndex = state.homeData.newArrivals!.indexWhere((element) => element.id == id);

    int restaurantsIndex = state.homeData.restaurants!.indexWhere((element) => element.id == id);

    int popularRestaurantIndex = state.homeData.popularRestaurant!.indexWhere((element) => element.id == id);

    if (newArrivalsIndex != -1) {
      state.homeData.newArrivals![newArrivalsIndex].isHidden = hideUnhide;
    }

    if (restaurantsIndex != -1) {
      state.homeData.restaurants![restaurantsIndex].isHidden = hideUnhide;
    }

    if (popularRestaurantIndex != -1) {
      state.homeData.popularRestaurant![popularRestaurantIndex].isHidden = hideUnhide;
    }
  }

  FutureOr<void> _onHomeSilentHideEvent(HomeSilentHideEvent event, Emitter<HomeState> emit) async {
    hideUnhideRestaurant(event.id, true);
    emit(state.copyWith(homeData: state.homeData));
  }

  FutureOr<void> _onHomeSilentUnHideEvent(HomeSilentUnHideEvent event, Emitter<HomeState> emit) async {
    hideUnhideRestaurant(event.id, false);
    emit(state.copyWith(homeData: state.homeData));
  }

  FutureOr<void> _onHomeSilentNotificationEvent(HomeSilentNotificationEvent event, Emitter<HomeState> emit) async {
    try {
      final String userId = await _homeRepository.userId();
      DioApiResponse response = await _homeRepository.getNotificationCount(userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        NotificationCountResponseModel data = NotificationCountResponseModel.fromJson(myMap);
        if (data.success!) {
          emit(state.copyWith(notificationCount: data.count!));
        }
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHomeNotificationListClickEvent(HomeNotificationListClickEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(notificationCount: 0));
  }

  FutureOr<void> _onHomePullRefreshEvent(HomePullRefreshEvent event, Emitter<HomeState> emit) async {
    try {
      final String addressTitle = await _locationRepository.getAddressTitle();
      final String fullAddress = await _locationRepository.getFullAddress();
      bool isAuthorized = await _homeRepository.isAuthorized();
      final String locale = await _homeRepository.getLocale();
      emit(
        state.copyWith(
          addressTitle: addressTitle,
          addressSubTitle: fullAddress,
          isAuthorized: isAuthorized,
          pageSize: ApiRequestService.pageSize,
          locale: locale.isNotEmpty ? locale : Environments.defaultLanguage,
          status: HomeStatus.loading,
        ),
      );
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final String userId = await _homeRepository.userId();
      HomeRestaurantRequest param = HomeRestaurantRequest(
        latitude: userLatitude != 0 ? userLatitude : 0,
        longitude: userLongitude != 0 ? userLongitude : 0,
        page: state.currentPage,
        limit: state.pageSize,
        uid: userId,
      );
      DioApiResponse response = await _homeRepository.getHomeData(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: HomeStatus.empty));
        } else {
          final String locale = await _homeRepository.getLocale();
          HomeResponseModel homeResponse = HomeResponseModel.fromJson(myMap, locale.toString());
          List<CampaignListModel> campaignCombine = <CampaignListModel>[];
          campaignCombine.clear();
          for (var element in homeResponse.foodCampaign!) {
            CampaignListModel data = CampaignListModel(
              title: element.title,
              shortDescription: element.shortDescription,
              image: element.image,
              startDate: element.startDate,
              endDate: element.endDate,
              startTime: element.startTime,
              endTime: element.endTime,
              type: 'food',
              id: element.id,
              locale: locale.toString(),
            );
            campaignCombine.add(data);
          }
          for (var element in homeResponse.restaurantCampaign!) {
            CampaignListModel data = CampaignListModel(
              title: element.title,
              shortDescription: element.shortDescription,
              image: element.image,
              startDate: element.startDate,
              endDate: element.endDate,
              startTime: element.startTime,
              endTime: element.endTime,
              type: 'restaurant',
              id: element.id,
              locale: locale.toString(),
            );
            campaignCombine.add(data);
          }
          for (var element in homeResponse.mostReviewedFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          for (var element in homeResponse.trendingFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          for (var element in homeResponse.popularFoods!) {
            if (await _cartRepository.checkProductInCart(element.id!)) {
              final int? quantityPromise = await _cartRepository.getQuantity(element.id!);
              element.quantity = quantityPromise;
              final String? cartEntityPromise = await _cartRepository.getProductCartEntity(element.id!);
              element.cartEntity = cartEntityPromise;
            } else {
              element.quantity = 0;
              element.cartEntity = 'single';
            }
          }
          homeResponse.newArrivals!.sort((a, b) => b.promote! ? 1 : -1);
          homeResponse.restaurants!.sort((a, b) => b.promote! ? 1 : -1);

          List<String> favIds = <String>[];
          for (var element in homeResponse.restaurants!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in homeResponse.newArrivals!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }
          for (var element in homeResponse.popularRestaurant!) {
            if (element.isFavourite! && !favIds.contains(element.id)) {
              favIds.add(element.id!);
            }
          }

          emit(state.copyWith(status: HomeStatus.success, favRestIds: favIds, homeData: homeResponse, campaignList: campaignCombine));
        }
        if (isAuthorized && userId.isNotEmpty) {
          add(HomeSilentNotificationEvent());
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HomeStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HomeStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}
