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

part of 'delivery_instructions_modal_bloc.dart';

enum DeliveryInstructionsModalStatus { loading, success, failure, selected }

extension DeliveryInstructionsModalStatusX on DeliveryInstructionsModalStatus {
  bool get isLoading => this == DeliveryInstructionsModalStatus.loading;
  bool get isSuccess => this == DeliveryInstructionsModalStatus.success;
  bool get isFailure => this == DeliveryInstructionsModalStatus.failure;
  bool get isSelected => this == DeliveryInstructionsModalStatus.selected;
}

final class DeliveryInstructionsModalState {
  final String deliveryInstructionId;
  final String deliveryInstructionName;
  final String deliveryInstructionImage;
  final List<InstructionConfigModel> instructions;
  final String addressTitle;
  final String addressSubtitle;
  final DeliveryInstructionsModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DeliveryInstructionsModalState({
    this.deliveryInstructionId = '',
    this.deliveryInstructionName = '',
    this.deliveryInstructionImage = '',
    this.instructions = const [],
    this.addressTitle = '',
    this.addressSubtitle = '',
    this.status = DeliveryInstructionsModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DeliveryInstructionsModalState copyWith({
    String? deliveryInstructionId,
    String? deliveryInstructionName,
    String? deliveryInstructionImage,
    List<InstructionConfigModel>? instructions,
    String? addressTitle,
    String? addressSubtitle,
    DeliveryInstructionsModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DeliveryInstructionsModalState(
      deliveryInstructionId: deliveryInstructionId ?? this.deliveryInstructionId,
      deliveryInstructionName: deliveryInstructionName ?? this.deliveryInstructionName,
      deliveryInstructionImage: deliveryInstructionImage ?? this.deliveryInstructionImage,
      instructions: instructions ?? this.instructions,
      addressTitle: addressTitle ?? this.addressTitle,
      addressSubtitle: addressSubtitle ?? this.addressSubtitle,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

