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

part 'restaurant_register_request_make_payment_event.dart';
part 'restaurant_register_request_make_payment_state.dart';

class RestaurantRegisterRequestMakePaymentBloc extends Bloc<RestaurantRegisterRequestMakePaymentEvent, RestaurantRegisterRequestMakePaymentState> {
  final AuthRepository _authRepository = AuthRepository();
  RestaurantRegisterRequestMakePaymentBloc() : super(const RestaurantRegisterRequestMakePaymentState()) {
    on<RestaurantRegisterRequestPaymentInitialEvent>(_onRestaurantRegisterRequestPaymentInitialEvent);
    on<RestaurantRegisterRequestPaymentResponseEvent>(_onRestaurantRegisterRequestPaymentResponseEvent);
  }

  FutureOr<void> _onRestaurantRegisterRequestPaymentInitialEvent(RestaurantRegisterRequestPaymentInitialEvent event, Emitter<RestaurantRegisterRequestMakePaymentState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_register_request_payments"}, 'restaurant_register_request_payment_screen', 'restaurant_register_request_payment_screen');
    emit(state.copyWith(status: RestaurantRegisterRequestMakePaymentStatus.initial));
  }

  FutureOr<void> _onRestaurantRegisterRequestPaymentResponseEvent(RestaurantRegisterRequestPaymentResponseEvent event, Emitter<RestaurantRegisterRequestMakePaymentState> emit) async {
    emit(state.copyWith(status: RestaurantRegisterRequestMakePaymentStatus.success));
  }
}

