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
import 'package:user/app/core/models/order_cancellation_reason_list_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'cancellation_reason_list_event.dart';
part 'cancellation_reason_list_state.dart';

class CancellationReasonListBloc extends Bloc<CancellationReasonListEvent, CancellationReasonListState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  CancellationReasonListBloc()
    : super(
        CancellationReasonListState(
          list: OrderCancellationListModel(reasons: [], locale: ''),
        ),
      ) {
    on<CancellationReasonListInitalEvent>(_onCancellationReasonListInitalEvent);
    on<CancellationReasonListSelectEvent>(_onCancellationReasonListSelectEvent);
  }

  FutureOr<void> _onCancellationReasonListInitalEvent(CancellationReasonListInitalEvent event, Emitter<CancellationReasonListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_cancellation_reason"}, 'order_cancellation_reason_screen', 'order_cancellation_reason_screen');
      emit(state.copyWith(status: CancellationReasonListStatus.loading));
      DioApiResponse response = await _historyRepository.getCancellationReasons();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        OrderCancellationListModel data = OrderCancellationListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? CancellationReasonListStatus.success : CancellationReasonListStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CancellationReasonListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CancellationReasonListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCancellationReasonListSelectEvent(CancellationReasonListSelectEvent event, Emitter<CancellationReasonListState> emit) async {
    emit(state.copyWith(status: CancellationReasonListStatus.success, reasonId: event.id));
  }
}

