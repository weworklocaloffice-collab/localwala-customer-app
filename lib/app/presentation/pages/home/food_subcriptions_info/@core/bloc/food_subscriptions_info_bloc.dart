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
import 'package:user/app/core/models/subscription_tiffin_package_info_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'food_subscriptions_info_event.dart';
part 'food_subscriptions_info_state.dart';

class FoodSubscriptionsInfoBloc extends Bloc<FoodSubscriptionsInfoEvent, FoodSubscriptionsInfoState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  FoodSubscriptionsInfoBloc() : super(FoodSubscriptionsInfoState(info: SubscriptionTiffinPackageInfoModel(locale: ''))) {
    on<FoodSubscriptionsInfoInitialEvent>(_onFoodSubscriptionsInfoInitialEvent);
  }

  FutureOr<void> _onFoodSubscriptionsInfoInitialEvent(FoodSubscriptionsInfoInitialEvent event, Emitter<FoodSubscriptionsInfoState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "tiffin_subscription_detail", "id": event.id}, 'tiffin_subscription_${event.id}_screen', 'tiffin_subscription_${event.id}_screen');
      final bool isAuthorized = await _subscriptionTiffinPackagesRepository.isAuthorized();
      emit(state.copyWith(status: FoodSubscriptionsInfoStatus.loading, id: event.id, isAuthorized: isAuthorized));
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.getSubscriptionPackageDetail(event.id);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        SubscriptionTiffinPackageInfoModel data = SubscriptionTiffinPackageInfoModel.fromJson(myMap, locale.toString());
        emit(state.copyWith(status: FoodSubscriptionsInfoStatus.success, info: data));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: FoodSubscriptionsInfoStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: FoodSubscriptionsInfoStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

