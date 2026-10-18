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

part of 'messages_bloc.dart';

enum MessagesStatus { loading, chatInitialize, failure, customError, loadMoreStart, loadMoreEnd, scrollDown }

extension MessagesStatusX on MessagesStatus {
  bool get isLoading => this == MessagesStatus.loading;
  bool get isChatInitialize => this == MessagesStatus.chatInitialize;
  bool get isFailure => this == MessagesStatus.failure;
  bool get isCustomError => this == MessagesStatus.customError;
  bool get isLoadMoreStart => this == MessagesStatus.loadMoreStart;
  bool get isLoadMoreEnd => this == MessagesStatus.loadMoreEnd;
  bool get isScrollDown => this == MessagesStatus.scrollDown;
}

final class MessagesState {
  final ChatMessagesResponseModel model;
  final String chatRoomId;
  final String userId;
  final String authRole;
  final String name;
  final String senderFirstName;
  final String senderLastName;
  final String senderCover;
  final int pageSize;
  final int currentPage;
  final bool loadMore;
  final MessagesStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const MessagesState({
    required this.model,
    this.chatRoomId = '',
    this.userId = '',
    this.authRole = '',
    this.name = '',
    this.senderFirstName = '',
    this.senderLastName = '',
    this.senderCover = '',
    required this.pageSize,
    this.currentPage = 0,
    this.loadMore = false,
    this.status = MessagesStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  MessagesState copyWith({
    ChatMessagesResponseModel? model,
    String? chatRoomId,
    String? userId,
    String? authRole,
    String? name,
    String? senderFirstName,
    String? senderLastName,
    String? senderCover,
    int? pageSize,
    int? currentPage,
    bool? loadMore,
    MessagesStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return MessagesState(
      model: model ?? this.model,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      authRole: authRole ?? this.authRole,
      name: name ?? this.name,
      senderFirstName: senderFirstName ?? this.senderFirstName,
      senderLastName: senderLastName ?? this.senderLastName,
      senderCover: senderCover ?? this.senderCover,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

