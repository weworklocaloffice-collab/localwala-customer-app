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

enum SupportChatStatus { loading, chatInitialize, failure, customError, loadMoreStart, loadMoreEnd, scrollDown, botThinking, botReplied }

extension SupportChatStatusX on SupportChatStatus {
  bool get isLoading => this == SupportChatStatus.loading;
  bool get isChatInitialize => this == SupportChatStatus.chatInitialize;
  bool get isFailure => this == SupportChatStatus.failure;
  bool get isCustomError => this == SupportChatStatus.customError;
  bool get isLoadMoreStart => this == SupportChatStatus.loadMoreStart;
  bool get isLoadMoreEnd => this == SupportChatStatus.loadMoreEnd;
  bool get isScrollDown => this == SupportChatStatus.scrollDown;
  /// Waiting on the bot. Distinct from `isLoading` so the transcript stays
  /// visible instead of being replaced by a spinner.
  bool get isBotThinking => this == SupportChatStatus.botThinking;
  bool get isBotReplied => this == SupportChatStatus.botReplied;
}

final class SupportChatState {
  final String chatRoomId;
  final String userId;
  final String authRole;
  final String name;
  final String senderFirstName;
  final String senderLastName;
  final String senderCover;
  final int pageSize;
  final int currentPage;
  final SupportChatMessageResponseModel model;
final bool loadMore;
  final SupportChatStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  // --- Enterprise: bot-first -> human handover ---
  /// bot | queued | assigned | human | resolved. Drives the header copy.
  final String handoverState;
  /// Name shown once a human is attached; empty while the bot is handling it.
  final String agentName;
  /// Agent avatar URL for the joined banner; empty falls back to initials.
  final String agentAvatar;
  /// 1-based backlog position, 0 when not queued.
  final int queuePosition;
  /// Live order card the bot resolved from the DB.
  final Map<String, dynamic>? orderSnapshot;
  /// Server-driven quick replies for this turn (single source of truth).
  /// Empty until the first bot turn; view falls back to snapshot chooser.
  final List<String> botActions;
  /// Server-driven human-state chips (label+message pairs from audience:
  /// customer canned replies). Empty until fetched; view falls back to the
  /// built-in status-aware set.
  final List<Map<String, String>> humanChips;
  /// Subject entity id (order/booking) for in-chat order actions.
  final String subjectId;
  final bool botHandled;
  /// CSAT recorded for this ticket.
  final int csatScore;
  const SupportChatState({
    this.chatRoomId = '',
    this.userId = '',
    this.authRole = '',
    this.name = '',
    this.senderFirstName = '',
    this.senderLastName = '',
    this.senderCover = '',
    required this.pageSize,
    this.currentPage = 0,
    required this.model,
    this.loadMore = false,
    this.status = SupportChatStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
    this.handoverState = 'bot',
    this.agentName = '',
    this.agentAvatar = '',
    this.queuePosition = 0,
    this.orderSnapshot,
    this.botActions = const [],
    this.humanChips = const [],
    this.subjectId = '',
    this.botHandled = false,
    this.csatScore = 0,
  });

  SupportChatState copyWith({
    String? chatRoomId,
    String? userId,
    String? authRole,
    String? name,
    String? senderFirstName,
    String? senderLastName,
    String? senderCover,
    int? pageSize,
    int? currentPage,
    SupportChatMessageResponseModel? model,
    bool? loadMore,
    SupportChatStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
    String? handoverState,
    String? agentName,
    String? agentAvatar,
    int? queuePosition,
    Map<String, dynamic>? orderSnapshot,
    List<String>? botActions,
    List<Map<String, String>>? humanChips,
    String? subjectId,
    bool? botHandled,
    int? csatScore,
  }) {
    return SupportChatState(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      authRole: authRole ?? this.authRole,
      name: name ?? this.name,
      senderFirstName: senderFirstName ?? this.senderFirstName,
      senderLastName: senderLastName ?? this.senderLastName,
      senderCover: senderCover ?? this.senderCover,
      pageSize: pageSize ?? this.pageSize,
      currentPage: currentPage ?? this.currentPage,
      model: model ?? this.model,
      loadMore: loadMore ?? this.loadMore,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
      handoverState: handoverState ?? this.handoverState,
      agentName: agentName ?? this.agentName,
      agentAvatar: agentAvatar ?? this.agentAvatar,
      queuePosition: queuePosition ?? this.queuePosition,
      orderSnapshot: orderSnapshot ?? this.orderSnapshot,
      botActions: botActions ?? this.botActions,
      humanChips: humanChips ?? this.humanChips,
      subjectId: subjectId ?? this.subjectId,
      botHandled: botHandled ?? this.botHandled,
      csatScore: csatScore ?? this.csatScore,
    );
  }
}

