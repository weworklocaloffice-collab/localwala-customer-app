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
import 'package:user/app/core/models/request/account_update_notification_setting_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_notification_setting_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';

part 'account_setting_notification_alert_event.dart';
part 'account_setting_notification_alert_state.dart';

class AccountSettingNotificationAlertBloc extends Bloc<AccountSettingNotificationAlertEvent, AccountSettingNotificationAlertState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountSettingNotificationAlertBloc() : super(const AccountSettingNotificationAlertState()) {
    on<AccountSettingNotificationAlertInitialEvent>(_onAccountSettingNotificationAlertInitialEvent);
    on<AccountSettingNotificationAlertChangeEvent>(_onAccountSettingNotificationAlertChangeEvent);
    on<AccountSettingNotificationAlertUpdateEvent>(_onAccountSettingNotificationAlertUpdateEvent);
  }

  FutureOr<void> _onAccountSettingNotificationAlertInitialEvent(AccountSettingNotificationAlertInitialEvent event, Emitter<AccountSettingNotificationAlertState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "notification_settings"}, 'notification_screen', 'notification_screen');
      emit(state.copyWith(status: AccountSettingNotificationAlertStatus.loading));
      DioApiResponse response = await _authRepository.userNotificationSetting();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UserNotificationSettingResponseModel data = UserNotificationSettingResponseModel.fromJson(myMap);
        bool newsletters = data.setting!.newsletters!;
        bool promoEmail = data.setting!.promoEmail!;
        bool promoNotification = data.setting!.promoNotification!;
        bool promoWhatsApp = data.setting!.promoWhatsApp!;
        bool socialEmail = data.setting!.socialEmail!;
        bool socialNotification = data.setting!.socialNotification!;
        bool orderEmail = data.setting!.orderEmail!;
        bool orderNotification = data.setting!.orderNotification!;
        bool orderWhatsApp = data.setting!.orderWhatsApp!;
        bool importantUpdate = data.setting!.importantUpdate!;
        emit(
          state.copyWith(
            settingId: data.setting!.id!,
            newsletters: newsletters,
            promoEmail: promoEmail,
            promoNotification: promoNotification,
            promoWhatsApp: promoWhatsApp,
            socialEmail: socialEmail,
            socialNotification: socialNotification,
            orderEmail: orderEmail,
            orderNotification: orderNotification,
            orderWhatsApp: orderWhatsApp,
            importantUpdate: importantUpdate,
            status: AccountSettingNotificationAlertStatus.success,
          ),
        );
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingNotificationAlertStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingNotificationAlertStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountSettingNotificationAlertChangeEvent(AccountSettingNotificationAlertChangeEvent event, Emitter<AccountSettingNotificationAlertState> emit) async {
    if (event.name == 'newsletters') {
      bool newsletters = state.newsletters == true ? false : true;
      emit(state.copyWith(newsletters: newsletters, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'promoEmail') {
      bool promoEmail = state.promoEmail == true ? false : true;
      emit(state.copyWith(promoEmail: promoEmail, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'promoNotification') {
      bool promoNotification = state.promoNotification == true ? false : true;
      emit(state.copyWith(promoNotification: promoNotification, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'promoWhatsApp') {
      bool promoWhatsApp = state.promoWhatsApp == true ? false : true;
      emit(state.copyWith(promoWhatsApp: promoWhatsApp, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'socialEmail') {
      bool socialEmail = state.socialEmail == true ? false : true;
      emit(state.copyWith(socialEmail: socialEmail, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'socialNotification') {
      bool socialNotification = state.socialNotification == true ? false : true;
      emit(state.copyWith(socialNotification: socialNotification, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'orderEmail') {
      bool orderEmail = state.orderEmail == true ? false : true;
      emit(state.copyWith(orderEmail: orderEmail, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'orderNotification') {
      bool orderNotification = state.orderNotification == true ? false : true;
      emit(state.copyWith(orderNotification: orderNotification, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'orderWhatsApp') {
      bool orderWhatsApp = state.orderWhatsApp == true ? false : true;
      emit(state.copyWith(orderWhatsApp: orderWhatsApp, status: AccountSettingNotificationAlertStatus.success));
    } else if (event.name == 'importantUpdate') {
      bool importantUpdate = state.importantUpdate == true ? false : true;
      emit(state.copyWith(importantUpdate: importantUpdate, status: AccountSettingNotificationAlertStatus.success));
    }
  }

  FutureOr<void> _onAccountSettingNotificationAlertUpdateEvent(AccountSettingNotificationAlertUpdateEvent event, Emitter<AccountSettingNotificationAlertState> emit) async {
    try {
      emit(state.copyWith(status: AccountSettingNotificationAlertStatus.update));
      AccountUpdateNotificationSettingRequestModel param = AccountUpdateNotificationSettingRequestModel(
        newsletters: state.newsletters,
        promoEmail: state.promoEmail,
        promoNotification: state.promoNotification,
        promoWhatsApp: state.promoWhatsApp,
        socialEmail: state.socialEmail,
        socialNotification: state.socialNotification,
        orderEmail: state.orderEmail,
        orderNotification: state.orderNotification,
        orderWhatsApp: state.orderWhatsApp,
        importantUpdate: state.importantUpdate,
      );
      DioApiResponse response = await _authRepository.updateNotificationSetting(state.settingId, param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel data = ApiStatusResponseModel.fromJson(myMap);
        if (!data.success!) {
          emit(state.copyWith(status: AccountSettingNotificationAlertStatus.updateFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          emit(state.copyWith(status: AccountSettingNotificationAlertStatus.updated));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AccountSettingNotificationAlertStatus.updateFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountSettingNotificationAlertStatus.updateFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

