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
import 'package:user/app/core/models/global_search_history_model.dart';
import 'package:user/app/core/models/global_search_initial_response_model.dart';
import 'package:user/app/core/models/global_search_result_model.dart';
import 'package:user/app/core/models/request/global_search_initial_request_model.dart';
import 'package:user/app/core/models/request/global_search_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/home_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final LocationRepository _locationRepository = LocationRepository();
  final HomeRepository _homeRepository = HomeRepository();
  final AuthRepository _authRepository = AuthRepository();
  Timer? _debounce;

  SearchBloc()
    : super(
        SearchState(
          result: GlobalSearchResultModel(categories: [], cuisines: [], restaurants: [], brands: [], success: false, locale: ''),
          initialData: GlobalSearchInitialResponseModel(category: [], locale: ''),
        ),
      ) {
    on<SearchInitialEvent>(_onSearchInitialEvent);
    on<SearchFindResultEvent>(_onSearchFindResultEvent);
    on<SearchSaveHistoryEvent>(_onSearchSaveHistoryEvent);
    on<SearchOnLocalSearchHistoryTapEvent>(_onSearchOnLocalSearchHistoryTapEvent);
    on<SearchOnLocalSearchHistoryDeleteEvent>(_onSearchOnLocalSearchHistoryDeleteEvent);
    on<SearchExecuteQueryEvent>(_onSearchExecuteQueryEvent);
  }

  FutureOr<void> _onSearchInitialEvent(SearchInitialEvent event, Emitter<SearchState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_food_search"}, 'search_restaurant_food_screen', 'search_restaurant_food_screen');
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      emit(state.copyWith(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0, status: SearchStatus.initial));
      await _homeRepository.getLocalSearchHistory().then((history) {
        emit(state.copyWith(localHistory: history));
      });
      GlobalSearchInitialRequestModel param = GlobalSearchInitialRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0);
      DioApiResponse response = await _homeRepository.getGlobalSearchInitial(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        GlobalSearchInitialResponseModel initialResponse = GlobalSearchInitialResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: SearchStatus.initial, initialData: initialResponse));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSearchFindResultEvent(SearchFindResultEvent event, Emitter<SearchState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      add(SearchExecuteQueryEvent(query: event.searchQuery));
    });
  }

  FutureOr<void> _onSearchExecuteQueryEvent(SearchExecuteQueryEvent event, Emitter<SearchState> emit) async {
    if (event.query.length >= 3) {
      try {
        GlobalSearchRequestModel param = GlobalSearchRequestModel(searchQuery: event.query, latitude: state.latitude, longitude: state.longitude);
        DioApiResponse response = await _homeRepository.globalSearch(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: SearchStatus.empty));
          } else {
            final String locale = await _authRepository.getLocale();
            GlobalSearchResultModel searchResult = GlobalSearchResultModel.fromJson(myMap, locale.toString());
            bool allEmpty = false;
            if (searchResult.brands!.isEmpty && searchResult.categories!.isEmpty && searchResult.cuisines!.isEmpty && searchResult.restaurants!.isEmpty) {
              allEmpty = true;
            }
            emit(state.copyWith(status: allEmpty ? SearchStatus.empty : SearchStatus.success, result: searchResult));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SearchStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: SearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(state.copyWith(status: SearchStatus.initial));
    }
  }

  FutureOr<void> _onSearchSaveHistoryEvent(SearchSaveHistoryEvent event, Emitter<SearchState> emit) async {
    if (event.type == 'categories') {
      Map<String, dynamic> valueJson = {
        "id": state.result.categories![event.index].id!,
        "name": state.result.categories![event.index].name!,
        "slug": state.result.categories![event.index].slug!,
        "city": state.initialData.city!.slug!,
      };
      GlobalSearchHistoryModel newItem = GlobalSearchHistoryModel(
        id: state.result.categories![event.index].id!,
        title: state.result.categories![event.index].name!,
        subTitle: 'Top Restaurant & Dish',
        type: 'categories',
        image: state.result.categories![event.index].image!,
        action: jsonEncode(valueJson).toString(),
      );
      state.localHistory.add(newItem);
      final ids = state.localHistory.map((e) => e.id!).toSet();
      state.localHistory.retainWhere((element) => ids.remove(element.id!));
      await _homeRepository.saveGlobalSearchHistory(state.localHistory);
    } else if (event.type == 'cuisines') {
      Map<String, dynamic> valueJson = {"id": state.result.cuisines![event.index].id!, "name": state.result.cuisines![event.index].name!, "slug": state.result.cuisines![event.index].slug!, "city": state.initialData.city!.slug!};
      GlobalSearchHistoryModel newItem = GlobalSearchHistoryModel(
        id: state.result.cuisines![event.index].id!,
        title: state.result.cuisines![event.index].name!,
        subTitle: 'Top Restaurants',
        type: 'cuisines',
        image: state.result.cuisines![event.index].image!,
        action: jsonEncode(valueJson).toString(),
      );
      state.localHistory.add(newItem);
      final ids = state.localHistory.map((e) => e.id!).toSet();
      state.localHistory.retainWhere((element) => ids.remove(element.id!));
      await _homeRepository.saveGlobalSearchHistory(state.localHistory);
    } else if (event.type == 'brands') {
      Map<String, dynamic> valueJson = {
        "id": state.result.brands![event.index].id!,
        "name": state.result.brands![event.index].name!,
        "cover": state.result.brands![event.index].cover!,
        "slug": state.result.brands![event.index].slug!,
        "city": state.initialData.city!.slug!,
      };
      GlobalSearchHistoryModel newItem = GlobalSearchHistoryModel(
        id: state.result.brands![event.index].id!,
        title: state.result.brands![event.index].name!,
        subTitle: 'Top Brands',
        type: 'brands',
        image: state.result.brands![event.index].logo!,
        action: jsonEncode(valueJson).toString(),
      );
      state.localHistory.add(newItem);
      final ids = state.localHistory.map((e) => e.id!).toSet();
      state.localHistory.retainWhere((element) => ids.remove(element.id!));
      await _homeRepository.saveGlobalSearchHistory(state.localHistory);
    } else if (event.type == 'restaurants') {
      Map<String, dynamic> valueJson = {"id": state.result.restaurants![event.index].id!, "slug": state.result.restaurants![event.index].slug!, "name": state.result.restaurants![event.index].name!};
      GlobalSearchHistoryModel newItem = GlobalSearchHistoryModel(
        id: state.result.restaurants![event.index].id!,
        title: state.result.restaurants![event.index].name!,
        subTitle: 'Restaurant',
        type: 'restaurants',
        image: state.result.restaurants![event.index].logo!,
        action: jsonEncode(valueJson).toString(),
      );
      state.localHistory.add(newItem);
      final ids = state.localHistory.map((e) => e.id!).toSet();
      state.localHistory.retainWhere((element) => ids.remove(element.id!));
      await _homeRepository.saveGlobalSearchHistory(state.localHistory);
    }
  }

  FutureOr<void> _onSearchOnLocalSearchHistoryTapEvent(SearchOnLocalSearchHistoryTapEvent event, Emitter<SearchState> emit) async {
    try {
      final String navigationRoute = state.localHistory[event.index].type!;
      List<String> navigationArgs = <String>[];
      if (navigationRoute == 'categories') {
        Map<String, dynamic> valueJson = <String, dynamic>{};
        valueJson = jsonDecode(state.localHistory[event.index].action!);
        if (valueJson.containsKey('id') &&
            valueJson.containsKey('name') &&
            valueJson.containsKey('slug') &&
            valueJson.containsKey('city') &&
            valueJson['id'].toString().isNotEmpty &&
            valueJson['name'].toString().isNotEmpty &&
            valueJson['slug'].toString().isNotEmpty &&
            valueJson['city'].toString().isNotEmpty) {
          navigationArgs.add(valueJson['name'].toString());
          navigationArgs.add(valueJson['slug'].toString());
          navigationArgs.add(valueJson['city'].toString());
          emit(state.copyWith(status: SearchStatus.navigate, navigationArgs: navigationArgs, navigateTo: navigationRoute));
        }
      } else if (navigationRoute == 'cuisines') {
        Map<String, dynamic> valueJson = <String, dynamic>{};
        valueJson = jsonDecode(state.localHistory[event.index].action!);
        if (valueJson.containsKey('id') &&
            valueJson.containsKey('name') &&
            valueJson.containsKey('slug') &&
            valueJson.containsKey('city') &&
            valueJson['id'].toString().isNotEmpty &&
            valueJson['name'].toString().isNotEmpty &&
            valueJson['slug'].toString().isNotEmpty &&
            valueJson['city'].toString().isNotEmpty) {
          navigationArgs.add(valueJson['name'].toString());
          navigationArgs.add(valueJson['slug'].toString());
          navigationArgs.add(valueJson['city'].toString());
          emit(state.copyWith(status: SearchStatus.navigate, navigationArgs: navigationArgs, navigateTo: navigationRoute));
        }
      } else if (navigationRoute == 'brands') {
        Map<String, dynamic> valueJson = <String, dynamic>{};
        valueJson = jsonDecode(state.localHistory[event.index].action!);
        if (valueJson.containsKey('id') &&
            valueJson.containsKey('name') &&
            valueJson.containsKey('cover') &&
            valueJson.containsKey('slug') &&
            valueJson.containsKey('city') &&
            valueJson['id'].toString().isNotEmpty &&
            valueJson['name'].toString().isNotEmpty &&
            valueJson['cover'].toString().isNotEmpty &&
            valueJson['slug'].toString().isNotEmpty &&
            valueJson['city'].toString().isNotEmpty) {
          navigationArgs.add(valueJson['id'].toString());
          navigationArgs.add(valueJson['name'].toString());
          navigationArgs.add(valueJson['cover'].toString());
          navigationArgs.add(valueJson['slug'].toString());
          navigationArgs.add(valueJson['city'].toString());
          emit(state.copyWith(status: SearchStatus.navigate, navigationArgs: navigationArgs, navigateTo: navigationRoute));
        }
      } else if (navigationRoute == 'restaurants') {
        Map<String, dynamic> valueJson = <String, dynamic>{};
        valueJson = jsonDecode(state.localHistory[event.index].action!);
        if (valueJson.containsKey('id') &&
            valueJson.containsKey('name') &&
            valueJson.containsKey('slug') &&
            valueJson['id'].toString().isNotEmpty &&
            valueJson['name'].toString().isNotEmpty &&
            valueJson['slug'].toString().isNotEmpty) {
          navigationArgs.add(valueJson['id'].toString());
          navigationArgs.add(valueJson['slug'].toString());
          navigationArgs.add(valueJson['name'].toString());
          emit(state.copyWith(status: SearchStatus.navigate, navigationArgs: navigationArgs, navigateTo: navigationRoute));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSearchOnLocalSearchHistoryDeleteEvent(SearchOnLocalSearchHistoryDeleteEvent event, Emitter<SearchState> emit) async {
    state.localHistory.removeAt(event.index);
    await _homeRepository.saveGlobalSearchHistory(state.localHistory);
    emit(state.copyWith(localHistory: state.localHistory));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

