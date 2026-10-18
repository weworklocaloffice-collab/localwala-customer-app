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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/global_settings.dart';
import 'package:user/app/core/models/notification_response_data_model.dart';
import 'package:user/app/core/models/request/default_setting_request_model.dart';
import 'package:user/app/core/models/request/push_notification_token_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/splash_respository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user/app/env.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashRepositry _splashRepositry = SplashRepositry();
  final AuthRepository _authRepository = AuthRepository();
  SplashBloc() : super(const SplashState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);
    on<SplashOrderNotificationEvent>(_onSplashOrderNotificationEvent);
    on<SplashNavigateScreenRouteEvent>(_onSplashNavigateScreenRouteEvent);
  }

  Future<void> _onSplashInitialEvent(SplashInitialEvent event, Emitter<SplashState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "splash"}, 'splash_screen', 'splash_screen');
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = (connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi));
    if (!hasInternet) {
      emit(state.copyWith(status: SplashStatus.connectionError));
    } else {
      try {
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        final String trackingId = await _splashRepositry.trackingId();
        DefaultSettingRequestModel param = DefaultSettingRequestModel(agent: userAgent, userTrackingId: trackingId);
        DioApiResponse response = await _splashRepositry.getDefaultSetting(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserSettingsModel data = UserSettingsModel.fromJson(myMap);
          final bool haveSavedLocale = await _splashRepositry.haveSavedLocale();
          if (haveSavedLocale) {
            final String locale = await _splashRepositry.getLocale();
            emit(state.copyWith(appLocale: locale.isNotEmpty ? locale : Environments.defaultLanguage, status: SplashStatus.appLocale));
          } else {
            emit(state.copyWith(appLocale: data.defaultLocale!.code.toString(), status: SplashStatus.appLocale));
          }
          await _splashRepositry.saveSettings(data);
          if (data.versions!.success!) {
            final PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final String currentVersion = packageInfo.version;
            final String latestVersion = userAgent == 'android' ? data.versions!.androidVersion! : data.versions!.iosVersion!;
            final String forceUpdateUrl = userAgent == 'android' ? data.versions!.androidUrl! : data.versions!.iosUrl!;
            if (_isVersionLower(currentVersion, latestVersion) && userAgent != 'browser') {
              emit(state.copyWith(status: SplashStatus.forceUpdate, newUpdateVersion: latestVersion, versionUpdateUrl: forceUpdateUrl));
            } else {
              add(SplashNavigateScreenRouteEvent(data: data));
            }
          } else {
            add(SplashNavigateScreenRouteEvent(data: data));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: SplashStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: SplashStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onSplashNavigateScreenRouteEvent(SplashNavigateScreenRouteEvent event, Emitter<SplashState> emit) async {
    if (event.data.settings!.maintenance!) {
      emit(state.copyWith(status: SplashStatus.maintenance, businessEmail: event.data.settings!.email, businessMobile: event.data.settings!.mobile));
    } else {
      if (!kIsWeb) {
        var notificationStatus = await Permission.notification.status;
        if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
          final String user = await _splashRepositry.userId();
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
              await _splashRepositry.savePushNotificationToken(tokenParam);
            }
          }
        } else {
          if (await Permission.notification.request().isGranted) {
            final String user = await _splashRepositry.userId();
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
                await _splashRepositry.savePushNotificationToken(tokenParam);
              }
            }
          }
        }
      }
      FirebaseMessaging.onMessage.handleError((error) {}).listen((RemoteMessage event) async {
        if (event.data.isNotEmpty) {
          Map<String, dynamic>? notificationMap = jsonDecode(jsonEncode(event.data)) as Map<String, dynamic>;
          NotificationResponseDataModel notificationData = NotificationResponseDataModel.fromJson(notificationMap);
          if (notificationData.type!.isNotEmpty && notificationData.type == 'order') {
            add(SplashOrderNotificationEvent(notificationData: notificationData));
          }
        }
      });
      await GlobalSettings().init();

      await _splashRepositry.haveIntro().then((value) async {
        if (value == false) {
          emit(state.copyWith(status: SplashStatus.intro));
        } else {
          final bool haveLoginSkip = await _splashRepositry.haveLoginSkip();
          final bool haveLocation = await _splashRepositry.haveLocation();
          final bool haveAuthToken = await _splashRepositry.haveAuthToken();
          if (haveAuthToken == false && haveLoginSkip == false && haveLocation == false) {
            emit(state.copyWith(status: SplashStatus.unAuthorized));
          } else if (haveLoginSkip == true && haveLocation == false) {
            emit(state.copyWith(status: SplashStatus.location));
          } else if (haveAuthToken == true && haveLocation == true) {
            emit(state.copyWith(status: SplashStatus.home));
          } else if (haveLoginSkip == true && haveLocation == true) {
            emit(state.copyWith(status: SplashStatus.home));
          } else if (haveLoginSkip == false && haveLocation == false) {
            emit(state.copyWith(status: SplashStatus.location));
          } else if (haveLoginSkip == false && haveLocation == true) {
            emit(state.copyWith(status: SplashStatus.home));
          } else {
            emit(state.copyWith(status: SplashStatus.home));
          }
        }
      });
    }
  }

  bool _isVersionLower(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
        return true;
      } else if (currentParts[i] > latestParts[i]) {
        return false;
      }
    }
    return false;
  }

  FutureOr<void> _onSplashOrderNotificationEvent(SplashOrderNotificationEvent event, Emitter<SplashState> emit) async {}
}

