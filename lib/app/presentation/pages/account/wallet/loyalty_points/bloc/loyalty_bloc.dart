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
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/loyalty_points_response_mode.dart';
import 'package:user/app/core/models/request/reedem_loyalty_point_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/wallet_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'loyalty_event.dart';
part 'loyalty_state.dart';

class LoyaltyBloc extends Bloc<LoyaltyEvent, LoyaltyState> {
  final WalletRepositry _walletRepositry = WalletRepositry();
  final AuthRepository _authRepository = AuthRepository();
  LoyaltyBloc() : super(LoyaltyState(points: LoyaltyPointsResponseModel(locale: ''))) {
    on<LoyaltyInitialEvent>(_onLoyalityInitialEvent);
    on<LoyaltyRedeemPointEvent>(_onLoyaltyRedeemPointEvent);
  }

  FutureOr<void> _onLoyalityInitialEvent(LoyaltyInitialEvent event, Emitter<LoyaltyState> emit) async {
    try {
      final String userId = await _walletRepositry.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "loyalty_points"}, 'loyalty_point_screen', 'loyalty_point_screen');
      if (userId.isNotEmpty) {
        emit(state.copyWith(status: LoyaltyStatus.loading));
        DioApiResponse response = await _walletRepositry.getLoyaltyPoints(userId);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          LoyaltyPointsResponseModel data = LoyaltyPointsResponseModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(points: data, status: data.activePoints!.isEmpty ? LoyaltyStatus.empty : LoyaltyStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: LoyaltyStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: LoyaltyStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoyaltyStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onLoyaltyRedeemPointEvent(LoyaltyRedeemPointEvent event, Emitter<LoyaltyState> emit) async {
    try {
      emit(state.copyWith(status: LoyaltyStatus.redeeming));
      List<String> loyaltyPointIds = <String>[];
      for (var element in state.points.activePoints!) {
        loyaltyPointIds.add(element.id!);
      }
      final String userId = await _walletRepositry.userId();
      RedeemLoyaltyPointRequestModel param = RedeemLoyaltyPointRequestModel(user: userId, ids: loyaltyPointIds.join(','));
      DioApiResponse response = await _walletRepositry.redeemLoyaltyPoints(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel redeemResponse = ApiStatusResponseModel.fromJson(myMap);
        if (redeemResponse.success!) {
          emit(state.copyWith(status: LoyaltyStatus.redeemSuccess));
        } else {
          emit(state.copyWith(status: LoyaltyStatus.customError, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: LoyaltyStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: LoyaltyStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

