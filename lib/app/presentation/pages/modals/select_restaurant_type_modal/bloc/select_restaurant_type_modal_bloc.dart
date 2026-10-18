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
import 'package:user/app/core/models/active_restaurant_type_list_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'select_restaurant_type_modal_event.dart';
part 'select_restaurant_type_modal_state.dart';

class SelectRestaurantTypeModalBloc extends Bloc<SelectRestaurantTypeModalEvent, SelectRestaurantTypeModalState> {
  final AuthRepository _accountRepository = AuthRepository();
  final AuthRepository _authRepository = AuthRepository();
  SelectRestaurantTypeModalBloc()
    : super(
        SelectRestaurantTypeModalState(
          model: ActiveRestaurantTypeListResponseModel(restaurantType: [], success: false, locale: ''),
        ),
      ) {
    on<SelectRestaurantTypeModalInitialEvent>(_onSelectRestaurantTypeModalInitialEvent);
    on<SelectRestaurantTypeModalSelectEvent>(_onSelectRestaurantTypeModalSelectEvent);
    on<SelectRestaurantTypeModalSaveEvent>(_onSelectRestaurantTypeModalSaveEvent);
  }

  FutureOr<void> _onSelectRestaurantTypeModalInitialEvent(SelectRestaurantTypeModalInitialEvent event, Emitter<SelectRestaurantTypeModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_type_modal"}, 'restaurant_type_modal_screen', 'restaurant_type_modal_screen');
      emit(state.copyWith(status: SelectRestaurantTypeModalStatus.loading, typeIds: event.type));
      DioApiResponse response = await _accountRepository.getActiveRestaurantType();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: SelectRestaurantTypeModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          ActiveRestaurantTypeListResponseModel data = ActiveRestaurantTypeListResponseModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(model: data, status: data.restaurantType!.isEmpty ? SelectRestaurantTypeModalStatus.empty : SelectRestaurantTypeModalStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SelectRestaurantTypeModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SelectRestaurantTypeModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSelectRestaurantTypeModalSelectEvent(SelectRestaurantTypeModalSelectEvent event, Emitter<SelectRestaurantTypeModalState> emit) async {
    List<String> savedType = <String>[];
    savedType = state.typeIds;
    if (savedType.contains(event.id)) {
      savedType.removeWhere((element) => element == event.id);
    } else {
      savedType.add(event.id);
    }
    emit(state.copyWith(typeIds: [...savedType]));
  }

  FutureOr<void> _onSelectRestaurantTypeModalSaveEvent(SelectRestaurantTypeModalSaveEvent event, Emitter<SelectRestaurantTypeModalState> emit) async {
    List<String> typeNames = <String>[];
    typeNames.clear();
    for (var element in state.model.restaurantType!) {
      if (state.typeIds.contains(element.id!)) {
        typeNames.add(element.name!);
      }
    }
    emit(state.copyWith(typeNames: typeNames, status: SelectRestaurantTypeModalStatus.saved));
  }
}

