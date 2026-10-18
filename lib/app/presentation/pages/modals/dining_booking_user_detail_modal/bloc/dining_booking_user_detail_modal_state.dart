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

part of 'dining_booking_user_detail_modal_bloc.dart';

final class DiningBookingUserDetailModalState {
  final DiningBookingEmailField userEmail;
  final DiningBookingNameField userName;
  final DiningBookingCountryCodeField userCountryCode;
  final String flag;
  final DiningBookingNumberField userContact;
  final bool isValid;
  final FormzSubmissionStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingUserDetailModalState({
    this.userEmail = const DiningBookingEmailField.pure(),
    this.userName = const DiningBookingNameField.pure(),
    this.userCountryCode = const DiningBookingCountryCodeField.pure(),
    this.flag = '',
    this.userContact = const DiningBookingNumberField.pure(),
    this.isValid = false,
    this.status = FormzSubmissionStatus.inProgress,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningBookingUserDetailModalState copyWith({
    DiningBookingEmailField? userEmail,
    DiningBookingNameField? userName,
    DiningBookingCountryCodeField? userCountryCode,
    String? flag,
    DiningBookingNumberField? userContact,
    bool? isValid,
    FormzSubmissionStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningBookingUserDetailModalState(
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userCountryCode: userCountryCode ?? this.userCountryCode,
      flag: flag ?? this.flag,
      userContact: userContact ?? this.userContact,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

