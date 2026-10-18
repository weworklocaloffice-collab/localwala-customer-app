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
import 'package:user/app/core/models/dining_booking_search_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_booking_search_event.dart';
part 'dining_booking_search_state.dart';

class DiningBookingSearchBloc extends Bloc<DiningBookingSearchEvent, DiningBookingSearchState> {
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingSearchBloc()
    : super(
        DiningBookingSearchState(
          model: DiningBookingSearchResponseModel(bookings: [], locale: ''),
        ),
      ) {
    on<DiningBookingSearchInitialEvent>(_onDiningBookingSearchInitialEvent);
    on<DiningBookingSearchInputChangeEvent>(_onDiningBookingSearchInputChangeEvent);
    on<DiningBookingSearchSubmitEvent>(_onDiningBookingSearchSubmitEvent);
  }

  FutureOr<void> _onDiningBookingSearchInitialEvent(DiningBookingSearchInitialEvent event, Emitter<DiningBookingSearchState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_search"}, 'dining_booking_search_screen', 'dining_booking_search_screen');
  }

  FutureOr<void> _onDiningBookingSearchInputChangeEvent(DiningBookingSearchInputChangeEvent event, Emitter<DiningBookingSearchState> emit) async {
    emit(state.copyWith(query: event.query));
  }

  FutureOr<void> _onDiningBookingSearchSubmitEvent(DiningBookingSearchSubmitEvent event, Emitter<DiningBookingSearchState> emit) async {
    if (state.query.isNotEmpty) {
      try {
        emit(state.copyWith(status: DiningBookingSearchStatus.loading));
        final String userId = await _diningRepository.userId();
        DioApiResponse response = await _diningRepository.searchDiningBookingList(userId, state.query.toString());
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          DiningBookingSearchResponseModel bookingResponse = DiningBookingSearchResponseModel.fromJson(myMap, locale.toString());
          if (bookingResponse.bookings!.isEmpty) {
            emit(state.copyWith(status: DiningBookingSearchStatus.empty));
          } else {
            emit(state.copyWith(status: DiningBookingSearchStatus.success, model: bookingResponse));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DiningBookingSearchStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: DiningBookingSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

