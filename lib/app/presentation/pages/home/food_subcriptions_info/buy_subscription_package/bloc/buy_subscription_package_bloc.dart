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
import 'package:user/app/core/models/buy_subscription_tiffin_package_response_model.dart';
import 'package:user/app/core/models/delivery_address_modal_response_model.dart';
import 'package:user/app/core/models/delivery_instruction_modal_response_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart' as food_in_cart_model;
import 'package:user/app/core/models/food_info_modal_response_model.dart';
import 'package:user/app/core/models/request/buy_tiffin_subscription_request_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_food_config_request_model.dart';
import 'package:user/app/core/models/request/tiffin_subscription_food_config_request_model.dart' as tiffin_food_config;
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/tiffin_subscription_purchase_response_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/subscription_tiffin_packages_repository.dart';
import 'package:user/app/services/uuid_generator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'buy_subscription_package_event.dart';
part 'buy_subscription_package_state.dart';

class BuySubscriptionPackageBloc extends Bloc<BuySubscriptionPackageEvent, BuySubscriptionPackageState> {
  final SubscriptionTiffinPackagesRepository _subscriptionTiffinPackagesRepository = SubscriptionTiffinPackagesRepository();
  final AuthRepository _authRepository = AuthRepository();
  BuySubscriptionPackageBloc()
    : super(
        BuySubscriptionPackageState(
          info: BuySubscriptionTiffinPackageResponseModel(locale: ''),
          savedAddress: DeliveryAddressModalResponseModel(),
        ),
      ) {
    on<BuySubscriptionPackageInitialEvent>(_onBuySubscriptionPackageInitialEvent);
    on<BuySubscriptionPackageSlotSelectEvent>(_onBuySubscriptionPackageSlotSelectEvent);
    on<BuySubscriptionPackagePaymentChangeEvent>(_onBuySubscriptionPackagePaymentChangeEvent);
    on<BuySubscriptionPackageDeliveryAddressChangeEvent>(_onBuySubscriptionPackageDeliveryAddressChangeEvent);
    on<BuySubscriptionPackageInstructionsEvent>(_onBuySubscriptionPackageInstructionsEvent);
    on<BuySubscriptionPackageDeliveryInstructionClearEvent>(_onBuySubscriptionPackageDeliveryInstructionClearEvent);
    on<BuySubscriptionPackageDeliveryInstructionChangeEvent>(_onBuySubscriptionPackageDeliveryInstructionChangeEvent);
    on<BuySubscriptionPackageReceiverChangeEvent>(_onBuySubscriptionPackageReceiverChangeEvent);
    on<BuySubscriptionPackageFoodModalResponseEvent>(_onBuySubscriptionPackageFoodModalResponseEvent);
    on<BuySubscriptionPackageCreateOrderEvent>(_onBuySubscriptionPackageCreateOrderEvent);
  }

  FutureOr<void> _onBuySubscriptionPackageInitialEvent(BuySubscriptionPackageInitialEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "buy_tiffin_subscription_package", "id": event.id}, 'buy_tiffin_subscription_${event.id}_screen', 'buy_tiffin_subscription_${event.id}_screen');
      emit(state.copyWith(status: BuySubscriptionPackageStatus.loading, id: event.id));
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.buySubscriptionPackageDetail(event.id);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        final String locale = await _authRepository.getLocale();
        BuySubscriptionTiffinPackageResponseModel orderSettingResponse = BuySubscriptionTiffinPackageResponseModel.fromJson(myMap, locale.toString());
        String paymentId = '';
        String paymentName = 'Online Payment';
        String paymentImageUrl = '';
        // Single gateway decision: Razorpay online. Payment screen owns
        // method choice (UPI/Card/NB/Wallet) — no pre-selector popup.
        final rzpIndex = orderSettingResponse.payments!.indexWhere((e) => (e.slug ?? '').toLowerCase() == 'razorpay');
        if (rzpIndex != -1) {
          paymentId = orderSettingResponse.payments![rzpIndex].id!;
          paymentName = orderSettingResponse.payments![rzpIndex].name!;
          paymentImageUrl = orderSettingResponse.payments![rzpIndex].image!;
        } else if (orderSettingResponse.primary != null && orderSettingResponse.primary!.name!.isNotEmpty) {
          paymentId = orderSettingResponse.primary!.id!;
          paymentName = orderSettingResponse.primary!.name!;
          paymentImageUrl = orderSettingResponse.primary!.image!;
        } else if (orderSettingResponse.payments!.isNotEmpty) {
          paymentId = orderSettingResponse.payments![0].id!;
          paymentName = orderSettingResponse.payments![0].name!;
          paymentImageUrl = orderSettingResponse.payments![0].image!;
        }
        emit(
          state.copyWith(
            status: BuySubscriptionPackageStatus.success,
            payment: paymentId,
            paymentName: paymentName,
            paymentImageURL: paymentImageUrl,
            info: orderSettingResponse,
            appLocale: locale.toString(),
            itemTotal: orderSettingResponse.details!.discount! > 0 ? orderSettingResponse.details!.offerPrice! : orderSettingResponse.details!.price!,
          ),
        );
        if (orderSettingResponse.orderSettings!.includeChargesForSubscription!) {
          emit(
            state.copyWith(
              grandTotal: calculateGrandTotal(),
              foodServiceCharge: calculateFoodTax(),
              serviceCharge: calculateServiceCharges(),
              packagingCharges: calculatePackagingCharges(),
              packagingChargesTax: calculatePackageTaxCharges(),
            ),
          );
        } else {
          emit(
            state.copyWith(
              grandTotal: orderSettingResponse.details!.discount! > 0 ? orderSettingResponse.details!.offerPrice! : orderSettingResponse.details!.price!,
              itemTotal: orderSettingResponse.details!.discount! > 0 ? orderSettingResponse.details!.offerPrice! : orderSettingResponse.details!.price!,
              serviceCharge: 0,
              foodServiceCharge: 0,
              extraCharge: 0,
              packagingCharges: 0,
              packagingChargesTax: 0,
            ),
          );
        }

        List<FoodInCartModel> foodInCart = <FoodInCartModel>[];
        for (var element in state.info.foods!) {
          food_in_cart_model.FoodRestaurantInfo restaurantInfo = food_in_cart_model.FoodRestaurantInfo(locale: locale.toString());
          List<food_in_cart_model.RestaurantTranslations> restaurantTranslation = <food_in_cart_model.RestaurantTranslations>[];
          restaurantTranslation.clear();
          for (var element in element.restaurants!.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.RestaurantTranslations savedData = food_in_cart_model.RestaurantTranslations.fromJson(myMap);
            restaurantTranslation.add(savedData);
          }
          restaurantInfo.id = element.restaurants!.id!;
          restaurantInfo.name = element.restaurants!.name!;
          restaurantInfo.cover = element.restaurants!.cover!;
          restaurantInfo.logo = element.restaurants!.logo!;
          restaurantInfo.translations = restaurantTranslation;

          List<food_in_cart_model.FoodTranslations> savedFoodTranslation = <food_in_cart_model.FoodTranslations>[];
          savedFoodTranslation.clear();
          for (var element in element.translations!) {
            var convertedItem = jsonEncode(element).toString();
            Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
            food_in_cart_model.FoodTranslations savedData = food_in_cart_model.FoodTranslations.fromJson(myMap);
            savedFoodTranslation.add(savedData);
          }

          FoodInCartModel foodInCartInfo = FoodInCartModel(
            uuid: Uuid().generateV4(),
            name: element.name!,
            shortDescription: element.shortDescription!,
            image: element.image!,
            restaurant: element.restaurant!,
            foodType: element.foodType!,
            price: element.price!,
            discountType: element.discountType!,
            discount: element.discount!,
            offerPrice: element.offerPrice!,
            purchaseLimit: element.purchaseLimit!,
            quantity: 1,
            id: element.id,
            addons: [],
            variations: [],
            restaurantInfo: restaurantInfo,
            translations: savedFoodTranslation,
            status: element.status,
            inStock: element.inStock,
            startTime: element.startTime,
            endTime: element.endTime,
            locale: locale.toString(),
          );
          foodInCart.add(foodInCartInfo);
        }
        emit(state.copyWith(inCart: [...foodInCart]));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: BuySubscriptionPackageStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: BuySubscriptionPackageStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  double calculateGrandTotal() {
    double grandTotal = 0.0;
    final double itemTotal = double.parse(state.itemTotal.toString());
    final double taxCharge = double.parse(calculateFoodTax().toString());
    final double serviceCharge = double.parse(calculateServiceCharges().toString());
    final double packagingCharges = double.parse(calculatePackagingCharges().toString());
    final double packagingChargesTax = double.parse(calculatePackageTaxCharges().toString());
    String total = (itemTotal + taxCharge + serviceCharge + packagingCharges + packagingChargesTax).toStringAsFixed(2);
    double subTotal = double.parse(total);
    String grandCount = (subTotal).toStringAsFixed(2);
    grandTotal = double.parse(grandCount);
    return grandTotal;
  }

  double calculateFoodTax() {
    double taxCharge = 0.0;
    if (state.info.businessSettings!.includeTaxOnFood!) {
      if (state.info.businessSettings!.foodTaxType! == 'per') {
        double percentage(numFirst, per) {
          return (numFirst / 100) * per;
        }

        String total = (double.parse(percentage(state.itemTotal, state.info.businessSettings!.foodTaxAmount!).toString())).toStringAsFixed(2);
        taxCharge = double.parse(total);
      } else {
        taxCharge = state.info.businessSettings!.foodTaxAmount!;
      }
    }
    return taxCharge;
  }

  double calculateServiceCharges() {
    double serviceCharge = 0.0;
    if (state.info.businessSettings!.additionalServiceCharge!) {
      serviceCharge = state.info.businessSettings!.additionalServiceAmount!;
    }
    String finalPrice = (serviceCharge * state.info.details!.totalOrder!).toStringAsFixed(2);
    return double.parse(finalPrice);
  }

  double calculatePackagingCharges() {
    double packagingCharges = 0.0;
    if (state.info.restaurantSettings!.havePackagingCharges!) {
      packagingCharges = state.info.restaurantSettings!.packagingCharges!;
    }
    String finalPrice = (packagingCharges * state.info.details!.totalOrder!).toStringAsFixed(2);
    return double.parse(finalPrice);
  }

  double calculatePackageTaxCharges() {
    double packagingChargesTax = 0.0;
    if (state.info.restaurantSettings!.havePackagingCharges!) {
      if (state.info.restaurantSettings!.includePackagesChargesInTax!) {
        double percentage(numFirst, per) {
          return (numFirst / 100) * per;
        }

        String total = (double.parse(percentage(state.info.restaurantSettings!.packagingCharges!, state.info.restaurantSettings!.packagingChargesTax!).toString())).toStringAsFixed(2);
        packagingChargesTax = double.parse(total);
      }
    }
    String finalPrice = (packagingChargesTax * state.info.details!.totalOrder!).toStringAsFixed(2);
    return double.parse(finalPrice);
  }

  FutureOr<void> _onBuySubscriptionPackageSlotSelectEvent(BuySubscriptionPackageSlotSelectEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(state.copyWith(savedSlot: event.slot));
  }

  FutureOr<void> _onBuySubscriptionPackagePaymentChangeEvent(BuySubscriptionPackagePaymentChangeEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    final int index = state.info.payments!.indexWhere((element) => element.id == event.id);
    if (index != -1) {
      String paymentId = state.info.payments![index].id!;
      String paymentName = state.info.payments![index].name!;
      String paymentImageUrl = state.info.payments![index].image!;
      emit(state.copyWith(payment: paymentId, paymentName: paymentName, paymentImageURL: paymentImageUrl));
    }
  }

  FutureOr<void> _onBuySubscriptionPackageDeliveryAddressChangeEvent(BuySubscriptionPackageDeliveryAddressChangeEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(
      state.copyWith(
        savedAddress: event.selected,
        deliveryAddressId: event.selected.selected!.id!,
        addressTitleNumber: event.selected.selected!.title!,
        addressTitle: event.selected.selected!.title!.toString(),
        addressSubTitle: '${event.selected.selected!.flatHouse!}, ${event.selected.selected!.locality!}, ${event.selected.selected!.landmark!}',
        receiverName: event.selected.selected!.receiverName!,
        receiverCountryCode: event.selected.selected!.countryCode!.toString(),
        receiverContact: event.selected.selected!.receiverContact!,
      ),
    );
  }

  FutureOr<void> _onBuySubscriptionPackageInstructionsEvent(BuySubscriptionPackageInstructionsEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(state.copyWith(foodInstruction: event.instructions));
  }

  FutureOr<void> _onBuySubscriptionPackageDeliveryInstructionClearEvent(BuySubscriptionPackageDeliveryInstructionClearEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(state.copyWith(deliveryInstructionId: '', deliveryInstruction: '', deliveryInstructionImage: ''));
  }

  FutureOr<void> _onBuySubscriptionPackageDeliveryInstructionChangeEvent(BuySubscriptionPackageDeliveryInstructionChangeEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(state.copyWith(deliveryInstructionId: event.data.id, deliveryInstruction: event.data.name, deliveryInstructionImage: event.data.image));
  }

  FutureOr<void> _onBuySubscriptionPackageReceiverChangeEvent(BuySubscriptionPackageReceiverChangeEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    emit(state.copyWith(receiverName: event.name, receiverCountryCode: event.countryCode, receiverContact: event.phoneNumber));
  }

  FutureOr<void> _onBuySubscriptionPackageFoodModalResponseEvent(BuySubscriptionPackageFoodModalResponseEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    int index = state.inCart.indexWhere((element) => element.id == event.id);
    if (index != -1 && event.response.action! == true) {
      final String locale = await _authRepository.getLocale();
      List<food_in_cart_model.AddonConfigModel> savedAddon = <food_in_cart_model.AddonConfigModel>[];
      savedAddon.clear();
      for (var element in event.response.cartItem!.addons!) {
        var convertedItem = jsonEncode(element).toString();
        Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
        food_in_cart_model.AddonConfigModel savedData = food_in_cart_model.AddonConfigModel.fromJson(myMap, locale.toString());
        savedAddon.add(savedData);
      }

      List<food_in_cart_model.VariationConfigModel> savedVariations = <food_in_cart_model.VariationConfigModel>[];
      savedVariations.clear();
      for (var element in event.response.cartItem!.variations!) {
        var convertedItem = jsonEncode(element).toString();
        Map<String, dynamic>? myMap = jsonDecode(convertedItem) as Map<String, dynamic>;
        food_in_cart_model.VariationConfigModel savedData = food_in_cart_model.VariationConfigModel.fromJson(myMap);
        savedVariations.add(savedData);
      }

      state.inCart[index].addons = savedAddon;
      state.inCart[index].variations = savedVariations;
      emit(state.copyWith(inCart: [...state.inCart]));
      for (var element in state.inCart) {
        List<String> optionNameList = <String>[];
        optionNameList.clear();
        for (var addons in element.addons!) {
          optionNameList.add(addons.name!);
        }
        for (var variation in element.variations!) {
          for (var options in variation.options!) {
            optionNameList.add(options.name!);
          }
        }
        element.optionName = optionNameList.join(',');
      }
    }
  }

  FutureOr<void> _onBuySubscriptionPackageCreateOrderEvent(BuySubscriptionPackageCreateOrderEvent event, Emitter<BuySubscriptionPackageState> emit) async {
    try {
      List<TiffinSubscriptionFoodConfigRequestModel> foodConfig = <TiffinSubscriptionFoodConfigRequestModel>[];
      for (var inCartFood in state.inCart) {
        List<String> addonIds = <String>[];
        for (var addon in inCartFood.addons!) {
          addonIds.add(addon.id!);
        }
        List<tiffin_food_config.SelectedVariationConfigModel> savedVariation = <tiffin_food_config.SelectedVariationConfigModel>[];
        for (var variation in inCartFood.variations!) {
          List<String> selectedOptions = <String>[];
          for (var option in variation.options!) {
            selectedOptions.add(option.name!);
          }
          tiffin_food_config.SelectedVariationConfigModel saveIt = tiffin_food_config.SelectedVariationConfigModel(variation: variation.title!, selected: selectedOptions);
          savedVariation.add(saveIt);
        }
        TiffinSubscriptionFoodConfigRequestModel foodData = TiffinSubscriptionFoodConfigRequestModel(id: inCartFood.id!, addon: addonIds.join(','), variations: savedVariation);
        foodConfig.add(foodData);
      }
      final String userId = await _subscriptionTiffinPackagesRepository.userId();
      BuyTiffinSubscriptionRequestModel purchaseParam = BuyTiffinSubscriptionRequestModel(
        user: userId,
        subscriptionPackage: state.id,
        payment: state.payment,
        slot: state.savedSlot,
        cookingInstruction: state.foodInstruction,
        deliveryInstruction: state.deliveryInstructionId,
        deliveryAddress: state.info.details!.orderTo! == 'homedelivery' ? state.deliveryAddressId : '',
        receiverName: state.receiverName,
        countryCode: state.receiverCountryCode,
        receiverContact: state.receiverContact,
        food: foodConfig,
      );
      emit(state.copyWith(status: BuySubscriptionPackageStatus.placingOrder));
      DioApiResponse response = await _subscriptionTiffinPackagesRepository.buyTiffinSubscriptionPackage(purchaseParam);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        TiffinSubscriptionPurchaseResponseModel orderResponse = TiffinSubscriptionPurchaseResponseModel.fromJson(myMap);
        emit(state.copyWith(status: BuySubscriptionPackageStatus.makePayment, paymentURL: orderResponse.payLink));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: BuySubscriptionPackageStatus.customError, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: BuySubscriptionPackageStatus.customError, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

