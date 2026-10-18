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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/core/models/local_search_history_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'location_maps_event.dart';
part 'location_maps_state.dart';

class LocationMapsBloc extends Bloc<LocationMapsEvent, LocationMapsState> {
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  LocationMapsBloc() : super(const LocationMapsState()) {
    on<LocationMapInitialEvent>(_onLocationMapInitialEvent);
    on<LocationMapPositionChangedEvent>(_onLocationMapPositionChangedEvent);
    on<LocationMapPositionEndedEvent>(_onLocationMapPositionEndedEvent);
    on<LocationMapsConfirmEvent>(_onLocationMapsConfirmEvent);
    on<LocationMapsLocateMeEvent>(_onLocationMapsLocateMeEvent);
    on<LocationMapsOpenSettingEvent>(_onLocationMapsOpenSettingEvent);
  }

  FutureOr<void> _onLocationMapInitialEvent(LocationMapInitialEvent event, Emitter<LocationMapsState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "location_map"}, 'location_maps_screen', 'location_maps_screen');
      emit(state.copyWith(status: LocationMapsStatus.initial, latitude: event.latitude, longitude: event.longitude, placeId: event.placeId, title: event.title, description: event.description));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LocationMapsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLocationMapPositionChangedEvent(LocationMapPositionChangedEvent event, Emitter<LocationMapsState> emit) async {
    emit(state.copyWith(latitude: event.latitude, longitude: event.longitude, status: LocationMapsStatus.dragged));
  }

  FutureOr<void> _onLocationMapPositionEndedEvent(LocationMapPositionEndedEvent event, Emitter<LocationMapsState> emit) async {
    emit(state.copyWith(status: LocationMapsStatus.loading));
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
        emit(state.copyWith(status: LocationMapsStatus.loaded, title: placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!, description: addressList.join(',')));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LocationMapsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLocationMapsConfirmEvent(LocationMapsConfirmEvent event, Emitter<LocationMapsState> emit) async {
    await _locationRepository.getLocalSearchHistory().then((history) async {
      int index = history.indexWhere((obj) => obj.placeId == state.placeId);
      if (index != -1) {
        LocalSearchHistoryModel updateItem = LocalSearchHistoryModel(description: state.description, mainText: state.title, latitude: state.latitude, longitude: state.longitude);
        history[index] = updateItem;
      }
      await _locationRepository.saveLocalSearchHistory(history);
      await _locationRepository.saveLocation(state.latitude, state.longitude, state.description, state.title);
      emit(state.copyWith(status: LocationMapsStatus.confirm));
    });
  }

  FutureOr<void> _onLocationMapsLocateMeEvent(LocationMapsLocateMeEvent event, Emitter<LocationMapsState> emit) async {
    await Permission.location.status.then((value) async {
      if (value.isPermanentlyDenied) {
        emit(state.copyWith(status: LocationMapsStatus.deniedForever));
      } else {
        try {
          emit(state.copyWith(status: LocationMapsStatus.dragged));
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
                    status: LocationMapsStatus.current,
                    latitude: value.latitude,
                    longitude: value.longitude,
                    title: placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!,
                    description: addressList.join(','),
                  ),
                );
              })
              .catchError((error, stacktrace) {
                emit(state.copyWith(status: LocationMapsStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                if (!kIsWeb) {
                  FirebaseCrashlytics.instance.recordError(error, stacktrace);
                }
              });
        } catch (e, stacktrace) {
          emit(state.copyWith(status: LocationMapsStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    });
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

  FutureOr<void> _onLocationMapsOpenSettingEvent(LocationMapsOpenSettingEvent event, Emitter<LocationMapsState> emit) async {
    await Geolocator.openLocationSettings();
  }
}

