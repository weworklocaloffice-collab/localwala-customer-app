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

part of 'history_detail_bloc.dart';

enum HistoryDetailStatus {
  loading,
  failure,
  newOrderView,
  ongoingOrderStatus,
  completedView,
  repayOrderRequested,
  repayOrderSuccess,
  repayOrderFailed,
  cancelRequested,
  cancelSuccess,
  cancelFailed,
  deniedForever,
  favouriteOrderChange,
}

extension HistoryDetailStatusX on HistoryDetailStatus {
  bool get isLoading => this == HistoryDetailStatus.loading;
  bool get isFailure => this == HistoryDetailStatus.failure;
  bool get isNewOrderView => this == HistoryDetailStatus.newOrderView;
  bool get isOngoingOrderStatus => this == HistoryDetailStatus.ongoingOrderStatus;
  bool get isCompletedView => this == HistoryDetailStatus.completedView;
  bool get isRepayOrderRequested => this == HistoryDetailStatus.repayOrderRequested;
  bool get isRepayOrderSuccess => this == HistoryDetailStatus.repayOrderSuccess;
  bool get isRepayOrderFailed => this == HistoryDetailStatus.repayOrderFailed;
  bool get isCancelRequested => this == HistoryDetailStatus.cancelRequested;
  bool get isCancelSuccess => this == HistoryDetailStatus.cancelSuccess;
  bool get isCancelFailed => this == HistoryDetailStatus.cancelFailed;
  bool get isDeniedForever => this == HistoryDetailStatus.deniedForever;
  bool get isFavouriteOrderChange => this == HistoryDetailStatus.favouriteOrderChange;
}

final class HistoryDetailState {
  final String orderId;
  final OrderDetailResponseModel orderDetail;
  final bool isPendingPaymentTimeOver;
  final String orderStatusName;
  final String newPaymentId;
  final String paymentName;
  final String paymentImageURL;
  final String? paymentURL;
  final Set<Marker> markers;
  final Set<Polyline> polyline;
  final double mapZoomLevel;
  final bool? callRestaurant;
  final bool? callDriver;
  final HistoryDetailStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const HistoryDetailState({
    this.orderId = '',
    required this.orderDetail,
    this.isPendingPaymentTimeOver = true,
    this.orderStatusName = '',
    this.newPaymentId = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.paymentURL = '',
    this.markers = const <Marker>{},
    this.polyline = const <Polyline>{},
    this.mapZoomLevel = 13,
    this.callRestaurant = false,
    this.callDriver = false,
    this.status = HistoryDetailStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  HistoryDetailState copyWith({
    String? orderId,
    OrderDetailResponseModel? orderDetail,
    bool? isPendingPaymentTimeOver,
    String? orderStatusName,
    String? newPaymentId,
    String? paymentName,
    String? paymentImageURL,
    String? paymentURL,
    Set<Marker>? markers,
    Set<Polyline>? polyline,
    double? mapZoomLevel,
    bool? callRestaurant,
    bool? callDriver,
    HistoryDetailStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return HistoryDetailState(
      orderId: orderId ?? this.orderId,
      orderDetail: orderDetail ?? this.orderDetail,
      isPendingPaymentTimeOver: isPendingPaymentTimeOver ?? this.isPendingPaymentTimeOver,
      orderStatusName: orderStatusName ?? this.orderStatusName,
      newPaymentId: newPaymentId ?? this.newPaymentId,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      paymentURL: paymentURL ?? this.paymentURL,
      markers: markers ?? this.markers,
      polyline: polyline ?? this.polyline,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
      callRestaurant: callRestaurant ?? this.callRestaurant,
      callDriver: callDriver ?? this.callDriver,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

