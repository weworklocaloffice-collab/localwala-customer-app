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
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/env.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AuthRepository _authRepository = AuthRepository();
  AccountBloc() : super(const AccountState()) {
    on<AccountInitialEvent>(_onAccountInitialEvent);
    on<AccountLogoutEvent>(_onAccountLogoutEvent);
    on<AccountChangeThemeEvent>(_onAccountChangeThemeEvent);
  }

  FutureOr<void> _onAccountInitialEvent(AccountInitialEvent event, Emitter<AccountState> emit) async {
    final bool isAuthorized = await _authRepository.isAuthorized();
    final bool isGoogleLoggedIn = await _authRepository.isGoogleLoggedIn();
    final bool isFacebookLoggedIn = await _authRepository.isFacebookLoggedIn();
    final String isGuestUser = await _authRepository.userId();
    final String locale = await _authRepository.getLocale();
    final String appLogo = await _authRepository.appLogo();
    await _authRepository.saveEvent('visited_screen', {"screen": "account"}, 'account_screen', 'account_screen');
    String userCoverImage = '';
    String userName = '';
    String userEmailAddress = '';
    if (isAuthorized) {
      final String userFirstName = await _authRepository.userFirstName();
      final String userLastName = await _authRepository.userLastName();
      final String userEmail = await _authRepository.userEmail();
      final String userCover = await _authRepository.userCover();
      userName = '$userFirstName $userLastName';
      userEmailAddress = userEmail;
      userCoverImage = userCover;
    }
    final theme = await _authRepository.currentTheme();
    final bool vendorRegisterEnable = await _authRepository.isVendorSelfRegisterEnable();
    final bool driverRegisterEnable = await _authRepository.isDriverSelfRegisterEnable();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    emit(
      state.copyWith(
        isAuthorized: isAuthorized,
        isGuestAuthorized: isGuestUser.isNotEmpty ? true : false,
        locale: locale.isNotEmpty ? locale : Environments.defaultLanguage,
        userName: userName,
        userCover: userCoverImage,
        userEmail: userEmailAddress,
        lightMode: theme,
        vendorRegisterEnable: vendorRegisterEnable,
        driverRegisterEnable: driverRegisterEnable,
        isGoogleLoggedIn: isGoogleLoggedIn,
        isFacebookLoggedIn: isFacebookLoggedIn,
        appLogo: appLogo,
        currentVersion: currentVersion,
        status: AccountStatus.initial,
      ),
    );
  }

  FutureOr<void> _onAccountLogoutEvent(AccountLogoutEvent event, Emitter<AccountState> emit) async {
    try {
      emit(state.copyWith(status: AccountStatus.logoutStart));
      if (state.isGoogleLoggedIn) {
        await GoogleSignIn.instance.disconnect();
      }
      if (state.isFacebookLoggedIn) {
        await FacebookAuth.instance.logOut();
      }
      String? refreshToken = await _authRepository.getRefreshToken();
      if (refreshToken.isNotEmpty) {
        DioApiResponse response = await _authRepository.logout(refreshToken);
        if (response.errorType == NetErrorType.none) {
          await _authRepository.onLogoutSuccess();
          emit(state.copyWith(status: AccountStatus.logoutSuccess));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          await _authRepository.onLogoutSuccess();
          emit(state.copyWith(status: AccountStatus.logoutFailed, statusCode: data.code!, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        await _authRepository.onLogoutSuccess();
        emit(state.copyWith(status: AccountStatus.logoutSuccess));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AccountStatus.logoutFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAccountChangeThemeEvent(AccountChangeThemeEvent event, Emitter<AccountState> emit) async {
    bool changeTheme = !state.lightMode;
    emit(state.copyWith(lightMode: changeTheme));
  }
}

