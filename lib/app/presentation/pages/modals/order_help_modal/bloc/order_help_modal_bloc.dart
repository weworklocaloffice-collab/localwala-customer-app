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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/request/create_refund_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'order_help_modal_event.dart';
part 'order_help_modal_state.dart';

class OrderHelpModalBloc extends Bloc<OrderHelpModalEvent, OrderHelpModalState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  OrderHelpModalBloc() : super(const OrderHelpModalState()) {
    on<OrderHelpModalInitialEvent>(_onOrderHelpModalInitialEvent);
    on<OrderHelpModalRefundRequestEvent>(_onOrderHelpModalRefundRequestEvent);
    on<OrderHelpModalOrderSummaryEvent>(_onOrderHelpModalOrderSummaryEvent);
    on<OrderHelpModalOrderInvoiceEvent>(_onOrderHelpModalOrderInvoiceEvent);
  }

  FutureOr<void> _onOrderHelpModalInitialEvent(OrderHelpModalInitialEvent event, Emitter<OrderHelpModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "order_help"}, 'order_help_screen', 'order_help_screen');
    bool checkRefundRequestButton = false;
    if (event.paymentMode == 'offline' && event.orderStatus == 'delivered' && event.subscriptionOrder == false) {
      checkRefundRequestButton = true;
    }
    if (event.paymentMode == 'online' && event.subscriptionOrder == false) {
      checkRefundRequestButton = true;
    }
    emit(
      state.copyWith(
        status: OrderHelpModalStatus.initial,
        orderId: event.orderId,
        orderNumber: event.orderNumber,
        orderStatus: event.orderStatus,
        paymentMode: event.paymentMode,
        refundRequestEnable: event.refundRequestEnable,
        restaurant: event.restaurant,
        payment: event.payment,
        canRequestRefund: checkRefundRequestButton,
      ),
    );
  }

  FutureOr<void> _onOrderHelpModalRefundRequestEvent(OrderHelpModalRefundRequestEvent event, Emitter<OrderHelpModalState> emit) async {
    try {
      emit(state.copyWith(status: OrderHelpModalStatus.refundRequestStarted));
      final String userId = await _historyRepository.userId();
      CreateRefundRequestModel param = CreateRefundRequestModel(reason: event.reasonId, orders: state.orderId, user: userId, restaurant: state.restaurant, payment: state.payment);
      DioApiResponse response = await _historyRepository.createRefundRequest(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: OrderHelpModalStatus.refundRequestSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderHelpModalStatus.refundRequestFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderHelpModalStatus.refundRequestFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOrderHelpModalOrderSummaryEvent(OrderHelpModalOrderSummaryEvent event, Emitter<OrderHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: OrderHelpModalStatus.orderSummaryDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String locale = (await _historyRepository.getLocale()).isNotEmpty ? await _historyRepository.getLocale() : Environments.defaultLanguage;

        final String savePath = '${directory.path}/${Environments.appName}_Order_ID_${state.orderNumber}.pdf';

        final bool response = await _historyRepository.orderSummary(state.orderId, locale, savePath);

        if (response) {
          final params = ShareParams(title: 'Download Order Summary', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: OrderHelpModalStatus.orderSummaryDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: OrderHelpModalStatus.orderSummaryDownloadFailed, alertMessage: 'Something went wrong'));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: OrderHelpModalStatus.orderSummaryDownloadFailed, alertMessage: e.toString()));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: OrderHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }

  FutureOr<void> _onOrderHelpModalOrderInvoiceEvent(OrderHelpModalOrderInvoiceEvent event, Emitter<OrderHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: OrderHelpModalStatus.orderInvoiceDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String locale = (await _historyRepository.getLocale()).isNotEmpty ? await _historyRepository.getLocale() : Environments.defaultLanguage;
        final String savePath = "${directory.path}/${Environments.appName}_Invoice_${state.orderNumber}.pdf";
        final bool response = await _historyRepository.orderInvoice(state.orderId, locale, savePath);
        if (response) {
          final params = ShareParams(title: 'Download Order Invoice', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: OrderHelpModalStatus.orderInvoiceDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: OrderHelpModalStatus.orderInvoiceDownloadFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: OrderHelpModalStatus.orderInvoiceDownloadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: OrderHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }
}

