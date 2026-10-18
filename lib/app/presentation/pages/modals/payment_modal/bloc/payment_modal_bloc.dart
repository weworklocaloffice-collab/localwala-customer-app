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
import 'package:user/app/core/models/payment_list_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'payment_modal_event.dart';
part 'payment_modal_state.dart';

class PaymentModalBloc extends Bloc<PaymentModalEvent, PaymentModalState> {
  final AuthRepository _authRepository = AuthRepository();
  PaymentModalBloc() : super(const PaymentModalState()) {
    on<PaymentModalInitialEvent>(_onPaymentModalInitialEvent);
  }

  FutureOr<void> _onPaymentModalInitialEvent(PaymentModalInitialEvent event, Emitter<PaymentModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "payment_list"}, 'payment_list_screen', 'payment_list_screen');
      List<dynamic> jsonList = jsonDecode(event.paymentList);
      final String locale = await _authRepository.getLocale();
      List<PaymentListModel> modelList = jsonList.map((json) => PaymentListModel.fromJson(json, locale.toString())).toList();
      emit(state.copyWith(paymentList: modelList, status: PaymentModalStatus.success));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: PaymentModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

