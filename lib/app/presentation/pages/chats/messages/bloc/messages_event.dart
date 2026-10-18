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

sealed class MessagesEvent {}

final class MessagesInitialEvent extends MessagesEvent {
  final String receiverId;
  final String name;
  MessagesInitialEvent({required this.receiverId, required this.name});
}

final class MessagesSendNewMessageEvent extends MessagesEvent {
  String msg;
  MessagesSendNewMessageEvent({required this.msg});
}

final class MessageReceiveNewMessageEvent extends MessagesEvent {
  final ChatSocketIncomingMessageModel msg;
  MessageReceiveNewMessageEvent({required this.msg});
}

final class MessageReceiveLoadMoreEvent extends MessagesEvent {}

