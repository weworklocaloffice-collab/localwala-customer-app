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
import 'package:user/app/core/models/notification_list_response_model.dart';
import 'package:user/app/core/models/request/notification_list_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'notification_list_event.dart';
part 'notification_list_state.dart';

class NotificationListBloc extends Bloc<NotificationListEvent, NotificationListState> {
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  NotificationListBloc()
    : super(
        NotificationListState(
          response: NotificationListResponseModel(results: [], limit: 0, page: 0, totalPages: 0, totalResults: 0, locale: ''),
          pageSize: ApiRequestService.pageSize,
        ),
      ) {
    on<NotificationListInitialEvent>(_onNotificationListInitialEvent);
    on<NotificationListReadAllEvent>(_onNotificationListReadAllEvent);
    on<NotificationListLoadMoreEvent>(_onNotificationListLoadMoreEvent);
    on<NotificationListPullRefreshEvent>(_onNotificationListPullRefreshEvent);
  }

  FutureOr<void> _onNotificationListInitialEvent(NotificationListInitialEvent event, Emitter<NotificationListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "notification_list"}, 'notification_screen', 'notification_screen');
      final String userId = await _homeRepository.userId();
      emit(state.copyWith(status: NotificationListStatus.loading, user: userId));
      NotificationListRequestModel param = NotificationListRequestModel(page: state.currentPage, limit: state.pageSize, user: userId);
      DioApiResponse response = await _homeRepository.getNotificationList(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        NotificationListResponseModel data = NotificationListResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(response: data, status: data.results!.isNotEmpty ? NotificationListStatus.success : NotificationListStatus.empty));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: NotificationListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: NotificationListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onNotificationListReadAllEvent(NotificationListReadAllEvent event, Emitter<NotificationListState> emit) async {
    try {
      for (var element in state.response.results!) {
        element.status = false;
      }
      emit(state.copyWith(response: state.response));
      DioApiResponse response = await _homeRepository.readAllNotification(state.user);
      if (response.errorType == NetErrorType.none) {
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: NotificationListStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: NotificationListStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onNotificationListLoadMoreEvent(NotificationListLoadMoreEvent event, Emitter<NotificationListState> emit) async {
    if (state.response.results!.length < state.response.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _homeRepository.userId();
        NotificationListRequestModel param = NotificationListRequestModel(page: state.currentPage, limit: state.pageSize * 2, user: userId);
        DioApiResponse response = await _homeRepository.getNotificationList(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          NotificationListResponseModel data = NotificationListResponseModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(response: data, status: data.results!.isNotEmpty ? NotificationListStatus.success : NotificationListStatus.empty, loadMore: false, pageSize: state.pageSize * 2));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: NotificationListStatus.failure, loadMore: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: NotificationListStatus.customError, loadMore: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onNotificationListPullRefreshEvent(NotificationListPullRefreshEvent event, Emitter<NotificationListState> emit) async {
    try {
      emit(state.copyWith(status: NotificationListStatus.loading, pageSize: ApiRequestService.pageSize));
      final String userId = await _homeRepository.userId();
      NotificationListRequestModel param = NotificationListRequestModel(page: state.currentPage, limit: state.pageSize, user: userId);
      DioApiResponse response = await _homeRepository.getNotificationList(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        NotificationListResponseModel data = NotificationListResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(response: data, status: data.results!.isNotEmpty ? NotificationListStatus.success : NotificationListStatus.empty));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: NotificationListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: NotificationListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

