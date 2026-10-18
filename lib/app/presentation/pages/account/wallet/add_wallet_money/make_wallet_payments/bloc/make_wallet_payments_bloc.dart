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

part 'make_wallet_payments_event.dart';
part 'make_wallet_payments_state.dart';

class MakeWalletPaymentsBloc extends Bloc<MakeWalletPaymentsEvent, MakeWalletPaymentsState> {
  final AuthRepository _authRepository = AuthRepository();
  MakeWalletPaymentsBloc() : super(const MakeWalletPaymentsState()) {
    on<MakeWalletPaymentsInitialEvent>(_onMakeWalletPaymentsInitialEvent);
    on<MakeWalletPaymentsResponseEvent>(_onMakeWalletPaymentsResponseEvent);
  }

  FutureOr<void> _onMakeWalletPaymentsInitialEvent(MakeWalletPaymentsInitialEvent event, Emitter<MakeWalletPaymentsState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "make_wallet_fund_payments"}, 'make_wallet_payment_screen', 'make_wallet_payment_screen');
    emit(state.copyWith(status: MakeWalletPaymentsStatus.initial));
  }

  FutureOr<void> _onMakeWalletPaymentsResponseEvent(MakeWalletPaymentsResponseEvent event, Emitter<MakeWalletPaymentsState> emit) async {
    emit(state.copyWith(status: MakeWalletPaymentsStatus.success));
  }
}

