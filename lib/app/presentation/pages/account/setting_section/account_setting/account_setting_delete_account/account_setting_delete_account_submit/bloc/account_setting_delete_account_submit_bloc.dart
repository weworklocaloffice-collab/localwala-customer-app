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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/user_account_delete_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';

part 'account_setting_delete_account_submit_event.dart';
part 'account_setting_delete_account_submit_state.dart';

class AccountSettingDeleteAccountSubmitBloc extends Bloc<AccountSettingDeleteAccountSubmitEvent, AccountSettingDeleteAccountSubmitState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingDeleteAccountSubmitBloc() : super(const AccountSettingDeleteAccountSubmitState()) {
    on<AccountSettingDeleteAccountSubmitInitialEvent>(_onAccountSettingDeleteAccountSubmitInitialEvent);
    on<AccountSettingDeleteAccountSubmitYesEvent>(_onAccountSettingDeleteAccountSubmitYesEvent);
  }

  FutureOr<void> _onAccountSettingDeleteAccountSubmitInitialEvent(AccountSettingDeleteAccountSubmitInitialEvent event, Emitter<AccountSettingDeleteAccountSubmitState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "confirm_delete_accounts"}, 'confirm_delete_account_screen', 'confirm_delete_account_screen');
    emit(state.copyWith(reason: event.reason, status: AccountSettingDeleteAccountSubmitStatus.initial));
  }

  FutureOr<void> _onAccountSettingDeleteAccountSubmitYesEvent(AccountSettingDeleteAccountSubmitYesEvent event, Emitter<AccountSettingDeleteAccountSubmitState> emit) async {
    try {
      emit(state.copyWith(status: AccountSettingDeleteAccountSubmitStatus.loading));
      final String user = await _authRepository.userId();
      UserAccountDeleteRequestModel param = UserAccountDeleteRequestModel(reason: state.reason, user: user);
      DioApiResponse response = await _authRepository.userAccountDelete(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
        if (!data.success!) {
          emit(state.copyWith(status: AccountSettingDeleteAccountSubmitStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          await _authRepository.onLogoutSuccess();
          emit(state.copyWith(status: AccountSettingDeleteAccountSubmitStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingDeleteAccountSubmitStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingDeleteAccountSubmitStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

