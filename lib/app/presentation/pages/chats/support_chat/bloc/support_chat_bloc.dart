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

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/chat_socket_incoming_message_model.dart';
import 'package:user/app/core/models/request/load_more_chat_conversion_request_model.dart';
import 'package:user/app/core/models/request/send_chat_message_request_model.dart';
import 'package:user/app/core/models/request/support_chat_convertion_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/support_chat_message_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'support_chat_event.dart';
part 'support_chat_state.dart';

class SupportChatBloc extends Bloc<SupportChatEvent, SupportChatState> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthRepository _authRepository = AuthRepository();
  // Last bot ticket for history refetch (bot replies must render).
  String _botType = '';
  String _botTypeId = '';

  /// Bot realism: keep the typing indicator visible at least this long so
  /// instant answers read as typed, not pasted. Fire-and-forget safe.
  static const Duration _minBotThinking = Duration(milliseconds: 1200);

  Future<void> _settleBotThinking(DateTime started) async {
    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minBotThinking) {
      await Future.delayed(_minBotThinking - elapsed);
    }
  }
  SupportChatBloc()
    : super(
        SupportChatState(
          pageSize: ApiRequestService.pageSize,
          model: SupportChatMessageResponseModel(chats: []),
        ),
      ) {
    on<SupportChatInitialEvent>(_onSupportChatInitialEvent);
    on<SupportChatSendNewMessageEvent>(_onSupportChatSendNewMessageEvent);
    on<SupportChatOptimisticSendEvent>(_onSupportChatOptimisticSendEvent);
    on<SupportChatSendFailedEvent>(_onSupportChatSendFailedEvent);
    on<SupportChatReceiveNewMessageEvent>(_onSupportChatReceiveNewMessageEvent);
    on<SupportChatReadReceiptEvent>(_onSupportChatReadReceiptEvent);
on<SupportChatReceiveLoadMoreEvent>(_onSupportChatReceiveLoadMoreEvent);
    on<SupportChatBotStartEvent>(_onSupportChatBotStartEvent);
    on<SupportChatBotMessageEvent>(_onSupportChatBotMessageEvent);
    on<SupportChatHandoverEvent>(_onSupportChatHandoverEvent);
    on<SupportChatCsatEvent>(_onSupportChatCsatEvent);
    on<SupportChatReopenEvent>(_onSupportChatReopenEvent);
  }

  FutureOr<void> _onSupportChatInitialEvent(SupportChatInitialEvent event, Emitter<SupportChatState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "support_chat_messages"}, 'support_chat_message_screen', 'support_chat_message_screen');
      final String userId = await _chatRepository.userId();
      final String authRole = await _chatRepository.authRole();
      final String firstName = await _chatRepository.firstName();
      final String lastName = await _chatRepository.lastName();
      final String userCover = await _chatRepository.userCover();
      emit(state.copyWith(status: SupportChatStatus.loading, userId: userId.toString(), authRole: authRole.toString(), senderFirstName: firstName, senderLastName: lastName, senderCover: userCover));
      SupportChatConvertionRequestModel param = SupportChatConvertionRequestModel(user: userId.toString(), type: event.type, typeId: event.typeId, page: state.currentPage, limit: state.pageSize);
      DioApiResponse response = await _chatRepository.fetchSupportChatMessages(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        SupportChatMessageResponseModel chatResponse = SupportChatMessageResponseModel.fromJson(myMap);
        String roomId = '';
        if (chatResponse.roomID!.isNotEmpty) {
          roomId = chatResponse.roomID!;
        }
        chatResponse.chats!.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateA.compareTo(dateB);
        });
        emit(state.copyWith(status: SupportChatStatus.chatInitialize, model: chatResponse, chatRoomId: roomId));
        await _syncRoomState(emit);
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  void _onSupportChatOptimisticSendEvent(SupportChatOptimisticSendEvent event, Emitter<SupportChatState> emit) {
    final optimistic = ChatMessageConfigModel(
      roomId: state.chatRoomId,
      senderId: state.userId,
      senderRole: 'user',
      message: event.message,
      messageType: event.msgType,
      createdAt: DateTime.now().toIso8601String(),
      randomId: event.randomId,
      readStatus: 'sent',
    );
    final updated = SupportChatMessageResponseModel(
      roomID: state.model.roomID,
      chats: [...?state.model.chats, optimistic],
      page: state.model.page,
      limit: state.model.limit,
      totalPages: state.model.totalPages,
      totalResults: state.model.totalResults,
      success: state.model.success,
    );
    emit(state.copyWith(status: SupportChatStatus.scrollDown, model: updated));
  }

  void _onSupportChatSendFailedEvent(SupportChatSendFailedEvent event, Emitter<SupportChatState> emit) {
    final chats = state.model.chats;
    if (chats == null || chats.isEmpty) return;
    chats.removeWhere((c) => c.randomId == event.randomId);
    emit(state.copyWith(status: SupportChatStatus.scrollDown, model: state.model));
  }

FutureOr<void> _onSupportChatSendNewMessageEvent(SupportChatSendNewMessageEvent event, Emitter<SupportChatState> emit) async {
    final String userId = await _chatRepository.userId();
    try {
      SendChatMessageRequestModel param = SendChatMessageRequestModel(room: state.model.roomID!, sender: userId, msg: event.msg, msgType: event.msgType);
      DioApiResponse response = await _chatRepository.sendSupportChatMessage(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          _removeLastMatching(event.msg, randomId: event.randomId);
          emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', model: state.model, extraMessage: ''));
        }
      } else {
        _removeLastMatching(event.msg, randomId: event.randomId);
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), model: state.model));
      }
    } catch (e, stacktrace) {
      _removeLastMatching(event.msg, randomId: event.randomId);
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', model: state.model));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  void _onSupportChatReadReceiptEvent(
      SupportChatReadReceiptEvent event, Emitter<SupportChatState> emit) {
    final chats = state.model.chats;
    if (chats == null || chats.isEmpty) return;
    bool changed = false;
    for (final c in chats) {
      final role = (c.senderRole ?? '').toLowerCase();
      final isOwn = c.senderId == state.userId && (role.isEmpty || role == 'user');
      if (isOwn && c.readStatus != 'read') {
        c.readStatus = 'read';
        changed = true;
      }
    }
    if (changed) emit(state.copyWith(status: SupportChatStatus.scrollDown, model: state.model));
  }

  /// Roll back the optimistic bubble on a failed send.  ///
  /// The previous code looked the message up by comparing `createdAt` against a
  /// CLIENT timestamp while the list holds SERVER timestamps, so `indexWhere`
  /// returned -1 essentially every time and `removeAt(-1)` threw a RangeError
  /// on every failed send — the rollback path could never run.
  void _removeLastMatching(String msg, {String? randomId}) {
    final chats = state.model.chats;
    if (chats == null || chats.isEmpty) return;
    if (randomId != null && randomId.isNotEmpty) {
      for (var i = chats.length - 1; i >= 0; i--) {
        if (chats[i].randomId == randomId) {
          chats.removeAt(i);
          return;
        }
      }
    }
    for (var i = chats.length - 1; i >= 0; i--) {
      if (chats[i].message == msg) {
        chats.removeAt(i);
        return;
      }
    }
  }

FutureOr<void> _onSupportChatReceiveNewMessageEvent(SupportChatReceiveNewMessageEvent event, Emitter<SupportChatState> emit) async {
    try {
      final String incomingRole = (event.msg.role ?? '').toLowerCase();
      ChatMessageConfigModel receivedMsg = ChatMessageConfigModel(
        createdAt: event.msg.currentDate!,
        roomId: state.chatRoomId,
        senderId: event.msg.senderId!,
        message: event.msg.message!,
        messageType: event.msg.messageType!,
        randomId: event.msg.randomId!,
        senderRole: incomingRole.isNotEmpty ? incomingRole : null,
      );

      // Adopt the agent's identity straight from their live messages. The
      // queue-status fetch can lag or fail; the sender card on the wire does
      // not. Only non-user roles from someone else qualify.
      String agentName = state.agentName;
      String agentAvatar = state.agentAvatar;
      final bool isPeer = receivedMsg.senderId != state.userId;
      final bool isAgentRole = isPeer && incomingRole.isNotEmpty && incomingRole != 'user' && incomingRole != 'bot' && incomingRole != 'system';
      // DEBUG-AGENT-HEADER: remove after diagnosis.
      // ignore: avoid_print
      print('[agent-debug] socket msg role=$incomingRole sender=${event.msg.senderId} first=${event.msg.senderFirstName} cover=${event.msg.senderCover} isAgentRole=$isAgentRole');
      if (isAgentRole) {
        final full = '${event.msg.senderFirstName ?? ''} ${event.msg.senderLastName ?? ''}'.trim();
        if (full.isNotEmpty) agentName = full;
        final cover = event.msg.senderCover ?? '';
        if (cover.isNotEmpty) agentAvatar = cover;
      }

      // A socket echo of a message we already hold is the SAME message, not a
      // new one. The old line was `chats.toSet();` with the result discarded —
      // a no-op that left every duplicate on screen. The socket emits to the
      // whole room INCLUDING the sender, so this fires on every own message.
      final chats = state.model.chats;
      if (chats != null) {
        final randomId = event.msg.randomId;
        final alreadyHave =
            (randomId != null && randomId.isNotEmpty && chats.any((c) => c.randomId == randomId)) ||
                (receivedMsg.senderId == state.userId &&
                    receivedMsg.message!.isNotEmpty &&
                    chats.any((c) => c.senderId == state.userId && c.message == receivedMsg.message && c.createdAt == receivedMsg.createdAt));

        if (alreadyHave) {
          emit(state.copyWith(status: SupportChatStatus.scrollDown, model: state.model, agentName: agentName, agentAvatar: agentAvatar));
          return;
        }
        chats.add(receivedMsg);
      }
      // Never clobber an in-flight bot turn: a socket arrival during typing
      // must not hide the typing indicator or its scroll.
      if (state.status.isBotThinking) {
        emit(state.copyWith(status: SupportChatStatus.botThinking, model: state.model, agentName: agentName, agentAvatar: agentAvatar));
        return;
      }
      emit(state.copyWith(status: SupportChatStatus.scrollDown, model: state.model, agentName: agentName, agentAvatar: agentAvatar));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  // --- Enterprise: bot-first -> human handover -------------------------------

  FutureOr<void> _onSupportChatBotStartEvent(SupportChatBotStartEvent event, Emitter<SupportChatState> emit) async {
    final started = DateTime.now();
    try {
      final String userId = await _chatRepository.userId();
      emit(state.copyWith(status: SupportChatStatus.botThinking, userId: userId.toString()));
      _botType = event.type;
      _botTypeId = event.typeId;

      DioApiResponse response = await _chatRepository.startSupportBot(user: userId, type: event.type, typeId: event.typeId);
      if (response.errorType != NetErrorType.none) {
        // Bot service down -> classic human ticket (same thread filter).
        add(SupportChatInitialEvent(type: event.type, typeId: event.typeId));
        return;
      }

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final String roomId = body['roomId']?.toString() ?? '';
      final Map<String, dynamic>? snapshot =
          body['snapshot'] is Map ? Map<String, dynamic>.from(body['snapshot'] as Map) : null;
      final String handover = body['handoverState']?.toString() ?? 'bot';
      // History carries the persisted greeting + prior transcript so the
      // bot's first answer is visible (bot API returns text, not history).
      final history = await _loadBotHistory(userId);
      await _settleBotThinking(started);
      emit(
        state.copyWith(
          status: SupportChatStatus.botReplied,
          chatRoomId: roomId,
          handoverState: handover,
          orderSnapshot: snapshot,
          botActions: _actionsOf(body),
          subjectId: _botTypeId,
          botHandled: body['resolved'] == true,
          model: history ?? state.model,
        ),
      );
      await _syncRoomState(emit);
    } catch (e, stacktrace) {
      if (_botType.isNotEmpty) {
        add(SupportChatInitialEvent(type: _botType, typeId: _botTypeId));
        return;
      }
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  /// Server actions -> typed list. Unknown values pass through; the view
  /// maps known ones to chips and drops the rest.
  static List<String> _actionsOf(Map<String, dynamic> body) {
    try {
      final a = body['actions'];
      if (a is List) return a.map((e) => '$e').where((s) => s.isNotEmpty).toList();
    } catch (_) {}
    return const [];
  }

  /// Shared history loader for bot turns (same room filter as classic).
  Future<SupportChatMessageResponseModel?> _loadBotHistory(String userId) async {
    try {
      if (_botType.isEmpty) return null;
      SupportChatConvertionRequestModel param = SupportChatConvertionRequestModel(
          user: userId.toString(), type: _botType, typeId: _botTypeId, page: 1, limit: state.pageSize);
      DioApiResponse response = await _chatRepository.fetchSupportChatMessages(param);
      if (response.errorType != NetErrorType.none) return null;
      Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
      SupportChatMessageResponseModel chatResponse = SupportChatMessageResponseModel.fromJson(myMap);
      chatResponse.chats!.sort((a, b) {
        DateTime dateA = DateTime.parse(a.createdAt!);
        DateTime dateB = DateTime.parse(b.createdAt!);
        return dateA.compareTo(dateB);
      });
      return chatResponse;
    } catch (_) {
      return null;
    }
  }

  FutureOr<void> _onSupportChatBotMessageEvent(SupportChatBotMessageEvent event, Emitter<SupportChatState> emit) async {
    final started = DateTime.now();
    try {
      if (state.chatRoomId.isEmpty) {
        return;
      }
      // Reach first: optimistic user bubble (right side) + typing indicator
      // together, so send -> delivered -> typing -> answer reads correctly.
      // Server refetch later replaces this temp with persisted truth.
      final optimistic = ChatMessageConfigModel(
        roomId: state.chatRoomId,
        senderId: state.userId,
        senderRole: 'user',
        message: event.message,
        messageType: 'text',
        createdAt: DateTime.now().toIso8601String(),
        randomId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      );
      final withOwn = SupportChatMessageResponseModel(
        roomID: state.model.roomID,
        chats: [...?state.model.chats, optimistic],
        page: state.model.page,
        limit: state.model.limit,
        totalPages: state.model.totalPages,
        totalResults: state.model.totalResults,
        success: state.model.success,
      );
      emit(state.copyWith(status: SupportChatStatus.botThinking, model: withOwn));

      DioApiResponse response = await _chatRepository.sendSupportBotMessage(roomId: state.chatRoomId, message: event.message);
      if (response.errorType != NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: data.code, alertMessage: data.message.toString()));
        return;
      }

      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final bool assigned = body['assigned'] == true;
      // Refetch so the bot's answer renders (bot API returns text only).
      final history = await _loadBotHistory(await _chatRepository.userId());
      await _settleBotThinking(started);
      // Silent server guard (ticket left bot ownership mid-turn): adopt the
      // true state so chips/handover UI match the room, no ghost reply.
      final String? serverState = body['handoverState']?.toString();
      final agent = assigned ? await _fetchAgent(state.chatRoomId) : (name: state.agentName, avatar: state.agentAvatar);
      emit(
        state.copyWith(
          status: SupportChatStatus.botReplied,
          queuePosition: _asInt(body['queuePosition']),
          handoverState: serverState ?? (assigned ? 'assigned' : state.handoverState),
          agentName: agent.name,
          agentAvatar: agent.avatar,
          orderSnapshot: body['snapshot'] is Map ? Map<String, dynamic>.from(body['snapshot'] as Map) : state.orderSnapshot,
          botActions: _actionsOf(body),
          botHandled: body['resolved'] == true,
          model: history ?? state.model,
        ),
      );
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSupportChatHandoverEvent(SupportChatHandoverEvent event, Emitter<SupportChatState> emit) async {
    final started = DateTime.now();
    try {
      if (state.chatRoomId.isEmpty) return;
      emit(state.copyWith(status: SupportChatStatus.botThinking));
      DioApiResponse response = await _chatRepository.requestSupportHandover(roomId: state.chatRoomId, reason: event.reason);
      if (response.errorType != NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: data.code, alertMessage: data.message.toString()));
        return;
      }
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      await _settleBotThinking(started);
      final agent = body['agentId'] != null
          ? await _fetchAgent(state.chatRoomId)
          : (name: state.agentName, avatar: state.agentAvatar);
      emit(
        state.copyWith(
          status: SupportChatStatus.botReplied,
          handoverState: body['assigned'] == true ? 'assigned' : 'queued',
          agentName: agent.name,
          agentAvatar: agent.avatar,
        ),
      );
      await _syncRoomState(emit);
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onSupportChatCsatEvent(SupportChatCsatEvent event, Emitter<SupportChatState> emit) async {
    try {
      if (state.chatRoomId.isEmpty) return;
      DioApiResponse response = await _chatRepository.submitSupportCsat(roomId: state.chatRoomId, score: event.score, comment: event.comment);
      if (response.errorType == NetErrorType.none) {
        emit(state.copyWith(status: SupportChatStatus.chatInitialize, csatScore: event.score));
      } else {
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: 'Something went wrong'));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  FutureOr<void> _onSupportChatReopenEvent(SupportChatReopenEvent event, Emitter<SupportChatState> emit) async {
    try {
      if (state.chatRoomId.isEmpty || state.userId.isEmpty) return;
      DioApiResponse response = await _chatRepository.reopenSupportChat(roomId: state.chatRoomId, userId: state.userId);
      if (response.errorType != NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: data.code, alertMessage: data.message.toString()));
        return;
      }
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      emit(
        state.copyWith(
          status: SupportChatStatus.botReplied,
          handoverState: body['handoverState']?.toString() ?? 'bot',
          agentName: '',
          agentAvatar: '',
          queuePosition: 0,
        ),
      );
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  /// Agent display profile for the header/banner. A failure here must not
  /// break the chat, so it returns empties rather than throwing.
  /// Single source of truth after any entry/turn: handover state, queue
  /// position, and the assigned agent's name/avatar. Previously the agent
  /// line was only fetched on handover events, so opening an already-human
  /// ticket showed no agent at all.
  Future<void> _syncRoomState(Emitter<SupportChatState> emit) async {
    try {
      if (state.chatRoomId.isEmpty) return;
      final DioApiResponse response = await _chatRepository.supportQueueStatus(state.chatRoomId);
      if (response.errorType != NetErrorType.none) return;
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      String name = state.agentName;
      String avatar = state.agentAvatar;
      final agent = body['assignedAgent'];
      // DEBUG-AGENT-HEADER: remove after diagnosis.
      // ignore: avoid_print
      print('[agent-debug] queueStatus assignedAgent=$agent handover=${body['handoverState']}');
      if (agent is Map && agent['firstName'] != null) {
        name = '${agent['firstName'] ?? ''} ${agent['lastName'] ?? ''}'.trim();
        avatar = agent['image']?.toString() ?? agent['cover']?.toString() ?? '';
      } else if (body['assignedAgent'] == null) {
        name = '';
        avatar = '';
      }
      emit(state.copyWith(
        handoverState: body['handoverState']?.toString() ?? state.handoverState,
        queuePosition: _asInt(body['queuePosition']),
        agentName: name,
        agentAvatar: avatar,
      ));
      // Human state owns chips too: server-driven set, fetched once.
      final hs = state.handoverState;
      if ((hs == 'queued' || hs == 'assigned' || hs == 'human') && state.humanChips.isEmpty) {
        await _loadHumanChips(emit);
      }
    } catch (_) {}
  }

  Future<void> _loadHumanChips(Emitter<SupportChatState> emit) async {
    try {
      final DioApiResponse response = await _chatRepository.fetchSupportChips();
      if (response.errorType != NetErrorType.none) return;
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = body['chips'];
      if (raw is! List || raw.isEmpty) return;
      final chips = <Map<String, String>>[];
      for (final c in raw) {
        if (c is Map) {
          final label = '${c['label'] ?? ''}'.trim();
          final message = '${c['message'] ?? ''}'.trim();
          if (label.isNotEmpty && message.isNotEmpty) chips.add({'label': label, 'message': message});
        }
        if (chips.length >= 6) break;
      }
      if (chips.isNotEmpty) emit(state.copyWith(status: SupportChatStatus.scrollDown, humanChips: chips));
    } catch (_) {}
  }

  Future<({String name, String avatar})> _fetchAgent(String roomId) async {
    try {
      DioApiResponse response = await _chatRepository.supportQueueStatus(roomId);
      if (response.errorType != NetErrorType.none) return (name: '', avatar: '');
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final agent = body['assignedAgent'];
      if (agent is Map && agent['firstName'] != null) {
        final first = agent['firstName']?.toString() ?? '';
        final last = agent['lastName']?.toString() ?? '';
        final avatar = agent['image']?.toString() ?? agent['cover']?.toString() ?? '';
        return (name: '$first $last'.trim(), avatar: avatar);
      }
      return (name: '', avatar: '');
    } catch (_) {
      return (name: '', avatar: '');
    }
  }

  FutureOr<void> _onSupportChatReceiveLoadMoreEvent(SupportChatReceiveLoadMoreEvent event, Emitter<SupportChatState> emit) async {
    try {
      emit(state.copyWith(loadMore: true, status: SupportChatStatus.loadMoreStart));
      LoadMoreChatConversionRequestModel param = LoadMoreChatConversionRequestModel(roomId: state.chatRoomId, limit: state.pageSize * 2, page: state.currentPage);
      DioApiResponse response = await _chatRepository.getSupportChatConversion(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        SupportChatMessageResponseModel chatResponse = SupportChatMessageResponseModel.fromJson(myMap);
        String roomId = '';
        if (chatResponse.roomID!.isNotEmpty) {
          roomId = chatResponse.roomID!;
        }
        chatResponse.chats!.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateA.compareTo(dateB);
        });
        emit(state.copyWith(status: SupportChatStatus.loadMoreEnd, loadMore: false, model: chatResponse, chatRoomId: roomId));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: SupportChatStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

