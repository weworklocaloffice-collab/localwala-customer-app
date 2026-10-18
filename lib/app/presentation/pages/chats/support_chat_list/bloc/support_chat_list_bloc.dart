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
import 'package:user/app/core/models/my_support_chat_list_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'support_chat_list_event.dart';
part 'support_chat_list_state.dart';

class SupportChatListBloc extends Bloc<SupportChatListEvent, SupportChatListState> {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthRepository _authRepository = AuthRepository();
  SupportChatListBloc()
    : super(
        SupportChatListState(
          model: MySupportChatListResponseModel(chats: [], success: false, locale: ''),
        ),
      ) {
    on<SupportChatListInitialEvent>(_onSupportChatListInitialEvent);
  }

  FutureOr<void> _onSupportChatListInitialEvent(SupportChatListInitialEvent event, Emitter<SupportChatListState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "support_chat_list"}, 'support_chat_list_screen', 'support_chat_list_screen');
      final String userId = await _chatRepository.userId();
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: SupportChatListStatus.loading, userId: userId.toString()));
        DioApiResponse response = await _chatRepository.getSupportChatList(userId.toString());
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: SupportChatListStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            final String locale = await _authRepository.getLocale();
            MySupportChatListResponseModel chatResponse = MySupportChatListResponseModel.fromJson(myMap, locale.toString());
            emit(state.copyWith(status: chatResponse.chats!.isNotEmpty ? SupportChatListStatus.success : SupportChatListStatus.empty, model: chatResponse));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SupportChatListStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: SupportChatListStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: SupportChatListStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

