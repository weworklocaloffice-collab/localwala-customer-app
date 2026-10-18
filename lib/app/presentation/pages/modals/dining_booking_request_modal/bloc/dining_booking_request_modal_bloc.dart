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

part 'dining_booking_request_modal_event.dart';
part 'dining_booking_request_modal_state.dart';

class DiningBookingRequestModalBloc extends Bloc<DiningBookingRequestModalEvent, DiningBookingRequestModalState> {
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingRequestModalBloc() : super(const DiningBookingRequestModalState()) {
    on<DiningBookingRequestModalInitialEvent>(_onDiningBookingRequestModalInitialEvent);
    on<DiningBookingRequestModalInstructionsChangeEvent>(_onDiningBookingRequestModalInstructionsChangeEvent);
  }

  FutureOr<void> _onDiningBookingRequestModalInitialEvent(DiningBookingRequestModalInitialEvent event, Emitter<DiningBookingRequestModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_special_request"}, 'dining_booking_special_request_screen', 'dining_booking_special_request_screen');
    emit(state.copyWith(status: DiningBookingRequestModalStatus.success, instructions: event.instructions));
  }

  FutureOr<void> _onDiningBookingRequestModalInstructionsChangeEvent(DiningBookingRequestModalInstructionsChangeEvent event, Emitter<DiningBookingRequestModalState> emit) {
    emit(state.copyWith(instructions: event.instructions));
  }
}

