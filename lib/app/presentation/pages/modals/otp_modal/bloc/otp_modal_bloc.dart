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
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/request/otp_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'otp_modal_event.dart';
part 'otp_modal_state.dart';

class OtpModalBloc extends Bloc<OtpModalEvent, OtpModalState> {
  final AuthRepository _authRepository = AuthRepository();
  OtpModalBloc() : super(const OtpModalState()) {
    on<OtpModalInitialEvent>(_onOtpModalInitialEvent);
    on<OtpModalOnSubmitEvent>(_onOtpModalOnSubmitEvent);
    on<OtpModalOnResendEvent>(_onOtpModalOnResendEvent);
    on<OtpModalOnOTPChanged>(_onOtpModalOnOTPChanged);
  }

  FutureOr<void> _onOtpModalInitialEvent(OtpModalInitialEvent event, Emitter<OtpModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "otp_verification"}, 'otp_verification_screen', 'otp_verification_screen');
    emit(state.copyWith(status: OtpModalStatus.initial, id: event.providerId, provider: event.provider));
  }

  FutureOr<void> _onOtpModalOnSubmitEvent(OtpModalOnSubmitEvent event, Emitter<OtpModalState> emit) async {
    try {
      emit(state.copyWith(status: OtpModalStatus.inProgress));
      OTPRequest otpRequestParam = OTPRequest(id: state.id, provider: state.provider, otp: state.otp);
      DioApiResponse response = await _authRepository.verifyOTP(otpRequestParam);
      if (response.errorType == NetErrorType.none) {
        emit(state.copyWith(status: OtpModalStatus.success));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OtpModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OtpModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOtpModalOnResendEvent(OtpModalOnResendEvent event, Emitter<OtpModalState> emit) async {
    try {
      emit(state.copyWith(status: OtpModalStatus.resend));
      DioApiResponse response = await _authRepository.resendOTP(state.id);
      if (response.errorType == NetErrorType.none) {
        emit(state.copyWith(status: OtpModalStatus.successResent));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OtpModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OtpModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOtpModalOnOTPChanged(OtpModalOnOTPChanged event, Emitter<OtpModalState> emit) async {
    emit(state.copyWith(status: OtpModalStatus.initial, otp: event.otp));
  }
}

