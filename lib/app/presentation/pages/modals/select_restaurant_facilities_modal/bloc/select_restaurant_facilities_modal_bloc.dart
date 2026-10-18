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
import 'package:user/app/core/models/active_restaurant_facility_list_model.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'select_restaurant_facilities_modal_event.dart';
part 'select_restaurant_facilities_modal_state.dart';

class SelectRestaurantFacilitiesModalBloc extends Bloc<SelectRestaurantFacilitiesModalEvent, SelectRestaurantFacilitiesModalState> {
  final AuthRepository _accountRepository = AuthRepository();
  final AuthRepository _authRepository = AuthRepository();
  SelectRestaurantFacilitiesModalBloc()
    : super(
        SelectRestaurantFacilitiesModalState(
          model: ActiveRestaurantFacilitiyListModel(facility: [], success: false, locale: ''),
        ),
      ) {
    on<SelectRestaurantFacilitiesModalInitialEvent>(_onSelectRestaurantFacilitiesModalInitialEvent);
    on<SelectRestaurantFacilitiesModalSelectEvent>(_onSelectRestaurantFacilitiesModalSelectEvent);
    on<SelectRestaurantFacilitiesModalSaveEvent>(_onSelectRestaurantFacilitiesModalSaveEvent);
  }

  FutureOr<void> _onSelectRestaurantFacilitiesModalInitialEvent(SelectRestaurantFacilitiesModalInitialEvent event, Emitter<SelectRestaurantFacilitiesModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_facilities"}, 'restaurant_facilities_screen', 'restaurant_facilities_screen');
      emit(state.copyWith(status: SelectRestaurantFacilitiesModalStatus.loading, facilityIds: event.facilities));
      DioApiResponse response = await _accountRepository.getActiveRestaurantFacility();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: SelectRestaurantFacilitiesModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          ActiveRestaurantFacilitiyListModel data = ActiveRestaurantFacilitiyListModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(model: data, status: data.facility!.isEmpty ? SelectRestaurantFacilitiesModalStatus.empty : SelectRestaurantFacilitiesModalStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SelectRestaurantFacilitiesModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SelectRestaurantFacilitiesModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSelectRestaurantFacilitiesModalSelectEvent(SelectRestaurantFacilitiesModalSelectEvent event, Emitter<SelectRestaurantFacilitiesModalState> emit) async {
    List<String> facilityIds = <String>[];
    facilityIds = state.facilityIds;
    if (facilityIds.contains(event.id)) {
      facilityIds.removeWhere((element) => element == event.id);
    } else {
      facilityIds.add(event.id);
    }
    emit(state.copyWith(facilityIds: [...facilityIds]));
  }

  FutureOr<void> _onSelectRestaurantFacilitiesModalSaveEvent(SelectRestaurantFacilitiesModalSaveEvent event, Emitter<SelectRestaurantFacilitiesModalState> emit) async {
    List<String> facilityName = <String>[];
    facilityName.clear();
    for (var element in state.model.facility!) {
      if (state.facilityIds.contains(element.id!)) {
        facilityName.add(element.name!);
      }
    }
    emit(state.copyWith(facilityNames: facilityName, status: SelectRestaurantFacilitiesModalStatus.saved));
  }
}

