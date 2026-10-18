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
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/repositories/auth_repository.dart';

part 'new_address_map_event.dart';
part 'new_address_map_state.dart';

class NewAddressMapBloc extends Bloc<NewAddressMapEvent, NewAddressMapState> {
  final AuthRepository _authRepository = AuthRepository();
  NewAddressMapBloc() : super(const NewAddressMapState()) {
    on<NewAddressMapInitialEvent>(_onNewAddressMapInitialEvent);
    on<NewAddressMapOpenSettingEvent>(_onNewAddressMapOpenSettingEvent);
    on<NewAddressMapLocateMeEvent>(_onNewAddressMapLocateMeEvent);
    on<NewAddressMapPositionChangedEvent>(_onNewAddressMapPositionChangedEvent);
    on<NewAddressMapPositionEndedEvent>(_onNewAddressMapPositionEndedEvent);
  }

  FutureOr<void> _onNewAddressMapInitialEvent(NewAddressMapInitialEvent event, Emitter<NewAddressMapState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "address_maps"}, 'new_address_map_screen', 'new_address_map_screen');
    emit(state.copyWith(status: NewAddressMapStatus.loading, title: 'Fetching...', description: 'Fetching...'));
    if (event.isNew == true && event.fromDelivery == false) {
      await Permission.location.status.then((value) async {
        if (value.isPermanentlyDenied) {
          emit(state.copyWith(status: NewAddressMapStatus.deniedForever));
        } else {
          try {
            await _determinePosition()
                .then((value) async {
                  List<Placemark> newPlace = await placemarkFromCoordinates(value.latitude, value.longitude);
                  Placemark placeMark = newPlace[0];
                  List<String> addressList = <String>[];
                  addressList.clear();
                  addressList.add(placeMark.name.toString());
                  addressList.add(placeMark.subLocality.toString());
                  addressList.add(placeMark.locality.toString());
                  addressList.add(placeMark.administrativeArea.toString());
                  addressList.add(placeMark.country.toString());
                  addressList = addressList.where((element) => element != '').toList();
                  emit(
                    state.copyWith(
                      status: NewAddressMapStatus.sucess,
                      latitude: value.latitude,
                      longitude: value.longitude,
                      title: placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!,
                      description: addressList.join(','),
                    ),
                  );
                })
                .catchError((error, stacktrace) {
                  emit(state.copyWith(status: NewAddressMapStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                  if (!kIsWeb) {
                    FirebaseCrashlytics.instance.recordError(error, stacktrace);
                  }
                });
          } catch (e, stacktrace) {
            emit(state.copyWith(status: NewAddressMapStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
            if (!kIsWeb) {
              FirebaseCrashlytics.instance.recordError(e, stacktrace);
            }
          }
        }
      });
    } else if (event.isNew == true && event.fromDelivery == true) {
      emit(state.copyWith(status: NewAddressMapStatus.sucess, latitude: event.latitude, longitude: event.longitude, title: event.flatHouse, description: event.locality));
    } else {
      emit(
        state.copyWith(
          isNew: event.isNew,
          id: event.id,
          latitude: event.latitude,
          longitude: event.longitude,
          titleAddress: event.title,
          receiverName: event.receiverName,
          countryCode: event.countryCode,
          receiverNumber: event.receiverContact,
          houseName: event.flatHouse,
          locality: event.locality,
          landmark: event.landmark,
          status: NewAddressMapStatus.sucess,
          title: event.flatHouse,
          description: '${event.landmark}, ${event.locality}',
        ),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  FutureOr<void> _onNewAddressMapOpenSettingEvent(NewAddressMapOpenSettingEvent event, Emitter<NewAddressMapState> emit) async {
    await Geolocator.openLocationSettings();
  }

  FutureOr<void> _onNewAddressMapLocateMeEvent(NewAddressMapLocateMeEvent event, Emitter<NewAddressMapState> emit) async {
    await Permission.location.status.then((value) async {
      if (value.isPermanentlyDenied) {
        emit(state.copyWith(status: NewAddressMapStatus.deniedForever));
      } else {
        try {
          await _determinePosition()
              .then((value) async {
                List<Placemark> newPlace = await placemarkFromCoordinates(value.latitude, value.longitude);
                Placemark placeMark = newPlace[0];
                List<String> addressList = <String>[];
                addressList.clear();
                addressList.add(placeMark.name.toString());
                addressList.add(placeMark.subLocality.toString());
                addressList.add(placeMark.locality.toString());
                addressList.add(placeMark.administrativeArea.toString());
                addressList.add(placeMark.country.toString());
                addressList = addressList.where((element) => element != '').toList();

                emit(
                  state.copyWith(
                    status: NewAddressMapStatus.addressFetched,
                    latitude: value.latitude,
                    longitude: value.longitude,
                    title: placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!,
                    description: addressList.join(','),
                  ),
                );
              })
              .catchError((error, stacktrace) {
                emit(state.copyWith(status: NewAddressMapStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                if (!kIsWeb) {
                  FirebaseCrashlytics.instance.recordError(error, stacktrace);
                }
              });
        } catch (e, stacktrace) {
          emit(state.copyWith(status: NewAddressMapStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    });
  }

  FutureOr<void> _onNewAddressMapPositionChangedEvent(NewAddressMapPositionChangedEvent event, Emitter<NewAddressMapState> emit) async {
    emit(state.copyWith(latitude: event.latitude, longitude: event.longitude, status: NewAddressMapStatus.dragged));
  }

  FutureOr<void> _onNewAddressMapPositionEndedEvent(NewAddressMapPositionEndedEvent event, Emitter<NewAddressMapState> emit) async {
    try {
      List<Placemark> newPlace = await placemarkFromCoordinates(state.latitude, state.longitude);
      if (newPlace.isNotEmpty) {
        Placemark placeMark = newPlace[0];
        List<String> addressList = <String>[];
        addressList.clear();
        addressList.add(placeMark.name.toString());
        addressList.add(placeMark.subLocality.toString());
        addressList.add(placeMark.locality.toString());
        addressList.add(placeMark.administrativeArea.toString());
        addressList.add(placeMark.country.toString());
        addressList = addressList.where((element) => element != '').toList();
        emit(state.copyWith(status: NewAddressMapStatus.addressFetched, title: placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!, description: addressList.join(',')));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: NewAddressMapStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

