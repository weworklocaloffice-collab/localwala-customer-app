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
import 'package:user/app/core/models/request/user_dining_transactions_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_dining_transaction_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_booking_transaction_event.dart';
part 'dining_booking_transaction_state.dart';

class DiningBookingTransactionBloc extends Bloc<DiningBookingTransactionEvent, DiningBookingTransactionState> {
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingTransactionBloc()
    : super(
        DiningBookingTransactionState(
          pageSize: ApiRequestService.pageSize,
          model: UserDiningTransactionResponseModel(transactions: [], locale: ''),
        ),
      ) {
    on<DiningBookingTransactionInitialEvent>(_onDiningBookingTransactionInitialEvent);
    on<DiningBookingTransactionLoadMoreBookingTransactionEvent>(_onDiningBookingTransactionLoadMoreBookingTransactionEvent);
    on<DiningBookingTransactionPullRefreshEvent>(_onDiningBookingTransactionPullRefreshEvent);
  }

  FutureOr<void> _onDiningBookingTransactionInitialEvent(DiningBookingTransactionInitialEvent event, Emitter<DiningBookingTransactionState> emit) async {
    try {
      final String userId = await _diningRepository.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_transaction"}, 'dining_booking_transaction_screen', 'dining_booking_transaction_screen');
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: DiningBookingTransactionStatus.loading));
        UserDiningTransactionRequestModel param = UserDiningTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
        DioApiResponse response = await _diningRepository.getDiningTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserDiningTransactionResponseModel transactions = UserDiningTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: DiningBookingTransactionStatus.empty));
          } else {
            emit(state.copyWith(status: DiningBookingTransactionStatus.success, model: transactions));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DiningBookingTransactionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: DiningBookingTransactionStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingTransactionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingTransactionLoadMoreBookingTransactionEvent(DiningBookingTransactionLoadMoreBookingTransactionEvent event, Emitter<DiningBookingTransactionState> emit) async {
    if (state.model.transactions!.length < state.model.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _diningRepository.userId();
        UserDiningTransactionRequestModel param = UserDiningTransactionRequestModel(page: state.currentPage, limit: state.pageSize * 2, uid: userId);
        DioApiResponse response = await _diningRepository.getDiningTransaction(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          UserDiningTransactionResponseModel transactions = UserDiningTransactionResponseModel.fromJson(myMap, locale.toString());
          if (transactions.transactions!.isEmpty) {
            emit(state.copyWith(status: DiningBookingTransactionStatus.empty, loadMore: false));
          } else {
            emit(state.copyWith(status: DiningBookingTransactionStatus.success, model: transactions, loadMore: false, pageSize: state.pageSize * 2));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DiningBookingTransactionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), loadMore: false));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: DiningBookingTransactionStatus.failure, loadMore: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onDiningBookingTransactionPullRefreshEvent(DiningBookingTransactionPullRefreshEvent event, Emitter<DiningBookingTransactionState> emit) async {
    try {
      final String userId = await _diningRepository.userId();
      emit(state.copyWith(status: DiningBookingTransactionStatus.loading, pageSize: ApiRequestService.pageSize));
      UserDiningTransactionRequestModel param = UserDiningTransactionRequestModel(page: state.currentPage, limit: state.pageSize, uid: userId);
      DioApiResponse response = await _diningRepository.getDiningTransaction(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        UserDiningTransactionResponseModel transactions = UserDiningTransactionResponseModel.fromJson(myMap, locale.toString());
        if (transactions.transactions!.isEmpty) {
          emit(state.copyWith(status: DiningBookingTransactionStatus.empty));
        } else {
          emit(state.copyWith(status: DiningBookingTransactionStatus.success, model: transactions));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingTransactionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingTransactionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

