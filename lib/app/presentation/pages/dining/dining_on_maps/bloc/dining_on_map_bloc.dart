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
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/google_direction_response_model.dart';
import 'package:user/app/core/models/near_me_dining_restaurant_on_map_response_model.dart';
import 'package:user/app/core/models/request/near_me_dining_restaurant_on_map_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'dining_on_map_event.dart';
part 'dining_on_map_state.dart';

class DiningOnMapBloc extends Bloc<DiningOnMapEvent, DiningOnMapState> {
  final LocationRepository _locationRepository = LocationRepository();
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  late BitmapDescriptor userIcon;
  late BitmapDescriptor restaurantIcon;
  DiningOnMapBloc() : super(DiningOnMapState(model: NearMeDiningRestaurantsOnMapResponseModel(locale: ''))) {
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)), AssetsUrl.imageURL.userMarkerColor).then((onValue) {
      userIcon = onValue;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)), AssetsUrl.imageURL.restaurantMarkerColor).then((onValue) {
      restaurantIcon = onValue;
    });
    on<DiningOnMapInitialEvent>(_onDiningOnMapInitialEvent);
    on<DiningOnMapDirectionEvent>(_onDiningOnMapDirectionEvent);
  }

  FutureOr<void> _onDiningOnMapInitialEvent(DiningOnMapInitialEvent event, Emitter<DiningOnMapState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "dining_maps"}, 'dining_restaurant_map_screen', 'dining_restaurant_map_screen');
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();
      emit(state.copyWith(status: DiningOnMapStatus.locationFetched, latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0));
      NearMeDiningRestaurantsOnMapRequestModel param = NearMeDiningRestaurantsOnMapRequestModel(latitude: userLatitude != 0 ? userLatitude : 0, longitude: userLongitude != 0 ? userLongitude : 0);
      DioApiResponse response = await _diningRepository.getDiningOnMaps(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DiningOnMapStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          NearMeDiningRestaurantsOnMapResponseModel diningResponse = NearMeDiningRestaurantsOnMapResponseModel.fromJson(myMap, locale.toString());
          diningResponse.dinings!.sort((a, b) => b.promote! ? 1 : -1);
          final Set<Marker> markersTemp = <Marker>{};
          final String userId = await _diningRepository.userId();
          markersTemp.add(
            Marker(
              markerId: MarkerId(userId),
              position: LatLng(userLatitude, userLongitude),
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: userIcon,
            ),
          );
          for (var element in diningResponse.dinings!) {
            markersTemp.add(
              Marker(
                markerId: MarkerId('${element.id}'),
                position: LatLng(element.location!.coordinates![1], element.location!.coordinates![0]),
                infoWindow: InfoWindow(title: '${element.name}'),
                icon: restaurantIcon,
              ),
            );
          }
          emit(state.copyWith(status: DiningOnMapStatus.success, model: diningResponse, markers: markersTemp));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningOnMapStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningOnMapStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningOnMapDirectionEvent(DiningOnMapDirectionEvent event, Emitter<DiningOnMapState> emit) async {
    try {
      final double userLatitude = await _locationRepository.userLatitude();
      final double userLongitude = await _locationRepository.userLongitude();

      final String restaurantId = state.model.dinings![event.diningIndex].id!;
      final double restLat = state.model.dinings![event.diningIndex].location!.coordinates![1];
      final double restLng = state.model.dinings![event.diningIndex].location!.coordinates![0];

      DioApiResponse response = await _diningRepository.googleDirection(userLatitude != 0 ? userLatitude : 0, userLongitude != 0 ? userLongitude : 0, restLat, restLng);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        GoogleDirectionResponseModel directionResponse = GoogleDirectionResponseModel.fromJson(myMap);
        if (directionResponse.routes!.isNotEmpty && directionResponse.routes![0].overviewPolyline!.points!.isNotEmpty) {
          final String routeLine = directionResponse.routes![0].overviewPolyline!.points!;
          final Set<Polyline> polyLines = <Polyline>{};
          polyLines.add(Polyline(polylineId: PolylineId(restaurantId), width: 10, points: convertToLatLng(decodePoly(routeLine)), color: ThemeProvider.primaryColor));
          emit(state.copyWith(polyline: polyLines, status: DiningOnMapStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningOnMapStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningOnMapStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  List<LatLng> convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List decodePoly(String poly) {
    var list = poly.codeUnits;
    List<double> lList = <double>[];
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);
    for (var i = 2; i < lList.length; i++) {
      lList[i] += lList[i - 2];
    }
    return lList;
  }
}

