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

part 'account_activity_event.dart';
part 'account_activity_state.dart';

class AccountActivityBloc extends Bloc<AccountActivityEvent, AccountActivityState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountActivityBloc() : super(AccountActivityStateInitial()) {
    on<AccountActivityInitialEvent>(_onAccountActivityInitialEvent);
  }

  FutureOr<void> _onAccountActivityInitialEvent(AccountActivityInitialEvent event, Emitter<AccountActivityState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "account_activity"}, 'account_activity_screen', 'account_activity_screen');
  }
}

