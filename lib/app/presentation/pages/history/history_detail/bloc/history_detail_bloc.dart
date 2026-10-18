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
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/call_number_fetched_response_model.dart';
import 'package:user/app/core/models/create_order_response_model.dart';
import 'package:user/app/core/models/google_direction_response_model.dart';
import 'package:user/app/core/models/order_detail_response_model.dart';
import 'package:user/app/core/models/request/cancel_my_order_request_model.dart';
import 'package:user/app/core/models/request/remove_favourite_order_request_model.dart';
import 'package:user/app/core/models/request/repay_pending_order_request_model.dart';
import 'package:user/app/core/models/request/save_favourite_order_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'history_detail_event.dart';
part 'history_detail_state.dart';

class HistoryDetailBloc extends Bloc<HistoryDetailEvent, HistoryDetailState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  late BitmapDescriptor userMarkerIcon;
  late BitmapDescriptor driverMarkerIcon;
  late BitmapDescriptor restaurantMarkerIcon;
  HistoryDetailBloc() : super(HistoryDetailState(orderDetail: OrderDetailResponseModel(locale: ''))) {
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)), AssetsUrl.iconsURL.driverMarker).then((onValue) {
      driverMarkerIcon = onValue;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)), AssetsUrl.iconsURL.restaurantMarker).then((onValue) {
      restaurantMarkerIcon = onValue;
    });
    BitmapDescriptor.asset(const ImageConfiguration(size: Size(50, 50)), AssetsUrl.iconsURL.userMarker).then((onValue) {
      userMarkerIcon = onValue;
    });
    on<HistoryDetailInitialEvent>(_onHistoryDetailInitialEvent);
    on<HistoryDetailRepayOrderEvent>(_onHistoryDetailRepayOrderEvent);
    on<HistoryDetailCancelMyOrderEvent>(_onHistoryDetailCancelMyOrderEvent);
    on<HistoryDetailOpenSettingEvent>(_onHistoryDetailOpenSettingEvent);
    on<HistoryDetailDirectionEvent>(_onHistoryDetailDirectionEvent);
    on<HistoryDetailFavouriteEvent>(_onHistoryDetailFavouriteEvent);
    on<HistoryDetailReviewSavedEvent>(_onHistoryDetailReviewSavedEvent);
    on<HistoryDetailPaymentChangedEvent>(_onHistoryDetailPaymentChangedEvent);
    on<HistoryDetailCallRestaurantEvent>(_onHistoryDetailCallRestaurantEvent);
    on<HistoryDetailCallDriverEvent>(_onHistoryDetailCallDriverEvent);
    on<HistoryDetailNewDeliverymanLocation>(_onHistoryDetailNewDeliverymanLocation);
  }

  FutureOr<void> _onHistoryDetailInitialEvent(HistoryDetailInitialEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_detail", "id": event.id}, 'order_detail_screen', 'order_detail_screen');
      emit(state.copyWith(status: HistoryDetailStatus.loading, orderId: event.id));
      final String userId = await _historyRepository.userId();
      DioApiResponse response = await _historyRepository.getOrderDetails(event.id, userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: HistoryDetailStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          OrderDetailResponseModel data = OrderDetailResponseModel.fromJson(myMap, locale.toString());
          HistoryDetailStatus viewStatus = HistoryDetailStatus.completedView;
          const newOrderStatus = ['created', 'accepted', 'preparing', 'ready'];
          const ongoingOrderStatus = ['handover', 'ongoing'];
          const completedOrderStatus = ['delivered', 'cancelled', 'rejected', 'refunded', 'partially_refunded', 'pending_payments'];
          if (newOrderStatus.contains(data.details!.status!)) {
            viewStatus = HistoryDetailStatus.newOrderView;
          } else if (ongoingOrderStatus.contains(data.details!.status!)) {
            viewStatus = HistoryDetailStatus.ongoingOrderStatus;
          } else if (completedOrderStatus.contains(data.details!.status!)) {
            viewStatus = HistoryDetailStatus.completedView;
          }
          if (data.details!.status! == 'pending_payments' && data.details!.timeDifferenceOfOrderInMinutes! <= Environments.payPendingAmountBeforeMinutesOffCreation) {
            String paymentId = '';
            String paymentName = 'Online Payment';
            String paymentImageUrl = '';
            // Single gateway decision: Razorpay online. Payment screen owns
            // method choice (UPI/Card/NB/Wallet/COD) — no pre-selector popup.
            final rzpIndex = data.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
            if (rzpIndex != -1) {
              paymentId = data.payments![rzpIndex].id!;
              paymentName = data.payments![rzpIndex].name!;
              paymentImageUrl = data.payments![rzpIndex].image!;
            } else if (data.primary != null && data.primary!.name!.isNotEmpty) {
              paymentId = data.primary!.id!;
              paymentName = data.primary!.name!;
              paymentImageUrl = data.primary!.image!;
            } else if (data.payments!.isNotEmpty) {
              paymentId = data.payments![0].id!;
              paymentName = data.payments![0].name!;
              paymentImageUrl = data.payments![0].image!;
            }
            emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, isPendingPaymentTimeOver: false));
          }
          final Set<Marker> markersLocal = <Marker>{};
          double currentUserLatitude = 0.0;
          double currentUserLongitude = 0.0;
          if (data.details!.orderTo == 'homedelivery') {
            markersLocal.add(
              Marker(
                markerId: MarkerId(data.details!.deliveryAddressRaw!.id!),
                position: LatLng(data.details!.deliveryAddressRaw!.location!.coordinates![1], data.details!.deliveryAddressRaw!.location!.coordinates![0]),
                infoWindow: const InfoWindow(title: 'Your Location'),
                icon: userMarkerIcon,
              ),
            );
            if (data.details!.driverInfo!.id!.isNotEmpty) {
              markersLocal.add(
                Marker(
                  markerId: MarkerId(data.details!.driverInfo!.id!),
                  position: LatLng(data.details!.driverInfo!.location!.coordinates![1], data.details!.driverInfo!.location!.coordinates![0]),
                  infoWindow: const InfoWindow(title: 'Driver Location'),
                  icon: driverMarkerIcon,
                ),
              );
            }
          } else {
            await Permission.location.status.then((value) async {
              if (value.isPermanentlyDenied) {
                emit(state.copyWith(status: HistoryDetailStatus.deniedForever));
              } else {
                try {
                  await _determinePosition()
                      .then((value) async {
                        currentUserLatitude = value.latitude;
                        currentUserLongitude = value.longitude;
                        markersLocal.add(
                          Marker(
                            markerId: MarkerId(event.id),
                            position: LatLng(value.latitude, value.longitude),
                            infoWindow: const InfoWindow(title: 'Your Location'),
                            icon: userMarkerIcon,
                          ),
                        );
                      })
                      .catchError((error, stacktrace) {
                        emit(state.copyWith(status: HistoryDetailStatus.failure, statusCode: 0, alertMessage: error.toString(), extraMessage: ''));
                        if (!kIsWeb) {
                          FirebaseCrashlytics.instance.recordError(error, stacktrace);
                        }
                      });
                } catch (e, stacktrace) {
                  emit(state.copyWith(status: HistoryDetailStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
                  if (!kIsWeb) {
                    FirebaseCrashlytics.instance.recordError(e, stacktrace);
                  }
                }
              }
            });
          }
          markersLocal.add(
            Marker(
              markerId: MarkerId(data.details!.restaurant!.id!),
              position: LatLng(data.details!.restaurant!.location!.coordinates![1], data.details!.restaurant!.location!.coordinates![0]),
              infoWindow: const InfoWindow(title: 'Restaurant Location'),
              icon: restaurantMarkerIcon,
            ),
          );
          if (viewStatus == HistoryDetailStatus.newOrderView) {
            if (data.details!.orderTo! == 'homedelivery') {
              add(
                HistoryDetailDirectionEvent(
                  startLatitude: data.details!.deliveryAddressRaw!.location!.coordinates![1],
                  startLongitude: data.details!.deliveryAddressRaw!.location!.coordinates![0],
                  endLatitude: data.details!.restaurant!.location!.coordinates![1],
                  endLongitude: data.details!.restaurant!.location!.coordinates![0],
                ),
              );
            } else {
              add(
                HistoryDetailDirectionEvent(
                  startLatitude: currentUserLatitude,
                  startLongitude: currentUserLongitude,
                  endLatitude: data.details!.restaurant!.location!.coordinates![1],
                  endLongitude: data.details!.restaurant!.location!.coordinates![0],
                ),
              );
            }
          } else if (viewStatus == HistoryDetailStatus.ongoingOrderStatus) {
            add(
              HistoryDetailDirectionEvent(
                startLatitude: data.details!.deliveryAddressRaw!.location!.coordinates![1],
                startLongitude: data.details!.deliveryAddressRaw!.location!.coordinates![0],
                endLatitude: data.details!.driverInfo!.location!.coordinates![1],
                endLongitude: data.details!.driverInfo!.location!.coordinates![0],
              ),
            );
          }
          emit(state.copyWith(orderDetail: data, status: viewStatus, markers: markersLocal, orderStatusName: titleize(data.details!.status!)));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HistoryDetailStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HistoryDetailStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
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

  String titleize(String slug) {
    List<String> words = slug.split('_');
    for (int i = 0; i < words.length; i++) {
      words[i] = '${words[i][0].toUpperCase()}${words[i].substring(1)}';
    }
    return words.join(' ');
  }

  FutureOr<void> _onHistoryDetailRepayOrderEvent(HistoryDetailRepayOrderEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      emit(state.copyWith(status: HistoryDetailStatus.repayOrderRequested));
      final String userId = await _historyRepository.userId();
      RepayPendingOrderRequestModel param = RepayPendingOrderRequestModel(userId: userId, orderId: state.orderId, payMethod: state.orderDetail.details!.paymentInfo!.id!, newPayMethod: state.newPaymentId);
      DioApiResponse response = await _historyRepository.repayPendingOrder(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        CreateOrderResponseModel orderResponse = CreateOrderResponseModel.fromJson(myMap);
        emit(state.copyWith(status: HistoryDetailStatus.repayOrderSuccess, paymentURL: orderResponse.payLink));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HistoryDetailStatus.repayOrderFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HistoryDetailStatus.repayOrderFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryDetailCancelMyOrderEvent(HistoryDetailCancelMyOrderEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      emit(state.copyWith(status: HistoryDetailStatus.cancelRequested));
      CancelMyOrderRequestModel param = CancelMyOrderRequestModel(orderId: state.orderId, reasonId: event.reasonId);
      DioApiResponse response = await _historyRepository.cancelMyOrder(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: HistoryDetailStatus.cancelSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: HistoryDetailStatus.cancelFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: HistoryDetailStatus.cancelFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryDetailOpenSettingEvent(HistoryDetailOpenSettingEvent event, Emitter<HistoryDetailState> emit) async {
    await Geolocator.openLocationSettings();
  }

  FutureOr<void> _onHistoryDetailDirectionEvent(HistoryDetailDirectionEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      DioApiResponse response = await _historyRepository.googleDirection(event.startLatitude, event.startLongitude, event.endLatitude, event.endLongitude);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        GoogleDirectionResponseModel directionResponse = GoogleDirectionResponseModel.fromJson(myMap);
        if (directionResponse.routes!.isNotEmpty && directionResponse.routes![0].overviewPolyline!.points!.isNotEmpty) {
          final String routeLine = directionResponse.routes![0].overviewPolyline!.points!;
          final Set<Polyline> polyLines = <Polyline>{};
          polyLines.add(Polyline(polylineId: PolylineId(state.orderId), width: 5, points: convertToLatLng(decodePoly(routeLine)), color: ThemeProvider.primaryColor, startCap: Cap.squareCap, endCap: Cap.squareCap));
          emit(state.copyWith(polyline: polyLines));
        }
      }
    } catch (e, stacktrace) {
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

  FutureOr<void> _onHistoryDetailFavouriteEvent(HistoryDetailFavouriteEvent event, Emitter<HistoryDetailState> emit) async {
    final HistoryDetailStatus oldStatus = state.status;
    try {
      final String userId = await _historyRepository.userId();
      if (state.orderDetail.details!.isFavouriteOrder!) {
        state.orderDetail.details!.isFavouriteOrder = !state.orderDetail.details!.isFavouriteOrder!;
        emit(state.copyWith(orderDetail: state.orderDetail));
        RemoveOrderFavouriteRequestModel param = RemoveOrderFavouriteRequestModel(user: userId, order: state.orderDetail.details!.id!);
        DioApiResponse response = await _historyRepository.removeOrderFavourite(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: HistoryDetailStatus.favouriteOrderChange));
          emit(state.copyWith(status: oldStatus));
        } else {
          state.orderDetail.details!.isFavouriteOrder = !state.orderDetail.details!.isFavouriteOrder!;
          emit(state.copyWith(orderDetail: state.orderDetail));
        }
      } else {
        state.orderDetail.details!.isFavouriteOrder = !state.orderDetail.details!.isFavouriteOrder!;
        emit(state.copyWith(orderDetail: state.orderDetail));
        SaveOrderFavouriteRequestModel param = SaveOrderFavouriteRequestModel(user: userId, order: state.orderDetail.details!.id!);
        DioApiResponse response = await _historyRepository.saveOrderFavourite(param);
        if (response.errorType == NetErrorType.none) {
          emit(state.copyWith(status: HistoryDetailStatus.favouriteOrderChange));
          emit(state.copyWith(status: oldStatus));
        } else {
          state.orderDetail.details!.isFavouriteOrder = !state.orderDetail.details!.isFavouriteOrder!;
          emit(state.copyWith(orderDetail: state.orderDetail));
        }
      }
    } catch (e, stacktrace) {
      state.orderDetail.details!.isFavouriteOrder = !state.orderDetail.details!.isFavouriteOrder!;
      emit(state.copyWith(orderDetail: state.orderDetail));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryDetailReviewSavedEvent(HistoryDetailReviewSavedEvent event, Emitter<HistoryDetailState> emit) async {
    state.orderDetail.details!.ratingSaved = true;
    emit(state.copyWith(orderDetail: state.orderDetail));
  }

  FutureOr<void> _onHistoryDetailPaymentChangedEvent(HistoryDetailPaymentChangedEvent event, Emitter<HistoryDetailState> emit) async {
    final int index = state.orderDetail.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.orderDetail.payments![index].id!;
      String paymentName = state.orderDetail.payments![index].name!;
      String paymentImageUrl = state.orderDetail.payments![index].image!;
      emit(state.copyWith(newPaymentId: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl));
    }
  }

  FutureOr<void> _onHistoryDetailCallRestaurantEvent(HistoryDetailCallRestaurantEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      emit(state.copyWith(callRestaurant: true));
      DioApiResponse response = await _historyRepository.fetchRestaurantCallNumber(state.orderDetail.details!.restaurant!.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(callRestaurant: false));
          CallNumberFetchedResponseModel callResponse = CallNumberFetchedResponseModel.fromJson(myMap);
          if (callResponse.detail!.contactInfo!.countryCode!.isNotEmpty && callResponse.detail!.contactInfo!.contactNumber!.isNotEmpty) {
            final Uri numberLaunchUri = Uri(scheme: 'tel', path: '${callResponse.detail!.contactInfo!.countryCode!}${callResponse.detail!.contactInfo!.contactNumber!}');
            launchUrl(numberLaunchUri);
          }
        }
      } else {
        emit(state.copyWith(callRestaurant: false));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(callRestaurant: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryDetailCallDriverEvent(HistoryDetailCallDriverEvent event, Emitter<HistoryDetailState> emit) async {
    try {
      emit(state.copyWith(callDriver: true));
      DioApiResponse response = await _historyRepository.fetchDriverCallNumber(state.orderDetail.details!.driverInfo!.id!);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(callDriver: false));
          CallNumberFetchedResponseModel callResponse = CallNumberFetchedResponseModel.fromJson(myMap);
          if (callResponse.detail!.contactInfo!.countryCode!.isNotEmpty && callResponse.detail!.contactInfo!.contactNumber!.isNotEmpty) {
            final Uri numberLaunchUri = Uri(scheme: 'tel', path: '${callResponse.detail!.contactInfo!.countryCode!}${callResponse.detail!.contactInfo!.contactNumber!}');
            launchUrl(numberLaunchUri);
          }
        }
      } else {
        emit(state.copyWith(callDriver: false));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(callDriver: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onHistoryDetailNewDeliverymanLocation(HistoryDetailNewDeliverymanLocation event, Emitter<HistoryDetailState> emit) async {
    state.markers.removeWhere((element) => element.markerId == MarkerId(state.orderDetail.details!.driverInfo!.id!));
    final Set<Marker> markersLocal = state.markers;
    markersLocal.add(
      Marker(
        markerId: MarkerId(state.orderDetail.details!.driverInfo!.id!),
        position: LatLng(event.latitude, event.longitude),
        infoWindow: const InfoWindow(title: 'Driver Location'),
        icon: driverMarkerIcon,
      ),
    );
    emit(state.copyWith(markers: markersLocal));
    add(
      HistoryDetailDirectionEvent(
        startLatitude: state.orderDetail.details!.deliveryAddressRaw!.location!.coordinates![1],
        startLongitude: state.orderDetail.details!.deliveryAddressRaw!.location!.coordinates![0],
        endLatitude: event.latitude,
        endLongitude: event.longitude,
      ),
    );
  }
}

