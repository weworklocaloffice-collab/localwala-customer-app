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
import 'package:user/app/core/models/address_list_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'address_book_event.dart';
part 'address_book_state.dart';

class AddressBookBloc extends Bloc<AddressBookEvent, AddressBookState> {
  final AddressRepository _addressRepository = AddressRepository();
  final AuthRepository _authRepository = AuthRepository();
  AddressBookBloc() : super(AddressBookState(addresses: MyAddressListResponseModel(list: [], total: 0))) {
    on<AddressBookInitialEvent>(_onAddressBookInitialEvent);
    on<AddressBookRefreshEvent>(_onAddressBookRefreshEvent);
    on<AddressBookDeleteEvent>(_onAddressBookDeleteEvent);
  }

  FutureOr<void> _onAddressBookInitialEvent(AddressBookInitialEvent event, Emitter<AddressBookState> emit) async {
    try {
      emit(state.copyWith(status: AddressBookStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "address_list"}, 'address_screen', 'address_screen');
      final String uid = await _addressRepository.userId();
      if (uid.isNotEmpty) {
        DioApiResponse response = await _addressRepository.getMyAddressList(uid);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          MyAddressListResponseModel data = MyAddressListResponseModel.fromJson(myMap);
          emit(state.copyWith(addresses: data, status: data.list!.isEmpty ? AddressBookStatus.empty : AddressBookStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: AddressBookStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: AddressBookStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AddressBookStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAddressBookRefreshEvent(AddressBookRefreshEvent event, Emitter<AddressBookState> emit) async {
    try {
      emit(state.copyWith(status: AddressBookStatus.loading));
      final String uid = await _addressRepository.userId();
      DioApiResponse response = await _addressRepository.getMyAddressList(uid);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        MyAddressListResponseModel data = MyAddressListResponseModel.fromJson(myMap);
        emit(state.copyWith(addresses: data, status: data.list!.isEmpty ? AddressBookStatus.empty : AddressBookStatus.success));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AddressBookStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AddressBookStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAddressBookDeleteEvent(AddressBookDeleteEvent event, Emitter<AddressBookState> emit) async {
    final int index = state.addresses.list!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      try {
        state.addresses.list![index].willShow = !state.addresses.list![index].willShow!;
        emit(state.copyWith(addresses: state.addresses, status: AddressBookStatus.success));
        DioApiResponse response = await _addressRepository.deleteMyAddress(event.id);
        if (response.errorType == NetErrorType.none) {
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          state.addresses.list![index].willShow = !state.addresses.list![index].willShow!;
          emit(state.copyWith(status: AddressBookStatus.failure, addresses: state.addresses, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        state.addresses.list![index].willShow = !state.addresses.list![index].willShow!;
        emit(state.copyWith(status: AddressBookStatus.failure, addresses: state.addresses, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

