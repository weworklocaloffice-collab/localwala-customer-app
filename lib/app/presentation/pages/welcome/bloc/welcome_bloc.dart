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
import 'package:user/app/core/repositories/splash_respository.dart';
import 'package:user/app/env.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final SplashRepositry _splashRepositry = SplashRepositry();
  final AuthRepository _authRepository = AuthRepository();
  WelcomeBloc() : super(const WelcomeState()) {
    on<WelcomeInitialEvent>(_onWelcomeInitialEvent);
    on<WelcomeLanguageChangeEvent>(_onWelcomeLanguageChangeEvent);
    on<WelcomeSubmitEvent>(_onWelcomeSubmitEvent);
  }

  FutureOr<void> _onWelcomeInitialEvent(WelcomeInitialEvent event, Emitter<WelcomeState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "intro"}, 'intro_screen', 'intro_screen');
    String? locale = await _splashRepositry.getLocale();
    emit(state.copyWith(locale: locale.isNotEmpty ? locale.toString() : Environments.defaultLanguage));
  }

  FutureOr<void> _onWelcomeLanguageChangeEvent(WelcomeLanguageChangeEvent event, Emitter<WelcomeState> emit) async {
    emit(state.copyWith(locale: event.locale));
  }

  FutureOr<void> _onWelcomeSubmitEvent(WelcomeSubmitEvent event, Emitter<WelcomeState> emit) async {
    await _splashRepositry.saveIntro();
    final bool haveLoginSkip = await _splashRepositry.haveLoginSkip();
    final bool haveLocation = await _splashRepositry.haveLocation();
    final bool haveAuthToken = await _splashRepositry.haveAuthToken();
    if (haveAuthToken == false && haveLoginSkip == false && haveLocation == false) {
      emit(state.copyWith(status: WelcomeStatus.unAuthorized));
    } else if (haveLoginSkip == true && haveLocation == false) {
      emit(state.copyWith(status: WelcomeStatus.location));
    } else if (haveAuthToken == true && haveLocation == true) {
      emit(state.copyWith(status: WelcomeStatus.home));
    } else if (haveLoginSkip == true && haveLocation == true) {
      emit(state.copyWith(status: WelcomeStatus.home));
    } else if (haveLoginSkip == false && haveLocation == false) {
      emit(state.copyWith(status: WelcomeStatus.location));
    } else if (haveLoginSkip == false && haveLocation == true) {
      emit(state.copyWith(status: WelcomeStatus.home));
    } else {
      emit(state.copyWith(status: WelcomeStatus.home));
    }
  }
}

