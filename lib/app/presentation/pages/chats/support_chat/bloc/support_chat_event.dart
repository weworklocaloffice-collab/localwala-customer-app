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

part of 'support_chat_bloc.dart';

sealed class SupportChatEvent {}

final class SupportChatInitialEvent extends SupportChatEvent {
  final String type;
  final String typeId;
  SupportChatInitialEvent({required this.type, required this.typeId});
}

final class SupportChatSendNewMessageEvent extends SupportChatEvent {
  String msg;
  String msgType;
  String? randomId;
  SupportChatSendNewMessageEvent({required this.msg, this.msgType = 'text', this.randomId});
}

/// Instant local bubble for a human-owned send. The server echo reconciles by
/// the same randomId, so this never becomes a second message.
final class SupportChatOptimisticSendEvent extends SupportChatEvent {
  final String message;
  final String randomId;
  final String msgType;
  SupportChatOptimisticSendEvent({required this.message, required this.randomId, this.msgType = 'text'});
}

/// Drop the local bubble when the socket reports a failed persist.
final class SupportChatSendFailedEvent extends SupportChatEvent {
  final String randomId;
  SupportChatSendFailedEvent({required this.randomId});
}

final class SupportChatReceiveNewMessageEvent extends SupportChatEvent {
  final ChatSocketIncomingMessageModel msg;
  SupportChatReceiveNewMessageEvent({required this.msg});
}

final class SupportChatReceiveLoadMoreEvent extends SupportChatEvent {}

/// Agent saw our messages (socket messageRead). Flips own ticks to read.
final class SupportChatReadReceiptEvent extends SupportChatEvent {}

/// Bot-first entry: opens the room and returns the bot's first answer.
final class SupportChatBotStartEvent extends SupportChatEvent {
  final String type;
  final String typeId;
  SupportChatBotStartEvent({required this.type, required this.typeId});
}

/// Customer turn. The bot answers; if it cannot, the server hands the ticket to
/// a human automatically and this state carries the agent name back.
final class SupportChatBotMessageEvent extends SupportChatEvent {
  final String message;
  SupportChatBotMessageEvent({required this.message});
}

/// Explicit "talk to a human" — skips the bot entirely.
final class SupportChatHandoverEvent extends SupportChatEvent {
  final String reason;
  SupportChatHandoverEvent({this.reason = 'user-request'});
}

/// Post-resolution rating.
final class SupportChatCsatEvent extends SupportChatEvent {
  final int score;
  final String comment;
  SupportChatCsatEvent({required this.score, this.comment = ''});
}

/// Reopens the customer's own resolved ticket (48h window, server-enforced).
/// Continues the same thread instead of forking a duplicate ticket.
final class SupportChatReopenEvent extends SupportChatEvent {}

