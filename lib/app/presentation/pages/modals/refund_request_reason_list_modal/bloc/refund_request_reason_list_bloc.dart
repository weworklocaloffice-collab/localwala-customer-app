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
import 'package:user/app/core/models/refund_request_list_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'refund_request_reason_list_event.dart';
part 'refund_request_reason_list_state.dart';

class RefundRequestReasonListBloc extends Bloc<RefundRequestReasonListEvent, RefundRequestReasonListState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  RefundRequestReasonListBloc()
    : super(
        RefundRequestReasonListState(
          list: RefundRequestListModel(reasons: [], locale: ''),
        ),
      ) {
    on<RefundRequestReasonListInitialEvent>(_onRefundRequestReasonListInitialEvent);
    on<RefundRequestReasonSelectEvent>(_onRefundRequestReasonSelectEvent);
  }

  FutureOr<void> _onRefundRequestReasonListInitialEvent(RefundRequestReasonListInitialEvent event, Emitter<RefundRequestReasonListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_refund_reason"}, 'order_refund_reason_screen', 'order_refund_reason_screen');
      emit(state.copyWith(status: RefundRequestReasonListStatus.loading));
      DioApiResponse response = await _historyRepository.getRefundReasonList();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        RefundRequestListModel data = RefundRequestListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? RefundRequestReasonListStatus.success : RefundRequestReasonListStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: RefundRequestReasonListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: RefundRequestReasonListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onRefundRequestReasonSelectEvent(RefundRequestReasonSelectEvent event, Emitter<RefundRequestReasonListState> emit) async {
    emit(state.copyWith(status: RefundRequestReasonListStatus.success, reasonId: event.id));
  }
}

