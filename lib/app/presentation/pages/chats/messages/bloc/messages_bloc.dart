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
import 'package:user/app/core/models/chat_messages_response_model.dart';
import 'package:user/app/core/models/chat_socket_incoming_message_model.dart';
import 'package:user/app/core/models/request/chat_conversion_request_model.dart';
import 'package:user/app/core/models/request/load_more_chat_conversion_request_model.dart';
import 'package:user/app/core/models/request/send_chat_message_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthRepository _authRepository = AuthRepository();
  MessagesBloc()
    : super(
        MessagesState(
          pageSize: ApiRequestService.pageSize,
          model: ChatMessagesResponseModel(chats: []),
        ),
      ) {
    on<MessagesInitialEvent>(_onMessagesInitialEvent);
    on<MessagesSendNewMessageEvent>(_onMessagesSendNewMessageEvent);
    on<MessageReceiveNewMessageEvent>(_onMessageReceiveNewMessageEvent);
    on<MessageReceiveLoadMoreEvent>(_onMessageReceiveLoadMoreEvent);
  }

  FutureOr<void> _onMessagesInitialEvent(MessagesInitialEvent event, Emitter<MessagesState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "regular_chat_messages"}, 'regular_chat_message_screen', 'regular_chat_message_screen');
      final String userId = await _chatRepository.userId();
      final String authRole = await _chatRepository.authRole();
      final String firstName = await _chatRepository.firstName();
      final String lastName = await _chatRepository.lastName();
      final String userCover = await _chatRepository.userCover();
      emit(state.copyWith(status: MessagesStatus.loading, userId: userId.toString(), authRole: authRole.toString(), name: event.name, senderFirstName: firstName, senderLastName: lastName, senderCover: userCover));
      ChatConversionRequestModel param = ChatConversionRequestModel(senderId: userId.toString(), receiverId: event.receiverId, page: state.currentPage, limit: state.pageSize);
      DioApiResponse response = await _chatRepository.fetchChatMessages(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ChatMessagesResponseModel chatResponse = ChatMessagesResponseModel.fromJson(myMap);
        String roomId = '';
        if (chatResponse.roomID!.isNotEmpty) {
          roomId = chatResponse.roomID!;
        }
        chatResponse.chats!.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateA.compareTo(dateB);
        });
        emit(state.copyWith(status: MessagesStatus.chatInitialize, model: chatResponse, chatRoomId: roomId));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: MessagesStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: MessagesStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onMessagesSendNewMessageEvent(MessagesSendNewMessageEvent event, Emitter<MessagesState> emit) async {
    final String userId = await _chatRepository.userId();
    DateTime now = DateTime.now().toUtc();
    String formattedDate = now.toIso8601String();
    final int indexOfNewMessage = state.model.chats!.indexWhere((element) => element.createdAt == formattedDate && element.message == event.msg);
    try {
      SendChatMessageRequestModel param = SendChatMessageRequestModel(room: state.model.roomID!, sender: userId, msg: event.msg, msgType: 'text');
      DioApiResponse response = await _chatRepository.sendChatMessage(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          state.model.chats!.removeAt(indexOfNewMessage);
          emit(state.copyWith(status: MessagesStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', model: state.model, extraMessage: ''));
        }
      } else {
        state.model.chats!.removeAt(indexOfNewMessage);
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: MessagesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString(), model: state.model));
      }
    } catch (e, stacktrace) {
      state.model.chats!.removeAt(indexOfNewMessage);
      emit(state.copyWith(status: MessagesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', model: state.model));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onMessageReceiveNewMessageEvent(MessageReceiveNewMessageEvent event, Emitter<MessagesState> emit) async {
    try {
      ChatMessageConfigModel receivedMsg = ChatMessageConfigModel(
        createdAt: event.msg.currentDate!,
        roomId: state.chatRoomId,
        senderId: event.msg.senderId!,
        message: event.msg.message!,
        messageType: event.msg.messageType!,
        randomId: event.msg.randomId!,
      );
      state.model.chats!.add(receivedMsg);
      state.model.chats!.toSet();
      emit(state.copyWith(status: MessagesStatus.scrollDown, model: state.model));
    } catch (e, stacktrace) {
      emit(state.copyWith(status: MessagesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onMessageReceiveLoadMoreEvent(MessageReceiveLoadMoreEvent event, Emitter<MessagesState> emit) async {
    try {
      emit(state.copyWith(loadMore: true, status: MessagesStatus.loadMoreStart));
      LoadMoreChatConversionRequestModel param = LoadMoreChatConversionRequestModel(roomId: state.chatRoomId, limit: state.pageSize * 2, page: state.currentPage);
      DioApiResponse response = await _chatRepository.getChatConversion(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ChatMessagesResponseModel chatResponse = ChatMessagesResponseModel.fromJson(myMap);
        String roomId = '';
        if (chatResponse.roomID!.isNotEmpty) {
          roomId = chatResponse.roomID!;
        }
        chatResponse.chats!.sort((a, b) {
          DateTime dateA = DateTime.parse(a.createdAt!);
          DateTime dateB = DateTime.parse(b.createdAt!);
          return dateA.compareTo(dateB);
        });
        emit(state.copyWith(status: MessagesStatus.loadMoreEnd, loadMore: false, model: chatResponse, chatRoomId: roomId));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: MessagesStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: MessagesStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: '', loadMore: false));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

