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
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'reset_password_event.dart';
part 'reset_password_state.dart';

class ResetPasswordBloc extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final AuthRepository _authRepository = AuthRepository();
  ResetPasswordBloc() : super(const ResetPasswordState()) {
    on<ResetPasswordInitialEvent>(_onResetPasswordInitialEvent);
  }

  FutureOr<void> _onResetPasswordInitialEvent(ResetPasswordInitialEvent event, Emitter<ResetPasswordState> emit) async {
    try {
      String? userResetPasswordWith = await _authRepository.userResetPasswordWith();
      await _authRepository.saveEvent('visited_screen', {"screen": "reset_password"}, 'reset_password_screen', 'reset_password_screen');
      emit(state.copyWith(userResetPasswordWith: userResetPasswordWith.isNotEmpty ? userResetPasswordWith : 'email_otp', status: ResetPasswordStatus.success));
    } catch (e, stacktrace) {
      emit(state.copyWith(userResetPasswordWith: 'email_otp', status: ResetPasswordStatus.success));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

