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
import 'package:user/app/core/models/delivery_address_list_from_checkout_model.dart';
import 'package:user/app/core/models/request/user_address_list_from_restaurant_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'delivery_addresss_list_event.dart';
part 'delivery_addresss_list_state.dart';

class DeliveryAddresssListBloc extends Bloc<DeliveryAddresssListEvent, DeliveryAddresssListState> {
  final AddressRepository _addressRepository = AddressRepository();
  final AuthRepository _authRepository = AuthRepository();
  DeliveryAddresssListBloc()
    : super(
        DeliveryAddresssListState(
          addresses: DeliveryAddressListFromCheckoutModel(list: [], total: 0, mode: 'km', courage: 50),
        ),
      ) {
    on<DeliveryAddressListInitialEvent>(_onDeliveryAddressListInitialEvent);
    on<DeliveryAddresssRefreshEvent>(_onDeliveryAddresssRefreshEvent);
    on<DeliveryAddressSelectEvent>(_onDeliveryAddressSelectEvent);
  }

  FutureOr<void> _onDeliveryAddressListInitialEvent(DeliveryAddressListInitialEvent event, Emitter<DeliveryAddresssListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "delivery_address_list"}, 'delivery_address_list_screen', 'delivery_address_list_screen');
      final double userLatitude = await _addressRepository.userLatitude();
      final double userLongitude = await _addressRepository.userLongitude();
      emit(state.copyWith(status: DeliveryAddresssListStatus.loading, restaurant: event.restaurant, latitude: userLatitude, longitude: userLongitude));
      final String uid = await _addressRepository.userId();
      UserAddressListFromRestaurantRequestModel param = UserAddressListFromRestaurantRequestModel(user: uid, restaurant: event.restaurant);
      DioApiResponse response = await _addressRepository.getMyAddressListFromRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        DeliveryAddressListFromCheckoutModel data = DeliveryAddressListFromCheckoutModel.fromJson(myMap);

        emit(state.copyWith(addresses: data, deliveryAddressId: event.deliveryAddressId, status: data.list!.isEmpty ? DeliveryAddresssListStatus.empty : DeliveryAddresssListStatus.success));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DeliveryAddresssListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliveryAddresssListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliveryAddresssRefreshEvent(DeliveryAddresssRefreshEvent event, Emitter<DeliveryAddresssListState> emit) async {
    try {
      emit(state.copyWith(status: DeliveryAddresssListStatus.loading));
      final String uid = await _addressRepository.userId();
      UserAddressListFromRestaurantRequestModel param = UserAddressListFromRestaurantRequestModel(user: uid, restaurant: state.restaurant);
      DioApiResponse response = await _addressRepository.getMyAddressListFromRestaurant(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        DeliveryAddressListFromCheckoutModel data = DeliveryAddressListFromCheckoutModel.fromJson(myMap);
        emit(state.copyWith(addresses: data, status: data.list!.isEmpty ? DeliveryAddresssListStatus.empty : DeliveryAddresssListStatus.success));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DeliveryAddresssListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DeliveryAddresssListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDeliveryAddressSelectEvent(DeliveryAddressSelectEvent event, Emitter<DeliveryAddresssListState> emit) async {
    final int index = state.addresses.list!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      if (double.parse(state.addresses.list![index].distance.toString()) <= double.parse(state.addresses.courage.toString())) {
        emit(state.copyWith(selectedIndex: index, status: DeliveryAddresssListStatus.selected));
      } else {
        emit(state.copyWith(status: DeliveryAddresssListStatus.failure, statusCode: 0, alertMessage: 'Can not deliver to this address', extraMessage: ''));
      }
    }
  }
}

