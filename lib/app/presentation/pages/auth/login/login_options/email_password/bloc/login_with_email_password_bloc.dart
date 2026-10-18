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
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:formz/formz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/email_password_login_request_model.dart';
import 'package:user/app/core/models/request/facebook_account_login_request_model.dart';
import 'package:user/app/core/models/request/google_account_login_request_model.dart';
import 'package:user/app/core/models/request/push_notification_token_request_model.dart';
import 'package:user/app/core/models/request/register_facebook_user_account_request_model.dart';
import 'package:user/app/core/models/request/register_google_user_account_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/social_account_verification_modal_response_model.dart';
import 'package:user/app/core/models/social_unverified_account_response_model.dart';
import 'package:user/app/core/models/user_login_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/core/validations/login_form/email_password_login_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'login_with_email_password_event.dart';
part 'login_with_email_password_state.dart';

class LoginWithEmailPasswordBloc extends Bloc<LoginWithEmailPasswordEvent, LoginWithEmailPasswordState> {
  final AuthRepository _authRepository = AuthRepository();
  final LocationRepository _locationRepository = LocationRepository();
  LoginWithEmailPasswordBloc()
    : super(
        LoginWithEmailPasswordState(
          unVerifiedAccountResponseModel: SocialUnVerifiedAccountResponseModel(firstName: '', lastName: '', success: false),
        ),
      ) {
    on<LoginWithEmailInitialEvent>(_onLoginWithEmailInitialEvent);
    on<LoginEmailChangedEvent>(_onLoginEmailChangedEvent);
    on<LoginPasswordChangedEvent>(_onLoginPasswordChangedEvent);
    on<LoginEmailUnfocusedEvent>(_onLoginEmailUnfocusedEvent);
    on<LoginPasswordUnfocusedEvent>(_onLoginPasswordUnfocusedEvent);
    on<LoginRememberChangedEvent>(_onLoginRememberChangedEvent);
    on<LoginFormSubmitEvent>(_onLoginFormSubmitEvent);
    on<LoginWithGoogleAccountEvent>(_onLoginWithGoogleAccountEvent);
    on<LoginWithGoogleLoginFailedEvent>(_onLoginWithGoogleLoginFailedEvent);
    on<LoginWithGoogleLoginAfterSuccessEvent>(_onLoginWithGoogleLoginAfterSuccessEvent);
    on<LoginRegisterGoogleAccountEvent>(_onLoginRegisterGoogleAccountEvent);
    on<LoginWithFacebookAccountEvent>(_onLoginWithFacebookAccountEvent);
    on<LoginRegisterFacebookAccountEvent>(_onLoginRegisterFacebookAccountEvent);
  }

  FutureOr<void> _onLoginWithEmailInitialEvent(LoginWithEmailInitialEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "email_password_login"}, 'login_with_email_password_screen', 'login_with_email_password_screen');
    final bool appleSignIn = await _authRepository.isAppleSignInEnabled();
    final bool googleSignIn = await _authRepository.isGoogleSignInEnabled();
    final bool facebookSignIn = await _authRepository.isFacebookSignInEnabled();
    emit(state.copyWith(appleSignInEnabled: appleSignIn, googleSignInEnabled: googleSignIn, facebookSignInEnabled: facebookSignIn, status: LoginWithEmailPasswordStatus.initial));
    if (googleSignIn && !kIsWeb) {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      final String clientId = await _authRepository.googleOAuthClientId();
      final String serverId = await _authRepository.googleOAuthServerId();
      unawaited(
        signIn.initialize(clientId: clientId, serverClientId: serverId).then((_) {
          signIn.authenticationEvents.listen(_handleAuthenticationEvent).onError(_handleAuthenticationError);
        }),
      );
    }
  }

  FutureOr<void> _onLoginEmailChangedEvent(LoginEmailChangedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final email = LoginWithTypeOneEmailField.dirty(event.email);
    emit(state.copyWith(email: email.isValid ? email : LoginWithTypeOneEmailField.pure(event.email), status: LoginWithEmailPasswordStatus.initial, isValid: Formz.validate([email, state.password])));
  }

  FutureOr<void> _onLoginPasswordChangedEvent(LoginPasswordChangedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final password = LoginWithTypeOnePasswordField.dirty(event.password);
    emit(state.copyWith(password: password.isValid ? password : LoginWithTypeOnePasswordField.pure(event.password), status: LoginWithEmailPasswordStatus.initial, isValid: Formz.validate([state.email, password])));
  }

  FutureOr<void> _onLoginRememberChangedEvent(LoginRememberChangedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final remember = LoginWithTypeOneRememberMeField.pure(event.checked);
    emit(state.copyWith(remember: remember, status: LoginWithEmailPasswordStatus.initial));
  }

  FutureOr<void> _onLoginEmailUnfocusedEvent(LoginEmailUnfocusedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final email = LoginWithTypeOneEmailField.dirty(state.email.value);
    emit(state.copyWith(email: email, status: LoginWithEmailPasswordStatus.initial, isValid: Formz.validate([email, state.password])));
  }

  FutureOr<void> _onLoginPasswordUnfocusedEvent(LoginPasswordUnfocusedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final password = LoginWithTypeOnePasswordField.dirty(state.password.value);
    emit(state.copyWith(password: password, status: LoginWithEmailPasswordStatus.initial, isValid: Formz.validate([state.email, password])));
  }

  Future<void> _onLoginFormSubmitEvent(LoginFormSubmitEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    final email = LoginWithTypeOneEmailField.dirty(state.email.value);
    final password = LoginWithTypeOnePasswordField.dirty(state.password.value);
    final rememeber = LoginWithTypeOneRememberMeField.dirty(state.remember.value);
    emit(state.copyWith(email: email, password: password, remember: rememeber, status: LoginWithEmailPasswordStatus.initial, isValid: Formz.validate([email, password])));
    if (state.isValid && state.email.value.isNotEmpty && state.password.value.isNotEmpty) {
      emit(state.copyWith(status: LoginWithEmailPasswordStatus.inProgress));
      try {
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        final String appLocale = await _authRepository.getLocale();
        EmailPasswordLoginRequest loginParam = EmailPasswordLoginRequest(
          email: state.email.value.toString(),
          password: state.password.value.toString(),
          remember: state.remember.value,
          userAgent: userAgent,
          locale: appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage,
        );
        DioApiResponse response = await _authRepository.loginWithEmailPassword(loginParam);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveLoginResponse(data);
          if (!kIsWeb) {
            var notificationStatus = await Permission.notification.status;
            if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
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
                  await _authRepository.updatePushNotificationToken(tokenParam);
                }
              }
            }
          }
          final bool haveLocation = await _locationRepository.haveLocation();
          if (haveLocation == true) {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.success));
          } else {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.location));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onLoginWithGoogleAccountEvent(LoginWithGoogleAccountEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    if (!kIsWeb) {
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.inProgress, googleSocialLoginClicked: true));
        await GoogleSignIn.instance.authenticate();
      }
    }
  }

  FutureOr<void> _onLoginRegisterGoogleAccountEvent(LoginRegisterGoogleAccountEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.inProgress, googleSocialLoginClicked: true));
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        final String appLocale = await _authRepository.getLocale();
        RegisterGoogleUserAccountRequestModel param = RegisterGoogleUserAccountRequestModel(
          firstName: event.model.firstName!,
          lastName: event.model.lastName!,
          countryCode: event.model.countryCode!,
          mobile: event.model.mobile!,
          idToken: state.googleIdToken,
          remember: state.remember.value,
          userAgent: userAgent,
          locale: appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage,
        );
        DioApiResponse response = await _authRepository.registerGoogleUserAccount(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveGoogleLogin();
          await _authRepository.saveLoginResponse(data);
          if (!kIsWeb) {
            var notificationStatus = await Permission.notification.status;
            if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
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
                  await _authRepository.updatePushNotificationToken(tokenParam);
                }
              }
            }
          }
          final bool haveLocation = await _locationRepository.haveLocation();
          if (haveLocation == true) {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.success));
          } else {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.location));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, googleSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
    const List<String> scopes = <String>['email'];
    final GoogleSignInClientAuthorization? authorization = await user?.authorizationClient.authorizationForScopes(scopes);
    if (user != null && authorization != null) {
      add(LoginWithGoogleLoginAfterSuccessEvent(token: user.authentication.idToken!));
    } else {
      add(LoginWithGoogleLoginFailedEvent(error: 'Something went wrong'));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    final String error = e is GoogleSignInException ? 'GoogleSignInException ${e.code}: ${e.description}' : 'Unknown error: $e';
    add(LoginWithGoogleLoginFailedEvent(error: error));
  }

  FutureOr<void> _onLoginWithGoogleLoginAfterSuccessEvent(LoginWithGoogleLoginAfterSuccessEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    try {
      String userAgent = 'unknown';
      if (kIsWeb) {
        userAgent = 'browser';
      } else if (Platform.isAndroid) {
        userAgent = 'android';
      } else if (Platform.isIOS) {
        userAgent = 'ios';
      }
      final String appLocale = await _authRepository.getLocale();
      GoogleAccountLoginRequestModel param = GoogleAccountLoginRequestModel(idToken: event.token, remember: state.remember.value, userAgent: userAgent, locale: appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage);
      DioApiResponse response = await _authRepository.loginWithGoogleAccount(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel userExist = ApiStatusResponseModel.fromJson(myMap);
        if (userExist.success!) {
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveGoogleLogin();
          await _authRepository.saveLoginResponse(data);
          if (!kIsWeb) {
            var notificationStatus = await Permission.notification.status;
            if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
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
                  await _authRepository.updatePushNotificationToken(tokenParam);
                }
              }
            }
          }
          final bool haveLocation = await _locationRepository.haveLocation();
          if (haveLocation == true) {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.success, googleSocialLoginClicked: false));
          } else {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.location, googleSocialLoginClicked: false));
          }
        } else {
          SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel = SocialUnVerifiedAccountResponseModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailPasswordStatus.socialVerification, unVerifiedAccountResponseModel: unVerifiedAccountResponseModel, googleIdToken: event.token, googleSocialLoginClicked: false));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, googleSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLoginWithGoogleLoginFailedEvent(LoginWithGoogleLoginFailedEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: event.error.toString(), extraMessage: ''));
  }

  FutureOr<void> _onLoginWithFacebookAccountEvent(LoginWithFacebookAccountEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.inProgress, facebookSocialLoginClicked: true));
        final LoginResult result = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
        if (result.status == LoginStatus.success) {
          final AccessToken accessToken = result.accessToken!;
          String userAgent = 'unknown';
          if (kIsWeb) {
            userAgent = 'browser';
          } else if (Platform.isAndroid) {
            userAgent = 'android';
          } else if (Platform.isIOS) {
            userAgent = 'ios';
          }
          final String appLocale = await _authRepository.getLocale();
          FacebookAccountLoginRequestModel param = FacebookAccountLoginRequestModel(
            accessToken: accessToken.tokenString,
            remember: state.remember.value,
            userAgent: userAgent,
            locale: appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage,
          );
          DioApiResponse response = await _authRepository.loginWithFacebookAccount(param);
          if (response.errorType == NetErrorType.none) {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ApiStatusResponseModel userExist = ApiStatusResponseModel.fromJson(myMap);
            if (userExist.success!) {
              UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
              await _authRepository.saveFacebookLogin();
              await _authRepository.saveLoginResponse(data);
              if (!kIsWeb) {
                var notificationStatus = await Permission.notification.status;
                if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
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
                      await _authRepository.updatePushNotificationToken(tokenParam);
                    }
                  }
                }
              }
              final bool haveLocation = await _locationRepository.haveLocation();
              if (haveLocation == true) {
                emit(state.copyWith(status: LoginWithEmailPasswordStatus.success, facebookSocialLoginClicked: false));
              } else {
                emit(state.copyWith(status: LoginWithEmailPasswordStatus.location, facebookSocialLoginClicked: false));
              }
            } else {
              SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel = SocialUnVerifiedAccountResponseModel.fromJson(myMap);
              emit(
                state.copyWith(
                  status: LoginWithEmailPasswordStatus.socialVerification,
                  unVerifiedAccountResponseModel: unVerifiedAccountResponseModel,
                  facebookAccessToken: accessToken.tokenString,
                  facebookSocialLoginClicked: false,
                ),
              );
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, facebookSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: result.message.toString(), extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onLoginRegisterFacebookAccountEvent(LoginRegisterFacebookAccountEvent event, Emitter<LoginWithEmailPasswordState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.inProgress, facebookSocialLoginClicked: true));
        String userAgent = 'unknown';
        if (kIsWeb) {
          userAgent = 'browser';
        } else if (Platform.isAndroid) {
          userAgent = 'android';
        } else if (Platform.isIOS) {
          userAgent = 'ios';
        }
        final String appLocale = await _authRepository.getLocale();
        RegisterFacebookUserAccountRequestModel param = RegisterFacebookUserAccountRequestModel(
          firstName: event.model.firstName!,
          lastName: event.model.lastName!,
          countryCode: event.model.countryCode!,
          mobile: event.model.mobile!,
          accessToken: state.facebookAccessToken,
          remember: state.remember.value,
          userAgent: userAgent,
          locale: appLocale.isNotEmpty ? appLocale : Environments.defaultLanguage,
        );
        DioApiResponse response = await _authRepository.registerFacebookUserAccount(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          UserLoginResponseModel data = UserLoginResponseModel.fromJson(myMap);
          await _authRepository.saveFacebookLogin();
          await _authRepository.saveLoginResponse(data);
          if (!kIsWeb) {
            var notificationStatus = await Permission.notification.status;
            if (notificationStatus.isGranted || notificationStatus.isLimited || notificationStatus.isProvisional) {
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
                  await _authRepository.updatePushNotificationToken(tokenParam);
                }
              }
            }
          }
          final bool haveLocation = await _locationRepository.haveLocation();
          if (haveLocation == true) {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.success));
          } else {
            emit(state.copyWith(status: LoginWithEmailPasswordStatus.location));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, facebookSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailPasswordStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

