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

part 'make_payments_subscription_package_event.dart';
part 'make_payments_subscription_package_state.dart';

class MakePaymentsSubscriptionPackageBloc extends Bloc<MakePaymentsSubscriptionPackageEvent, MakePaymentsSubscriptionPackageState> {
  final AuthRepository _authRepository = AuthRepository();
  MakePaymentsSubscriptionPackageBloc() : super(const MakePaymentsSubscriptionPackageState()) {
    on<MakePaymentsSubscriptionPackageInitialEvent>(_onMakePaymentsSubscriptionPackageInitialEvent);
    on<MakePaymentsSubscriptionPackageResponseEvent>(_onMakePaymentsSubscriptionPackageResponseEvent);
  }

  FutureOr<void> _onMakePaymentsSubscriptionPackageInitialEvent(MakePaymentsSubscriptionPackageInitialEvent event, Emitter<MakePaymentsSubscriptionPackageState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "make_payment_tiffin_subscription_package"}, 'make_payment_tiffin_subscription_package_screen', 'make_payment_tiffin_subscription_package_screen');
    emit(state.copyWith(status: MakePaymentsSubscriptionPackageStatus.initial));
  }

  FutureOr<void> _onMakePaymentsSubscriptionPackageResponseEvent(MakePaymentsSubscriptionPackageResponseEvent event, Emitter<MakePaymentsSubscriptionPackageState> emit) async {
    emit(state.copyWith(status: MakePaymentsSubscriptionPackageStatus.success));
  }
}

