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
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/order_detail_for_review_model.dart';
import 'package:user/app/core/models/product_review_rating_model.dart';
import 'package:user/app/core/models/request/order_review_request_model.dart';
import 'package:user/app/core/models/request/product_review_param_request_model.dart';
import 'package:user/app/core/models/request/remove_image_file_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'order_review_ratings_modal_event.dart';
part 'order_review_ratings_modal_state.dart';

class OrderReviewRatingsModalBloc extends Bloc<OrderReviewRatingsModalEvent, OrderReviewRatingsModalState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  OrderReviewRatingsModalBloc() : super(OrderReviewRatingsModalState(details: OrderDetailForReviewModel(locale: ''))) {
    on<OrderReviewRatingsModalInitialEvent>(_onOrderReviewRatingsModalInitialEvent);
    on<OrderReviewRatingIconPressEvent>(_onOrderReviewRatingIconPressEvent);
    on<OrderReviewRatingDriverMessageSelectEvent>(_onOrderReviewRatingDriverMessageSelectEvent);
    on<OrderReviewRatingRestaurantMessageSelectEvent>(_onOrderReviewRatingRestaurantMessageSelectEvent);
    on<OrderReviewRatingProductMessageSelectEvent>(_onOrderReviewRatingProductMessageSelectEvent);
    on<OrderReviewRatingUploadImageEvent>(_onOrderReviewRatingUploadImageEvent);
    on<OrderReviewRatingRemoveUploadImageEvent>(_onOrderReviewRatingRemoveUploadImageEvent);
    on<OrderReviewShortReviewTextChangeEvent>(_onOrderReviewShortReviewTextChangeEvent);
    on<OrderReviewRatingSubmitEvent>(_onOrderReviewRatingSubmitEvent);
  }

  FutureOr<void> _onOrderReviewRatingsModalInitialEvent(OrderReviewRatingsModalInitialEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_review_rating"}, 'order_review_rating_screen', 'order_review_rating_screen');
      final String userId = await _historyRepository.userId();
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.loading, orderId: event.orderId));
      DioApiResponse response = await _historyRepository.getOrderDetailsForReview(event.orderId, userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: OrderReviewRatingsModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          OrderDetailForReviewModel data = OrderDetailForReviewModel.fromJson(myMap, locale.toString());
          List<ProductReviewRatingModel> productsList = <ProductReviewRatingModel>[];
          for (var element in data.details!.cartItem!) {
            ProductReviewRatingModel product = ProductReviewRatingModel(id: element.id!, name: element.name!, rate: 0, msg: [], messages: [], locale: locale.toString());
            final int indexOfProduct = productsList.indexWhere((x) => x.id == product.id);
            if (indexOfProduct == -1) {
              productsList.add(product);
            }
          }
          emit(
            state.copyWith(
              details: data,
              status: OrderReviewRatingsModalStatus.success,
              canGiveRatingToDriver: data.details!.orderTo! == 'homedelivery' && data.details!.driverInfo!.id!.isNotEmpty ? true : false,
              products: productsList,
            ),
          );
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderReviewRatingsModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOrderReviewRatingIconPressEvent(OrderReviewRatingIconPressEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    if (event.to == 'deliveryman') {
      List<OrderRatingMessagesConfigModel> message = <OrderRatingMessagesConfigModel>[];
      message = state.details.messages!.where((element) => element.type == 'deliveryman' && element.rateNumber == event.rate).toList();
      emit(state.copyWith(driverRating: event.rate, driverMessageList: [...message], driverMessage: [], canSubmit: true));
    } else if (event.to == 'restaurant') {
      List<OrderRatingMessagesConfigModel> message = <OrderRatingMessagesConfigModel>[];
      message = state.details.messages!.where((element) => element.type == 'restaurant' && element.rateNumber == event.rate).toList();
      emit(state.copyWith(restauratnRating: event.rate, restaurantMessageList: [...message], restaurantMessage: [], canSubmit: true));
    } else if (event.to == 'product') {
      final int productIndex = state.products.indexWhere((element) => element.id == event.id);
      if (productIndex != -1) {
        List<OrderRatingMessagesConfigModel> message = <OrderRatingMessagesConfigModel>[];
        message = state.details.messages!.where((element) => element.type == 'product' && element.rateNumber == event.rate).toList();
        state.products[productIndex].rate = event.rate;
        state.products[productIndex].messages = message;
        state.products[productIndex].msg = [];
        emit(state.copyWith(products: [...state.products], canSubmit: true));
      }
    }
  }

  FutureOr<void> _onOrderReviewRatingDriverMessageSelectEvent(OrderReviewRatingDriverMessageSelectEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    if (state.driverMessage.contains(event.id)) {
      state.driverMessage.removeWhere((element) => element == event.id);
    } else {
      state.driverMessage.add(event.id);
    }
    emit(state.copyWith(driverMessage: [...state.driverMessage], canSubmit: true));
  }

  FutureOr<void> _onOrderReviewRatingRestaurantMessageSelectEvent(OrderReviewRatingRestaurantMessageSelectEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    if (state.restaurantMessage.contains(event.id)) {
      state.restaurantMessage.removeWhere((element) => element == event.id);
    } else {
      state.restaurantMessage.add(event.id);
    }
    emit(state.copyWith(restaurantMessage: [...state.restaurantMessage], canSubmit: true));
  }

  FutureOr<void> _onOrderReviewRatingProductMessageSelectEvent(OrderReviewRatingProductMessageSelectEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    final int productIndex = state.products.indexWhere((element) => element.id == event.productId);
    if (productIndex != -1) {
      if (state.products[productIndex].msg!.contains(event.msgId)) {
        state.products[productIndex].msg!.removeWhere((element) => element == event.msgId);
      } else {
        state.products[productIndex].msg!.add(event.msgId);
      }
      emit(state.copyWith(products: [...state.products], canSubmit: true));
    }
  }

  FutureOr<void> _onOrderReviewRatingUploadImageEvent(OrderReviewRatingUploadImageEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.uploadStarted));
      final String userId = await _historyRepository.userId();
      DioApiResponse response = await _historyRepository.uploadMediaImage(event.newImage, userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UploadImageModel data = UploadImageModel.fromJson(myMap);
        List<String> imageList = <String>[];
        for (var element in state.imageProof) {
          imageList.add(element);
        }
        imageList.add(data.path!);
        emit(state.copyWith(status: OrderReviewRatingsModalStatus.uploadSuccess, imageProof: imageList));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderReviewRatingsModalStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOrderReviewRatingRemoveUploadImageEvent(OrderReviewRatingRemoveUploadImageEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.mediaDeleteStarted, mediaDeleteIndex: event.index));
      final String userId = await _historyRepository.userId();
      RemoveImageFileRequestModel param = RemoveImageFileRequestModel(path: state.imageProof[event.index], uid: userId);
      DioApiResponse response = await _historyRepository.deleteMediaFile(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: OrderReviewRatingsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          state.imageProof.removeAt(event.index);
          emit(state.copyWith(status: OrderReviewRatingsModalStatus.mediaDeleteSuccess, imageProof: [...state.imageProof]));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderReviewRatingsModalStatus.mediaDeleteFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onOrderReviewShortReviewTextChangeEvent(OrderReviewShortReviewTextChangeEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    emit(state.copyWith(shortReview: event.txt));
  }

  FutureOr<void> _onOrderReviewRatingSubmitEvent(OrderReviewRatingSubmitEvent event, Emitter<OrderReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.inProgress));
      final String userId = await _historyRepository.userId();
      List<ProductReviewParamRequestModel> products = <ProductReviewParamRequestModel>[];
      for (var element in state.products) {
        if (element.rate! != 0) {
          ProductReviewParamRequestModel product = ProductReviewParamRequestModel(id: element.id!, rate: element.rate!, message: element.msg!.join(','));
          products.add(product);
        }
      }
      OrderReviewRequestModel param = OrderReviewRequestModel(
        user: userId,
        orders: state.orderId,
        driver: state.canGiveRatingToDriver && state.details.details!.driverInfo!.id!.isNotEmpty ? state.details.details!.driverInfo!.id! : null,
        restaurant: state.details.details!.restaurant!.id!.isNotEmpty ? state.details.details!.restaurant!.id! : null,
        driverRate: state.driverRating,
        restaurantRate: state.restauratnRating,
        driverMessage: state.driverMessage.join(','),
        restaurantMessage: state.restaurantMessage.join(','),
        product: products,
        shortReview: state.shortReview.toString(),
        images: state.imageProof.join(','),
      );
      DioApiResponse response = await _historyRepository.saveOrderReview(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: OrderReviewRatingsModalStatus.submitFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          emit(state.copyWith(status: OrderReviewRatingsModalStatus.submitSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: OrderReviewRatingsModalStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: OrderReviewRatingsModalStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

