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
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/intl.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/coupon_list_response_model.dart';
import 'package:user/app/core/models/create_order_response_model.dart';
import 'package:user/app/core/models/delivery_address_modal_response_model.dart';
import 'package:user/app/core/models/delivery_instruction_modal_response_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/order_settings_model.dart';
import 'package:user/app/core/models/request/order_settings_request_model.dart';
import 'package:user/app/core/models/request/place_order_request_model.dart';
import 'package:user/app/core/models/request/remove_from_cart_with_uuid_request_model.dart';
import 'package:user/app/core/models/request/update_cart_food_variation_quantity_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/cart_repository.dart';
import 'package:user/app/env.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartRepository _cartRepository = CartRepository();
  final AuthRepository _authRepository = AuthRepository();
  CheckoutBloc()
    : super(
        CheckoutState(
          orderSettings: OrderSettingsModel(locale: ''),
          couponData: CouponConfigModel(locale: ''),
        ),
      ) {
    on<CheckoutInitialEvent>(_onCheckoutInitialEvent);
    on<CheckoutQuantityEvent>(_onCheckoutQuantityEvent);
    on<CheckoutPaymentChangedEvent>(_onCheckoutPaymentChangedEvent);
    on<CheckoutInstructionsEvent>(_onCheckoutInstructionsEvent);
    on<CheckoutDeliveryAddressChangeEvent>(_onCheckoutDeliveryAddressChangeEvent);
    on<CheckoutDeliveryInstructionChangeEvent>(_onCheckoutDeliveryInstructionChangeEvent);
    on<CheckoutDeliveryInstructionClearEvent>(_onCheckoutDeliveryInstructionClearEvent);
    on<CheckoutReceiverChangeEvent>(_onCheckoutReceiverChangeEvent);
    on<CheckoutBillingInfoExtraChargeEvent>(_onCheckoutBillingInfoExtraChargeEvent);
    on<CheckoutCouponCodeResponseEvent>(_onCheckoutCouponCodeResponseEvent);
    on<CheckoutRemoveCouponEvent>(_onCheckoutRemoveCouponEvent);
    on<CheckoutWalletUseEvent>(_onCheckoutWalletUseEvent);
    on<CheckoutCouponValidationErrorEvent>(_onCheckoutCouponValidationErrorEvent);
    on<CheckoutChangeOrderToEvent>(_onCheckoutChangeOrderToEvent);
    on<CheckoutScheduleDateEvent>(_onCheckoutScheduleDateEvent);
    on<CheckoutScheduleTimeEvent>(_onCheckoutScheduleTimeEvent);
    on<CheckoutCreateOrderEvent>(_onCheckoutCreateOrderEvent);
  }

  FutureOr<void> _onCheckoutInitialEvent(CheckoutInitialEvent event, Emitter<CheckoutState> emit) async {
    try {
      final String defaultLanguage = await _cartRepository.getLocale();
      final String userId = await _cartRepository.userId();
      await _authRepository.saveEvent('visited_screen', {"screen": "checkout"}, 'checkout_screen', 'checkout_screen');
      final currentDate = DateTime.now();
      final String locale = await _authRepository.getLocale();
      emit(
        state.copyWith(
          status: CheckoutStatus.loading,
          user: userId,
          restaurant: event.restaurant,
          trackingId: await _cartRepository.trackingId(),
          locale: defaultLanguage.isNotEmpty ? defaultLanguage : Environments.defaultLanguage,
          orderTo: 'homedelivery',
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          inCart: const [],
          foodInstruction: '',
          deliveryInstructionId: '',
          deliveryInstruction: '',
          deliveryInstructionImage: '',
          itemTotal: 0,
          realPrice: 0,
          itemDiscount: 0,
          couponUsed: false,
          couponTitle: '',
          couponData: CouponConfigModel(locale: locale.toString()),
          couponDiscount: 0,
          walletUsed: false,
          walletAmount: 0,
          serviceCharge: 0,
          serviceChargeName: '',
          foodServiceCharge: 0,
          foodServiceChargeName: '',
          deliveryTip: 0,
          extraCharge: 0,
          deliveryCharge: 0,
          packagingCharges: 0,
          packagingChargesTax: 0,
          grandTotal: 0,
          deliveryAddressId: '',
          payment: '',
          paymentName: '',
          paymentImageURL: '',
          addressTitle: '',
          addressSubTitle: '',
          receiverName: '',
          receiverCountryCode: '',
          receiverContact: '',
          instantOrder: false,
          scheduleOrder: false,
          scheduleDate: '${currentDate.year}-${currentDate.month}-${currentDate.day}',
          scheduleTime: '',
          timeSlots: const [],
          customerCanOrderWithinDays: 0,
          canDeliverNow: false,
          paymentURL: '',
          statusCode: 0,
          alertMessage: '',
          extraMessage: '',
        ),
      );

      final double userLatitude = await _cartRepository.userLatitude();
      final double userLongitude = await _cartRepository.userLongitude();
      final String deliveryAddressId = await _cartRepository.checkoutAddressId();

      OrderSettingsRequestModel param = OrderSettingsRequestModel(
        userId: userId,
        restaurant: event.restaurant,
        deliveryAddressId: deliveryAddressId,
        userLatitude: userLatitude != 0 ? userLatitude : 0,
        userLongitude: userLongitude != 0 ? userLongitude : 0,
        trackingId: await _cartRepository.trackingId(),
      );
      DioApiResponse response = await _cartRepository.getOrderSettings(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        OrderSettingsModel orderSettingResponse = OrderSettingsModel.fromJson(myMap, locale.toString());
        double itemTotal = 0;
        double realPrice = 0;
        double itemDiscount = 0;

        await _cartRepository.getByRestaurant(event.restaurant).then((value) async {
          for (var element in value) {
            if (orderSettingResponse.foods!.foodInfoInCart!.isNotEmpty) {
              for (var foodInServer in orderSettingResponse.foods!.foodInfoInCart!) {
                if (element.id == foodInServer.id) {
                  element.price = foodInServer.price!;
                  element.discountType = foodInServer.discountType!;
                  element.discount = foodInServer.discount!;
                  element.purchaseLimit = foodInServer.purchaseLimit!;
                  element.stockNumber = foodInServer.stockNumber!;
                  element.stockType = foodInServer.stockType!;

                  if (element.addons!.isNotEmpty) {
                    for (var elementAddon in element.addons!) {
                      if (foodInServer.addons!.isNotEmpty) {
                        for (var foodInServerAddon in foodInServer.addons!) {
                          if (elementAddon.id! == foodInServerAddon.id!) {
                            elementAddon.price = foodInServerAddon.price!;
                            elementAddon.stockNumber = foodInServerAddon.stockNumber!;
                            elementAddon.stockType = foodInServerAddon.stockType!;
                          }
                        }
                      }
                    }
                  }

                  if (element.variations!.isNotEmpty) {
                    for (var elementVariation in element.variations!) {
                      if (foodInServer.variations!.isNotEmpty) {
                        for (var foodInServerVariation in foodInServer.variations!) {
                          if (elementVariation.title! == foodInServerVariation.title!) {
                            if (elementVariation.options!.isNotEmpty) {
                              for (var elementVariationOption in elementVariation.options!) {
                                if (foodInServerVariation.options!.isNotEmpty) {
                                  for (var foodInServerVariationOption in foodInServerVariation.options!) {
                                    if (elementVariationOption.name! == foodInServerVariationOption.name!) {
                                      elementVariationOption.price = foodInServerVariationOption.price!;
                                      elementVariationOption.stock = foodInServerVariationOption.stock!;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }

                  element.taxationEnable = foodInServer.taxationEnable!;

                  if (element.foodtaxations!.isNotEmpty) {
                    for (var elementFoodTaxation in element.foodtaxations!) {
                      if (foodInServer.foodtaxations!.isNotEmpty) {
                        for (var foodInServerFoodTaxation in foodInServer.foodtaxations!) {
                          if (elementFoodTaxation.id! == foodInServerFoodTaxation.id!) {
                            elementFoodTaxation.taxAmount = foodInServerFoodTaxation.taxAmount!;
                          }
                        }
                      }
                    }
                  }
                  await _cartRepository.syncProductWithServer(element.uuid!, element.id!, element);
                }
              }
            }
          }
        });

        await _cartRepository.getByRestaurant(event.restaurant).then((value) {
          for (var element in value) {
            String countTotal = (double.parse(itemTotal.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotal = double.parse(countTotal);
            String realCountTotal = (double.parse(realPrice.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
            realPrice = double.parse(realCountTotal);
            String itemDisountCountTotal = (double.parse(itemDiscount.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
            itemDiscount = double.parse(itemDisountCountTotal);
          }
          emit(state.copyWith(inCart: value, itemTotal: itemTotal, realPrice: realPrice, itemDiscount: itemDiscount));
        });

        String paymentId = '';
        String paymentName = 'Online Payment';
        String paymentImageUrl = '';
        // CustomUI: force Razorpay online (UPI/Card/NB/Wallet/PayLater in-app).
        // Never auto-select COD — COD would bypass CustomUI submit().
        final rzpIndex = orderSettingResponse.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
        if (rzpIndex != -1) {
          paymentId = orderSettingResponse.payments![rzpIndex].id!;
          paymentName = _displayPaymentName(
              orderSettingResponse.payments![rzpIndex].slug, orderSettingResponse.payments![rzpIndex].name);
          paymentImageUrl = orderSettingResponse.payments![rzpIndex].image!;
        } else if (orderSettingResponse.primary != null && orderSettingResponse.primary!.name!.isNotEmpty) {
          paymentId = orderSettingResponse.primary!.id!;
          paymentName = _displayPaymentName(orderSettingResponse.primary!.slug, orderSettingResponse.primary!.name);
          paymentImageUrl = orderSettingResponse.primary!.image!;
        } else if (orderSettingResponse.payments!.isNotEmpty) {
          paymentId = orderSettingResponse.payments![0].id!;
          paymentName = _displayPaymentName(
              orderSettingResponse.payments![0].slug, orderSettingResponse.payments![0].name);
          paymentImageUrl = orderSettingResponse.payments![0].image!;
        }
        String dbDeliveryAddressId = '';
        String dbAddressTitle = '';
        String dbAddressSubTitle = '';
        String dbReceiverName = '';
        String dbReceiverCountryCode = '';
        String dbReceiverContact = '';
        if (orderSettingResponse.address != null && orderSettingResponse.address!.id!.isNotEmpty) {
          dbDeliveryAddressId = orderSettingResponse.address!.id!;
          dbAddressTitle = orderSettingResponse.address!.title!.toString();
          dbAddressSubTitle = '${orderSettingResponse.address!.flatHouse!}, ${orderSettingResponse.address!.locality!}, ${orderSettingResponse.address!.landmark!}';
          dbReceiverName = orderSettingResponse.address!.receiverName!;
          dbReceiverCountryCode = orderSettingResponse.address!.countryCode!.toString();
          dbReceiverContact = '${orderSettingResponse.address!.receiverContact}';
        }

        emit(
          state.copyWith(
            orderSettings: orderSettingResponse,
            deliveryAddressId: dbDeliveryAddressId,
            addressTitle: dbAddressTitle,
            addressSubTitle: dbAddressSubTitle,
            receiverName: dbReceiverName,
            receiverCountryCode: dbReceiverCountryCode,
            receiverContact: dbReceiverContact,
            payment: paymentId,
            paymentName: paymentName,
            paymentImageURL: paymentImageUrl,
            deliveryLatitude: userLatitude,
            deliveryLongitude: userLongitude,
          ),
        );

        emit(
          state.copyWith(
            grandTotal: calculateGrandTotal(),
            deliveryCharge: calculateDeliveryCharge(),
            foodServiceCharge: calculateFoodTax(),
            foodServiceChargeName: orderSettingResponse.business!.foodTaxName!,
            serviceCharge: calculateServiceCharges(),
            serviceChargeName: orderSettingResponse.business!.additionalServiceName!,
            packagingCharges: calculatePackagingCharges(),
            packagingChargesTax: calculatePackageTaxCharges(),
          ),
        );
        List<String> permissionList = <String>[];
        permissionList.clear();
        if (orderSettingResponse.orders!.homeDelivery! && orderSettingResponse.restaurant!.acceptHomeDelivery!) {
          permissionList.add('homedelivery');
        }
        if (orderSettingResponse.orders!.takeaway! && orderSettingResponse.restaurant!.takeAway!) {
          permissionList.add('takeaway');
        }
        if (orderSettingResponse.orders!.scheduleDelivery! && orderSettingResponse.restaurant!.acceptScheduleDelivery!) {
          permissionList.add('schedule');
        }

        String deliveryOrderTo = '';
        if (permissionList.contains('homedelivery')) {
          deliveryOrderTo = 'homedelivery';
        } else if (!permissionList.contains('homedelivery') && permissionList.contains('takeaway')) {
          deliveryOrderTo = 'selfpickup';
        }

        bool canPlaceOrderNow = false;
        int customerCanOrderWithinDays = orderSettingResponse.orders!.customerCanOrderWithinDays! <= 0 ? 5 : orderSettingResponse.orders!.customerCanOrderWithinDays!;
        List<String> futureTimeSlots = <String>[];
        if (orderSettingResponse.restaurant!.slots!.isNotEmpty) {
          int dayNumberToday = (DateTime.now().weekday - 1);
          debugPrint('Day Number Today ---> $dayNumberToday');
          final int currentDayIndex = orderSettingResponse.restaurant!.slots!.indexWhere((element) => element.day == dayNumberToday);
          debugPrint('Current Day Index --> $currentDayIndex');
          if (currentDayIndex != -1) {
            DateTime todayDate = DateTime.now();
            await getSlotFromDate(todayDate).then((slot) {
              futureTimeSlots = slot;
              if (slot.isEmpty) {
                canPlaceOrderNow = false;
              } else {
                bool checkCurrentTimeInSlots(List<TimesConfigModel> timeSlotsOfDay) {
                   String currentTime = DateFormat('hh:mm a').format(todayDate);
                  DateTime now = DateFormat.jm('en').parse(currentTime);

                  for (var slot in timeSlotsOfDay) {
                    DateTime start = DateFormat.jm('en').parse(slot.start!);
                    DateTime end = DateFormat.jm('en').parse(slot.end!);
                    if (end.isBefore(start)) {
                      end = end.add(const Duration(days: 1));
                    }
                    if (now.isAfter(start) && now.isBefore(end)) {
                      return true;
                    }
                  }
                  return false;
                }

                canPlaceOrderNow = checkCurrentTimeInSlots(orderSettingResponse.restaurant!.slots![currentDayIndex].times!);
              }
            });
          } else {
            canPlaceOrderNow = false;
          }
        } else {
          canPlaceOrderNow = false;
        }
        debugPrint('canPlaceOrderNow --> $canPlaceOrderNow');
        emit(
          state.copyWith(
            isMinAmountSatisfied: state.itemTotal >= state.orderSettings.restaurant!.minOrderAmount!,
            orderTo: deliveryOrderTo,
            canDeliverNow: canPlaceOrderNow,
            instantOrder: canPlaceOrderNow,
            permissionList: permissionList,
            timeSlots: futureTimeSlots,
            customerCanOrderWithinDays: customerCanOrderWithinDays,
            status: CheckoutStatus.success,
          ),
        );
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CheckoutStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CheckoutStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCheckoutQuantityEvent(CheckoutQuantityEvent event, Emitter<CheckoutState> emit) async {
    int index = state.inCart.indexWhere((element) => element.id == event.id && element.uuid == event.uuid);
    if (event.action == 'decrease') {
      if (index != -1) {
        if (state.inCart[index].quantity! == 1) {
          await _cartRepository.removeFromCartWithUuidLocal(state.inCart[index].uuid!, state.inCart[index].id!);
          RemoveFromCartWithUuidRequestModel onlineRemoveParam = RemoveFromCartWithUuidRequestModel(trackingId: await _cartRepository.trackingId(), uuid: state.inCart[index].uuid!, id: state.inCart[index].id!);
          DioApiResponse cartOnlineResponse = await _cartRepository.removeFromCartWithUuidServer(onlineRemoveParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        } else {
          state.inCart[index].quantity = state.inCart[index].quantity! - 1;
          await _cartRepository.updateProductVariationInCartLocal(state.inCart[index].uuid!, state.inCart[index].id!, state.inCart[index].quantity!);
          UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
            trackingId: await _cartRepository.trackingId(),
            uuid: state.inCart[index].uuid!,
            id: state.inCart[index].id!,
            quantity: state.inCart[index].quantity!,
          );
          DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
          if (cartOnlineResponse.errorType == NetErrorType.none) {
          } else {
            Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
            ServerErrorModel data = ServerErrorModel.fromJson(myMap);
            emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
          }
        }
        emit(state.copyWith(status: CheckoutStatus.cartUpdate));
        double itemTotal = 0;
        double realPrice = 0;
        double itemDiscount = 0;
        await _cartRepository.getByRestaurant(state.restaurant).then((value) {
          for (var element in value) {
            String countTotal = (double.parse(itemTotal.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotal = double.parse(countTotal);
            String realCountTotal = (double.parse(realPrice.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
            realPrice = double.parse(realCountTotal);
            String itemDisountCountTotal = (double.parse(itemDiscount.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
            itemDiscount = double.parse(itemDisountCountTotal);
          }
          emit(state.copyWith(inCart: value, itemTotal: itemTotal, realPrice: realPrice, itemDiscount: itemDiscount, status: value.isEmpty ? CheckoutStatus.empty : CheckoutStatus.success));
        });
      }
    } else if (event.action == 'increase') {
      if (index != -1) {
        if (state.inCart[index].quantity! < state.inCart[index].purchaseLimit!) {
          bool checkAddonHaveStock = true;
          bool checkVariationHaveStock = true;
          int addonOutOfStockLimitNumber = 0;
          int variationOutOfStockLimitNumber = 0;
          for (var addon in state.inCart[index].addons!) {
            if (state.inCart[index].quantity! >= addon.stockNumber!) {
              checkAddonHaveStock = false;
              if (addonOutOfStockLimitNumber == 0) {
                addonOutOfStockLimitNumber = addon.stockNumber!;
              }
            }
          }
          for (var variation in state.inCart[index].variations!) {
            for (var options in variation.options!) {
              if (state.inCart[index].quantity! >= options.stock!) {
                checkVariationHaveStock = false;
                if (variationOutOfStockLimitNumber == 0) {
                  variationOutOfStockLimitNumber = options.stock!;
                }
              }
            }
          }
          if (state.inCart[index].stockType == 'unlimited' && checkAddonHaveStock && checkVariationHaveStock) {
            state.inCart[index].quantity = state.inCart[index].quantity! + 1;
            await _cartRepository.updateProductVariationInCartLocal(state.inCart[index].uuid!, state.inCart[index].id!, state.inCart[index].quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: state.inCart[index].uuid!,
              id: state.inCart[index].id!,
              quantity: state.inCart[index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else if (state.inCart[index].quantity! < state.inCart[index].stockNumber! && checkAddonHaveStock && checkVariationHaveStock) {
            state.inCart[index].quantity = state.inCart[index].quantity! + 1;
            await _cartRepository.updateProductVariationInCartLocal(state.inCart[index].uuid!, state.inCart[index].id!, state.inCart[index].quantity!);
            UpdateCartFoodVariationQuantityRequestModel onlineUpdateParam = UpdateCartFoodVariationQuantityRequestModel(
              trackingId: await _cartRepository.trackingId(),
              uuid: state.inCart[index].uuid!,
              id: state.inCart[index].id!,
              quantity: state.inCart[index].quantity!,
            );
            DioApiResponse cartOnlineResponse = await _cartRepository.updateProductVariationInCartServer(onlineUpdateParam);
            if (cartOnlineResponse.errorType == NetErrorType.none) {
            } else {
              Map<String, dynamic>? myMap = jsonDecode(cartOnlineResponse.body) as Map<String, dynamic>;
              ServerErrorModel data = ServerErrorModel.fromJson(myMap);
              emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
            }
          } else {
            if (checkAddonHaveStock == false || checkVariationHaveStock == false) {
              emit(
                state.copyWith(
                  status: CheckoutStatus.cartError,
                  statusCode: 0,
                  alertMessage: 'Sorry, our variation limited to ##dynamic## items right now.',
                  extraMessage: '${!checkAddonHaveStock ? addonOutOfStockLimitNumber : variationOutOfStockLimitNumber}',
                ),
              );
            } else {
              emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: 0, alertMessage: 'Sorry, our stock is limited to ##dynamic## items right now.', extraMessage: '${state.inCart[index].stockNumber!}'));
            }
          }
        } else {
          emit(state.copyWith(status: CheckoutStatus.cartError, statusCode: 0, alertMessage: 'Sorry, You can purchase upto ##dynamic## items on this food', extraMessage: '${state.inCart[index].purchaseLimit}'));
        }
        emit(state.copyWith(status: CheckoutStatus.cartUpdate));
        double itemTotal = 0;
        double realPrice = 0;
        double itemDiscount = 0;
        await _cartRepository.getByRestaurant(state.restaurant).then((value) {
          for (var element in value) {
            String countTotal = (double.parse(itemTotal.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotal = double.parse(countTotal);
            String realCountTotal = (double.parse(realPrice.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
            realPrice = double.parse(realCountTotal);
            String itemDisountCountTotal = (double.parse(itemDiscount.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
            itemDiscount = double.parse(itemDisountCountTotal);
          }
          emit(state.copyWith(inCart: value, itemTotal: itemTotal, realPrice: realPrice, itemDiscount: itemDiscount, status: value.isEmpty ? CheckoutStatus.empty : CheckoutStatus.success));
        });
      }
    }
    final String locale = await _authRepository.getLocale();
    emit(state.copyWith(couponUsed: false, couponData: CouponConfigModel(locale: locale.toString()), couponDiscount: 0, walletUsed: false, walletAmount: 0));
    emit(
      state.copyWith(
        status: CheckoutStatus.success,
        isMinAmountSatisfied: state.itemTotal >= state.orderSettings.restaurant!.minOrderAmount!,
        grandTotal: calculateGrandTotal(),
        deliveryCharge: calculateDeliveryCharge(),
        foodServiceCharge: calculateFoodTax(),
        serviceCharge: calculateServiceCharges(),
      ),
    );
  }

  FutureOr<void> _onCheckoutPaymentChangedEvent(CheckoutPaymentChangedEvent event, Emitter<CheckoutState> emit) async {
    final int index = state.orderSettings.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.orderSettings.payments![index].id!;
      String paymentName = _displayPaymentName(
          state.orderSettings.payments![index].slug, state.orderSettings.payments![index].name);
      String paymentImageUrl = state.orderSettings.payments![index].image!;
      emit(state.copyWith(payment: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl, status: CheckoutStatus.success));
    }
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    final double itemTotal = double.parse(state.itemTotal.toString());
    final double deliveryCharge = double.parse(calculateDeliveryCharge().toString());
    final double taxCharge = double.parse(calculateFoodTax().toString());
    final double serviceCharge = double.parse(calculateServiceCharges().toString());
    final double packagingCharges = double.parse(calculatePackagingCharges().toString());
    final double packagingChargesTax = double.parse(calculatePackageTaxCharges().toString());
    final double deliveryTipCharge = double.parse(state.deliveryTip.toString());
    final double couponDiscount = double.parse(state.couponDiscount.toString());
    final double walletAmount = double.parse(state.walletAmount.toString());
    String total = (itemTotal + deliveryCharge + taxCharge + serviceCharge + packagingCharges + packagingChargesTax + deliveryTipCharge).toStringAsFixed(2);
    double subTotal = double.parse(total);
    String grandCount = (subTotal - couponDiscount - walletAmount).toStringAsFixed(2);
    grandTotal = double.parse(grandCount);
    return grandTotal;
  }

  double calculateDeliveryCharge() {
    double deliveryCharge = 0.0;
    if (state.orderSettings.business!.haveFreeDeliveryInTotal! && state.orderSettings.business!.freeDelivery! > 0 && state.itemTotal >= state.orderSettings.business!.freeDelivery!) {
      deliveryCharge = 0.0;
    } else if (state.orderSettings.business!.haveFreeDeliveryInDistance! &&
        state.orderSettings.business!.freeDeliveryInDistance! > 0 &&
        state.orderSettings.business!.freeDeliveryInDistance! > state.orderSettings.restaurant!.distance!) {
      deliveryCharge = 0.0;
    } else {
      if (state.orderSettings.business!.deliveryChargeMethod! == 'distance') {
        String total = (double.parse(state.orderSettings.restaurant!.distance!.toString()) * double.parse(state.orderSettings.business!.deliveryChargeAmount!.toString())).toStringAsFixed(2);
        deliveryCharge = double.parse(total);
      } else {
        deliveryCharge = state.orderSettings.business!.deliveryChargeAmount!;
      }
    }
    if (state.couponData.id != null && state.couponData.discountType == 'freedelivery') {
      deliveryCharge = 0;
    }
    if (state.orderTo == 'selfpickup') {
      deliveryCharge = 0;
    }
    return deliveryCharge;
  }

  double calculateFoodTax() {
    double taxCharge = 0.0;
    if (state.orderSettings.business!.includeTaxOnFood!) {
      if (state.orderSettings.business!.foodTaxType! == 'per') {
        double percentage(numFirst, per) {
          return (numFirst / 100) * per;
        }

        String total = (double.parse(percentage(state.itemTotal, state.orderSettings.business!.foodTaxAmount!).toString())).toStringAsFixed(2);
        taxCharge = double.parse(total);
      } else {
        taxCharge = state.orderSettings.business!.foodTaxAmount!;
      }
    }
    return taxCharge;
  }

  double calculateServiceCharges() {
    double serviceCharge = 0.0;
    if (state.orderSettings.business!.additionalServiceCharge!) {
      serviceCharge = state.orderSettings.business!.additionalServiceAmount!;
    }
    return serviceCharge;
  }

  double calculatePackagingCharges() {
    double packagingCharges = 0.0;
    if (state.orderSettings.packaging!.havePackagingCharges!) {
      packagingCharges = state.orderSettings.packaging!.packagingCharges!;
    }
    return packagingCharges;
  }

  double calculatePackageTaxCharges() {
    double packagingChargesTax = 0.0;
    if (state.orderSettings.packaging!.havePackagingCharges!) {
      if (state.orderSettings.packaging!.includePackagesChargesInTax!) {
        double percentage(numFirst, per) {
          return (numFirst / 100) * per;
        }

        String total = (double.parse(percentage(state.orderSettings.packaging!.packagingCharges!, state.orderSettings.packaging!.packagingChargesTax!).toString())).toStringAsFixed(2);
        packagingChargesTax = double.parse(total);
      }
    }
    return packagingChargesTax;
  }

  FutureOr<void> _onCheckoutInstructionsEvent(CheckoutInstructionsEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(status: CheckoutStatus.success, foodInstruction: event.instructions));
  }

  FutureOr<void> _onCheckoutDeliveryAddressChangeEvent(CheckoutDeliveryAddressChangeEvent event, Emitter<CheckoutState> emit) async {
    try {
      emit(state.copyWith(status: CheckoutStatus.loading, scheduleTime: '', clearCovers: true));
      final String userId = await _cartRepository.userId();
      OrderSettingsRequestModel param = OrderSettingsRequestModel(
        userId: userId,
        restaurant: state.restaurant,
        deliveryAddressId: event.selected.selected!.id!,
        userLatitude: event.selected.selected!.location!.coordinates![1],
        userLongitude: event.selected.selected!.location!.coordinates![0],
        trackingId: await _cartRepository.trackingId(),
      );
      DioApiResponse response = await _cartRepository.getOrderSettings(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        OrderSettingsModel orderSettingResponse = OrderSettingsModel.fromJson(myMap, locale.toString());
        double itemTotal = 0;
        double realPrice = 0;
        double itemDiscount = 0;
        await _cartRepository.getByRestaurant(state.restaurant).then((value) async {
          for (var element in value) {
            if (orderSettingResponse.foods!.foodInfoInCart!.isNotEmpty) {
              for (var foodInServer in orderSettingResponse.foods!.foodInfoInCart!) {
                if (element.id == foodInServer.id) {
                  element.price = foodInServer.price!;
                  element.discountType = foodInServer.discountType!;
                  element.discount = foodInServer.discount!;
                  element.purchaseLimit = foodInServer.purchaseLimit!;
                  element.stockNumber = foodInServer.stockNumber!;
                  element.stockType = foodInServer.stockType!;

                  if (element.addons!.isNotEmpty) {
                    for (var elementAddon in element.addons!) {
                      if (foodInServer.addons!.isNotEmpty) {
                        for (var foodInServerAddon in foodInServer.addons!) {
                          if (elementAddon.id! == foodInServerAddon.id!) {
                            elementAddon.price = foodInServerAddon.price!;
                            elementAddon.stockNumber = foodInServerAddon.stockNumber!;
                            elementAddon.stockType = foodInServerAddon.stockType!;
                          }
                        }
                      }
                    }
                  }

                  if (element.variations!.isNotEmpty) {
                    for (var elementVariation in element.variations!) {
                      if (foodInServer.variations!.isNotEmpty) {
                        for (var foodInServerVariation in foodInServer.variations!) {
                          if (elementVariation.title! == foodInServerVariation.title!) {
                            if (elementVariation.options!.isNotEmpty) {
                              for (var elementVariationOption in elementVariation.options!) {
                                if (foodInServerVariation.options!.isNotEmpty) {
                                  for (var foodInServerVariationOption in foodInServerVariation.options!) {
                                    if (elementVariationOption.name! == foodInServerVariationOption.name!) {
                                      elementVariationOption.price = foodInServerVariationOption.price!;
                                      elementVariationOption.stock = foodInServerVariationOption.stock!;
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }

                  element.taxationEnable = foodInServer.taxationEnable!;

                  if (element.foodtaxations!.isNotEmpty) {
                    for (var elementFoodTaxation in element.foodtaxations!) {
                      if (foodInServer.foodtaxations!.isNotEmpty) {
                        for (var foodInServerFoodTaxation in foodInServer.foodtaxations!) {
                          if (elementFoodTaxation.id! == foodInServerFoodTaxation.id!) {
                            elementFoodTaxation.taxAmount = foodInServerFoodTaxation.taxAmount!;
                          }
                        }
                      }
                    }
                  }
                  await _cartRepository.syncProductWithServer(element.uuid!, element.id!, element);
                }
              }
            }
          }
        });

        await _cartRepository.getByRestaurant(state.restaurant).then((value) {
          for (var element in value) {
            String countTotal = (double.parse(itemTotal.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotal = double.parse(countTotal);
            String realCountTotal = (double.parse(realPrice.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
            realPrice = double.parse(realCountTotal);
            String itemDisountCountTotal = (double.parse(itemDiscount.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
            itemDiscount = double.parse(itemDisountCountTotal);
          }
          emit(state.copyWith(inCart: value, itemTotal: itemTotal, realPrice: realPrice, itemDiscount: itemDiscount));
        });

        String paymentId = '';
        String paymentName = 'Online Payment';
        String paymentImageUrl = '';
        // CustomUI: force Razorpay online (UPI/Card/NB/Wallet/PayLater in-app).
        // Never auto-select COD — COD would bypass CustomUI submit().
        final rzpIndex = orderSettingResponse.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
        if (rzpIndex != -1) {
          paymentId = orderSettingResponse.payments![rzpIndex].id!;
          paymentName = _displayPaymentName(
              orderSettingResponse.payments![rzpIndex].slug, orderSettingResponse.payments![rzpIndex].name);
          paymentImageUrl = orderSettingResponse.payments![rzpIndex].image!;
        } else if (orderSettingResponse.primary != null && orderSettingResponse.primary!.name!.isNotEmpty) {
          paymentId = orderSettingResponse.primary!.id!;
          paymentName = _displayPaymentName(orderSettingResponse.primary!.slug, orderSettingResponse.primary!.name);
          paymentImageUrl = orderSettingResponse.primary!.image!;
        } else if (orderSettingResponse.payments!.isNotEmpty) {
          paymentId = orderSettingResponse.payments![0].id!;
          paymentName = _displayPaymentName(
              orderSettingResponse.payments![0].slug, orderSettingResponse.payments![0].name);
          paymentImageUrl = orderSettingResponse.payments![0].image!;
        }
        String dbDeliveryAddressId = '';
        String dbAddressTitle = '';
        String dbAddressSubTitle = '';
        String dbReceiverName = '';
        String dbReceiverCountryCode = '';
        String dbReceiverContact = '';
        if (orderSettingResponse.address != null && orderSettingResponse.address!.id!.isNotEmpty) {
          dbDeliveryAddressId = orderSettingResponse.address!.id!;
          dbAddressTitle = orderSettingResponse.address!.title!.toString();
          dbAddressSubTitle = '${orderSettingResponse.address!.flatHouse!}, ${orderSettingResponse.address!.locality!}, ${orderSettingResponse.address!.landmark!}';
          dbReceiverName = orderSettingResponse.address!.receiverName!;
          dbReceiverCountryCode = orderSettingResponse.address!.countryCode!.toString();
          dbReceiverContact = '${orderSettingResponse.address!.receiverContact}';
        }

        emit(
          state.copyWith(
            orderSettings: orderSettingResponse,
            deliveryAddressId: dbDeliveryAddressId,
            addressTitle: dbAddressTitle,
            addressSubTitle: dbAddressSubTitle,
            receiverName: dbReceiverName,
            receiverCountryCode: dbReceiverCountryCode,
            receiverContact: dbReceiverContact,
            payment: paymentId,
            paymentName: paymentName,
            paymentImageURL: paymentImageUrl,
            deliveryLatitude: event.selected.selected!.location!.coordinates![1],
            deliveryLongitude: event.selected.selected!.location!.coordinates![0],
          ),
        );

        emit(state.copyWith(couponUsed: false, couponData: CouponConfigModel(locale: locale.toString()), couponDiscount: 0, walletUsed: false, walletAmount: 0));

        emit(
          state.copyWith(
            grandTotal: calculateGrandTotal(),
            deliveryCharge: calculateDeliveryCharge(),
            foodServiceCharge: calculateFoodTax(),
            foodServiceChargeName: orderSettingResponse.business!.foodTaxName!,
            serviceCharge: calculateServiceCharges(),
            serviceChargeName: orderSettingResponse.business!.additionalServiceName!,
            packagingCharges: calculatePackagingCharges(),
            packagingChargesTax: calculatePackageTaxCharges(),
          ),
        );

        List<String> permissionList = <String>[];
        permissionList.clear();
        if (orderSettingResponse.orders!.homeDelivery! && orderSettingResponse.restaurant!.acceptHomeDelivery!) {
          permissionList.add('homedelivery');
        }
        if (orderSettingResponse.orders!.takeaway! && orderSettingResponse.restaurant!.takeAway!) {
          permissionList.add('takeaway');
        }
        if (orderSettingResponse.orders!.scheduleDelivery! && orderSettingResponse.restaurant!.acceptScheduleDelivery!) {
          permissionList.add('schedule');
        }

        String deliveryOrderTo = '';
        if (permissionList.contains('homedelivery')) {
          deliveryOrderTo = 'homedelivery';
        } else if (!permissionList.contains('homedelivery') && permissionList.contains('takeaway')) {
          deliveryOrderTo = 'selfpickup';
        }

        bool canPlaceOrderNow = false;
        int customerCanOrderWithinDays = orderSettingResponse.orders!.customerCanOrderWithinDays! <= 0 ? 5 : orderSettingResponse.orders!.customerCanOrderWithinDays!;
        List<String> futureTimeSlots = <String>[];
        if (orderSettingResponse.restaurant!.slots!.isNotEmpty) {
          int dayNumberToday = (DateTime.now().weekday - 1);
          final int currentDayIndex = orderSettingResponse.restaurant!.slots!.indexWhere((element) => element.day == dayNumberToday);
          if (currentDayIndex != -1) {
            DateTime todayDate = DateTime.now();
            await getSlotFromDate(todayDate).then((slot) {
              futureTimeSlots = slot;
              if (slot.isEmpty) {
                canPlaceOrderNow = false;
              } else {
                bool checkCurrentTimeInSlots(List<TimesConfigModel> timeSlotsOfDay) {
                   String currentTime = DateFormat('hh:mm a').format(todayDate);
                  DateTime now = DateFormat.jm('en').parse(currentTime);

                  for (var slot in timeSlotsOfDay) {
                    DateTime start = DateFormat.jm('en').parse(slot.start!);
                    DateTime end = DateFormat.jm('en').parse(slot.end!);
                    if (end.isBefore(start)) {
                      end = end.add(const Duration(days: 1));
                    }
                    if (now.isAfter(start) && now.isBefore(end)) {
                      return true;
                    }
                  }
                  return false;
                }

                canPlaceOrderNow = checkCurrentTimeInSlots(orderSettingResponse.restaurant!.slots![currentDayIndex].times!);
              }
            });
          } else {
            canPlaceOrderNow = false;
          }
        } else {
          canPlaceOrderNow = false;
        }

        emit(
          state.copyWith(
            orderTo: deliveryOrderTo,
            canDeliverNow: canPlaceOrderNow,
            instantOrder: canPlaceOrderNow,
            permissionList: permissionList,
            timeSlots: futureTimeSlots,
            isMinAmountSatisfied: state.itemTotal >= state.orderSettings.restaurant!.minOrderAmount!,
            customerCanOrderWithinDays: customerCanOrderWithinDays,
            status: CheckoutStatus.success,
          ),
        );
        // Coverage pre-check (Batch G-3): warn early when the kitchen cannot
        // serve the newly picked pin. Advisory only — createOrder enforces,
        // so a failed or silent check must never break address switching.
        try {
          final DioApiResponse coversResponse = await _cartRepository.restaurantCovers(
            restaurant: state.restaurant,
            latitude: (event.selected.selected!.location!.coordinates![1] as num).toDouble(),
            longitude: (event.selected.selected!.location!.coordinates![0] as num).toDouble(),
          );
          if (coversResponse.errorType == NetErrorType.none) {
            final Map<String, dynamic>? coversMap =
                jsonDecode(coversResponse.body) as Map<String, dynamic>?;
            emit(
              state.copyWith(
                coversRestaurant: coversMap == null ? null : (coversMap['inside'] as bool?),
                coversReason: coversMap == null ? '' : (coversMap['reason']?.toString() ?? ''),
              ),
            );
          }
        } catch (_) {
          // Advisory — leave the banner cleared.
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CheckoutStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CheckoutStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onCheckoutDeliveryInstructionChangeEvent(CheckoutDeliveryInstructionChangeEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(deliveryInstructionId: event.data.id, deliveryInstruction: event.data.name, deliveryInstructionImage: event.data.image, status: CheckoutStatus.success));
  }

  FutureOr<void> _onCheckoutDeliveryInstructionClearEvent(CheckoutDeliveryInstructionClearEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(deliveryInstructionId: '', deliveryInstruction: '', deliveryInstructionImage: '', status: CheckoutStatus.success));
  }

  FutureOr<void> _onCheckoutReceiverChangeEvent(CheckoutReceiverChangeEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(status: CheckoutStatus.success, receiverName: event.name, receiverCountryCode: event.countryCode, receiverContact: event.phoneNumber));
  }

  FutureOr<void> _onCheckoutBillingInfoExtraChargeEvent(CheckoutBillingInfoExtraChargeEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(deliveryTip: event.deliveryTip, status: CheckoutStatus.success));
    emit(state.copyWith(status: CheckoutStatus.success, grandTotal: calculateGrandTotal()));
  }

  FutureOr<void> _onCheckoutCouponCodeResponseEvent(CheckoutCouponCodeResponseEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(couponUsed: true, couponData: event.coupon, status: CheckoutStatus.success));
    if (event.coupon.id != null) {
      if (event.coupon.couponType == 'default' || event.coupon.couponType == 'restaurant' || event.coupon.couponType == 'firstorder') {
        if (event.coupon.discountType == 'amount') {
          String title = "You saved ${kAppPriceFormat(event.coupon.minDiscount!)} with '${event.coupon.code}'";
          emit(state.copyWith(couponDiscount: event.coupon.minDiscount, couponData: event.coupon, couponTitle: title));
        } else {
          double percentage(numFirst, per) {
            return (numFirst / 100) * per;
          }

          String minDiscount = (double.parse(percentage(state.itemTotal, event.coupon.minDiscount).toString())).toStringAsFixed(2);
          String maxDiscount = (double.parse(percentage(state.itemTotal, event.coupon.maxDiscount).toString())).toStringAsFixed(2);
          double minSave = double.parse(minDiscount);
          double maxSave = double.parse(maxDiscount);
          int randomNumber = event.coupon.code!.length;
          if (randomNumber.floor().isEven) {
            String title = "You saved ${kAppPriceFormat(minSave)} with '${event.coupon.code}'";
            emit(state.copyWith(couponDiscount: minSave, couponData: event.coupon, couponTitle: title));
          } else {
            String title = "You saved ${kAppPriceFormat(maxSave)} with '${event.coupon.code}'";
            emit(state.copyWith(couponDiscount: maxSave, couponData: event.coupon, couponTitle: title));
          }
        }
      } else if (event.coupon.couponType == 'freedelivery') {
        String title = state.deliveryCharge > 0 ? "You saved ${kAppPriceFormat(state.deliveryCharge)} with '${event.coupon.code}'" : "You have free delivery with '${event.coupon.code}'";
        emit(state.copyWith(deliveryCharge: 0, couponTitle: title));
      } else if (event.coupon.couponType == 'loyality') {
        String title = "${event.coupon.loyalityPoints} points will credited with '${event.coupon.code}'";
        emit(state.copyWith(couponTitle: title));
      } else if (event.coupon.couponType == 'bogo') {
        String title = "Buy One Get One free with '${event.coupon.code}'";

        double realPriceBeforeBOGO = 0;
        double itemTotalBeforeBOGO = 0;
        double itemDiscountBeforeBOGO = 0;

        double itemTotalAfterBOGO = 0;

        await _cartRepository.getByRestaurant(state.restaurant).then((value) {
          for (var element in value) {
            String countTotal = (double.parse(itemTotalBeforeBOGO.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotalBeforeBOGO = double.parse(countTotal);
            String realCountTotal = (double.parse(realPriceBeforeBOGO.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
            realPriceBeforeBOGO = double.parse(realCountTotal);
            String itemDisountCountTotal = (double.parse(itemDiscountBeforeBOGO.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
            itemDiscountBeforeBOGO = double.parse(itemDisountCountTotal);
            if (element.quantity! >= 2) {
              element.containBOGOItem = true;
              final String newTotalPriceString = (element.totalPrice! - element.singleProductPrice!).toStringAsFixed(2);
              final double newTotalPrice = double.parse(newTotalPriceString);
              element.totalPrice = newTotalPrice;
            }
          }
          List<FoodInCartModel> singleQuantityItems = <FoodInCartModel>[];
          singleQuantityItems = value.where((x) => x.quantity == 1).toList();
          if (singleQuantityItems.length >= 2) {
            FoodInCartModel minTotalItem = singleQuantityItems.reduce((a, b) => a.totalPrice! < b.totalPrice! ? a : b);
            if (minTotalItem.uuid!.isNotEmpty) {
              final int indexOfMinTotalItem = value.indexWhere((x) => x.uuid == minTotalItem.uuid);
              if (indexOfMinTotalItem != -1) {
                value[indexOfMinTotalItem].isBOGOApplied = true;
                value[indexOfMinTotalItem].totalPrice = 0;
              }
            }
          }
          for (var element in value) {
            String countTotal = (double.parse(itemTotalAfterBOGO.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
            itemTotalAfterBOGO = double.parse(countTotal);
          }
          final String couponDiscountAmountString = (itemTotalBeforeBOGO - itemTotalAfterBOGO).toStringAsFixed(2);
          final double couponDiscountAmount = double.parse(couponDiscountAmountString);
          emit(
            state.copyWith(
              inCart: value,
              couponDiscount: couponDiscountAmount,
              itemTotal: itemTotalBeforeBOGO,
              realPrice: realPriceBeforeBOGO,
              itemDiscount: itemDiscountBeforeBOGO,
              isMinAmountSatisfied: itemTotalBeforeBOGO >= state.orderSettings.restaurant!.minOrderAmount!,
            ),
          );
        });

        emit(state.copyWith(couponTitle: title));
      }

      emit(
        state.copyWith(
          status: CheckoutStatus.success,
          grandTotal: calculateGrandTotal(),
          deliveryCharge: calculateDeliveryCharge(),
          foodServiceCharge: calculateFoodTax(),
          serviceCharge: calculateServiceCharges(),
          packagingCharges: calculatePackagingCharges(),
          packagingChargesTax: calculatePackageTaxCharges(),
        ),
      );
    }
  }

  FutureOr<void> _onCheckoutRemoveCouponEvent(CheckoutRemoveCouponEvent event, Emitter<CheckoutState> emit) async {
    double itemTotal = 0;
    double realPrice = 0;
    double itemDiscount = 0;
    await _cartRepository.getByRestaurant(state.restaurant).then((value) {
      for (var element in value) {
        element.isBOGOApplied = false;
        element.containBOGOItem = false;
        String countTotal = (double.parse(itemTotal.toString()) + double.parse(element.totalPrice.toString())).toStringAsFixed(2);
        itemTotal = double.parse(countTotal);
        String realCountTotal = (double.parse(realPrice.toString()) + double.parse(element.realPrice.toString())).toStringAsFixed(2);
        realPrice = double.parse(realCountTotal);
        String itemDisountCountTotal = (double.parse(itemDiscount.toString()) + double.parse(element.itemDiscount.toString())).toStringAsFixed(2);
        itemDiscount = double.parse(itemDisountCountTotal);
      }
      emit(state.copyWith(inCart: value, itemTotal: itemTotal, realPrice: realPrice, itemDiscount: itemDiscount));
    });
    final String locale = await _authRepository.getLocale();
    emit(
      state.copyWith(
        couponUsed: false,
        couponData: CouponConfigModel(locale: locale.toString()),
        couponDiscount: 0,
        status: CheckoutStatus.success,
      ),
    );
    emit(state.copyWith(status: CheckoutStatus.success, grandTotal: calculateGrandTotal(), deliveryCharge: calculateDeliveryCharge(), foodServiceCharge: calculateFoodTax(), serviceCharge: calculateServiceCharges()));
  }

  FutureOr<void> _onCheckoutWalletUseEvent(CheckoutWalletUseEvent event, Emitter<CheckoutState> emit) async {
    if (state.couponUsed == false) {
      if (state.walletUsed == false) {
        if (state.orderSettings.wallet!.balance! <= state.itemTotal) {
          emit(state.copyWith(walletUsed: true, walletAmount: state.orderSettings.wallet!.balance!, status: CheckoutStatus.success));
          emit(
            state.copyWith(
              status: CheckoutStatus.success,
              grandTotal: calculateGrandTotal(),
              deliveryCharge: calculateDeliveryCharge(),
              foodServiceCharge: calculateFoodTax(),
              serviceCharge: calculateServiceCharges(),
              packagingCharges: calculatePackagingCharges(),
              packagingChargesTax: calculatePackageTaxCharges(),
            ),
          );
        } else {
          final double minimumWalletAmount = state.itemTotal;
          emit(state.copyWith(walletUsed: true, walletAmount: minimumWalletAmount, status: CheckoutStatus.success));
          emit(
            state.copyWith(
              status: CheckoutStatus.success,
              grandTotal: calculateGrandTotal(),
              deliveryCharge: calculateDeliveryCharge(),
              foodServiceCharge: calculateFoodTax(),
              serviceCharge: calculateServiceCharges(),
              packagingCharges: calculatePackagingCharges(),
              packagingChargesTax: calculatePackageTaxCharges(),
            ),
          );
        }
      } else {
        emit(state.copyWith(walletUsed: false, walletAmount: 0, status: CheckoutStatus.success));
        emit(
          state.copyWith(
            status: CheckoutStatus.success,
            grandTotal: calculateGrandTotal(),
            deliveryCharge: calculateDeliveryCharge(),
            foodServiceCharge: calculateFoodTax(),
            serviceCharge: calculateServiceCharges(),
            packagingCharges: calculatePackagingCharges(),
            packagingChargesTax: calculatePackageTaxCharges(),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          status: CheckoutStatus.customError,
          statusCode: 0,
          alertMessage: "Oops! Looks like you've applied a coupon code for your order.Please note that you can't use your wallet balance along with a coupon code",
          extraMessage: '',
        ),
      );
    }
  }

  FutureOr<void> _onCheckoutCouponValidationErrorEvent(CheckoutCouponValidationErrorEvent event, Emitter<CheckoutState> emit) async {
    emit(
      state.copyWith(
        status: CheckoutStatus.customError,
        statusCode: 0,
        alertMessage: "Oops! Looks like you've applied a wallet money for your order.Please note that you can't use coupon code along with a wallet money",
        extraMessage: '',
      ),
    );
  }

  FutureOr<void> _onCheckoutChangeOrderToEvent(CheckoutChangeOrderToEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(orderTo: event.orderTo, deliveryTip: event.orderTo == 'selfpickup' ? 0 : state.deliveryTip, status: CheckoutStatus.success));
    emit(
      state.copyWith(
        status: CheckoutStatus.success,
        grandTotal: calculateGrandTotal(),
        deliveryCharge: calculateDeliveryCharge(),
        foodServiceCharge: calculateFoodTax(),
        serviceCharge: calculateServiceCharges(),
        packagingCharges: calculatePackagingCharges(),
        packagingChargesTax: calculatePackageTaxCharges(),
      ),
    );
  }

  FutureOr<void> _onCheckoutScheduleDateEvent(CheckoutScheduleDateEvent event, Emitter<CheckoutState> emit) async {
    DateTime todayDate = DateTime.now();
    String selectedDateString = '${event.date.year}-${event.date.month}-${event.date.day}';
    String todayDateString = '${todayDate.year}-${todayDate.month}-${todayDate.day}';
    bool isInstantOrder = false;
    await getSlotFromDate(event.date).then((slot) async {
      if (selectedDateString == todayDateString) {
        int dayNumberToday = (DateTime.now().weekday - 1);
        final int currentDayIndex = state.orderSettings.restaurant!.slots!.indexWhere((element) => element.day == dayNumberToday);
        if (currentDayIndex != -1) {
          if (slot.isNotEmpty) {
                bool checkCurrentTimeInSlots(List<TimesConfigModel> timeSlotsOfDay) {
                   String currentTime = DateFormat('hh:mm a').format(todayDate);
                  DateTime now = DateFormat.jm('en').parse(currentTime);

                  for (var slot in timeSlotsOfDay) {
                    DateTime start = DateFormat.jm('en').parse(slot.start!);
                    DateTime end = DateFormat.jm('en').parse(slot.end!);
                if (end.isBefore(start)) {
                  end = end.add(const Duration(days: 1));
                }
                if (now.isAfter(start) && now.isBefore(end)) {
                  return true;
                }
              }
              return false;
            }

            isInstantOrder = checkCurrentTimeInSlots(state.orderSettings.restaurant!.slots![currentDayIndex].times!);
          }
        }
      }
      emit(
        state.copyWith(
          scheduleDate: '${event.date.year}-${event.date.month}-${event.date.day}',
          timeSlots: slot,
          instantOrder: isInstantOrder,
          canDeliverNow: isInstantOrder,
          scheduleOrder: !isInstantOrder,
          scheduleTime: '',
          status: CheckoutStatus.success,
        ),
      );
    });
  }

  Future<List<String>> getSlotFromDate(DateTime selectedDate) async {
    int dayNumberOfDate = (selectedDate.weekday - 1);
    final int slotExist = state.orderSettings.restaurant!.slots!.indexWhere((element) => element.day == dayNumberOfDate);
    if (slotExist != -1) {
      Iterable<TimeOfDay> generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
        var hour = startTime.hour;
        var minute = startTime.minute;

        do {
          yield TimeOfDay(hour: hour, minute: minute);
          minute += step.inMinutes;
          while (minute >= 60) {
            minute -= 60;
            hour++;
          }
        } while (hour < endTime.hour || (hour == endTime.hour && minute <= endTime.minute));
      }

      int stepIntervalNumber = state.orderSettings.orders!.timeIntervalForScheduleDelivery!.value!;
      String stepIntervalType = state.orderSettings.orders!.timeIntervalForScheduleDelivery!.type!;
      List<String> tempSlots = <String>[];
      for (var element in state.orderSettings.restaurant!.slots![dayNumberOfDate].times!) {
        int startHour = int.parse(element.start!.split(":").first);
        int startMinute = int.parse(element.start!.split(":").last.split(" ").first);
        String startMeridium = element.start!.split(":").last.split(" ").last.toLowerCase();
        if (startMeridium == "PM" || startMeridium == "pm") {
          if (startHour != 12) {
            startHour = startHour + 12;
          }
        }

        int endHour = int.parse(element.end!.split(":").first);
        int endMinute = int.parse(element.end!.split(":").last.split(" ").first);
        String endMeridium = element.end!.split(":").last.split(" ").last.toLowerCase();
        if (endMeridium == "PM" || endMeridium == "pm") {
          if (endHour != 12) {
            endHour = endHour + 12;
          }
        }

        final startTime = TimeOfDay(hour: startHour, minute: startMinute);
        final endTime = TimeOfDay(hour: endHour, minute: endMinute);
        final convertedSlots = generateTimeSlots(startTime, endTime, stepIntervalType == 'min' ? Duration(minutes: stepIntervalNumber) : Duration(hours: stepIntervalNumber)).map((slot) => '${slot.hour}:${slot.minute}').toList();
        for (var slot in convertedSlots) {
          tempSlots.add(slot);
        }
      }
      List<String> futureSlots = <String>[];
      await getFutureSlots(tempSlots, selectedDate).then((listOfSlots) {
        futureSlots = listOfSlots;
      });
      return futureSlots;
    }
    return [];
  }

  Future<List<String>> getFutureSlots(List<String> tempSlots, DateTime selectedDate) async {
    List<String> slotList = <String>[];
    final currentDate = DateTime.now();
    String convertTo12HourFormat(String time24Hour) {
      final dateFormat = DateFormat('HH:mm');
      final dateTime = dateFormat.parse(time24Hour);
      return DateFormat('h:mm a').format(dateTime);
    }

    for (var slot in tempSlots) {
      final hourMinute = slot.split(':');
      if (hourMinute.isNotEmpty && hourMinute.length == 2) {
        final futureDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(hourMinute[0].toString()), int.parse(hourMinute[1].toString()));

        if (futureDate.isAfter(currentDate)) {
          slotList.add(convertTo12HourFormat(slot));
        }
      }
    }

    return slotList;
  }

  FutureOr<void> _onCheckoutScheduleTimeEvent(CheckoutScheduleTimeEvent event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(scheduleTime: event.time, canDeliverNow: true, instantOrder: false, scheduleOrder: true, status: CheckoutStatus.success));
  }

  FutureOr<void> _onCheckoutCreateOrderEvent(CheckoutCreateOrderEvent event, Emitter<CheckoutState> emit) async {
    final currentDateTime = DateTime.now();
    String convertTo12HourFormat(String time24Hour) {
      final dateFormat = DateFormat('HH:mm');
      final dateTime = dateFormat.parse(time24Hour);
      return DateFormat('h:mm a').format(dateTime);
    }

    String time12Hour = convertTo12HourFormat('${currentDateTime.hour}:${currentDateTime.minute}');
    try {
      List<LocalCartItemArrayRequestModel> localCart = <LocalCartItemArrayRequestModel>[];
      for (var element in state.inCart) {
        LocalCartItemArrayRequestModel localCartParam = LocalCartItemArrayRequestModel(uuid: element.uuid!, quantity: element.quantity!);
        localCart.add(localCartParam);
      }
      emit(state.copyWith(status: CheckoutStatus.placingOrder));
      PlaceOrderRequestModel orderParam = PlaceOrderRequestModel(
        user: state.user,
        payment: state.payment,
        restaurant: state.restaurant,
        trackingId: await _cartRepository.trackingId(),
        coupon: state.couponUsed && state.couponData.id!.isNotEmpty ? state.couponData.id! : '',
        orderTo: state.orderTo,
        cookingInstruction: state.foodInstruction,
        deliveryInstruction: state.deliveryInstructionId,
        deliveryAddress: state.orderTo == 'homedelivery' ? state.deliveryAddressId : '',
        receiverName: state.receiverName,
        countryCode: state.receiverCountryCode,
        receiverContact: state.receiverContact,
        walletUsed: state.walletUsed,
        instantOrder: state.instantOrder,
        scheduleOrder: state.scheduleOrder,
        scheduleDate: state.scheduleOrder ? state.scheduleDate : '',
        scheduleTime: state.scheduleOrder ? state.scheduleTime : '',
        orderAt: time12Hour,
        locale: state.locale,
        deliveryTip: state.deliveryTip,
        localCartItem: localCart,
      );
      DioApiResponse response = await _cartRepository.placeOrder(orderParam);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        CreateOrderResponseModel orderResponse = CreateOrderResponseModel.fromJson(myMap);
        await _cartRepository.removeFromCartWithRestaurant(state.restaurant);
        if (orderResponse.status == 'offline') {
          emit(state.copyWith(status: CheckoutStatus.orderPlaced));
        } else {
          emit(state.copyWith(status: CheckoutStatus.makePayment, paymentURL: orderResponse.payLink));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: CheckoutStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: CheckoutStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

/// Customer-facing payment label. Gateway brands (Razorpay/Stripe/Cashfree…)
/// are processor names from admin config — never shown. Online renders the
/// generic label (localized at the view via pay_online); COD keeps its name.
String _displayPaymentName(String? slug, String? rawName) {
  const onlineSlugs = {
    'razorpay',
    'stripe',
    'cashfree',
    'paytm',
    'paystack',
    'paypal',
    'instamojo',
    'flutterwave',
    'xendit',
  };
  if (slug != null && onlineSlugs.contains(slug.toLowerCase())) return 'Online Payment';
  return (rawName == null || rawName.isEmpty) ? 'Online Payment' : rawName;
}

