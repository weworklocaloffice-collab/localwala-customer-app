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
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/services/shared_pref.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  ThemeBloc() : super(const ThemeState(isDarkTheme: false)) {
    on<ThemeInitialEvent>(_onThemeInitialEvent);
    on<ChangeThemeEvent>(changeThemeEventHandler);
  }

  FutureOr<void> changeThemeEventHandler(ChangeThemeEvent event, Emitter<ThemeState> emit) {
    if (state.isDarkTheme) {
      emit(state.copyWith(isDarkTheme: false));
      _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.isDark, false);
    } else {
      emit(state.copyWith(isDarkTheme: true));
      _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.isDark, true);
    }
  }

  Future<void> _onThemeInitialEvent(ThemeInitialEvent event, Emitter<ThemeState> emit) async {
    final isDarkTheme = await (_sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.isDark));
    emit(state.copyWith(isDarkTheme: isDarkTheme));
  }
}

