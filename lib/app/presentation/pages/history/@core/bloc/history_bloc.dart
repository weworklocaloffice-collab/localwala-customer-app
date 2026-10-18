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
import 'package:user/app/core/models/my_order_list_response_model.dart';
import 'package:user/app/core/models/request/my_order_list_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  HistoryBloc()
    : super(
        HistoryState(
          pageSize: ApiRequestService.pageSize,
          orderList: MyOrderListResponseModel(limit: 0, page: 0, totalPages: 0, totalResults: 0, success: false, orders: [], locale: ''),
        ),
      ) {
    on<HistoryInitialEvent>(_onHistoryInitialEvent);
    on<HistoryPullRefreshEvent>(_onHistoryPullRefreshEvent);
    on<HistoryLoadMoreOrderEvent>(_onHistoryLoadMoreOrderEvent);
  }

  FutureOr<void> _onHistoryInitialEvent(HistoryInitialEvent event, Emitter<HistoryState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_history"}, 'order_history_screen', 'order_history_screen');
      final String userId = await _historyRepository.userId();
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: HistoryStatus.loading));
        MyOrderListRequestModel param = MyOrderListRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _historyRepository.getMyOrderList(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          MyOrderListResponseModel orderResponse = MyOrderListResponseModel.fromJson(myMap, locale.toString());
          if (orderResponse.orders!.isEmpty) {
            emit(state.copyWith(status: HistoryStatus.empty));
          } else {
            emit(state.copyWith(status: HistoryStatus.success, orderList: orderResponse));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: HistoryStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: HistoryStatus.unAuthorized, statusCode: 0, alertMessage: 'Oh snap! Looks like you took a wrong turn. Permission Denied. Please Logged In', extraMessage: ''));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HistoryStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryPullRefreshEvent(HistoryPullRefreshEvent event, Emitter<HistoryState> emit) async {
    try {
      emit(state.copyWith(status: HistoryStatus.loading, pageSize: ApiRequestService.pageSize));
      final String userId = await _historyRepository.userId();
      MyOrderListRequestModel param = MyOrderListRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
      DioApiResponse response = await _historyRepository.getMyOrderList(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        MyOrderListResponseModel orderResponse = MyOrderListResponseModel.fromJson(myMap, locale.toString());
        if (orderResponse.orders!.isEmpty) {
          emit(state.copyWith(status: HistoryStatus.empty));
        } else {
          emit(state.copyWith(status: HistoryStatus.success, orderList: orderResponse));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HistoryStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HistoryStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryLoadMoreOrderEvent(HistoryLoadMoreOrderEvent event, Emitter<HistoryState> emit) async {
    if (state.orderList.orders!.length < state.orderList.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _historyRepository.userId();
        MyOrderListRequestModel param = MyOrderListRequestModel(page: state.currentPage, limit: state.pageSize * 2, uid: userId);
        DioApiResponse response = await _historyRepository.getMyOrderList(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          MyOrderListResponseModel orderResponse = MyOrderListResponseModel.fromJson(myMap, locale.toString());
          if (orderResponse.orders!.isEmpty) {
            emit(state.copyWith(status: HistoryStatus.empty, loadMore: false));
          } else {
            emit(state.copyWith(status: HistoryStatus.success, orderList: orderResponse, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: HistoryStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: HistoryStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

