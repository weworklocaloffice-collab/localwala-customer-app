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

part of 'address_book_bloc.dart';

enum AddressBookStatus { loading, empty, success, failure, unAuthorized }

extension AddressBookStatusX on AddressBookStatus {
  bool get isLoading => this == AddressBookStatus.loading;
  bool get isEmpty => this == AddressBookStatus.empty;
  bool get isSuccess => this == AddressBookStatus.success;
  bool get isFailure => this == AddressBookStatus.failure;
  bool get isUnAuthorizd => this == AddressBookStatus.unAuthorized;
}

final class AddressBookState {
  final MyAddressListResponseModel addresses;
  final AddressBookStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const AddressBookState({required this.addresses, this.status = AddressBookStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  AddressBookState copyWith({MyAddressListResponseModel? addresses, AddressBookStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return AddressBookState(
      addresses: addresses ?? this.addresses,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

