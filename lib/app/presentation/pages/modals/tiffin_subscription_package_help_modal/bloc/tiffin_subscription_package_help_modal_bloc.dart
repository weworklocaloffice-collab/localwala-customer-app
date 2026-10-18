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
import 'package:user/app/core/models/request/tiffin_subscription_refund_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:user/app/env.dart';

part 'tiffin_subscription_package_help_modal_event.dart';
part 'tiffin_subscription_package_help_modal_state.dart';

class TiffinSubscriptionPackageHelpModalBloc extends Bloc<TiffinSubscriptionPackageHelpModalEvent, TiffinSubscriptionPackageHelpModalState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  TiffinSubscriptionPackageHelpModalBloc() : super(const TiffinSubscriptionPackageHelpModalState()) {
    on<TiffinSubscriptionPackageHelpModalInitialEvent>(_onTiffinSubscriptionPackageHelpModalInitialEvent);
    on<TiffinSubscriptionPackageHelpModalRefundRequestEvent>(_onTiffinSubscriptionPackageHelpModalRefundRequestEvent);
    on<TiffinSubscriptionPackageHelpModalSummaryEvent>(_onTiffinSubscriptionPackageHelpModalSummaryEvent);
    on<TiffinSubscriptionPackageHelpModalInvoiceEvent>(_onTiffinSubscriptionPackageHelpModalInvoiceEvent);
  }

  FutureOr<void> _onTiffinSubscriptionPackageHelpModalInitialEvent(TiffinSubscriptionPackageHelpModalInitialEvent event, Emitter<TiffinSubscriptionPackageHelpModalState> emit) async {
    await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_help"}, 'tiffin_subscription_help_screen', 'tiffin_subscription_help_screen');
    emit(
      state.copyWith(
        status: TiffinSubscriptionPackageHelpModalStatus.initial,
        purchaseId: event.purchaseId,
        subscriptionPackage: event.subscriptionPackage,
        restaurant: event.restaurant,
        payment: event.payment,
        purchaseStatus: event.purchaseStatus,
        refundRequestEnable: event.refundRequestEnable,
        requestedOffDates: event.requestedOffDates,
        offDays: event.offDays,
        totalOrders: event.totalOrders,
      ),
    );
  }

  FutureOr<void> _onTiffinSubscriptionPackageHelpModalRefundRequestEvent(TiffinSubscriptionPackageHelpModalRefundRequestEvent event, Emitter<TiffinSubscriptionPackageHelpModalState> emit) async {
    try {
      emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.refundRequestStarted));
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      TiffinSubscriptionRefundRequestModel param = TiffinSubscriptionRefundRequestModel(
        reason: event.reasonId,
        user: userId,
        purchaseId: state.purchaseId,
        subscriptionPackage: state.subscriptionPackage,
        restaurant: state.restaurant,
        payment: state.payment,
      );
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.sendTiffinSubscriptionRefundRequest(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (initialResponse.success!) {
          emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.refundRequestSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.refundRequestFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.refundRequestFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onTiffinSubscriptionPackageHelpModalSummaryEvent(TiffinSubscriptionPackageHelpModalSummaryEvent event, Emitter<TiffinSubscriptionPackageHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.summaryDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String savePath = "${directory.path}/${Environments.appName}_Tiffin_Subscription_Summary_ID_${state.purchaseId}.pdf";
        final bool response = await _subscriptionTiffinPackagesRepository.downloadSummary(state.purchaseId, savePath);
        if (response) {
          final params = ShareParams(title: 'Download Tiffin Meal Summary', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.summaryDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.summaryDownloadFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.summaryDownloadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }

  FutureOr<void> _onTiffinSubscriptionPackageHelpModalInvoiceEvent(TiffinSubscriptionPackageHelpModalInvoiceEvent event, Emitter<TiffinSubscriptionPackageHelpModalState> emit) async {
    if (!kIsWeb) {
      try {
        emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.invoiceDownloadStarted));
        Directory directory;
        if (Platform.isAndroid || Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          throw Exception('Unsupported platform');
        }

        final String savePath = "${directory.path}/${Environments.appName}_Tiffin_Subscription_Invoice_ID_${state.purchaseId}.pdf";
        final bool response = await _subscriptionTiffinPackagesRepository.downloadInvoice(state.purchaseId, savePath);
        if (response) {
          final params = ShareParams(title: 'Download Tiffin Meal Invoice', files: [XFile(savePath)]);
          await SharePlus.instance.share(params);
          emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.invoiceDownloadSuccess, downloadPath: savePath));
        } else {
          emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.invoiceDownloadFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.invoiceDownloadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    } else {
      emit(state.copyWith(status: TiffinSubscriptionPackageHelpModalStatus.customError, statusCode: 0, alertMessage: 'File cannot be downloaded from the browser. Please use a mobile device to download.', extraMessage: ''));
    }
  }
}

