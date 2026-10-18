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
import 'package:user/app/core/models/request/make_wallet_payment_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/wallet_payment_list_model.dart';
import 'package:user/app/core/models/wallet_payment_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/wallet_repository.dart';
import 'package:user/app/core/validations/wallet_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'add_wallet_money_event.dart';
part 'add_wallet_money_state.dart';

class AddWalletMoneyBloc extends Bloc<AddWalletMoneyEvent, AddWalletMoneyState> {
  final WalletRepositry _walletRepositry = WalletRepositry();
  final AuthRepository _authRepository = AuthRepository();
  AddWalletMoneyBloc()
    : super(
        AddWalletMoneyState(
          basicDetail: WalletAddMoneyBasicDetailModel(payments: [], bonus: [], locale: ''),
        ),
      ) {
    on<AddWalletMoneyInitialEvent>(_onAddWalletMoneyInitialEvent);
    on<AddWalletMoneyAmountChanged>(_onAddWalletMoneyAmountChanged);
    on<AddWalletMoneyAmountUnfocused>(_onAddWalletMoneyAmountUnfocused);
    on<AddWalletMoneyIncrementEvent>(_onAddWalletMoneyIncrementEvent);
    on<AddWalletMoneyPaymentChangedEvent>(_onAddWalletMoneyPaymentChangedEvent);
    on<AddWalletMoneySubmitEvent>(_onAddWalletMoneySubmitEvent);
  }

  FutureOr<void> _onAddWalletMoneyInitialEvent(AddWalletMoneyInitialEvent event, Emitter<AddWalletMoneyState> emit) async {
    try {
      emit(state.copyWith(status: AddWalletMoneyStatus.loading));
      await _authRepository.saveEvent('visited_screen', {"screen": "add_wallet_funds"}, 'add_wallet_money_screen', 'add_wallet_money_screen');
      DioApiResponse response = await _walletRepositry.getWalletPaymentList();
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: AddWalletMoneyStatus.empty));
        } else {
          String paymentId = '';
          String paymentName = 'Online Payment';
          String paymentImageUrl = '';
          final String locale = await _authRepository.getLocale();
          WalletAddMoneyBasicDetailModel basicDetail = WalletAddMoneyBasicDetailModel.fromJson(myMap, locale.toString());
          // Single gateway decision: Razorpay online. Payment screen owns
          // method choice (UPI/Card/NB/Wallet) — no pre-selector popup.
          final rzpIndex = basicDetail.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
          if (rzpIndex != -1) {
            paymentId = basicDetail.payments![rzpIndex].id!;
            paymentName = basicDetail.payments![rzpIndex].name!;
            paymentImageUrl = basicDetail.payments![rzpIndex].image!;
          } else if (basicDetail.primary != null && basicDetail.primary!.name!.isNotEmpty) {
            paymentId = basicDetail.primary!.id!;
            paymentName = basicDetail.primary!.name!;
            paymentImageUrl = basicDetail.primary!.image!;
          } else if (basicDetail.payments!.isNotEmpty) {
            paymentId = basicDetail.payments![0].id!;
            paymentName = basicDetail.payments![0].name!;
            paymentImageUrl = basicDetail.payments![0].image!;
          }

          emit(state.copyWith(status: AddWalletMoneyStatus.newCount, payment: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, basicDetail: basicDetail));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AddWalletMoneyStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AddWalletMoneyStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onAddWalletMoneyAmountChanged(AddWalletMoneyAmountChanged event, Emitter<AddWalletMoneyState> emit) async {
    final amount = WalletAmountField.dirty(event.amount);
    emit(state.copyWith(amount: amount.isValid ? amount : WalletAmountField.pure(event.amount), status: AddWalletMoneyStatus.initial));
  }

  FutureOr<void> _onAddWalletMoneyAmountUnfocused(AddWalletMoneyAmountUnfocused event, Emitter<AddWalletMoneyState> emit) async {
    final amount = WalletAmountField.dirty(state.amount.value);
    emit(state.copyWith(amount: amount, status: AddWalletMoneyStatus.initial));
  }

  FutureOr<void> _onAddWalletMoneyIncrementEvent(AddWalletMoneyIncrementEvent event, Emitter<AddWalletMoneyState> emit) {
    double toAdd = double.parse(event.amount.toString());
    String newTotal = (double.parse(state.amount.value.toString()) + double.parse(toAdd.toString())).toStringAsFixed(2);
    final amount = WalletAmountField.dirty(newTotal);
    emit(state.copyWith(amount: amount.isValid ? amount : WalletAmountField.pure(event.amount), status: AddWalletMoneyStatus.newCount));
  }

  FutureOr<void> _onAddWalletMoneyPaymentChangedEvent(AddWalletMoneyPaymentChangedEvent event, Emitter<AddWalletMoneyState> emit) async {
    final int index = state.basicDetail.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.basicDetail.payments![index].id!;
      String paymentName = state.basicDetail.payments![index].name!;
      String paymentImageUrl = state.basicDetail.payments![index].image!;
      emit(state.copyWith(payment: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, status: AddWalletMoneyStatus.initial));
    }
  }

  FutureOr<void> _onAddWalletMoneySubmitEvent(AddWalletMoneySubmitEvent event, Emitter<AddWalletMoneyState> emit) async {
    try {
      emit(state.copyWith(status: AddWalletMoneyStatus.fetchingPaymentLink));
      final String userId = await _walletRepositry.userId();
      final double amountToAdd = double.parse(state.amount.value.toString());
      MakeWalletPaymentRequestModel param = MakeWalletPaymentRequestModel(user: userId, payment: state.payment, amount: amountToAdd, from: 'wallet', ref: 'Wallet Payments');
      DioApiResponse response = await _walletRepositry.getWalletPaymentLink(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        WalletPaymentResponseModel walletPaymentResponse = WalletPaymentResponseModel.fromJson(myMap);
        emit(state.copyWith(status: AddWalletMoneyStatus.paymentLinkFetched, paymentLinkId: walletPaymentResponse.id!));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: AddWalletMoneyStatus.paymentLinkFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: AddWalletMoneyStatus.paymentLinkFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

