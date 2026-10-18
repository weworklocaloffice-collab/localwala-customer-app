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

part 'restaurant_menu_modal_event.dart';
part 'restaurant_menu_modal_state.dart';

class RestaurantMenuModalBloc extends Bloc<RestaurantMenuModalEvent, RestaurantMenuModalState> {
  final AuthRepository _authRepository = AuthRepository();
  RestaurantMenuModalBloc() : super(const RestaurantMenuModalState()) {
    on<RestuarantMenuInitialEvent>(_onRestuarantMenuInitialEvent);
  }

  FutureOr<void> _onRestuarantMenuInitialEvent(RestuarantMenuInitialEvent event, Emitter<RestaurantMenuModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_category_menu"}, 'restaurant_category_menu_screen', 'restaurant_category_menu_screen');
    emit(state.copyWith(currentInView: event.currentInView, isDarkTheme: event.isDarkTheme, status: RestaurantMenuModalStatus.success));
  }
}

