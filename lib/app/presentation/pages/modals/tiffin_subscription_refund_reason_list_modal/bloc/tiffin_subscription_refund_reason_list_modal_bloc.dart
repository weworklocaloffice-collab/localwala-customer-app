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
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/tiffin_subscription_refund_reason_list_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'tiffin_subscription_refund_reason_list_modal_event.dart';
part 'tiffin_subscription_refund_reason_list_modal_state.dart';

class TiffinSubscriptionRefundReasonListModalBloc extends Bloc<TiffinSubscriptionRefundReasonListModalEvent, TiffinSubscriptionRefundReasonListModalState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  TiffinSubscriptionRefundReasonListModalBloc()
    : super(
        TiffinSubscriptionRefundReasonListModalState(
          list: TiffinSubscriptionRefundReasonListModel(reasons: [], locale: ''),
        ),
      ) {
    on<TiffinSubscriptionRefundReasonListModalInitialEvent>(_onTiffinSubscriptionRefundReasonListModalInitialEvent);
    on<TiffinSubscriptionRefundReasonListModalReasonSelectEvent>(_onTiffinSubscriptionRefundReasonListModalReasonSelectEvent);
  }

  FutureOr<void> _onTiffinSubscriptionRefundReasonListModalInitialEvent(TiffinSubscriptionRefundReasonListModalInitialEvent event, Emitter<TiffinSubscriptionRefundReasonListModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_refund_reason"}, 'tiffin_subscription_refund_reason_screen', 'tiffin_subscription_refund_reason_screen');
      emit(state.copyWith(status: TiffinSubscriptionRefundReasonListModalStatus.loading));
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.getTiffinSubscriptionRefundReason();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        TiffinSubscriptionRefundReasonListModel data = TiffinSubscriptionRefundReasonListModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.reasons!.isNotEmpty ? TiffinSubscriptionRefundReasonListModalStatus.success : TiffinSubscriptionRefundReasonListModalStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: TiffinSubscriptionRefundReasonListModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: TiffinSubscriptionRefundReasonListModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onTiffinSubscriptionRefundReasonListModalReasonSelectEvent(TiffinSubscriptionRefundReasonListModalReasonSelectEvent event, Emitter<TiffinSubscriptionRefundReasonListModalState> emit) async {
    emit(state.copyWith(status: TiffinSubscriptionRefundReasonListModalStatus.success, reasonId: event.id));
  }
}

