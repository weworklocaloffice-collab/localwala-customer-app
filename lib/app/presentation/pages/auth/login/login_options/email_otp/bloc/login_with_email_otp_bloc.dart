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
import 'package:user/app/core/models/register_otp_verification_response_model.dart';
import 'package:user/app/core/models/request/email_otp_login_request_model.dart';
import 'package:user/app/core/models/request/email_otp_send_verification_mail_request_model.dart';
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
import 'package:user/app/core/validations/login_form/email_otp_login_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'login_with_email_otp_event.dart';
part 'login_with_email_otp_state.dart';

class LoginWithEmailOtpBloc extends Bloc<LoginWithEmailOtpEvent, LoginWithEmailOtpState> {
  final AuthRepository _authRepository = AuthRepository();
  final LocationRepository _locationRepository = LocationRepository();
  LoginWithEmailOtpBloc()
    : super(
        LoginWithEmailOtpState(
          verification: OtpVerificationResponseModel(sent: false, provider: '', mode: '', otpLength: 0, canResendOtp: false, id: ''),
          unVerifiedAccountResponseModel: SocialUnVerifiedAccountResponseModel(firstName: '', lastName: '', success: false),
        ),
      ) {
    on<LoginWithEmailOtpInitialEvent>(_onLoginWithEmailOtpInitialEvent);
    on<LoginWithEmailOtpChangedEvent>(_onLoginWithEmailOtpChangedEvent);
    on<LoginWithEmailOtpUnfocusedEvent>(_onLoginWithEmailOtpUnfocusedEvent);
    on<LoginWithEmailOtpRememberChangedEvent>(_onLoginWithEmailOtpRememberChangedEvent);
    on<LoginWithEmailOtpFormSubmitEvent>(_onLoginWithEmailOtpFormSubmitEvent);
    on<LoginWithEmailOtpLoginNowEvent>(_onLoginWithEmailOtpLoginNowEvent);
    on<LoginWithEmailOtpGoogleAccountEvent>(_onLoginWithEmailOtpGoogleAccountEvent);
    on<LoginWithGoogleLoginFailedEvent>(_onLoginWithGoogleLoginFailedEvent);
    on<LoginWithGoogleLoginAfterSuccessEvent>(_onLoginWithGoogleLoginAfterSuccessEvent);
    on<LoginWithEmailOtpRegisterGoogleAccountEvent>(_onLoginWithEmailOtpRegisterGoogleAccountEvent);
    on<LoginWithEmailOtpFacebookAccountEvent>(_onLoginWithEmailOtpFacebookAccountEvent);
    on<LoginWithEmailOtpRegisterFacebookAccountEvent>(_onLoginWithEmailOtpRegisterFacebookAccountEvent);
  }

  FutureOr<void> _onLoginWithEmailOtpInitialEvent(LoginWithEmailOtpInitialEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "email_otp_login"}, 'login_with_email_otp_screen', 'login_with_email_otp_screen');
    final bool appleSignIn = await _authRepository.isAppleSignInEnabled();
    final bool googleSignIn = await _authRepository.isGoogleSignInEnabled();
    final bool facebookSignIn = await _authRepository.isFacebookSignInEnabled();
    emit(state.copyWith(appleSignInEnabled: appleSignIn, googleSignInEnabled: googleSignIn, facebookSignInEnabled: facebookSignIn, status: LoginWithEmailOtpStatus.initial));
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

  FutureOr<void> _onLoginWithEmailOtpChangedEvent(LoginWithEmailOtpChangedEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    final email = LoginWithTypeThreeEmailField.dirty(event.email);
    emit(state.copyWith(email: email.isValid ? email : LoginWithTypeThreeEmailField.pure(event.email), status: LoginWithEmailOtpStatus.initial, isValid: Formz.validate([email])));
  }

  FutureOr<void> _onLoginWithEmailOtpUnfocusedEvent(LoginWithEmailOtpUnfocusedEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    final email = LoginWithTypeThreeEmailField.dirty(state.email.value);
    emit(state.copyWith(email: email, status: LoginWithEmailOtpStatus.initial, isValid: Formz.validate([email])));
  }

  FutureOr<void> _onLoginWithEmailOtpRememberChangedEvent(LoginWithEmailOtpRememberChangedEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    final remember = LoginWithTypeThreeRememberMeField.pure(event.checked);
    emit(state.copyWith(remember: remember, status: LoginWithEmailOtpStatus.initial));
  }

  FutureOr<void> _onLoginWithEmailOtpFormSubmitEvent(LoginWithEmailOtpFormSubmitEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    final email = LoginWithTypeThreeEmailField.dirty(state.email.value);
    final rememeber = LoginWithTypeThreeRememberMeField.dirty(state.remember.value);
    emit(state.copyWith(email: email, remember: rememeber, status: LoginWithEmailOtpStatus.initial, isValid: Formz.validate([email])));
    if (state.isValid && state.email.value.isNotEmpty) {
      try {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress));
        final String defaultLocale = await _authRepository.getLocale();
        LoginWithEmailOtpSendVerificationMailRequestModel param = LoginWithEmailOtpSendVerificationMailRequestModel(email: state.email.value, locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage);
        DioApiResponse response = await _authRepository.loginWithEmailOtpSendEmailVerificationMail(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          OtpVerificationResponseModel data = OtpVerificationResponseModel.fromJson(myMap);
          emit(state.copyWith(verification: data, status: LoginWithEmailOtpStatus.verify));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onLoginWithEmailOtpLoginNowEvent(LoginWithEmailOtpLoginNowEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    try {
      emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress));
      final String defaultLocale = await _authRepository.getLocale();
      String userAgent = 'unknown';
      if (kIsWeb) {
        userAgent = 'browser';
      } else if (Platform.isAndroid) {
        userAgent = 'android';
      } else if (Platform.isIOS) {
        userAgent = 'ios';
      }
      LoginWithEmailOtpRequestModel param = LoginWithEmailOtpRequestModel(
        email: state.email.value,
        locale: defaultLocale.isNotEmpty ? defaultLocale : Environments.defaultLanguage,
        userAgent: userAgent,
        remember: state.remember.value,
        verificationId: state.verification.id!.isNotEmpty ? state.verification.id! : '',
        verificationCode: event.otp.isNotEmpty ? event.otp : '',
      );
      DioApiResponse response = await _authRepository.loginWithEmailOtp(param);
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
        if (haveLocation) {
          emit(state.copyWith(status: LoginWithEmailOtpStatus.success));
        } else {
          emit(state.copyWith(status: LoginWithEmailOtpStatus.location));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLoginWithEmailOtpGoogleAccountEvent(LoginWithEmailOtpGoogleAccountEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    if (!kIsWeb) {
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress, googleSocialLoginClicked: true));
        await GoogleSignIn.instance.authenticate();
      }
    }
  }

  FutureOr<void> _onLoginWithGoogleLoginFailedEvent(LoginWithGoogleLoginFailedEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: event.error.toString(), extraMessage: ''));
  }

  FutureOr<void> _onLoginWithGoogleLoginAfterSuccessEvent(LoginWithGoogleLoginAfterSuccessEvent event, Emitter<LoginWithEmailOtpState> emit) async {
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
            emit(state.copyWith(status: LoginWithEmailOtpStatus.success, googleSocialLoginClicked: false));
          } else {
            emit(state.copyWith(status: LoginWithEmailOtpStatus.location, googleSocialLoginClicked: false));
          }
        } else {
          SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel = SocialUnVerifiedAccountResponseModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailOtpStatus.socialVerification, unVerifiedAccountResponseModel: unVerifiedAccountResponseModel, googleIdToken: event.token, googleSocialLoginClicked: false));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, googleSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
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

  FutureOr<void> _onLoginWithEmailOtpRegisterGoogleAccountEvent(LoginWithEmailOtpRegisterGoogleAccountEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress, googleSocialLoginClicked: true));
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
            emit(state.copyWith(status: LoginWithEmailOtpStatus.success));
          } else {
            emit(state.copyWith(status: LoginWithEmailOtpStatus.location));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, googleSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, googleSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onLoginWithEmailOtpFacebookAccountEvent(LoginWithEmailOtpFacebookAccountEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress, facebookSocialLoginClicked: true));
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
                emit(state.copyWith(status: LoginWithEmailOtpStatus.success, facebookSocialLoginClicked: false));
              } else {
                emit(state.copyWith(status: LoginWithEmailOtpStatus.location, facebookSocialLoginClicked: false));
              }
            } else {
              SocialUnVerifiedAccountResponseModel unVerifiedAccountResponseModel = SocialUnVerifiedAccountResponseModel.fromJson(myMap);
              emit(
                state.copyWith(status: LoginWithEmailOtpStatus.socialVerification, unVerifiedAccountResponseModel: unVerifiedAccountResponseModel, facebookAccessToken: accessToken.tokenString, facebookSocialLoginClicked: false),
              );
            }
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, facebookSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: result.message.toString(), extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }

  FutureOr<void> _onLoginWithEmailOtpRegisterFacebookAccountEvent(LoginWithEmailOtpRegisterFacebookAccountEvent event, Emitter<LoginWithEmailOtpState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.inProgress, facebookSocialLoginClicked: true));
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
            emit(state.copyWith(status: LoginWithEmailOtpStatus.success));
          } else {
            emit(state.copyWith(status: LoginWithEmailOtpStatus.location));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, facebookSocialLoginClicked: false, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: LoginWithEmailOtpStatus.failure, facebookSocialLoginClicked: false, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

