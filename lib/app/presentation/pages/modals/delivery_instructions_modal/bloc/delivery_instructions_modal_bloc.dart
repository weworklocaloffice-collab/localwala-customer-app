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
import 'package:user/app/core/models/order_settings_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'delivery_instructions_modal_event.dart';
part 'delivery_instructions_modal_state.dart';

class DeliveryInstructionsModalBloc extends Bloc<DeliveryInstructionsModalEvent, DeliveryInstructionsModalState> {
  final AuthRepository _authRepository = AuthRepository();
  DeliveryInstructionsModalBloc() : super(const DeliveryInstructionsModalState()) {
    on<DeliveryInstructionsModalInitialEvent>(_onDeliveryInstructionsModalInitialEvent);
    on<DeliveryInstructionSaveEvent>(_onDeliveryInstructionSaveEvent);
  }

  FutureOr<void> _onDeliveryInstructionsModalInitialEvent(DeliveryInstructionsModalInitialEvent event, Emitter<DeliveryInstructionsModalState> emit) async {
    try {
      final String locale = await _authRepository.getLocale();
      await _authRepository.saveEvent('visited_screen', {"screen": "delivery_instructions"}, 'delivery_instructions_screen', 'delivery_instructions_screen');
      List<dynamic> jsonList = jsonDecode(event.deliveryInstructionList);
      List<InstructionConfigModel> modelList = jsonList.map((json) => InstructionConfigModel.fromJson(json, locale.toString())).toList();
      emit(state.copyWith(instructions: modelList, deliveryInstructionId: event.deliveryInstructionId, addressTitle: event.addressTitle, addressSubtitle: event.addressSubtitle, status: DeliveryInstructionsModalStatus.success));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliveryInstructionsModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliveryInstructionSaveEvent(DeliveryInstructionSaveEvent event, Emitter<DeliveryInstructionsModalState> emit) async {
    emit(state.copyWith(deliveryInstructionId: event.id, deliveryInstructionName: event.name, deliveryInstructionImage: event.image));
  }
}

