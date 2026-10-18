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

part 'food_instructions_event.dart';
part 'food_instructions_state.dart';

class FoodInstructionsBloc extends Bloc<FoodInstructionsEvent, FoodInstructionsState> {
  final AuthRepository _authRepository = AuthRepository();
  FoodInstructionsBloc() : super(const FoodInstructionsState()) {
    on<FoodInstructionsInitialEvent>(_onFoodInstructionsInitialEvent);
    on<FoodInstructionsChangeEvent>(_onFoodInstructionsChangeEvent);
  }

  FutureOr<void> _onFoodInstructionsInitialEvent(FoodInstructionsInitialEvent event, Emitter<FoodInstructionsState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "food_instructions"}, 'food_instructions_screen', 'food_instructions_screen');
    emit(state.copyWith(status: FoodInstructionsStatus.success, instructions: event.instructions));
  }

  FutureOr<void> _onFoodInstructionsChangeEvent(FoodInstructionsChangeEvent event, Emitter<FoodInstructionsState> emit) async {
    emit(state.copyWith(instructions: event.instructions));
  }
}

