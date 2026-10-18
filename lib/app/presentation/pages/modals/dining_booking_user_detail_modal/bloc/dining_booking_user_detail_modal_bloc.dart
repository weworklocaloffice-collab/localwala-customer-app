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
import 'package:formz/formz.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/dining_booking_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_booking_user_detail_modal_event.dart';
part 'dining_booking_user_detail_modal_state.dart';

class DiningBookingUserDetailModalBloc extends Bloc<DiningBookingUserDetailModalEvent, DiningBookingUserDetailModalState> {
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingUserDetailModalBloc() : super(const DiningBookingUserDetailModalState()) {
    on<DiningBookingUserDetailModalInitialEvent>(_onDiningBookingUserDetailModalInitialEvent);
    on<DiningBookingUserDetailModalNameChangedEvent>(_onDiningBookingUserDetailModalNameChangedEvent);
    on<DiningBookingUserDetailModalNameUnfocusedEvent>(_onDiningBookingUserDetailModalNameUnfocusedEvent);
    on<DiningBookingUserDetailModalCountryCodeChangedEvent>(_onDiningBookingUserDetailModalCountryCodeChangedEvent);
    on<DiningBookingUserDetailModalNumberChangedEvent>(_onDiningBookingUserDetailModalNumberChangedEvent);
    on<DiningBookingUserDetailModalNumberUnfocusedEvent>(_onDiningBookingUserDetailModalNumberUnfocusedEvent);
    on<DiningBookingUserDetailModalEmailChangedEvent>(_onDiningBookingUserDetailModalEmailChangedEvent);
    on<DiningBookingUserDetailModalEmailUnfocusedEvent>(_onDiningBookingUserDetailModalEmailUnfocusedEvent);
    on<DiningBookingUserDetailModalSubmitEvent>(_onDiningBookingUserDetailModalSubmitEvent);
  }

  FutureOr<void> _onDiningBookingUserDetailModalInitialEvent(DiningBookingUserDetailModalInitialEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_customer_detail"}, 'dining_booking_customer_detail_screen', 'dining_booking_customer_detail_screen');
      String defaultCountryCode = '';
      String flag = '';
      final name = DiningBookingNameField.dirty(state.userName.value);
      final number = DiningBookingNumberField.dirty(state.userContact.value);
      final email = DiningBookingEmailField.dirty(state.userEmail.value);
      if (event.userCountryCode.isEmpty) {
        await _authRepository.getDefaultCountryCode().then((value) {
          if (value.isNotEmpty) {
            try {
              Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
              AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
              defaultCountryCode = countryCodeData.dialCode!;
              flag = countryCodeData.flag!;
            } catch (e, stacktrace) {
              if (!kIsWeb) {
                FirebaseCrashlytics.instance.recordError(e, stacktrace);
              }
            }
          }
        });
      } else {
        await _authRepository.getCountryList().then((value) {
          final selected = value.firstWhere((element) => element.dialCode == '+${event.userCountryCode}');
          if (selected.dialCode != null && selected.flag != null) {
            defaultCountryCode = selected.dialCode!;
            flag = selected.flag!;
          }
        });
      }

      emit(
        state.copyWith(
          userEmail: email.isValid ? email : DiningBookingEmailField.pure(event.userEmail),
          userName: name.isValid ? name : DiningBookingNameField.pure(event.userName),
          userCountryCode: DiningBookingCountryCodeField.pure(defaultCountryCode),
          flag: flag,
          userContact: number.isValid ? number : DiningBookingNumberField.pure(event.userPhoneNumber),
          status: FormzSubmissionStatus.initial,
          isValid: Formz.validate([name, number]),
        ),
      );
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingUserDetailModalNameChangedEvent(DiningBookingUserDetailModalNameChangedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final name = DiningBookingNameField.dirty(event.name);
    emit(state.copyWith(userName: name.isValid ? name : DiningBookingNameField.pure(event.name), status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail])));
  }

  FutureOr<void> _onDiningBookingUserDetailModalNameUnfocusedEvent(DiningBookingUserDetailModalNameUnfocusedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final name = DiningBookingNameField.dirty(state.userName.value);
    emit(state.copyWith(userName: name, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, state.userContact, state.userCountryCode, state.userEmail])));
  }

  FutureOr<void> _onDiningBookingUserDetailModalCountryCodeChangedEvent(DiningBookingUserDetailModalCountryCodeChangedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final countryCode = DiningBookingCountryCodeField.dirty(event.countryCode);
    emit(state.copyWith(userCountryCode: countryCode, flag: event.flag, status: FormzSubmissionStatus.initial, isValid: Formz.validate([countryCode, state.userName, state.userContact, state.userEmail])));
  }

  FutureOr<void> _onDiningBookingUserDetailModalNumberChangedEvent(DiningBookingUserDetailModalNumberChangedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final number = DiningBookingNumberField.dirty(event.number);
    emit(
      state.copyWith(
        userContact: number.isValid ? number : DiningBookingNumberField.pure(event.number),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail]),
      ),
    );
  }

  FutureOr<void> _onDiningBookingUserDetailModalNumberUnfocusedEvent(DiningBookingUserDetailModalNumberUnfocusedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final number = DiningBookingNumberField.dirty(state.userContact.value);
    emit(state.copyWith(userContact: number, status: FormzSubmissionStatus.initial, isValid: Formz.validate([number, state.userName, state.userCountryCode, state.userEmail])));
  }

  FutureOr<void> _onDiningBookingUserDetailModalEmailChangedEvent(DiningBookingUserDetailModalEmailChangedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final email = DiningBookingEmailField.dirty(event.email);
    emit(
      state.copyWith(userEmail: email.isValid ? email : DiningBookingEmailField.pure(event.email), status: FormzSubmissionStatus.initial, isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact])),
    );
  }

  FutureOr<void> _onDiningBookingUserDetailModalEmailUnfocusedEvent(DiningBookingUserDetailModalEmailUnfocusedEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final email = DiningBookingEmailField.dirty(state.userEmail.value);
    emit(state.copyWith(userEmail: email, status: FormzSubmissionStatus.initial, isValid: Formz.validate([email, state.userName, state.userCountryCode, state.userContact])));
  }

  FutureOr<void> _onDiningBookingUserDetailModalSubmitEvent(DiningBookingUserDetailModalSubmitEvent event, Emitter<DiningBookingUserDetailModalState> emit) async {
    final name = DiningBookingNameField.dirty(state.userName.value);
    final number = DiningBookingNumberField.dirty(state.userContact.value);
    final countryCode = DiningBookingCountryCodeField.dirty(state.userCountryCode.value);
    final email = DiningBookingEmailField.dirty(state.userEmail.value);
    emit(state.copyWith(userName: name, userContact: number, userCountryCode: countryCode, userEmail: email, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, number, countryCode, email])));
    if (state.isValid && state.userName.value.isNotEmpty && state.userContact.value.isNotEmpty && state.userCountryCode.value.isNotEmpty && state.userEmail.value.isNotEmpty) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    }
  }
}

