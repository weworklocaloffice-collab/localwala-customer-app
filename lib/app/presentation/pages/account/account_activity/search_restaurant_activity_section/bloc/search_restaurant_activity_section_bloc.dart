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
import 'package:user/app/core/models/request/search_restaurant_for_reviews_request_model.dart';
import 'package:user/app/core/models/search_restaurant_for_review_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'search_restaurant_activity_section_event.dart';
part 'search_restaurant_activity_section_state.dart';

class SearchRestaurantActivitySectionBloc extends Bloc<SearchRestaurantActivitySectionEvent, SearchRestaurantActivitySectionState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final AuthRepository _authRepository = AuthRepository();
  Timer? _debounce;
  SearchRestaurantActivitySectionBloc()
    : super(
        SearchRestaurantActivitySectionState(
          model: SearchRestaurantForReviewResponseModel(restaurants: [], success: false, locale: ''),
        ),
      ) {
    on<SearchRestaurantActivitySectionInitialEvent>(_onSearchRestaurantActivitySectionInitialEvent);
    on<SearchRestaurantActivitySectionFindResultEvent>(_onSearchRestaurantActivitySectionFindResultEvent);
    on<SearchRestaurantActivitySectionExecuteEvent>(_onSearchRestaurantActivitySectionExecuteEvent);
  }

  FutureOr<void> _onSearchRestaurantActivitySectionInitialEvent(SearchRestaurantActivitySectionInitialEvent event, Emitter<SearchRestaurantActivitySectionState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "account_search_restaurants"}, 'account_search_screen', 'account_search_screen');
  }

  FutureOr<void> _onSearchRestaurantActivitySectionFindResultEvent(SearchRestaurantActivitySectionFindResultEvent event, Emitter<SearchRestaurantActivitySectionState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      add(SearchRestaurantActivitySectionExecuteEvent(query: event.searchQuery));
    });
  }

  FutureOr<void> _onSearchRestaurantActivitySectionExecuteEvent(SearchRestaurantActivitySectionExecuteEvent event, Emitter<SearchRestaurantActivitySectionState> emit) async {
    if (event.query.length >= 3) {
      try {
        SearchRestaurantForReviewRequestModel param = SearchRestaurantForReviewRequestModel(searchQuery: event.query);
        DioApiResponse response = await _restaurantRepository.searchRestaurantForReview(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: SearchRestaurantActivitySectionStatus.empty));
          } else {
            final String locale = await _authRepository.getLocale();
            SearchRestaurantForReviewResponseModel searchResult = SearchRestaurantForReviewResponseModel.fromJson(myMap, locale.toString());
            emit(state.copyWith(status: searchResult.restaurants!.isEmpty ? SearchRestaurantActivitySectionStatus.empty : SearchRestaurantActivitySectionStatus.success, model: searchResult));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SearchRestaurantActivitySectionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: SearchRestaurantActivitySectionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(
        state.copyWith(
          status: SearchRestaurantActivitySectionStatus.empty,
          model: SearchRestaurantForReviewResponseModel(restaurants: [], success: false, locale: ''),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

