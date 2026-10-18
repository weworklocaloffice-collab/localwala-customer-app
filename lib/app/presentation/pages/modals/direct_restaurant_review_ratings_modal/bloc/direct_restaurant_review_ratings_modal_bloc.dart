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
import 'package:user/app/core/models/request/remove_image_file_request_model.dart';
import 'package:user/app/core/models/request/save_direct_restaurant_review_request_model.dart';
import 'package:user/app/core/models/restaurant_info_for_direct_review_rating_response_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/restaurant_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'direct_restaurant_review_ratings_modal_event.dart';
part 'direct_restaurant_review_ratings_modal_state.dart';

class DirectRestaurantReviewRatingsModalBloc extends Bloc<DirectRestaurantReviewRatingsModalEvent, DirectRestaurantReviewRatingsModalState> {
  final RestaurantRepository _restaurantRepository = RestaurantRepository();
  final AuthRepository _authRepository = AuthRepository();
  DirectRestaurantReviewRatingsModalBloc() : super(DirectRestaurantReviewRatingsModalState(model: RestaurantInfoForDirectReviewResponseModel(locale: ''))) {
    on<DirectRestaurantReviewRatingsModalInitialEvent>(_onDirectRestaurantReviewRatingsModalInitialEvent);
    on<DirectRestaurantReviewRatingsModalShortReviewTextChangeEvent>(_onDirectRestaurantReviewRatingsModalShortReviewTextChangeEvent);
    on<DirectRestaurantReviewRatingsModalRemoveUploadImageEvent>(_onDirectRestaurantReviewRatingsModalRemoveUploadImageEvent);
    on<DirectRestaurantReviewRatingsModalUploadImageEvent>(_onDirectRestaurantReviewRatingsModalUploadImageEvent);
    on<DirectRestaurantReviewRatingsModalIconPressEvent>(_onDirectRestaurantReviewRatingsModalIconPressEvent);
    on<DirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent>(_onDirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent);
    on<DirectRestaurantReviewRatingsModalSubmitEvent>(_onDirectRestaurantReviewRatingsModalSubmitEvent);
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalInitialEvent(DirectRestaurantReviewRatingsModalInitialEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "restaurant_direct_review"}, 'restaurant_direct_review_screen', 'restaurant_direct_review_screen');
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.loading, restaurant: event.restaurant));
      DioApiResponse response = await _restaurantRepository.getRestaurantInfoForDirectReview(event.restaurant);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          RestaurantInfoForDirectReviewResponseModel data = RestaurantInfoForDirectReviewResponseModel.fromJson(myMap, locale.toString());
          emit(state.copyWith(model: data, status: DirectRestaurantReviewRatingsModalStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalShortReviewTextChangeEvent(DirectRestaurantReviewRatingsModalShortReviewTextChangeEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    emit(state.copyWith(shortReview: event.txt));
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalRemoveUploadImageEvent(DirectRestaurantReviewRatingsModalRemoveUploadImageEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.mediaDeleteStarted, mediaDeleteIndex: event.index));
      final String userId = await _restaurantRepository.userId();
      RemoveImageFileRequestModel param = RemoveImageFileRequestModel(path: state.imageProof[event.index], uid: userId);
      DioApiResponse response = await _restaurantRepository.deleteMediaFile(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          state.imageProof.removeAt(event.index);
          emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.mediaDeleteSuccess, imageProof: [...state.imageProof]));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.mediaDeleteFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalUploadImageEvent(DirectRestaurantReviewRatingsModalUploadImageEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.uploadStarted));
      final String userId = await _restaurantRepository.userId();
      DioApiResponse response = await _restaurantRepository.uploadMediaImage(event.newImage, userId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        UploadImageModel data = UploadImageModel.fromJson(myMap);
        List<String> imageList = <String>[];
        for (var element in state.imageProof) {
          imageList.add(element);
        }
        imageList.add(data.path!);
        emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.uploadSuccess, imageProof: imageList));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalIconPressEvent(DirectRestaurantReviewRatingsModalIconPressEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    List<RestaurantMessagesConfigModel> message = <RestaurantMessagesConfigModel>[];
    message = state.model.messages!.where((element) => element.type == 'restaurant' && element.rateNumber == event.rate).toList();
    emit(state.copyWith(restauratnRating: event.rate, restaurantMessageList: [...message], restaurantMessage: [], canSubmit: true));
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent(DirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    if (state.restaurantMessage.contains(event.id)) {
      state.restaurantMessage.removeWhere((element) => element == event.id);
    } else {
      state.restaurantMessage.add(event.id);
    }
    emit(state.copyWith(restaurantMessage: [...state.restaurantMessage], canSubmit: true));
  }

  FutureOr<void> _onDirectRestaurantReviewRatingsModalSubmitEvent(DirectRestaurantReviewRatingsModalSubmitEvent event, Emitter<DirectRestaurantReviewRatingsModalState> emit) async {
    try {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.inProgress));
      final String userId = await _restaurantRepository.userId();
      SaveDirectRestaurantReviewRequestModel param = SaveDirectRestaurantReviewRequestModel(
        user: userId,
        restaurant: state.restaurant,
        restaurantRate: state.restauratnRating,
        restaurantMessage: state.restaurantMessage.join(','),
        shortReview: state.shortReview.toString(),
        images: state.imageProof.join(','),
      );
      DioApiResponse response = await _restaurantRepository.saveDirectRestaurantReview(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.submitFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.submitSuccess));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: DirectRestaurantReviewRatingsModalStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }
}

