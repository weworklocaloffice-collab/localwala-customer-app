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
import 'package:user/app/core/models/dining_booking_cancellation_reason_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_booking_cancellation_reason_list_modal_event.dart';
part 'dining_booking_cancellation_reason_list_modal_state.dart';

class DiningBookingCancellationReasonListModalBloc extends Bloc<DiningBookingCancellationReasonListModalEvent, DiningBookingCancellationReasonListModalState> {
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingCancellationReasonListModalBloc()
    : super(
        DiningBookingCancellationReasonListModalState(
          list: DiningBookingCancellationReasonListModel(reasons: [], locale: ''),
        ),
      ) {
    on<DiningBookingCancellationReasonListModalInitialEvent>(_onDiningBookingCancellationReasonListModalInitialEvent);
    on<DiningBookingCancellationReasonListModalSelectEvent>(_onDiningBookingCancellationReasonListModalSelectEvent);
  }

  FutureOr<void> _onDiningBookingCancellationReasonListModalInitialEvent(DiningBookingCancellationReasonListModalInitialEvent event, Emitter<DiningBookingCancellationReasonListModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_cancellation_reason"}, 'dining_booking_cancellation_reason_screen', 'dining_booking_cancellation_reason_screen');
      emit(state.copyWith(status: DiningBookingCancellationReasonListModalStatus.loading));
      DioApiResponse response = await _diningRepository.getDiningBookingCancellationReasonList();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        DiningBookingCancellationReasonListModel data = DiningBookingCancellationReasonListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? DiningBookingCancellationReasonListModalStatus.success : DiningBookingCancellationReasonListModalStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingCancellationReasonListModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingCancellationReasonListModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingCancellationReasonListModalSelectEvent(DiningBookingCancellationReasonListModalSelectEvent event, Emitter<DiningBookingCancellationReasonListModalState> emit) async {
    emit(state.copyWith(status: DiningBookingCancellationReasonListModalStatus.success, reasonId: event.id));
  }
}

