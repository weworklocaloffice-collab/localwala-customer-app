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
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/guest_account_status_response_model.dart';
import 'package:user/app/core/models/request/push_notification_token_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/models/user_register_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/env.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository = AuthRepository();
  LoginBloc() : super(const LoginState()) {
    on<LoginInitialEvent>(_onLoginInitialEvent);
    on<LoginSkipEvent>(_onLoginSkipEvent);
    on<LoginGuestAccountEvent>(_onLoginGuestAccountEvent);
    on<LoginLanguageChangeEvent>(_onLoginLanguageChangeEvent);
  }

  FutureOr<void> _onLoginInitialEvent(LoginInitialEvent event, Emitter<LoginState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "login_view"}, 'login_screen', 'login_screen');
      String? userLoginWith = await _authRepository.userLoginWith();
      bool? guestCheckout = await _authRepository.isGuestCheckout();
      String? locale = await _authRepository.getLocale();
      emit(state.copyWith(locale: locale.isNotEmpty ? locale.toString() : Environments.defaultLanguage));
      if (await Permission.notification.request().isGranted) {
        if (!kIsWeb) {
          final String user = await _authRepository.userId();
          String? pushToken = '';
          String deviceType = '';
          String deviceId = '';
          final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
          await FirebaseMessaging.instance.getToken().then((value) async {
            pushToken = value;
          });
          if (pushToken != null && pushToken!.isNotEmpty) {
            if (Platform.isAndroid) {
              deviceType = 'android';
              var androidDeviceInfo = await deviceInfoPlugin.androidInfo;
              deviceId = '${androidDeviceInfo.host}:${androidDeviceInfo.device}:${androidDeviceInfo.id}:${androidDeviceInfo.model}:${androidDeviceInfo.brand}';
            } else if (Platform.isIOS) {
              deviceType = 'ios';
              var iosDeviceInfo = await deviceInfoPlugin.iosInfo;
              deviceId = '${iosDeviceInfo.name}:${iosDeviceInfo.model}:${iosDeviceInfo.identifierForVendor}';
            }
            if (Platform.isAndroid || Platform.isIOS) {
              PushNotificationTokenRequestModel tokenParam = PushNotificationTokenRequestModel(user: user, deviceId: deviceId, deviceType: deviceType, token: pushToken!);
              await _authRepository.savePushNotificationToken(tokenParam);
            }
          }
        }
        emit(state.copyWith(userLoginWith: userLoginWith.isNotEmpty ? userLoginWith : 'email_password', guestCheckout: guestCheckout, status: LoginStatus.notificationGranted));
      } else {
        emit(state.copyWith(userLoginWith: userLoginWith, guestCheckout: guestCheckout, status: LoginStatus.notificationDicline));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(userLoginWith: 'email_password', guestCheckout: false, status: LoginStatus.notificationDicline));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLoginSkipEvent(LoginSkipEvent event, Emitter<LoginState> emit) async {
    await _authRepository.skipLogin();
    await _authRepository.saveEvent('customer_skip_login', {}, '', '');
    await _authRepository.haveLocation().then((value) {
      if (value) {
        emit(state.copyWith(status: LoginStatus.home));
      } else {
        emit(state.copyWith(status: LoginStatus.location));
      }
    });
  }

  FutureOr<void> _onLoginGuestAccountEvent(LoginGuestAccountEvent event, Emitter<LoginState> emit) async {
    try {
      emit(state.copyWith(status: LoginStatus.guestRegisterStart));
      String userAgent = 'unknown';
      if (kIsWeb) {
        userAgent = 'browser';
      } else if (Platform.isAndroid) {
        userAgent = 'android';
      } else if (Platform.isIOS) {
        userAgent = 'ios';
      }
      final String appLocale = await _authRepository.getLocale();
      DioApiResponse response = await _authRepository.registerGuestAccount(userAgent, appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        GuestAccountStatusResponseModel initialResponse = GuestAccountStatusResponseModel.fromJson(myMap);
        if (!initialResponse.signup!) {
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveEvent('customer_guest_login', {"agent": userAgent, "locale": appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage}, '', '');
          await _authRepository.saveLoginResponse(data);
          await _authRepository.haveLocation().then((value) {
            if (value) {
              emit(state.copyWith(status: LoginStatus.guestRegisterHome));
            } else {
              emit(state.copyWith(status: LoginStatus.guestRegisterLocation));
            }
          });
        } else {
          UserRegisterResponseModel data = UserRegisterResponseModel.fromJson(myMap);
          await _authRepository.saveRegisterResponse(data);
          await _authRepository.haveLocation().then((value) {
            if (value) {
              emit(state.copyWith(status: LoginStatus.guestRegisterHome));
            } else {
              emit(state.copyWith(status: LoginStatus.guestRegisterLocation));
            }
          });
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: LoginStatus.guestRegisterFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoginStatus.guestRegisterFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLoginLanguageChangeEvent(LoginLanguageChangeEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(locale: event.locale));
  }
}

