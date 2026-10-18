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
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  LocationBloc() : super(const LocationState()) {
    on<LocationInitialEvent>(_onLocationInitialEvent);
    on<LocationFetchEvent>(_onLocatoinFetchEvent);
    on<LocationOpenSettingEvent>(_onLocationOpenSettingEvent);
  }

  FutureOr<void> _onLocationInitialEvent(LocationInitialEvent event, Emitter<LocationState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "location"}, 'location_screen', 'location_screen');
  }

  FutureOr<void> _onLocatoinFetchEvent(LocationFetchEvent event, Emitter<LocationState> emit) async {
    await Permission.location.status.then((value) async {
      if (value.isPermanentlyDenied) {
        emit(state.copyWith(status: LocationStatus.deniedForever));
      } else {
        try {
          emit(state.copyWith(status: LocationStatus.loading));
          await _determinePosition()
              .then((value) async {
                // Test //
                // await _locationRepository.saveLocation(-33.865143, 151.2099, '77 Mock Road, Docklands, Melbourne VIC 3008', 'Melbourne, Sydney');
                // emit(state.copyWith(status: LocationStatus.success));
                // Test //

                // Live //
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

                 _locationRepository.saveLocation(value.latitude, value.longitude, addressList.join(','), placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!);
                emit(state.copyWith(status: LocationStatus.success));
                // Live //
              })
              .catchError((error, stacktrace) {
                emit(state.copyWith(status: LocationStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                if (!kIsWeb) {
                  FirebaseCrashlytics.instance.recordError(error, stacktrace);
                }
              });
        } catch (e, stacktrace) {
          emit(state.copyWith(status: LocationStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
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

  FutureOr<void> _onLocationOpenSettingEvent(LocationOpenSettingEvent event, Emitter<LocationState> emit) async {
    await Geolocator.openLocationSettings();
  }
}

