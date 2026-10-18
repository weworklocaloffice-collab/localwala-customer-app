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
import 'package:user/app/core/models/hide_restaurant_reason_list_model.dart';
import 'package:user/app/core/models/request/update_hide_restaurant_reason_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'hide_restaurant_reason_modal_event.dart';
part 'hide_restaurant_reason_modal_state.dart';

class HideRestaurantReasonModalBloc extends Bloc<HideRestaurantReasonModalEvent, HideRestaurantReasonModalState> {
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  HideRestaurantReasonModalBloc()
    : super(
        HideRestaurantReasonModalState(
          list: HideRestaurantReasonListModel(reasons: [], locale: ''),
        ),
      ) {
    on<HideRestaurantReasonModalInitialEvent>(_onHideRestaurantReasonModalInitialEvent);
    on<HideRestaurantReasonSelectEvent>(_onHideRestaurantReasonSelectEvent);
    on<HideRestaurantReasonSubmitEvent>(_onHideRestaurantReasonSubmitEvent);
  }

  FutureOr<void> _onHideRestaurantReasonModalInitialEvent(HideRestaurantReasonModalInitialEvent event, Emitter<HideRestaurantReasonModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "hide_restaurant_reason"}, 'hide_restaurant_reason_screen', 'hide_restaurant_reason_screen');
      emit(state.copyWith(status: HideRestaurantReasonModalStatus.loading, restaurantId: event.restaurantId, restaurantName: event.restaurantName));
      DioApiResponse response = await _homeRepository.getHideRestaurantReason();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        HideRestaurantReasonListModel data = HideRestaurantReasonListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? HideRestaurantReasonModalStatus.success : HideRestaurantReasonModalStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HideRestaurantReasonModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HideRestaurantReasonModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHideRestaurantReasonSelectEvent(HideRestaurantReasonSelectEvent event, Emitter<HideRestaurantReasonModalState> emit) async {
    emit(state.copyWith(status: HideRestaurantReasonModalStatus.success, reasonId: event.reasonId));
  }

  FutureOr<void> _onHideRestaurantReasonSubmitEvent(HideRestaurantReasonSubmitEvent event, Emitter<HideRestaurantReasonModalState> emit) async {
    if (state.reasonId.isNotEmpty) {
      try {
        emit(state.copyWith(status: HideRestaurantReasonModalStatus.submit));
        final String userId = await _homeRepository.userId();
        UpdateHideRestaurantReasonRequestModel param = UpdateHideRestaurantReasonRequestModel(restaurant: state.restaurantId, reason: state.reasonId, user: userId);
        DioApiResponse response = await _homeRepository.updateHideRestauantReason(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: HideRestaurantReasonModalStatus.submitSuccess));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: HideRestaurantReasonModalStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: HideRestaurantReasonModalStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

