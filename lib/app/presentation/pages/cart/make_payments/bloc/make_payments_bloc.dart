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

import 'package:bloc/bloc.dart';
import 'package:user/app/core/repositories/auth_repository.dart';

part 'make_payments_event.dart';
part 'make_payments_state.dart';

class MakePaymentsBloc extends Bloc<MakePaymentsEvent, MakePaymentsState> {
  final AuthRepository _authRepository = AuthRepository();
  MakePaymentsBloc() : super(const MakePaymentsState()) {
    on<MakePaymentsInitialEvent>(_onMakePaymentsInitialEvent);
    on<MakePaymentsResponseEvent>(_onMakePaymentsResponseEvent);
  }

  FutureOr<void> _onMakePaymentsInitialEvent(MakePaymentsInitialEvent event, Emitter<MakePaymentsState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "order_payment"}, 'make_order_payment_screen', 'make_order_payment_screen');
    emit(state.copyWith(status: MakePaymentStatus.initial));
  }

  FutureOr<void> _onMakePaymentsResponseEvent(MakePaymentsResponseEvent event, Emitter<MakePaymentsState> emit) async {
    emit(state.copyWith(status: MakePaymentStatus.success));
  }
}

