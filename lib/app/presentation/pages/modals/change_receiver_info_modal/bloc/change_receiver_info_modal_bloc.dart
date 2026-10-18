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
import 'package:flutter/widgets.dart';
import 'package:formz/formz.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/address_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'change_receiver_info_modal_event.dart';
part 'change_receiver_info_modal_state.dart';

class ChangeReceiverInfoModalBloc extends Bloc<ChangeReceiverInfoModalEvent, ChangeReceiverInfoModalState> {
  final AuthRepository _authRepository = AuthRepository();
  ChangeReceiverInfoModalBloc() : super(const ChangeReceiverInfoModalState()) {
    on<ChangeReceiverInfoModalInitialEvent>(_onChangeReceiverInfoModalInitialEvent);
    on<ChangeReceiverNameChanged>(_onChangeReceiverNameChanged);
    on<ChangeReceiverNameUnfocused>(_onChangeReceiverNameUnfocused);
    on<ChangeReceiverCountryCodeChanged>(_onChangeReceiverCountryCodeChanged);
    on<ChangeReceiverNumberChanged>(_onChangeReceiverNumberChanged);
    on<ChangeReceiverNumberUnfocused>(_onChangeReceiverNumberUnfocused);
    on<ChangeReceiverSubmitted>(_onChangeReceiverSubmitted);
  }

  FutureOr<void> _onChangeReceiverInfoModalInitialEvent(ChangeReceiverInfoModalInitialEvent event, Emitter<ChangeReceiverInfoModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_receiver_detail"}, 'order_receiver_detail_screen', 'order_receiver_detail_screen');
      String defaultCountryCode = '';
      String flag = '';
      final name = AddressReceiverNameField.dirty(state.receiverName.value);
      final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
      if (event.receiverCountryCode.isNotEmpty) {
        await _authRepository.getCountryList().then((value) {
          final selected = value.firstWhere((element) => element.dialCode == '+${event.receiverCountryCode}');
          if (selected.dialCode != null && selected.flag != null) {
            defaultCountryCode = selected.dialCode!;
            flag = selected.flag!;
          }
        });
      } else {
        await _authRepository.getDefaultCountryCode().then((value) {
          if (value.isNotEmpty) {
            try {
              Map<String, dynamic>? myMap = jsonDecode(value) as Map<String, dynamic>;
              AppDefaultCountryCodeConfigModel countryCodeData = AppDefaultCountryCodeConfigModel.fromJson(myMap);
              flag = countryCodeData.flag!;
              defaultCountryCode = countryCodeData.dialCode!;
            } catch (e, stacktrace) {
              defaultCountryCode = '91';
              if (!kIsWeb) {
                FirebaseCrashlytics.instance.recordError(e, stacktrace);
              }
            }
          }
        });
      }
      debugPrint('||${event.orderTo}');
      emit(
        state.copyWith(
          receiverName: name.isValid ? name : AddressReceiverNameField.pure(event.receiverName),
          countryCode: AddressReceiveCountryCodeField.pure(defaultCountryCode),
          flag: flag,
          orderTo: event.orderTo,
          addressTitle: event.addressTitle,
          addressSubtitle: event.addressSubtitle,
          receiverNumber: number.isValid ? number : AddressReceiverNumberField.pure(event.receiverPhoneNumber),
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

  FutureOr<void> _onChangeReceiverNameChanged(ChangeReceiverNameChanged event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final name = AddressReceiverNameField.dirty(event.name);
    emit(state.copyWith(receiverName: name.isValid ? name : AddressReceiverNameField.pure(event.name), status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, state.receiverNumber, state.countryCode])));
  }

  FutureOr<void> _onChangeReceiverNameUnfocused(ChangeReceiverNameUnfocused event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final name = AddressReceiverNameField.dirty(state.receiverName.value);
    emit(state.copyWith(receiverName: name, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, state.receiverNumber, state.countryCode])));
  }

  FutureOr<void> _onChangeReceiverCountryCodeChanged(ChangeReceiverCountryCodeChanged event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final countryCode = AddressReceiveCountryCodeField.dirty(event.countryCode);
    emit(state.copyWith(countryCode: countryCode, flag: event.flag, status: FormzSubmissionStatus.initial, isValid: Formz.validate([countryCode, state.receiverName, state.receiverNumber])));
  }

  FutureOr<void> _onChangeReceiverNumberChanged(ChangeReceiverNumberChanged event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final number = AddressReceiverNumberField.dirty(event.number);
    emit(state.copyWith(receiverNumber: number.isValid ? number : AddressReceiverNumberField.pure(event.number), status: FormzSubmissionStatus.initial, isValid: Formz.validate([number, state.receiverName, state.countryCode])));
  }

  FutureOr<void> _onChangeReceiverNumberUnfocused(ChangeReceiverNumberUnfocused event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
    emit(state.copyWith(receiverNumber: number, status: FormzSubmissionStatus.initial, isValid: Formz.validate([number, state.receiverName, state.countryCode])));
  }

  FutureOr<void> _onChangeReceiverSubmitted(ChangeReceiverSubmitted event, Emitter<ChangeReceiverInfoModalState> emit) async {
    final name = AddressReceiverNameField.dirty(state.receiverName.value);
    final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
    final countryCode = AddressReceiveCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(receiverName: name, receiverNumber: number, countryCode: countryCode, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, number])));
    if (state.isValid && state.receiverName.value.isNotEmpty && state.receiverNumber.value.isNotEmpty && state.countryCode.value.isNotEmpty) {
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    }
  }
}

