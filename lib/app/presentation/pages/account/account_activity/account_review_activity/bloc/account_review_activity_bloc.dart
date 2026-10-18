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
import 'package:user/app/core/models/my_review_list_activity_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'account_review_activity_event.dart';
part 'account_review_activity_state.dart';

class AccountReviewActivityBloc extends Bloc<AccountReviewActivityEvent, AccountReviewActivityState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountReviewActivityBloc()
    : super(
        AccountReviewActivityState(
          model: MyReviewListActivityModel(driverReviews: [], foodReviews: [], restaurantReviews: [], success: false, locale: ''),
        ),
      ) {
    on<AccountReviewActivityInitialEvent>(_onAccountReviewActivityInitialEvent);
    on<AccountReviewActivityFoodReviewToggleViewEvent>(_onAccountReviewActivityFoodReviewToggleViewEvent);
    on<AccountReviewActivityRestaurantReviewToggleViewEvent>(_onAccountReviewActivityRestaurantReviewToggleViewEvent);
    on<AccountReviewActivityDriverReviewToggleViewEvent>(_onAccountReviewActivityDriverReviewToggleViewEvent);
  }

  FutureOr<void> _onAccountReviewActivityInitialEvent(AccountReviewActivityInitialEvent event, Emitter<AccountReviewActivityState> emit) async {
    try {
      emit(state.copyWith(status: AccountReviewActivityStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "account_review"}, 'account_review_screen', 'account_review_screen');
      final String userId = await _authRepository.userId();
      DioApiResponse response = await _authRepository.getMyReviewList(userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        MyReviewListActivityModel reviewModel = MyReviewListActivityModel.fromJson(myMap, locale.toString());
        if (reviewModel.foodReviews!.isEmpty && reviewModel.driverReviews!.isEmpty && reviewModel.restaurantReviews!.isEmpty) {
          emit(state.copyWith(status: AccountReviewActivityStatus.empty));
        } else {
          emit(state.copyWith(status: AccountReviewActivityStatus.success, model: reviewModel));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountReviewActivityStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountReviewActivityStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountReviewActivityFoodReviewToggleViewEvent(AccountReviewActivityFoodReviewToggleViewEvent event, Emitter<AccountReviewActivityState> emit) async {
    bool toggleView = !state.isFoodReviewOpen;
    emit(state.copyWith(isFoodReviewOpen: toggleView));
  }

  FutureOr<void> _onAccountReviewActivityRestaurantReviewToggleViewEvent(AccountReviewActivityRestaurantReviewToggleViewEvent event, Emitter<AccountReviewActivityState> emit) async {
    bool toggleView = !state.isRestaurantReviewOpen;
    emit(state.copyWith(isRestaurantReviewOpen: toggleView));
  }

  FutureOr<void> _onAccountReviewActivityDriverReviewToggleViewEvent(AccountReviewActivityDriverReviewToggleViewEvent event, Emitter<AccountReviewActivityState> emit) async {
    bool toggleView = !state.isDriverReviewOpen;
    emit(state.copyWith(isDriverReviewOpen: toggleView));
  }
}

