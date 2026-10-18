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
import 'package:user/app/core/models/account_setting_delete_account_reason_list_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';

part 'account_setting_delete_account_event.dart';
part 'account_setting_delete_account_state.dart';

class AccountSettingDeleteAccountBloc extends Bloc<AccountSettingDeleteAccountEvent, AccountSettingDeleteAccountState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingDeleteAccountBloc()
    : super(
        AccountSettingDeleteAccountState(
          list: AccountSettingDeleteAccountReasonListResponseModel(result: [], success: false, locale: ''),
        ),
      ) {
    on<AccountSettingDeleteAccountInitialEvent>(_onAccountSettingDeleteAccountInitialEvent);
  }

  FutureOr<void> _onAccountSettingDeleteAccountInitialEvent(AccountSettingDeleteAccountInitialEvent event, Emitter<AccountSettingDeleteAccountState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "delete_accounts"}, 'delete_account_screen', 'delete_account_screen');
      emit(state.copyWith(status: AccountSettingDeleteAccountStatus.loading));
      DioApiResponse response = await _authRepository.getAccountDeleteReason();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        AccountSettingDeleteAccountReasonListResponseModel data = AccountSettingDeleteAccountReasonListResponseModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: data.result!.isNotEmpty ? AccountSettingDeleteAccountStatus.success : AccountSettingDeleteAccountStatus.empty, list: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingDeleteAccountStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingDeleteAccountStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

