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
import 'package:user/app/env.dart';

part 'app_localization_event.dart';
part 'app_localization_state.dart';

class AppLocalizationBloc extends Bloc<AppLocalizationEvent, AppLocalizationState> {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  AppLocalizationBloc() : super(const AppLocalizationState(appLanguage: Environments.defaultLanguage)) {
    on<AppLocalizationInitialEvent>(_onAppLocalizationInitialEvent);
    on<ChangeAppLocalizationEvent>(_onChangeAppLocalizationEvent);
  }

  Future<void> _onAppLocalizationInitialEvent(AppLocalizationInitialEvent event, Emitter<AppLocalizationState> emit) async {
    final defaultLanguage = await (_sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage));
    emit(state.copyWith(appLanguage: defaultLanguage));
  }

  Future<void> _onChangeAppLocalizationEvent(ChangeAppLocalizationEvent event, Emitter<AppLocalizationState> emit) async {
    emit(state.copyWith(appLanguage: event.defaultLanguage));
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.defaultLanguage, event.defaultLanguage);
  }
}

