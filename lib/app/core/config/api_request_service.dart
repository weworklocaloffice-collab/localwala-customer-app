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

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_endpoints.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/env.dart';
import 'package:user/app/services/shared_pref.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiRequestService {
  Dio _dio = Dio();
  static String baseUrl = Environments.apiBaseURL;
  static int timeoutInSeconds = 30;
  static int pageSize = 20;
  final SharedPreferencesManager _sharedPreferencesManager = SharedPreferencesManager();

  ApiRequestService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        responseType: ResponseType.json,
        contentType: 'application/json',
        connectTimeout: Duration(seconds: timeoutInSeconds),
        receiveTimeout: Duration(seconds: timeoutInSeconds),
      ),
    );
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
          String? authToken = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.authToken);
          if (authToken != null && authToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          String? authRefreshToken = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.authRefreshToken);

          bool isRejected = false;
          if (error.response?.statusCode != null && error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/') && authRefreshToken != null && authRefreshToken.isNotEmpty) {
            try {
              Response refreshResponse = await _dio.post(ApiEndPoints.v1request.refreshToken, data: {'refreshToken': authRefreshToken});
              if (refreshResponse.statusCode == 200) {
                RefreshTokenModel data = RefreshTokenModel.fromJson(refreshResponse.data);
                if (data.access!.token != null && data.refresh!.token != null && data.access!.token!.isNotEmpty && data.refresh!.token!.isNotEmpty) {
                  await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authToken, data.access!.token!);
                  await _sharedPreferencesManager.putString(SharedPreferencesKey.authKeys.authRefreshToken, data.refresh!.token!);
                  final opts = Options(
                    method: error.requestOptions.method,
                    extra: error.requestOptions.extra,
                    headers: error.requestOptions.headers,
                    contentType: error.requestOptions.contentType,
                    responseType: error.requestOptions.responseType,
                    listFormat: error.requestOptions.listFormat,
                  );

                  final cloneReq = await _dio.request(error.requestOptions.path, options: opts, data: error.requestOptions.data, queryParameters: error.requestOptions.queryParameters);

                  return handler.resolve(cloneReq);
                } else {
                  authFailed();
                  isRejected = true;
                  handler.reject(error);
                }
              } else {
                authFailed();
                isRejected = true;
                handler.reject(error);
              }
            } catch (e, stacktrace) {
              authFailed();
              isRejected = true;
              handler.reject(error);
              if (!kIsWeb) {
                FirebaseCrashlytics.instance.recordError(e, stacktrace);
              }
            }
          } else if (error.response?.statusMessage != null) {
            isRejected = true;
            return handler.reject(error);
          }
          if (isRejected == false) {
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> authFailed() async {
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.authRefreshToken);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.authToken);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.uid);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userFirstName);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userLastName);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userCover);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userEmail);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userRole);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userMobile);
    await _sharedPreferencesManager.clearKey(SharedPreferencesKey.authKeys.userCountryCode);
  }

  Future<DioApiResponse> googleDirection(double latFirst, double lngFirst, double latSecond, double lngSecond) async {
    try {
      Dio externalRequest = Dio();
      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=$latFirst,$lngFirst&destination=$latSecond,$lngSecond&key=${Environments.googleMapsKey}";
      final response = await externalRequest.get(url);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<DioApiResponse> get(String endPoint) async {
    try {
      final response = await _dio.get(endPoint);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<DioApiResponse> post(String endPoint, {dynamic body}) async {
    try {
      final response = await _dio.post(endPoint, data: body);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<DioApiResponse> delete(String endPoint) async {
    try {
      final response = await _dio.delete(endPoint);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<DioApiResponse> patch(String endPoint, {dynamic body}) async {
    try {
      final response = await _dio.patch(endPoint, data: body);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<DioApiResponse> uploadImageFile(String endPoint, String uid, XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({"fileName": await MultipartFile.fromFile(file.path, filename: fileName, contentType: MediaType('image', 'jpeg')), "uid": uid});
      final response = await _dio.post(endPoint, data: formData);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return parseDioError(e);
    }
  }

  Future<bool> download(String endPoint, String path) async {
    try {
      String? authToken = await _sharedPreferencesManager.getString(SharedPreferencesKey.authKeys.authToken);
      Dio dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          responseType: ResponseType.bytes,
          connectTimeout: Duration(seconds: timeoutInSeconds),
          receiveTimeout: Duration(seconds: timeoutInSeconds),
          headers: {'Authorization': 'Bearer $authToken', 'Content-Type': 'application/json'},
        ),
      );
      await dio.download(endPoint, path);
      return true;
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      return false;
    }
  }

  DioApiResponse parseResponse(Response res) {
    DioApiResponse response = DioApiResponse(res);
    return response;
  }

  /// Timeout / offline have NO response — old `e.response!` crashed with
  /// "Null check operator used on a null value" (your placeOrder log).
  /// Build a synthetic response so callers get timedOut + retry dialog.
  DioApiResponse parseDioError(DioException e) {
    if (e.response != null) return parseResponse(e.response!);
    final req = e.requestOptions;
    int code;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      code = 508;
    } else if (e.type == DioExceptionType.connectionError) {
      code = 503;
    } else if (e.type == DioExceptionType.cancel) {
      code = 499;
    } else {
      code = 500;
    }
    final synthetic = Response(
      requestOptions: req,
      statusCode: code,
      data: {'code': code, 'message': e.message ?? e.toString(), 'extra': e.type.name},
    );
    return parseResponse(synthetic);
  }
}

class DioApiResponse {
  final Response raw;
  NetErrorType errorType = NetErrorType.none;
  bool get success => errorType == NetErrorType.none;
  String get body => jsonEncode(raw.data);
  Headers get headers => raw.headers;
  int? get statusCode => raw.statusCode;

  DioApiResponse(this.raw) {
    if (raw.statusCode! >= 200 && raw.statusCode! <= 299) {
      errorType = NetErrorType.none;
    } else if (raw.statusCode! >= 500 && raw.statusCode! < 600) {
      errorType = NetErrorType.timedOut;
    } else if (raw.statusCode! >= 400 && raw.statusCode! < 500) {
      errorType = NetErrorType.denied;
    } else {
      errorType = NetErrorType.unknown;
    }
  }
}

enum NetErrorType { none, disconnected, timedOut, denied, unknown }

class RefreshTokenModel {
  Access? access;
  Access? refresh;

  RefreshTokenModel({this.access, this.refresh});

  RefreshTokenModel.fromJson(Map<String, dynamic> json) {
    access = json['access'] != null ? Access.fromJson(json['access']) : null;
    refresh = json['refresh'] != null ? Access.fromJson(json['refresh']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (access != null) {
      data['access'] = access!.toJson();
    }
    if (refresh != null) {
      data['refresh'] = refresh!.toJson();
    }
    return data;
  }
}

class Access {
  String? token;
  String? expires;

  Access({this.token, this.expires});

  Access.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['expires'] = expires;
    return data;
  }
}

class ApiExternalRequestService {
  Dio _dio = Dio();
  static int timeoutInSeconds = 30;
  ApiExternalRequestService() {
    _dio = Dio(
      BaseOptions(
        responseType: ResponseType.json,
        contentType: 'application/json',
        connectTimeout: Duration(seconds: timeoutInSeconds),
        receiveTimeout: Duration(seconds: timeoutInSeconds),
      ),
    );
  }

  Future<DioApiResponse> getExternal(String endPoint) async {
    try {
      final response = await _dio.get(endPoint);
      return parseResponse(response);
    } on DioException catch (e, stacktrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
      if (e.response != null) return parseResponse(e.response!);
      final synthetic = Response(
        requestOptions: e.requestOptions,
        statusCode: 503,
        data: {'code': 503, 'message': e.message ?? e.toString(), 'extra': e.type.name},
      );
      return parseResponse(synthetic);
    }
  }

  DioApiResponse parseResponse(Response res) {
    DioApiResponse response = DioApiResponse(res);
    return response;
  }
}

