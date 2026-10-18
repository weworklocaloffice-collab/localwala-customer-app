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

part of 'food_instructions_bloc.dart';

enum FoodInstructionsStatus { success, failure }

extension FoodInstructionsStatusX on FoodInstructionsStatus {
  bool get isSuccess => this == FoodInstructionsStatus.success;
  bool get isFailure => this == FoodInstructionsStatus.failure;
}

final class FoodInstructionsState {
  final String instructions;
  final FoodInstructionsStatus status;
  final String alertMessage;
  final String extraMessage;
  const FoodInstructionsState({this.status = FoodInstructionsStatus.success, this.instructions = '', this.alertMessage = '', this.extraMessage = ''});

  FoodInstructionsState copyWith({String? instructions, FoodInstructionsStatus? status, String? alertMessage, String? extraMessage}) {
    return FoodInstructionsState(instructions: instructions ?? this.instructions, status: status ?? this.status, alertMessage: alertMessage ?? this.alertMessage, extraMessage: extraMessage ?? this.extraMessage);
  }
}

