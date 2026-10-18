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

part of 'support_chat_list_bloc.dart';

enum SupportChatListStatus { loading, empty, success, failure, unAuthorized }

extension SupportChatListStatusX on SupportChatListStatus {
  bool get isLoading => this == SupportChatListStatus.loading;
  bool get isSuccess => this == SupportChatListStatus.success;
  bool get isFailure => this == SupportChatListStatus.failure;
  bool get isEmpty => this == SupportChatListStatus.empty;
  bool get isUnAuthorized => this == SupportChatListStatus.unAuthorized;
}

final class SupportChatListState {
  final String userId;
  final MySupportChatListResponseModel model;
  final SupportChatListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const SupportChatListState({this.userId = '', required this.model, this.status = SupportChatListStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  SupportChatListState copyWith({String? userId, MySupportChatListResponseModel? model, SupportChatListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return SupportChatListState(
      userId: userId ?? this.userId,
      model: model ?? this.model,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

