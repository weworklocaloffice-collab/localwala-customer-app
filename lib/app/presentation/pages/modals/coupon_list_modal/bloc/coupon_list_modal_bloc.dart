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
import 'package:user/app/core/models/coupon_list_response_model.dart';
import 'package:user/app/core/models/request/redeem_coupon_request_model.dart';
import 'package:user/app/core/models/request/user_coupon_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'coupon_list_modal_event.dart';
part 'coupon_list_modal_state.dart';

class CouponListModalBloc extends Bloc<CouponListModalEvent, CouponListModalState> {
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  CouponListModalBloc()
    : super(
        CouponListModalState(
          coupons: CouponListResponseModel(coupons: [], totalResults: 0, success: false, locale: ''),
        ),
      ) {
    on<CouponListModalInitialEvent>(_onCouponListModalInitialEvent);
    on<CouponListModalOpenDiscriptionEvent>(_onCouponListModalOpenDiscriptionEvent);
    on<CouponListModalSelectCouponEvent>(_onCouponListModalSelectCouponEvent);
  }

  FutureOr<void> _onCouponListModalInitialEvent(CouponListModalInitialEvent event, Emitter<CouponListModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_coupon"}, 'order_coupon_screen', 'order_coupon_screen');
      emit(state.copyWith(restaurant: event.restaurant, trackingId: event.trackingId, itemTotal: event.itemTotal, status: CouponListModalStatus.loading));
      UserCouponRequestModel param = UserCouponRequestModel(latitude: event.latitude, longitude: event.longitude);
      DioApiResponse response = await _cartRepository.getUserCoupon(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: CouponListModalStatus.empty));
        } else {
          final String locale = await _authRepository.getLocale();
          CouponListResponseModel couponList = CouponListResponseModel.fromJson(myMap, locale.toString());
          for (var element in couponList.coupons!) {
            if (event.itemTotal >= element.minCartTotal! || element.couponType! == 'bogo') {
              element.enabled = true;
            } else {
              element.enabled = false;
              String requiredAmount = (double.parse(element.minCartTotal!.toString()) - double.parse(event.itemTotal.toString())).toStringAsFixed(2);
              double amountRequired = double.parse(requiredAmount);
              element.requiredAmount = amountRequired;
            }

            if (element.couponType == 'default' || element.couponType == 'restaurant' || element.couponType == 'firstorder') {
              if (element.discountType == 'amount') {
                element.promoLbl = 'Save ${kAppPriceFormat(element.minDiscount!)} with this discount';
              } else {
                double percentage(numFirst, per) {
                  return (numFirst / 100) * per;
                }

                String minDiscount = (double.parse(percentage(event.itemTotal, element.minDiscount).toString())).toStringAsFixed(2);
                String maxDiscount = (double.parse(percentage(event.itemTotal, element.maxDiscount).toString())).toStringAsFixed(2);
                double minSave = double.parse(minDiscount);
                double maxSave = double.parse(maxDiscount);
                element.minSave = minSave;
                element.maxSave = maxSave;
                element.promoLbl = element.maxDiscount! > 0 ? 'Save ${kAppPriceFormat(minSave)} to ${kAppPriceFormat(maxSave)} with this code' : 'Save ${kAppPriceFormat(minSave)} with this code';
              }
            } else if (element.couponType == 'loyality') {
              element.promoLbl = 'Earn ${element.loyalityPoints} loyality points with this code on your wallet';
            } else if (element.couponType == 'bogo') {
              element.promoLbl = 'Buy One Get One Free with this code';
            } else if (element.couponType == 'freedelivery') {
              element.promoLbl = 'Save delivery charges with this code';
            }
          }
          emit(state.copyWith(coupons: couponList, status: CouponListModalStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CouponListModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CouponListModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCouponListModalOpenDiscriptionEvent(CouponListModalOpenDiscriptionEvent event, Emitter<CouponListModalState> emit) async {
    state.coupons.coupons![event.index].isOpened = !state.coupons.coupons![event.index].isOpened!;
    emit(state.copyWith(coupons: state.coupons, status: CouponListModalStatus.success));
  }

  FutureOr<void> _onCouponListModalSelectCouponEvent(CouponListModalSelectCouponEvent event, Emitter<CouponListModalState> emit) async {
    try {
      if (state.coupons.coupons![event.index].enabled! == true) {
        final String userId = await _cartRepository.userId();

        bool isEnableForMe = false;
        if (state.coupons.coupons![event.index].allRestaurants! == true && state.coupons.coupons![event.index].allUsers! == true) {
          isEnableForMe = true;
        } else if (state.coupons.coupons![event.index].allRestaurants! == false &&
            state.coupons.coupons![event.index].allUsers! == false &&
            state.coupons.coupons![event.index].restaurant!.contains(state.restaurant) &&
            state.coupons.coupons![event.index].user!.contains(userId)) {
          isEnableForMe = true;
        } else if (state.coupons.coupons![event.index].allRestaurants! == true && state.coupons.coupons![event.index].allUsers! == false && state.coupons.coupons![event.index].user!.contains(userId)) {
          isEnableForMe = true;
        } else if (state.coupons.coupons![event.index].allRestaurants! == false && state.coupons.coupons![event.index].restaurant!.contains(state.restaurant) && state.coupons.coupons![event.index].allUsers! == true) {
          isEnableForMe = true;
        }
        if (isEnableForMe == true) {
          final String? couponId = state.coupons.coupons![event.index].id;
          emit(state.copyWith(redeemCouponIndex: event.index, status: CouponListModalStatus.couponRedeemStart));
          RedeemCouponRequestModel param = RedeemCouponRequestModel(user: userId, coupon: couponId!, tracking: state.trackingId, restaurant: state.restaurant);
          DioApiResponse response = await _cartRepository.redeemCoupon(param);
          if (response.errorType == NetErrorType.none) {
            emit(state.copyWith(status: CouponListModalStatus.couponRedeemSuccess));
          } else {
            Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: CouponListModalStatus.couponRedeemFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          emit(state.copyWith(status: CouponListModalStatus.validationFailure, statusCode: 0, alertMessage: 'Opps, Sorry this coupon is not available for you.', extraMessage: ''));
        }
      } else {
        emit(
          state.copyWith(
            status: CouponListModalStatus.validationFailure,
            statusCode: 0,
            alertMessage: 'Opps, Sorry. you required minimum ##dynamic## on your cart.',
            extraMessage: kAppPriceFormat(state.coupons.coupons![event.index].minCartTotal!),
          ),
        );
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CouponListModalStatus.couponRedeemFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

