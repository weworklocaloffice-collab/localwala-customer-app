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
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_avatar_list_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'user_avatar_list_modal_event.dart';
part 'user_avatar_list_modal_state.dart';

class UserAvatarListModalBloc extends Bloc<UserAvatarListModalEvent, UserAvatarListModalState> {
  final AuthRepository _authRepository = AuthRepository();
  UserAvatarListModalBloc() : super(UserAvatarListModalState(model: UserAvatarListResponseModel(avatar: [], success: false))) {
    on<UserAvatarListModalInitialEvent>(_onUserAvatarListModalInitialEvent);
    on<UserAvatarListModalSelectEvent>(_onUserAvatarListModalSelectEvent);
  }

  FutureOr<void> _onUserAvatarListModalInitialEvent(UserAvatarListModalInitialEvent event, Emitter<UserAvatarListModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "user_avatar"}, 'user_avatar_screen', 'user_avatar_screen');
      emit(state.copyWith(status: UserAvatarListModalStatus.loading));
      DioApiResponse response = await _authRepository.getAvatarList();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UserAvatarListResponseModel data = UserAvatarListResponseModel.fromJson(myMap);
        emit(state.copyWith(status: data.avatar!.isNotEmpty ? UserAvatarListModalStatus.success : UserAvatarListModalStatus.empty, model: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: UserAvatarListModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: UserAvatarListModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onUserAvatarListModalSelectEvent(UserAvatarListModalSelectEvent event, Emitter<UserAvatarListModalState> emit) async {
    emit(state.copyWith(selected: event.avatar, status: UserAvatarListModalStatus.success));
  }
}

