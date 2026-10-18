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
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/call_number_fetched_response_model.dart';
import 'package:user/app/core/models/request/restaurant_detail_information_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_request_model.dart';
import 'package:user/app/core/models/restaurant_detail_information_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/favourite_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'restaurant_detail_info_event.dart';
part 'restaurant_detail_info_state.dart';

class RestaurantDetailInfoBloc extends Bloc<RestaurantDetailInfoEvent, RestaurantDetailInfoState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final LocationRepository _locationRepository = LocationRepository();
  final FavouriteRepository _favouriteRepository = FavouriteRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  RestaurantDetailInfoBloc() : super(RestaurantDetailInfoState(model: RestaurantDetailInformationResponseModel(locale: ''))) {
    on<RestaurantDetailInfoInitialEvent>(_onRestaurantDetailInfoInitialEvent);
    on<RestaurantDetailInfoFavouriteEvent>(_onRestaurantDetailInfoFavouriteEvent);
    on<RestaurantDetailInfoShareEvent>(_onRestaurantDetailInfoShareEvent);
    on<RestaurantDetailInfoDirectionEvent>(_onRestaurantDetailInfoDirectionEvent);
    on<RestaurantCallNumberEvent>(_onRestaurantCallNumberEvent);
    on<RestaurantShowMoreSlotEvent>(_onRestaurantShowMoreSlotEvent);
  }

  FutureOr<void> _onRestaurantDetailInfoInitialEvent(RestaurantDetailInfoInitialEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_detail_information", "slug": event.slug, "name": event.name}, '${event.slug}_restaurant_screen', '${event.slug}_restaurant_screen');
      bool isAuthorized = await _restaurantRepository.isAuthorized();
      emit(state.copyWith(status: RestaurantDetailInfoStatus.loading, slug: event.slug, name: event.name, isAuthorized: isAuthorized));
      final String userId = await _restaurantRepository.userId();
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      RestaurantDetailInformationRequestModel param = RestaurantDetailInformationRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, slug: event.slug, uid: userId);
      DioApiResponse response = await _restaurantRepository.getRestaurantDetailInformation(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: RestaurantDetailInfoStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          RestaurantDetailInformationResponseModel data = RestaurantDetailInformationResponseModel.fromJson(myMap, locale.toString());
          for (var element in data.orderCoupons!) {
            if (element.couponType! == 'default' || element.couponType! == 'restaurant' || element.couponType! == 'firstorder') {
              if (element.discountType == 'amount') {
                element.promoLbl = 'Save ${kAppPriceFormat(element.minDiscount!)} with this discount';
              } else {
                element.promoLbl = element.maxDiscount! > 0 ? 'Save ${element.minDiscount!}% to ${element.maxDiscount!}% with this code' : 'Save ${element.minDiscount!}% with this code';
              }
            } else if (element.couponType! == 'loyality') {
              element.promoLbl = 'Earn ${element.loyalityPoints} loyality points with this code on your wallet';
            } else if (element.couponType! == 'bogo') {
              element.promoLbl = 'Buy One Get One Free with this code';
            } else if (element.couponType! == 'freedelivery') {
              element.promoLbl = 'Save delivery charges with this code';
            }
          }
          if (event.campaignId.isNotEmpty) {
            await _homeRepository.saveVisitCampaignDetail(event.campaignId, 'dining');
          } else {
            await _homeRepository.clearVisitedCampaignDetail();
          }
          emit(state.copyWith(status: RestaurantDetailInfoStatus.success, model: data));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantDetailInfoStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantDetailInfoStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantDetailInfoFavouriteEvent(RestaurantDetailInfoFavouriteEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    final String userId = await _favouriteRepository.userId();
    final String userRole = await _favouriteRepository.userRole();
    if (userId.isNotEmpty && userRole.isNotEmpty && userRole == 'user') {
      if (state.model.details!.isFavourite == true) {
        state.model.details!.isFavourite = !state.model.details!.isFavourite!;
        emit(state.copyWith(model: state.model));
        try {
          DioApiResponse response = await _favouriteRepository.deleteFavouriteRestaurant(userId, state.model.details!.id!);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: RestaurantDetailInfoStatus.favRemove));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            state.model.details!.isFavourite = !state.model.details!.isFavourite!;
            emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), model: state.model));
          }
        } catch (e, stacktrace) {
          state.model.details!.isFavourite = !state.model.details!.isFavourite!;
          emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', model: state.model));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      } else {
        state.model.details!.isFavourite = !state.model.details!.isFavourite!;
        emit(state.copyWith(model: state.model));
        try {
          SaveFavouriteRequestModel param = SaveFavouriteRequestModel(user: userId, type: 'restaurant', restaurant: state.model.details!.id!, food: '');
          DioApiResponse response = await _homeRepository.saveFavourite(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
            if (initialResponse.success!) {
              emit(state.copyWith(status: RestaurantDetailInfoStatus.favAdd));
            }
          } else {
            state.model.details!.isFavourite = !state.model.details!.isFavourite!;
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), model: state.model));
          }
        } catch (e, stacktrace) {
          state.model.details!.isFavourite = !state.model.details!.isFavourite!;
          emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', model: state.model));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    } else {
      emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
    }
  }

  FutureOr<void> _onRestaurantDetailInfoShareEvent(RestaurantDetailInfoShareEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    final String websiteURL = await _restaurantRepository.websiteURL();
    final String restaurantURL = '$websiteURL/${state.model.details!.slug!}?source=app_sharing';
    final String shareText = "Hello, I bet you’ll appreciate ordering from ${state.model.details!.name!} | ${state.model.details!.address!} $restaurantURL";
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  FutureOr<void> _onRestaurantDetailInfoDirectionEvent(RestaurantDetailInfoDirectionEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    try {
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      final double restLat = state.model.details!.location!.coordinates![1];
      final double restLng = state.model.details!.location!.coordinates![0];
      final availableMaps = await MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty) {
        await availableMaps.first.showMarker(
          title: 'Destination',
          coords: Coords(restLat, restLng),
        );
      }
    } catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantCallNumberEvent(RestaurantCallNumberEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    try {
      emit(state.copyWith(status: RestaurantDetailInfoStatus.callRequested));
      DioApiResponse response = await _homeRepository.fetchRestaurantCallNumber(state.model.details!.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
        } else {
          emit(state.copyWith(status: RestaurantDetailInfoStatus.success));
          CallNumberFetchedResponseModel callResponse = CallNumberFetchedResponseModel.fromJson(myMap);
          if (callResponse.detail!.contactInfo!.countryCode!.isNotEmpty && callResponse.detail!.contactInfo!.contactNumber!.isNotEmpty) {
            final Uri numberLaunchUri = Uri(scheme: 'tel', path: '${callResponse.detail!.contactInfo!.countryCode!}${callResponse.detail!.contactInfo!.contactNumber!}');
            launchUrl(numberLaunchUri);
          }
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), model: state.model));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RestaurantDetailInfoStatus.customError, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRestaurantShowMoreSlotEvent(RestaurantShowMoreSlotEvent event, Emitter<RestaurantDetailInfoState> emit) async {
    state.model.details!.slots![event.slotIndex].isShowMore = !state.model.details!.slots![event.slotIndex].isShowMore!;
    emit(state.copyWith(model: state.model));
  }
}

