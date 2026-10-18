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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:user/app/core/repositories/auth_repository.dart';

part 'setting_section_event.dart';
part 'setting_section_state.dart';

class SettingSectionBloc extends Bloc<SettingSectionEvent, SettingSectionState> {
  final AuthRepository _authRepository = AuthRepository();
  SettingSectionBloc() : super(const SettingSectionState()) {
    on<SettingSectionInitialEvent>(_onSettingSectionInitialEvent);
  }

  FutureOr<void> _onSettingSectionInitialEvent(SettingSectionInitialEvent event, Emitter<SettingSectionState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "account_settings"}, 'account_settings_screen', 'account_settings_screen');
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final bool isAuthorized = await _authRepository.isAuthorized();
      emit(state.copyWith(isAuthorized: isAuthorized, currentVersion: currentVersion, status: SettingSectionStatus.initial));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SettingSectionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

