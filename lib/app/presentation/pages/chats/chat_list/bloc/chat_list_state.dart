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

part of 'chat_list_bloc.dart';

enum ChatListStatus { loading, empty, success, failure, unAuthorized }

extension ChatListStatusX on ChatListStatus {
  bool get isLoading => this == ChatListStatus.loading;
  bool get isSuccess => this == ChatListStatus.success;
  bool get isFailure => this == ChatListStatus.failure;
  bool get isEmpty => this == ChatListStatus.empty;
  bool get isUnAuthorized => this == ChatListStatus.unAuthorized;
}

final class ChatListState {
  final MyChatListResponseModel model;
  final String userId;
  final ChatListStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ChatListState({required this.model, this.userId = '', this.status = ChatListStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  ChatListState copyWith({MyChatListResponseModel? model, String? userId, ChatListStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return ChatListState(
      model: model ?? this.model,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

