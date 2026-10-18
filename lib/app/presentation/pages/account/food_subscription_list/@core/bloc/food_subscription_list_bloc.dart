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
import 'package:user/app/core/models/purchased_tiffin_subscription_response_package_model.dart';
import 'package:user/app/core/models/request/purchased_tiffin_subscription_package_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_subscription_list_event.dart';
part 'food_subscription_list_state.dart';

class FoodSubscriptionListBloc extends Bloc<FoodSubscriptionListEvent, FoodSubscriptionListState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  FoodSubscriptionListBloc()
    : super(
        FoodSubscriptionListState(
          pageSize: ApiRequestService.pageSize,
          purchasedList: PurchasedTiffinSubscriptionPackageResponseModel(limit: 0, page: 0, totalPages: 0, totalResults: 0, success: false, purchased: [], locale: ''),
        ),
      ) {
    on<FoodSubscriptionListInitialEvent>(_onFoodSubscriptionListInitialEvent);
    on<FoodSubscriptionListLoadMoreEvent>(_onFoodSubscriptionListLoadMoreEvent);
  }

  FutureOr<void> _onFoodSubscriptionListInitialEvent(FoodSubscriptionListInitialEvent event, Emitter<FoodSubscriptionListState> emit) async {
    try {
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_packages"}, 'food_subscription_list_screen', 'food_subscription_list_screen');
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: FoodSubscriptionListStatus.loading));
        PurchasedTiffinSubscriptionPackageRequestModel param = PurchasedTiffinSubscriptionPackageRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _subscriptionTiffinPackagesRepository.getPurchasedSubscriptionPackage(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          PurchasedTiffinSubscriptionPackageResponseModel purchasedResponse = PurchasedTiffinSubscriptionPackageResponseModel.fromJson(myMap, locale.toString());
          if (purchasedResponse.purchased!.isEmpty) {
            emit(state.copyWith(status: FoodSubscriptionListStatus.empty));
          } else {
            emit(state.copyWith(status: FoodSubscriptionListStatus.success, purchasedList: purchasedResponse));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FoodSubscriptionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: FoodSubscriptionListStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSubscriptionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSubscriptionListLoadMoreEvent(FoodSubscriptionListLoadMoreEvent event, Emitter<FoodSubscriptionListState> emit) async {
    if (state.purchasedList.purchased!.length < state.purchasedList.totalResults! && !state.loadMore) {
      try {
        final String userId = await _subscriptionTiffinPackagesRepository.userId();
        emit(state.copyWith(loadMore: true));
        PurchasedTiffinSubscriptionPackageRequestModel param = PurchasedTiffinSubscriptionPackageRequestModel(page: state.currentPage, limit: state.pageSize * 2, uid: userId);
        DioApiResponse response = await _subscriptionTiffinPackagesRepository.getPurchasedSubscriptionPackage(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          PurchasedTiffinSubscriptionPackageResponseModel purchasedResponse = PurchasedTiffinSubscriptionPackageResponseModel.fromJson(myMap, locale.toString());
          if (purchasedResponse.purchased!.isEmpty) {
            emit(state.copyWith(status: FoodSubscriptionListStatus.empty, loadMore: false));
          } else {
            emit(state.copyWith(status: FoodSubscriptionListStatus.success, purchasedList: purchasedResponse, pageSize: state.pageSize * 2, loadMore: false));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FoodSubscriptionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FoodSubscriptionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

