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
import 'package:formz/formz.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/deliverytime_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'select_delivery_time_modal_event.dart';
part 'select_delivery_time_modal_state.dart';

class SelectDeliveryTimeModalBloc extends Bloc<SelectDeliveryTimeModalEvent, SelectDeliveryTimeModalState> {
  final AuthRepository _authRepository = AuthRepository();
  SelectDeliveryTimeModalBloc()
    : super(
        SelectDeliveryTimeModalState(
          time: DeliveryTimeTimeModel(label: '', value: ''),
        ),
      ) {
    on<SelectDeliveryTimeModalInitialEvent>(_onSelectDeliveryTimeModalInitialEvent);
    on<SelectDeliveryTimeModalFromChangeEvent>(_onSelectDeliveryTimeModalFromChangeEvent);
    on<SelectDeliveryTimeModalFromUnfocusedEvent>(_onSelectDeliveryTimeModalFromUnfocusedEvent);
    on<SelectDeliveryTimeModalToChangeEvent>(_onSelectDeliveryTimeModalToChangeEvent);
    on<SelectDeliveryTimeModalToUnfocusedEvent>(_onSelectDeliveryTimeModalToUnfocusedEvent);
    on<SelectDeliveryTimeChangeEvent>(_onSelectDeliveryTimeChangeEvent);
  }

  FutureOr<void> _onSelectDeliveryTimeModalInitialEvent(SelectDeliveryTimeModalInitialEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_schedule_time"}, 'order_schedule_time_screen', 'order_schedule_time_screen');
      List<String> timeList = event.deliveryTime.split(' ');
      if (timeList.isNotEmpty && timeList.length == 4) {
        final String from = timeList[0];
        final String to = timeList[2];
        final String time = timeList[3];
        List<DeliveryTimeTimeModel> timeListOption = <DeliveryTimeTimeModel>[];
        timeListOption.clear();
        DeliveryTimeTimeModel min = DeliveryTimeTimeModel(label: 'dd_min', value: 'min');
        DeliveryTimeTimeModel hour = DeliveryTimeTimeModel(label: 'dd_hour', value: 'hour');
        timeListOption.add(min);
        timeListOption.add(hour);
        final int indexOfTime = timeListOption.indexWhere((element) => element.value == time);
        final fromTime = DeliveryTimeFromField.dirty(from);
        final toTime = DeliveryTimeToField.dirty(to);
        emit(
          state.copyWith(
            from: fromTime,
            to: toTime,
            time: indexOfTime != -1 ? timeListOption[indexOfTime] : timeListOption.first,
            timeList: timeListOption,
            isValid: Formz.validate([fromTime, toTime]),
            status: SelectDeliveryTimeModalStatus.fetched,
          ),
        );
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SelectDeliveryTimeModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSelectDeliveryTimeModalFromChangeEvent(SelectDeliveryTimeModalFromChangeEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    final from = DeliveryTimeFromField.dirty(event.from);
    emit(state.copyWith(from: from.isValid ? from : DeliveryTimeFromField.pure(event.from), status: SelectDeliveryTimeModalStatus.initial, isValid: Formz.validate([from, state.to])));
  }

  FutureOr<void> _onSelectDeliveryTimeModalFromUnfocusedEvent(SelectDeliveryTimeModalFromUnfocusedEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    final from = DeliveryTimeFromField.dirty(state.from.value);
    emit(state.copyWith(from: from, status: SelectDeliveryTimeModalStatus.initial, isValid: Formz.validate([from, state.to])));
  }

  FutureOr<void> _onSelectDeliveryTimeModalToChangeEvent(SelectDeliveryTimeModalToChangeEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    final to = DeliveryTimeToField.dirty(event.to);
    emit(state.copyWith(to: to.isValid ? to : DeliveryTimeToField.pure(event.to), status: SelectDeliveryTimeModalStatus.initial, isValid: Formz.validate([to, state.from])));
  }

  FutureOr<void> _onSelectDeliveryTimeModalToUnfocusedEvent(SelectDeliveryTimeModalToUnfocusedEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    final to = DeliveryTimeToField.dirty(state.to.value);
    emit(state.copyWith(to: to, status: SelectDeliveryTimeModalStatus.initial, isValid: Formz.validate([to, state.from])));
  }

  FutureOr<void> _onSelectDeliveryTimeChangeEvent(SelectDeliveryTimeChangeEvent event, Emitter<SelectDeliveryTimeModalState> emit) async {
    emit(state.copyWith(time: event.time, status: SelectDeliveryTimeModalStatus.initial));
  }
}

