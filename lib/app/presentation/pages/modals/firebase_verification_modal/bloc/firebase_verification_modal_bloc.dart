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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'firebase_verification_modal_event.dart';
part 'firebase_verification_modal_state.dart';

class FirebaseVerificationModalBloc extends Bloc<FirebaseVerificationModalEvent, FirebaseVerificationModalState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  FirebaseVerificationModalBloc() : super(const FirebaseVerificationModalState()) {
    on<FirebaseVerificationModalInitialEvent>(_onFirebaseVerificationModalInitialEvent);
    on<FirebaseVerificationModalErrorEvent>(_onFirebaseVerificationModalErrorEvent);
    on<FirebaseVerificationIdEvent>(_onFirebaseVerificationIdEvent);
    on<FirebaseVerificationSMSChangeEvent>(_onFirebaseVerificationSMSChangeEvent);
    on<FirebaseVerificationVerifyEvent>(_onFirebaseVerificationVerifyEvent);
  }

  FutureOr<void> _onFirebaseVerificationModalInitialEvent(FirebaseVerificationModalInitialEvent event, Emitter<FirebaseVerificationModalState> emit) async {
    if (!kIsWeb) {
      try {
        await _authRepository.saveEvent('visited_screen', {"screen": "firebase_verification"}, 'firebase_verification_screen', 'firebase_verification_screen');
        emit(state.copyWith(toNumber: '${event.countryCode} ${event.mobileNumber}', countryCode: event.countryCode, mobileNumber: event.mobileNumber, status: FirebaseVerificationModalStatus.sending));
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: '${event.countryCode}${event.mobileNumber}',
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) async {
            add(FirebaseVerificationModalErrorEvent(error: e.toString()));
          },
          codeSent: (String verificationId, int? resendToken) async {
            add(FirebaseVerificationIdEvent(id: verificationId));
          },
          codeAutoRetrievalTimeout: (String verificationId) async {
            add(FirebaseVerificationIdEvent(id: verificationId));
          },
          // autoRetrievedSmsCodeForTesting: '123456',
        );
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FirebaseVerificationModalStatus.sentFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onFirebaseVerificationModalErrorEvent(FirebaseVerificationModalErrorEvent event, Emitter<FirebaseVerificationModalState> emit) async {
    emit(state.copyWith(status: FirebaseVerificationModalStatus.sentFailed, statusCode: 0, alertMessage: event.error, extraMessage: ''));
  }

  FutureOr<void> _onFirebaseVerificationIdEvent(FirebaseVerificationIdEvent event, Emitter<FirebaseVerificationModalState> emit) async {
    emit(state.copyWith(verificationId: event.id, status: FirebaseVerificationModalStatus.sent));
  }

  FutureOr<void> _onFirebaseVerificationSMSChangeEvent(FirebaseVerificationSMSChangeEvent event, Emitter<FirebaseVerificationModalState> emit) async {
    emit(state.copyWith(smsCode: event.otp));
  }

  FutureOr<void> _onFirebaseVerificationVerifyEvent(FirebaseVerificationVerifyEvent event, Emitter<FirebaseVerificationModalState> emit) async {
    try {
      emit(state.copyWith(status: FirebaseVerificationModalStatus.verifying));
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: state.verificationId, smsCode: state.smsCode);
      await _firebaseAuth.signInWithCredential(credential);
      final user = _firebaseAuth.currentUser;
      final String? idToken = await user!.getIdToken();
      emit(state.copyWith(status: FirebaseVerificationModalStatus.verified, accessToken: idToken!));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FirebaseVerificationModalStatus.verifyFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

