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
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/global_dining_search_initial_response_model.dart';
import 'package:user/app/core/models/global_dining_search_result_model.dart';
import 'package:user/app/core/models/request/global_search_initial_request_model.dart';
import 'package:user/app/core/models/request/global_search_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_search_event.dart';
part 'dining_search_state.dart';

class DiningSearchBloc extends Bloc<DiningSearchEvent, DiningSearchState> {
  final LocationRepository _locationRepository = LocationRepository();
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  Timer? _debounce;

  DiningSearchBloc()
    : super(
        DiningSearchState(
          initialData: GlobalDiningSearchInitialResponseModel(category: [], locale: ''),
          result: GlobalDiningSearchResultModel(categories: [], restaurants: [], success: false, locale: ''),
        ),
      ) {
    on<DiningSearchInitialEvent>(_onDiningSearchInitialEvent);
    on<DiningSearchFindResultEvent>(_onDiningSearchFindResultEvent);
    on<DiningSearchExecuteEvent>(_onDiningSearchExecuteEvent);
  }

  FutureOr<void> _onDiningSearchInitialEvent(DiningSearchInitialEvent event, Emitter<DiningSearchState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_search"}, 'dining_restaurant_screen', 'dining_restaurant_screen');
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      emit(state.copyWith(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, status: DiningSearchStatus.initial));
      GlobalSearchInitialRequestModel param = GlobalSearchInitialRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0);
      DioApiResponse response = await _diningRepository.getGlobalDiningSearchInitial(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        GlobalDiningSearchInitialResponseModel initialResponse = GlobalDiningSearchInitialResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: DiningSearchStatus.initial, initialData: initialResponse));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningSearchFindResultEvent(DiningSearchFindResultEvent event, Emitter<DiningSearchState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      add(DiningSearchExecuteEvent(query: event.searchQuery));
    });
  }

  FutureOr<void> _onDiningSearchExecuteEvent(DiningSearchExecuteEvent event, Emitter<DiningSearchState> emit) async {
    try {
      if (event.query.length >= 3) {
        GlobalSearchRequestModel param = GlobalSearchRequestModel(searchQuery: event.query, latitude: state.latitude, longitude: state.longitude);
        DioApiResponse response = await _diningRepository.globalDiningSearch(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: DiningSearchStatus.empty));
          } else {
            final String locale = await _authRepository.getLocale();
            GlobalDiningSearchResultModel searchResult = GlobalDiningSearchResultModel.fromJson(myMap, locale.toString());
            bool allEmpty = false;
            if (searchResult.categories!.isEmpty && searchResult.restaurants!.isEmpty) {
              allEmpty = true;
            }
            emit(state.copyWith(status: allEmpty ? DiningSearchStatus.empty : DiningSearchStatus.success, result: searchResult));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: DiningSearchStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: DiningSearchStatus.initial));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

