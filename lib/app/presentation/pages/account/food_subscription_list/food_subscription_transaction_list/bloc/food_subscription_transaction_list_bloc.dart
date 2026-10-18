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
import 'package:user/app/core/models/request/user_food_subscription_transaction_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_food_subscription_transaction_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_subscription_transaction_list_event.dart';
part 'food_subscription_transaction_list_state.dart';

class FoodSubscriptionTransactionListBloc extends Bloc<FoodSubscriptionTransactionListEvent, FoodSubscriptionTransactionListState> {
  final SubscriptionTiffinPackagesRepository _packagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  FoodSubscriptionTransactionListBloc()
    : super(
        FoodSubscriptionTransactionListState(
          pageSize: ApiRequestService.pageSize,
          model: UserFoodSubscriptionTransactionResponseModel(transactions: [], locale: ''),
        ),
      ) {
    on<FoodSubscriptionTransactionListInitialEvent>(_onFoodSubscriptionTransactionListInitialEvent);
    on<FoodSubscriptionLoadMoreSubscriptionTransactionEvent>(_onFoodSubscriptionLoadMoreSubscriptionTransactionEvent);
    on<FoodSubscriptionPullRefreshEvent>(_onFoodSubscriptionPullRefreshEvent);
  }

  FutureOr<void> _onFoodSubscriptionTransactionListInitialEvent(FoodSubscriptionTransactionListInitialEvent event, Emitter<FoodSubscriptionTransactionListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_transactions"}, 'tiffin_subscription_transactions_screen', 'tiffin_subscription_transactions_screen');
      final String userId = await _packagesRepository.userId();
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.loading));
        UserFoodSubscriptionTransactionRequestModel param = UserFoodSubscriptionTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _packagesRepository.getFoodSubscriptionTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserFoodSubscriptionTransactionResponseModel transactions = UserFoodSubscriptionTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.empty));
          } else {
            emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.success, model: transactions));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onFoodSubscriptionLoadMoreSubscriptionTransactionEvent(FoodSubscriptionLoadMoreSubscriptionTransactionEvent event, Emitter<FoodSubscriptionTransactionListState> emit) async {
    if (state.model.transactions!.length < state.model.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _packagesRepository.userId();
        UserFoodSubscriptionTransactionRequestModel param = UserFoodSubscriptionTransactionRequestModel(page: state.currentPage, limit: state.pageSize * 2, uid: userId);
        DioApiResponse response = await _packagesRepository.getFoodSubscriptionTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserFoodSubscriptionTransactionResponseModel transactions = UserFoodSubscriptionTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.empty, loadMore: false));
          } else {
            emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.success, model: transactions, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, loadMore: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onFoodSubscriptionPullRefreshEvent(FoodSubscriptionPullRefreshEvent event, Emitter<FoodSubscriptionTransactionListState> emit) async {
    try {
      final String userId = await _packagesRepository.userId();
      emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.loading, pageSize: ApiRequestService.pageSize));
      UserFoodSubscriptionTransactionRequestModel param = UserFoodSubscriptionTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
      DioApiResponse response = await _packagesRepository.getFoodSubscriptionTransaction(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        UserFoodSubscriptionTransactionResponseModel transactions = UserFoodSubscriptionTransactionResponseModel.fromJson(myMap, locale.toString());
        if (transactions.transactions!.isEmpty) {
          emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.empty));
        } else {
          emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.success, model: transactions));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSubscriptionTransactionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

