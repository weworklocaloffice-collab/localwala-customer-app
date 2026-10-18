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
import 'package:user/app/core/models/request/user_order_transaction_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_order_transaction_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'order_transaction_list_event.dart';
part 'order_transaction_list_state.dart';

class OrderTransactionListBloc extends Bloc<OrderTransactionListEvent, OrderTransactionListState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  OrderTransactionListBloc()
    : super(
        OrderTransactionListState(
          pageSize: ApiRequestService.pageSize,
          model: UserOrderTransactionResponseModel(transactions: [], locale: ''),
        ),
      ) {
    on<OrderTransactionListInitialEvent>(_onOrderTransactionListInitialEvent);
    on<OrderTransactionListLoadMoreOrderTransactionEvent>(_onOrderTransactionListLoadMoreOrderTransactionEvent);
    on<OrderTransactionListPullRefreshEvent>(_onOrderTransactionListPullRefreshEvent);
  }

  FutureOr<void> _onOrderTransactionListInitialEvent(OrderTransactionListInitialEvent event, Emitter<OrderTransactionListState> emit) async {
    try {
      final String userId = await _historyRepository.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "order_transactions"}, 'order_transaction_screen', 'order_transaction_screen');
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: OrderTransactionListStatus.loading));
        UserOrderTransactionRequestModel param = UserOrderTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _historyRepository.getUserOrderTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserOrderTransactionResponseModel transactions = UserOrderTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: OrderTransactionListStatus.empty));
          } else {
            emit(state.copyWith(status: OrderTransactionListStatus.success, model: transactions));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: OrderTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: OrderTransactionListStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderTransactionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOrderTransactionListLoadMoreOrderTransactionEvent(OrderTransactionListLoadMoreOrderTransactionEvent event, Emitter<OrderTransactionListState> emit) async {
    if (state.model.transactions!.length < state.model.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _historyRepository.userId();
        UserOrderTransactionRequestModel param = UserOrderTransactionRequestModel(page: state.currentPage, limit: state.pageSize * 2, uid: userId);
        DioApiResponse response = await _historyRepository.getUserOrderTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserOrderTransactionResponseModel transactions = UserOrderTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: OrderTransactionListStatus.empty, loadMore: false));
          } else {
            emit(state.copyWith(status: OrderTransactionListStatus.success, model: transactions, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: OrderTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: OrderTransactionListStatus.failure, loadMore: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onOrderTransactionListPullRefreshEvent(OrderTransactionListPullRefreshEvent event, Emitter<OrderTransactionListState> emit) async {
    try {
      final String userId = await _historyRepository.userId();
      emit(state.copyWith(status: OrderTransactionListStatus.loading, pageSize: ApiRequestService.pageSize));
      UserOrderTransactionRequestModel param = UserOrderTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
      DioApiResponse response = await _historyRepository.getUserOrderTransaction(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        UserOrderTransactionResponseModel transactions = UserOrderTransactionResponseModel.fromJson(myMap, locale.toString());
        if (transactions.transactions!.isEmpty) {
          emit(state.copyWith(status: OrderTransactionListStatus.empty));
        } else {
          emit(state.copyWith(status: OrderTransactionListStatus.success, model: transactions));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderTransactionListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderTransactionListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

