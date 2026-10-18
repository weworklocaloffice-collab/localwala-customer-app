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
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/request/save_address_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/validations/address_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'address_action_event.dart';
part 'address_action_state.dart';

class AddressActionBloc extends Bloc<AddressActionEvent, AddressActionState> {
  final AddressRepository _addressRepository = AddressRepository();
  final AuthRepository _authRepository = AuthRepository();
  AddressActionBloc() : super(const AddressActionState()) {
    on<AddressActionInitialEvent>(_onAddressActionInitialEvent);
    on<AddressActionTitleChangeEvent>(_onAddressActionTitleChangeEvent);
    on<AddressActionNameChanged>(_onAddressActionNameChanged);
    on<AddressActionNameUnfocused>(_onAddressActionNameUnfocused);
    on<AddressActionCountryCodeChanged>(_onAddressActionCountryCodeChanged);
    on<AddressActionNumberChanged>(_onAddressActionNumberChanged);
    on<AddressActionNumberUnfocused>(_onAddressActionNumberUnfocused);
    on<AddressActionHouseChanged>(_onAddressActionHouseChanged);
    on<AddressActionHouseUnfocused>(_onAddressActionHouseUnfocused);
    on<AddressActionLocalityChanged>(_onAddressActionLocalityChanged);
    on<AddressActionLocalityUnfocused>(_onAddressActionLocalityUnfocused);
    on<AddressActionLandmarkChanged>(_onAddressActionLandmarkChanged);
    on<AddressActionSubmitted>(_onAddressActionSubmitted);
  }

  FutureOr<void> _onAddressActionInitialEvent(AddressActionInitialEvent event, Emitter<AddressActionState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "add_or_edit_address"}, 'address_add_update_screen', 'address_add_update_screen');
    final locality = AddressLocalityField.dirty(event.locality);
    final name = AddressReceiverNameField.dirty(state.receiverName.value);
    final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
    final house = AddressHouseField.dirty(state.houseName.value);
    String defaultCountryCode = '';
    String flag = '';
    if (event.isNew) {
      await _addressRepository.getDefaultCountryCode().then((value) {
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
    } else {
      await _authRepository.getCountryList().then((value) {
        final selected = value.firstWhere((element) => element.dialCode == '+${event.countryCode}');
        if (selected.dialCode != null && selected.flag != null) {
          defaultCountryCode = selected.dialCode!;
          flag = selected.flag!;
        }
      });
    }

    emit(
      state.copyWith(
        id: event.id,
        isNew: event.isNew,
        locality: locality.isValid ? locality : AddressLocalityField.pure(event.locality),
        receiverName: name.isValid ? name : AddressReceiverNameField.pure(event.receiverName),
        countryCode: AddressReceiveCountryCodeField.pure(defaultCountryCode),
        flag: flag,
        receiverNumber: number.isValid ? number : AddressReceiverNumberField.pure(event.receiverContact),
        houseName: house.isValid ? house : AddressHouseField.pure(event.flatHouse),
        latitude: event.latitude.toString(),
        longitude: event.longitude.toString(),
        landmark: event.landmark,
        title: event.title,
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([locality, name, number, house]),
      ),
    );
  }

  FutureOr<void> _onAddressActionTitleChangeEvent(AddressActionTitleChangeEvent event, Emitter<AddressActionState> emit) async {
    emit(state.copyWith(title: event.title));
  }

  FutureOr<void> _onAddressActionNameChanged(AddressActionNameChanged event, Emitter<AddressActionState> emit) async {
    final name = AddressReceiverNameField.dirty(event.name);
    emit(
      state.copyWith(
        receiverName: name.isValid ? name : AddressReceiverNameField.pure(event.name),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([name, state.receiverNumber, state.houseName, state.locality, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onAddressActionNameUnfocused(AddressActionNameUnfocused event, Emitter<AddressActionState> emit) async {
    final name = AddressReceiverNameField.dirty(state.receiverName.value);
    emit(state.copyWith(receiverName: name, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, state.receiverNumber, state.houseName, state.locality, state.countryCode])));
  }

  FutureOr<void> _onAddressActionCountryCodeChanged(AddressActionCountryCodeChanged event, Emitter<AddressActionState> emit) async {
    final countryCode = AddressReceiveCountryCodeField.dirty(event.countryCode);
    emit(state.copyWith(countryCode: countryCode, flag: event.flag, status: FormzSubmissionStatus.initial, isValid: Formz.validate([countryCode, state.receiverName, state.receiverNumber, state.houseName, state.locality])));
  }

  FutureOr<void> _onAddressActionNumberChanged(AddressActionNumberChanged event, Emitter<AddressActionState> emit) async {
    final number = AddressReceiverNumberField.dirty(event.number);
    emit(
      state.copyWith(
        receiverNumber: number.isValid ? number : AddressReceiverNumberField.pure(event.number),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([number, state.receiverName, state.houseName, state.locality, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onAddressActionNumberUnfocused(AddressActionNumberUnfocused event, Emitter<AddressActionState> emit) async {
    final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
    emit(state.copyWith(receiverNumber: number, status: FormzSubmissionStatus.initial, isValid: Formz.validate([number, state.receiverName, state.houseName, state.locality, state.countryCode])));
  }

  FutureOr<void> _onAddressActionHouseChanged(AddressActionHouseChanged event, Emitter<AddressActionState> emit) async {
    final house = AddressHouseField.dirty(event.house);
    emit(
      state.copyWith(
        houseName: house.isValid ? house : AddressHouseField.pure(event.house),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([house, state.receiverName, state.receiverNumber, state.locality, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onAddressActionHouseUnfocused(AddressActionHouseUnfocused event, Emitter<AddressActionState> emit) async {
    final house = AddressHouseField.dirty(state.houseName.value);
    emit(state.copyWith(houseName: house, status: FormzSubmissionStatus.initial, isValid: Formz.validate([house, state.receiverName, state.receiverNumber, state.locality, state.countryCode])));
  }

  FutureOr<void> _onAddressActionLocalityChanged(AddressActionLocalityChanged event, Emitter<AddressActionState> emit) async {
    final locality = AddressLocalityField.dirty(event.locality);
    emit(
      state.copyWith(
        locality: locality.isValid ? locality : AddressLocalityField.pure(event.locality),
        status: FormzSubmissionStatus.initial,
        isValid: Formz.validate([locality, state.receiverName, state.receiverNumber, state.houseName, state.countryCode]),
      ),
    );
  }

  FutureOr<void> _onAddressActionLocalityUnfocused(AddressActionLocalityUnfocused event, Emitter<AddressActionState> emit) async {
    final locality = AddressLocalityField.dirty(state.locality.value);
    emit(state.copyWith(locality: locality, status: FormzSubmissionStatus.initial, isValid: Formz.validate([locality, state.receiverName, state.receiverNumber, state.houseName, state.countryCode])));
  }

  FutureOr<void> _onAddressActionLandmarkChanged(AddressActionLandmarkChanged event, Emitter<AddressActionState> emit) async {
    emit(state.copyWith(landmark: event.landmark));
  }

  FutureOr<void> _onAddressActionSubmitted(AddressActionSubmitted event, Emitter<AddressActionState> emit) async {
    final name = AddressReceiverNameField.dirty(state.receiverName.value);
    final number = AddressReceiverNumberField.dirty(state.receiverNumber.value);
    final house = AddressHouseField.dirty(state.houseName.value);
    final locality = AddressLocalityField.dirty(state.locality.value);
    final countryCode = AddressReceiveCountryCodeField.dirty(state.countryCode.value);
    emit(state.copyWith(receiverName: name, receiverNumber: number, houseName: house, locality: locality, countryCode: countryCode, status: FormzSubmissionStatus.initial, isValid: Formz.validate([name, number, house, locality])));
    if (state.isValid && state.receiverName.value.isNotEmpty && state.receiverNumber.value.isNotEmpty && state.houseName.value.isNotEmpty && state.locality.value.isNotEmpty && state.countryCode.value.isNotEmpty) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        final String userId = await _addressRepository.userId();
        SaveAddressRequestModel param = SaveAddressRequestModel(
          user: userId,
          title: state.title,
          receiverName: state.receiverName.value.toString(),
          countryCode: state.countryCode.value.toString(),
          receiverContact: state.receiverNumber.value.toString(),
          flatHouse: state.houseName.value.toString(),
          locality: state.locality.value.toString(),
          landmark: state.landmark.toString(),
          type: 'Point',
          longitude: state.longitude.toString(),
          latitude: state.latitude.toString(),
        );
        if (state.isNew == true) {
          DioApiResponse response = await _addressRepository.saveAddress(param);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: FormzSubmissionStatus.success));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FormzSubmissionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          DioApiResponse response = await _addressRepository.updateAddress(state.id, param);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: FormzSubmissionStatus.success));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: FormzSubmissionStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

