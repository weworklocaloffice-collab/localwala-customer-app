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

part 'web_otp_modal_event.dart';
part 'web_otp_modal_state.dart';

class WebOtpModalBloc extends Bloc<WebOtpModalEvent, WebOtpModalState> {
  final AuthRepository _authRepository = AuthRepository();
  WebOtpModalBloc() : super(const WebOtpModalState()) {
    on<WebOtpModalInitialEvent>(_onWebOtpModalInitialEvent);
    on<WebOtpModalResponseEvent>(_onWebOtpModalResponseEvent);
  }

  FutureOr<void> _onWebOtpModalInitialEvent(WebOtpModalInitialEvent event, Emitter<WebOtpModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "web_otp_verification"}, 'web_otp_verification_screen', 'web_otp_verification_screen');
    emit(state.copyWith(status: WebOtpModalStatus.initial, otpId: event.otpId, locale: event.locale));
  }

  FutureOr<void> _onWebOtpModalResponseEvent(WebOtpModalResponseEvent event, Emitter<WebOtpModalState> emit) async {
    emit(state.copyWith(dummyOTP: event.dummyOTP, status: event.isSuccess ? WebOtpModalStatus.success : WebOtpModalStatus.failed));
  }
}

