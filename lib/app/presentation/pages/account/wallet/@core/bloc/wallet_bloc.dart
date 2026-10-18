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
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/wallet_info_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/wallet_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepositry _walletRepositry = WalletRepositry();
  final AuthRepository _authRepository = AuthRepository();
  WalletBloc()
    : super(
        WalletState(
          wallet: WalletInfoModel(locale: ''),
          pageSize: ApiRequestService.pageSize,
        ),
      ) {
    on<WalletInitalEvent>(_onWalletInitalEvent);
    on<WalletToggleTransactionEvent>(_onWalletToggleTransactionEvent);
    on<WalletScrollMoreTransactionEvent>(_onWalletScrollMoreTransactionEvent);
  }

  FutureOr<void> _onWalletInitalEvent(WalletInitalEvent event, Emitter<WalletState> emit) async {
    try {
      emit(state.copyWith(status: WalletStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "wallets"}, 'wallet_screen', 'wallet_screen');
      final String userId = await _walletRepositry.userId();
      if (userId.isNotEmpty) {
        emit(state.copyWith(isAuthorized: true));
        DioApiResponse response = await _walletRepositry.getWalletInfo(userId, state.pageSize, state.currentPage);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          WalletInfoModel data = WalletInfoModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(wallet: data, status: data.transaction!.isEmpty ? WalletStatus.empty : WalletStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: WalletStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } else {
        emit(state.copyWith(status: WalletStatus.unAuthorized));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: WalletStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onWalletToggleTransactionEvent(WalletToggleTransactionEvent event, Emitter<WalletState> emit) async {
    if (state.toggleTransaction == event.transaction) {
      emit(state.copyWith(toggleTransaction: ''));
    } else {
      emit(state.copyWith(toggleTransaction: event.transaction));
    }
  }

  FutureOr<void> _onWalletScrollMoreTransactionEvent(WalletScrollMoreTransactionEvent event, Emitter<WalletState> emit) async {
    if (state.wallet.transaction!.length < state.wallet.totalResults! && !state.loadMore) {
      try {
        emit(state.copyWith(loadMore: true));
        final String userId = await _walletRepositry.userId();
        DioApiResponse response = await _walletRepositry.getWalletInfo(userId, state.pageSize * 2, state.currentPage);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          final String locale = await _authRepository.getLocale();
          WalletInfoModel data = WalletInfoModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(wallet: data, loadMore: false, pageSize: state.pageSize * 2, status: data.transaction!.isEmpty ? WalletStatus.empty : WalletStatus.success));
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: WalletStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: WalletStatus.loadMoreError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

