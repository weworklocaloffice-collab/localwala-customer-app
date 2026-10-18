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

part of 'confirm_pre_booking_table_bloc.dart';

enum ConfirmPreBookingTableStatus { loading, success, failure, customError, makeBooking, bookingPlaced, makePayment }

extension ConfirmPreBookingTableStatusX on ConfirmPreBookingTableStatus {
  bool get isLoading => this == ConfirmPreBookingTableStatus.loading;
  bool get isSuccess => this == ConfirmPreBookingTableStatus.success;
  bool get isFailure => this == ConfirmPreBookingTableStatus.failure;
  bool get isCustomError => this == ConfirmPreBookingTableStatus.customError;
  bool get isMakeBooking => this == ConfirmPreBookingTableStatus.makeBooking;
  bool get isMakePayment => this == ConfirmPreBookingTableStatus.makePayment;
  bool get isBookingPlaced => this == ConfirmPreBookingTableStatus.bookingPlaced;
}

final class ConfirmPreBookingTableState {
  final String restaurant;
  final String selectedDate;
  final String formatedDate;
  final int selectedGuest;
  final String selectedSlot;
  final String selectedCoupon;
  final String userName;
  final String userContryCode;
  final String userContact;
  final String userEmail;
  final bool isValid;
  final DiningBookingConfirmResponseModel model;
  final double grandTotal;
  final String payment;
  final String paymentName;
  final String paymentImageURL;
  final String userSpecialRequest;
  final String paymentURL;
  final String campaignId;
  final ConfirmPreBookingTableStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ConfirmPreBookingTableState({
    this.restaurant = '',
    this.selectedDate = '',
    this.formatedDate = '',
    this.selectedGuest = 0,
    this.selectedSlot = '',
    this.selectedCoupon = '',
    this.userName = '',
    this.userContryCode = '',
    this.userContact = '',
    this.userEmail = '',
    this.isValid = false,
    required this.model,
    this.grandTotal = 0.0,
    this.payment = '',
    this.paymentName = '',
    this.paymentImageURL = '',
    this.userSpecialRequest = '',
    this.paymentURL = '',
    this.campaignId = '',
    this.status = ConfirmPreBookingTableStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ConfirmPreBookingTableState copyWith({
    String? restaurant,
    String? selectedDate,
    String? formatedDate,
    int? selectedGuest,
    String? selectedSlot,
    String? selectedCoupon,
    String? userName,
    String? userContryCode,
    String? userContact,
    String? userEmail,
    bool? isValid,
    DiningBookingConfirmResponseModel? model,
    double? grandTotal,
    String? payment,
    String? paymentName,
    String? paymentImageURL,
    String? userSpecialRequest,
    String? paymentURL,
    String? campaignId,
    ConfirmPreBookingTableStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ConfirmPreBookingTableState(
      restaurant: restaurant ?? this.restaurant,
      selectedDate: selectedDate ?? this.selectedDate,
      formatedDate: formatedDate ?? this.formatedDate,
      selectedGuest: selectedGuest ?? this.selectedGuest,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      selectedCoupon: selectedCoupon ?? this.selectedCoupon,
      userName: userName ?? this.userName,
      userContryCode: userContryCode ?? this.userContryCode,
      userContact: userContact ?? this.userContact,
      userEmail: userEmail ?? this.userEmail,
      isValid: isValid ?? this.isValid,
      model: model ?? this.model,
      grandTotal: grandTotal ?? this.grandTotal,
      payment: payment ?? this.payment,
      paymentName: paymentName ?? this.paymentName,
      paymentImageURL: paymentImageURL ?? this.paymentImageURL,
      userSpecialRequest: userSpecialRequest ?? this.userSpecialRequest,
      paymentURL: paymentURL ?? this.paymentURL,
      campaignId: campaignId ?? this.campaignId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

