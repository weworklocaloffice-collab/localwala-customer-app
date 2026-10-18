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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/address_list_response_model.dart';
import 'package:user/app/core/models/google_places_result_model.dart';
import 'package:user/app/core/models/local_search_history_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'location_search_event.dart';
part 'location_search_state.dart';

class LocationSearchBloc extends Bloc<LocationSearchEvent, LocationSearchState> {
  final LocationRepository _locationRepository = LocationRepository();
  final AuthRepository _authRepository = AuthRepository();
  Timer? _debounce;

  LocationSearchBloc() : super(LocationSearchState(addresses: MyAddressListResponseModel(list: [], total: 0))) {
    on<LocationSearchInitialEvent>(_onLocationSearchInitialEvent);
    on<LocationSearchInputEvent>(_onLocationSearchInputEvent);
    on<LocationSearchLocalSelectEvent>(_onLocationSearchLocalSelectEvent);
    on<LocationSearchSelectEvent>(_onLocationSearchSelectEvent);
    on<LocationSearchLiveLocationEvent>(_onLocationSearchLiveLocationEvent);
    on<LocationSearchOpenSettingEvent>(_onLocationSearchOpenSettingEvent);
    on<LocationSearchSavedAddressEvent>(_onLocationSearchSavedAddressEvent);
    on<LocationSearchExecuteEvent>(_onLocationSearchExecuteEvent);
  }

  FutureOr<void> _onLocationSearchInitialEvent(LocationSearchInitialEvent event, Emitter<LocationSearchState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "location_search"}, 'location_search_screen', 'location_search_screen');
    await _locationRepository.getLocalSearchHistory().then((history) {
      emit(state.copyWith(localHistory: history));
    });
    try {
      final String uid = await _locationRepository.userId();
      if (uid.isNotEmpty) {
        DioApiResponse response = await _locationRepository.getMyAddressList(uid);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          MyAddressListResponseModel data = MyAddressListResponseModel.fromJson(myMap);
          emit(state.copyWith(addresses: data));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLocationSearchInputEvent(LocationSearchInputEvent event, Emitter<LocationSearchState> emit) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      add(LocationSearchExecuteEvent(query: event.searchText));
    });
  }

  FutureOr<void> _onLocationSearchLocalSelectEvent(LocationSearchLocalSelectEvent event, Emitter<LocationSearchState> emit) async {
    try {
      await _locationRepository.saveLocation(event.localResult.latitude!, event.localResult.longitude!, event.localResult.description!, event.localResult.mainText!);
      emit(state.copyWith(status: LocationSearchStatus.historySelected, latitude: event.localResult.latitude, longitude: event.localResult.longitude, placeId: event.localResult.placeId));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLocationSearchSelectEvent(LocationSearchSelectEvent event, Emitter<LocationSearchState> emit) async {
    try {
      List<Location> locations = await locationFromAddress(event.predictions.description!);
      if (locations.isNotEmpty) {
        LocalSearchHistoryModel newItem = LocalSearchHistoryModel(
          description: event.predictions.description,
          mainText: event.predictions.structuredFormatting!.mainText!,
          placeId: event.predictions.placeId,
          latitude: locations[0].latitude,
          longitude: locations[0].longitude,
        );
        state.localHistory.add(newItem);
        final ids = state.localHistory.map((e) => e.placeId).toSet();
        state.localHistory.retainWhere((element) => ids.remove(element.placeId));
        await _locationRepository.saveLocalSearchHistory(state.localHistory);
        emit(
          state.copyWith(
            status: LocationSearchStatus.selected,
            placeId: event.predictions.placeId,
            latitude: locations[0].latitude,
            longitude: locations[0].longitude,
            title: event.predictions.structuredFormatting!.mainText!,
            description: event.predictions.description,
          ),
        );
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLocationSearchLiveLocationEvent(LocationSearchLiveLocationEvent event, Emitter<LocationSearchState> emit) async {
    await Permission.location.status.then((value) async {
      if (value.isPermanentlyDenied) {
        emit(state.copyWith(status: LocationSearchStatus.deniedForever));
      } else {
        try {
          emit(state.copyWith(status: LocationSearchStatus.liveLoading));
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

                await _locationRepository.saveLocation(value.latitude, value.longitude, addressList.join(','), placeMark.subLocality!.isNotEmpty ? placeMark.subLocality! : placeMark.name!);
                emit(state.copyWith(status: LocationSearchStatus.success));
              })
              .catchError((error, stacktrace) {
                emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                if (!kIsWeb) {
                  FirebaseCrashlytics.instance.recordError(error, stacktrace);
                }
              });
        } catch (e, stacktrace) {
          emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
          if (!kIsWeb) {
            FirebaseCrashlytics.instance.recordError(e, stacktrace);
          }
        }
      }
    });
  }

  FutureOr<void> _onLocationSearchOpenSettingEvent(LocationSearchOpenSettingEvent event, Emitter<LocationSearchState> emit) async {
    await Geolocator.openLocationSettings();
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

  FutureOr<void> _onLocationSearchSavedAddressEvent(LocationSearchSavedAddressEvent event, Emitter<LocationSearchState> emit) async {
    await _locationRepository.saveDeliveryLocation(
      event.result.location!.coordinates![1],
      event.result.location!.coordinates![0],
      '${event.result.flatHouse!}, ${event.result.locality!}, ${event.result.landmark!}',
      event.result.title!.toString(),
      event.result.id!,
    );
    emit(state.copyWith(status: LocationSearchStatus.success));
  }

  FutureOr<void> _onLocationSearchExecuteEvent(LocationSearchExecuteEvent event, Emitter<LocationSearchState> emit) async {
    if (event.query.isNotEmpty) {
      try {
        emit(state.copyWith(status: LocationSearchStatus.loading));
        DioApiResponse response = await _locationRepository.getGooglePlacesResults(event.query);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          GooglePlacesModel data = GooglePlacesModel.fromJson(myMap);
          if (data.status == 'OK' && data.predictions!.isNotEmpty) {
            emit(state.copyWith(status: LocationSearchStatus.listed, predictions: data.predictions!));
          } else {
            emit(state.copyWith(status: LocationSearchStatus.listed, predictions: [...[]]));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LocationSearchStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    } else {
      emit(state.copyWith(predictions: [...[]]));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

