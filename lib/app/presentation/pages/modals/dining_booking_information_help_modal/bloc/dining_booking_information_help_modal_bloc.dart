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
import 'package:user/app/core/models/request/dining_booking_refund_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/dining_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'dining_booking_information_help_modal_event.dart';
part 'dining_booking_information_help_modal_state.dart';

class DiningBookingInformationHelpModalBloc extends Bloc<DiningBookingInformationHelpModalEvent, DiningBookingInformationHelpModalState> {
  final DiningRepository _diningRepository = DiningRepository();
  final AuthRepository _authRepository = AuthRepository();
  DiningBookingInformationHelpModalBloc() : super(const DiningBookingInformationHelpModalState()) {
    on<DiningBookingInformationHelpModalInitialEvent>(_onDiningBookingInformationHelpModalInitialEvent);
    on<DiningBookingInformationHelpModalRefundRequestEvent>(_onDiningBookingInformationHelpModalRefundRequestEvent);
    on<DiningBookingInformationHelpModalSummaryEvent>(_onDiningBookingInformationHelpModalSummaryEvent);
    on<DiningBookingInformationHelpModalInvoiceEvent>(_onDiningBookingInformationHelpModalInvoiceEvent);
  }

  FutureOr<void> _onDiningBookingInformationHelpModalInitialEvent(DiningBookingInformationHelpModalInitialEvent event, Emitter<DiningBookingInformationHelpModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "dining_booking_help"}, 'dining_booking_help_screen', 'dining_booking_help_screen');
    bool checkRefundRequestButton = false;
    if (event.paymentMode == 'online') {
      checkRefundRequestButton = true;
    }
    emit(
      state.copyWith(
        status: DiningBookingInformationHelpModalStatus.initial,
        bookingId: event.bookingId,
        bookingStatus: event.bookingStatus,
        paymentMode: event.paymentMode,
        refundRequestEnable: event.refundRequestEnable,
        restaurant: event.restaurant,
        payment: event.payment,
        canRequestRefund: checkRefundRequestButton,
      ),
    );
  }

  FutureOr<void> _onDiningBookingInformationHelpModalRefundRequestEvent(DiningBookingInformationHelpModalRefundRequestEvent event, Emitter<DiningBookingInformationHelpModalState> emit) async {
    try {
      emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.refundRequestStarted));
      final String userId = await _diningRepository.userId();
      DiningBookingRefundRequestModel param = DiningBookingRefundRequestModel(user: userId, booking: state.bookingId, reason: event.reasonId, restaurant: state.restaurant, payment: state.payment);
      DioApiResponse response = await _diningRepository.createDiningBookingRefundRequest(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.refundRequestSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.refundRequestFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.refundRequestFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDiningBookingInformationHelpModalSummaryEvent(DiningBookingInformationHelpModalSummaryEvent event, Emitter<DiningBookingInformationHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.summaryDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String savePath = "${directory.path}/${Environments.appName}_Dining_Booking_Summary_ID_${state.bookingId}.pdf";
        final bool response = await _diningRepository.downloadSummary(state.bookingId, savePath);
        if (response) {
          final params = ShareParams(title: 'Download Dining Booking Summary', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.summaryDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.summaryDownloadFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.summaryDownloadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }

  FutureOr<void> _onDiningBookingInformationHelpModalInvoiceEvent(DiningBookingInformationHelpModalInvoiceEvent event, Emitter<DiningBookingInformationHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.invoiceDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String savePath = "${directory.path}/${Environments.appName}_Dining_Booking_Invoice_ID_${state.bookingId}.pdf";
        final bool response = await _diningRepository.downloadInvoice(state.bookingId, savePath);
        if (response) {
          final params = ShareParams(title: 'Download Dining Booking Invoice', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.invoiceDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.invoiceDownloadFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.invoiceDownloadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: DiningBookingInformationHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }
}

