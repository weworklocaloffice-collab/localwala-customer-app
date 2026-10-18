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

import 'dart:convert';

import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/core/models/request/default_setting_request_model.dart';
import 'package:user/app/core/models/request/push_notification_token_request_model.dart';
import 'package:user/app/core/models/user_settings_model.dart';
import 'package:user/app/env.dart';
import 'package:user/app/services/shared_pref.dart';

class SplashRepositry {
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();
  final ApiRequestService _apiRequestService = ApiRequestService();

  Future<bool> haveIntro() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.introKey);
  }

  Future<void> saveIntro() async {
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.introKey, true);
  }

  Future<DioApiResponse> getDefaultSetting(DefaultSettingRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.getUserSettings, body: param);
  }

  Future<DioApiResponse> savePushNotificationToken(PushNotificationTokenRequestModel param) async {
    return await _apiRequestService.post(ApiEndPoints.v1request.savePushNotificationToken, body: param);
  }

  Future<void> saveSettings(UserSettingsModel userSettingsModel) async {
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.businessEmail, userSettingsModel.settings!.email!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.businessMobile, userSettingsModel.settings!.mobile!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.companyNameKey, userSettingsModel.settings!.companyName!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.currencySymbolKey, userSettingsModel.settings!.currency!.symbol!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.currencySide, userSettingsModel.settings!.currencySide!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.canEarnBuyFromReferral, userSettingsModel.user!.canEarnBuyFromReferral!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.signUpVerification, userSettingsModel.user!.signUpVerification!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.userLoginWith, userSettingsModel.user!.userLoginWith!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.userResetPasswordWith, userSettingsModel.user!.userResetPasswordWith!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.defaultCountryCode, jsonEncode(userSettingsModel.settings!.defaultCountryCode!).toString());
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.websiteUrl, userSettingsModel.settings!.websiteUrl!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.guestCheckout, userSettingsModel.settings!.guestCheckout!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.socialAppleSignIn, userSettingsModel.social!.appleSignin!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.socialGoogleSignIn, userSettingsModel.social!.googleSignin!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.socialFacebookSignIn, userSettingsModel.social!.facebookSignin!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.googleOAuthClientId, userSettingsModel.social!.googleOAuth!.googleClientId!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.googleOAuthServerId, userSettingsModel.social!.googleOAuth!.googleServerId!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.vendorSelfRegisterButton, userSettingsModel.selfRegister!.vendor!);
    await _sharedPreferencesManager.putBool(SharedPreferencesKey.publicKeys.driverSelfRegisterButton, userSettingsModel.selfRegister!.driver!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.appLogo, userSettingsModel.settings!.logo!);
    await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.userTrackingId).then((value) async {
      if (value == false) {
        await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.userTrackingId, userSettingsModel.tracking!.id!);
      }
    });
    await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.defaultLanguage).then((value) async {
      if (value == false) {
        await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.defaultLanguage, userSettingsModel.defaultLocale!.code!);
      }
    });
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.androidUrl, userSettingsModel.versions!.androidUrl!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.androidVersion, userSettingsModel.versions!.androidVersion!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.iosUrl, userSettingsModel.versions!.iosUrl!);
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.iosVersion, userSettingsModel.versions!.iosVersion!);

    final String imagePath = userSettingsModel.imagePath! != 'none' ? userSettingsModel.imagePath! : '${Environments.apiBaseURL}storage/';
    await _sharedPreferencesManager.putString(SharedPreferencesKey.publicKeys.mediaUrl, imagePath);
  }

  Future<bool> haveAuthToken() async {
    return await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.authKeys.authToken);
  }

  Future<bool> haveLoginSkip() async {
    return await _sharedPreferencesManager.getBool(SharedPreferencesKey.publicKeys.loginSkip);
  }

  Future<bool> haveLocation() async {
    bool userLatitude = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.userLatitude);
    bool userLongitude = await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.userLongitude);
    if (userLatitude && userLongitude) {
      return true;
    }
    return false;
  }

  Future<String> userId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.uid) ?? '';
  }

  Future<bool> haveSavedLocale() async {
    return await _sharedPreferencesManager.isKeyExists(SharedPreferencesKey.publicKeys.defaultLanguage);
  }

  Future<String> getLocale() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.defaultLanguage) ?? '';
  }

  Future<String> trackingId() async {
    return await _sharedPreferencesManager.getString(SharedPreferencesKey.publicKeys.userTrackingId) ?? '';
  }
}

