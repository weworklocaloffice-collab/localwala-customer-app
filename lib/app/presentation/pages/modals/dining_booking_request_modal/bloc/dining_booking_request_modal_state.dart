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

part of 'dining_booking_request_modal_bloc.dart';

enum DiningBookingRequestModalStatus { success, failure }

extension DiningBookingRequestModalStatusX on DiningBookingRequestModalStatus {
  bool get isSuccess => this == DiningBookingRequestModalStatus.success;
  bool get isFailure => this == DiningBookingRequestModalStatus.failure;
}

final class DiningBookingRequestModalState {
  final String instructions;
  final DiningBookingRequestModalStatus status;
  final String alertMessage;
  final String extraMessage;
  const DiningBookingRequestModalState({this.status = DiningBookingRequestModalStatus.success, this.instructions = '', this.alertMessage = '', this.extraMessage = ''});

  DiningBookingRequestModalState copyWith({String? instructions, DiningBookingRequestModalStatus? status, String? alertMessage, String? extraMessage}) {
    return DiningBookingRequestModalState(instructions: instructions ?? this.instructions, status: status ?? this.status, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

