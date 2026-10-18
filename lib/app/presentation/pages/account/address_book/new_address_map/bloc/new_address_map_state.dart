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

part of 'new_address_map_bloc.dart';

enum NewAddressMapStatus { loading, sucess, addressFetched, dragged, failure, deniedForever, confirm }

extension NewAddressMapStatusX on NewAddressMapStatus {
  bool get isLoading => this == NewAddressMapStatus.loading;
  bool get isSuccess => this == NewAddressMapStatus.sucess;
  bool get isAddressFetched => this == NewAddressMapStatus.addressFetched;
  bool get isDragged => this == NewAddressMapStatus.dragged;
  bool get isFailure => this == NewAddressMapStatus.failure;
  bool get isDeniedForever => this == NewAddressMapStatus.deniedForever;
  bool get isConfirm => this == NewAddressMapStatus.confirm;
}

final class NewAddressMapState {
  final String id;
  final bool isNew;
  final String receiverName;
  final String countryCode;
  final String receiverNumber;
  final String houseName;
  final String locality;
  final String landmark;
  final int titleAddress;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final bool updated;
  final NewAddressMapStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const NewAddressMapState({
    this.id = '',
    this.isNew = true,
    this.receiverName = '',
    this.countryCode = '',
    this.receiverNumber = '',
    this.houseName = '',
    this.locality = '',
    this.landmark = '',
    this.titleAddress = 0,
    this.latitude = 21.5346,
    this.longitude = 71.8275,
    this.title = '',
    this.description = '',
    this.updated = false,
    this.status = NewAddressMapStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  NewAddressMapState copyWith({
    String? id,
    bool? isNew,
    String? receiverName,
    String? countryCode,
    String? receiverNumber,
    String? houseName,
    String? locality,
    String? landmark,
    int? titleAddress,
    double? latitude,
    double? longitude,
    String? title,
    String? description,
    bool? updated,
    NewAddressMapStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return NewAddressMapState(
      id: id ?? this.id,
      isNew: isNew ?? this.isNew,
      receiverName: receiverName ?? this.receiverName,
      countryCode: countryCode ?? this.countryCode,
      receiverNumber: receiverNumber ?? this.receiverNumber,
      houseName: houseName ?? this.houseName,
      locality: locality ?? this.locality,
      landmark: landmark ?? this.landmark,
      titleAddress: titleAddress ?? this.titleAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      description: description ?? this.description,
      updated: updated ?? this.updated,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

