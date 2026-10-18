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
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/api_status_response_model.dart';
import 'package:user/app/core/models/complaints_issue_with_list_model.dart';
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/core/models/order_details_complaints_model.dart';
import 'package:user/app/core/models/request/remove_image_file_request_model.dart';
import 'package:user/app/core/models/request/save_complaints_request_model.dart';
import 'package:user/app/core/models/server_error_model.dart';
import 'package:user/app/core/models/upload_image_model.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/core/repositories/history_repository.dart';
import 'package:user/app/core/validations/complaints_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'complaints_modal_event.dart';
part 'complaints_modal_state.dart';

class ComplaintsModalBloc extends Bloc<ComplaintsModalEvent, ComplaintsModalState> {
  final HistoryRepository _historyRepository = HistoryRepository();
  final AuthRepository _authRepository = AuthRepository();
  ComplaintsModalBloc()
    : super(
        ComplaintsModalState(
          details: OrderDetailComplaintResponseModel(locale: ''),
          complaintTo: ComplaintIssueWithListModel(label: '', value: ''),
          reason: ComplaintReasonListModel(name: '', type: '', translations: [], status: false, id: '', locale: ''),
          food: FoodInCartModel(locale: ''),
        ),
      ) {
    on<ComplaintsModalInitialEvent>(_onComplaintsModalInitialEvent);
    on<ComplaintModalIssueWithEvent>(_onComplaintModalIssueWithEvent);
    on<ComplaintModalReasonSelectEvent>(_onComplaintModalReasonSelectEvent);
    on<ComplaintModalFoodSelectEvent>(_onComplaintModalFoodSelectEvent);
    on<ComplaintModalTitleChangedEvent>(_onComplaintModalTitleChangedEvent);
    on<ComplaintModalTitleUnfocusedEvent>(_onComplaintModalTitleUnfocusedEvent);
    on<ComplaintModalBriefChangedEvent>(_onComplaintModalBriefChangedEvent);
    on<ComplaintModalBriefUnfocusedEvent>(_onComplaintModalBriefUnfocusedEvent);
    on<ComplaintModalUploadImageEvent>(_onComplaintModalUploadImageEvent);
    on<ComplaintModalRemoveUploadImageEvent>(_onComplaintModalRemoveUploadImageEvent);
    on<ComplaintModalSubmittedEvent>(_onComplaintModalSubmittedEvent);
  }

  FutureOr<void> _onComplaintsModalInitialEvent(ComplaintsModalInitialEvent event, Emitter<ComplaintsModalState> emit) async {
    try {
      await _authRepository.saveEvent('visited_screen', {"screen": "order_complaints", "order": event.orderId}, 'order_complaints_screen', 'order_complaints_screen');
      emit(state.copyWith(status: ComplaintsModalStatus.loading, orderId: event.orderId));
      DioApiResponse response = await _historyRepository.getOrderDetailsForComplaints(event.orderId);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: ComplaintsModalStatus.failure, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          final String locale = await _authRepository.getLocale();
          OrderDetailComplaintResponseModel data = OrderDetailComplaintResponseModel.fromJson(myMap, locale.toString());
          List<ComplaintIssueWithListModel> complaintWithList = <ComplaintIssueWithListModel>[];
          complaintWithList.clear();
          ComplaintIssueWithListModel order = ComplaintIssueWithListModel(label: 'dd_order', value: 'order');
          ComplaintIssueWithListModel restaurant = ComplaintIssueWithListModel(label: 'dd_restaurant', value: 'restaurant');
          ComplaintIssueWithListModel product = ComplaintIssueWithListModel(label: 'dd_food', value: 'product');
          complaintWithList.add(order);
          complaintWithList.add(restaurant);
          complaintWithList.add(product);
          if (data.details!.orderTo! == 'homedelivery' && data.details!.driverInfo!.id!.isNotEmpty) {
            ComplaintIssueWithListModel deliveryman = ComplaintIssueWithListModel(label: 'dd_deliveryman', value: 'deliveryman');
            complaintWithList.add(deliveryman);
          }
          if (complaintWithList.isNotEmpty) {
            emit(state.copyWith(complaintTo: complaintWithList.first));
            List<ComplaintReasonListModel> reasonList = <ComplaintReasonListModel>[];
            reasonList = data.reason!.where((element) => element.type == state.complaintTo.value!.toString()).toList();
            emit(state.copyWith(reasonList: reasonList));
            if (reasonList.isNotEmpty) {
              emit(state.copyWith(reason: reasonList.first));
            }
          }
          emit(state.copyWith(details: data, complaintsWith: complaintWithList, status: ComplaintsModalStatus.success));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ComplaintsModalStatus.failure, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ComplaintsModalStatus.failure, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onComplaintModalIssueWithEvent(ComplaintModalIssueWithEvent event, Emitter<ComplaintsModalState> emit) async {
    List<ComplaintReasonListModel> reasonList = <ComplaintReasonListModel>[];
    reasonList = state.details.reason!.where((element) => element.type == event.issueWith.value!.toString()).toList();
    emit(state.copyWith(complaintTo: event.issueWith, reasonList: reasonList, status: ComplaintsModalStatus.success));
    if (reasonList.isNotEmpty) {
      emit(state.copyWith(reason: reasonList.first, status: ComplaintsModalStatus.success));
    }
    if (event.issueWith.value == 'product') {
      emit(state.copyWith(food: state.details.details!.cartItem!.first, status: ComplaintsModalStatus.success));
    }
  }

  FutureOr<void> _onComplaintModalReasonSelectEvent(ComplaintModalReasonSelectEvent event, Emitter<ComplaintsModalState> emit) async {
    emit(state.copyWith(reason: event.reason, status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalFoodSelectEvent(ComplaintModalFoodSelectEvent event, Emitter<ComplaintsModalState> emit) async {
    emit(state.copyWith(food: event.food, status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalTitleChangedEvent(ComplaintModalTitleChangedEvent event, Emitter<ComplaintsModalState> emit) async {
    final title = ComplaintsTitleField.dirty(event.title);
    emit(state.copyWith(complaintTitle: title.isValid ? title : ComplaintsTitleField.pure(event.title), isValid: Formz.validate([title, state.complaintBrief]), status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalTitleUnfocusedEvent(ComplaintModalTitleUnfocusedEvent event, Emitter<ComplaintsModalState> emit) async {
    final title = ComplaintsTitleField.dirty(state.complaintTitle.value);
    emit(state.copyWith(complaintTitle: title, isValid: Formz.validate([title, state.complaintBrief]), status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalBriefChangedEvent(ComplaintModalBriefChangedEvent event, Emitter<ComplaintsModalState> emit) async {
    final brief = ComplaintsBriefField.dirty(event.brief);
    emit(state.copyWith(complaintBrief: brief.isValid ? brief : ComplaintsBriefField.pure(event.brief), isValid: Formz.validate([brief, state.complaintTitle]), status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalBriefUnfocusedEvent(ComplaintModalBriefUnfocusedEvent event, Emitter<ComplaintsModalState> emit) async {
    final brief = ComplaintsBriefField.dirty(state.complaintBrief.value);
    emit(state.copyWith(complaintBrief: brief, isValid: Formz.validate([brief, state.complaintTitle]), status: ComplaintsModalStatus.success));
  }

  FutureOr<void> _onComplaintModalUploadImageEvent(ComplaintModalUploadImageEvent event, Emitter<ComplaintsModalState> emit) async {
    try {
      emit(state.copyWith(status: ComplaintsModalStatus.uploadStarted));
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
        emit(state.copyWith(status: ComplaintsModalStatus.uploadSuccess, imageProof: imageList));
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ComplaintsModalStatus.uploadFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ComplaintsModalStatus.uploadFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onComplaintModalRemoveUploadImageEvent(ComplaintModalRemoveUploadImageEvent event, Emitter<ComplaintsModalState> emit) async {
    try {
      emit(state.copyWith(status: ComplaintsModalStatus.mediaDeleteStarted, mediaDeleteIndex: event.index));
      final String userId = await _historyRepository.userId();
      RemoveImageFileRequestModel param = RemoveImageFileRequestModel(path: state.imageProof[event.index], uid: userId);
      DioApiResponse response = await _historyRepository.deleteMediaFile(param);
      if (response.errorType == NetErrorType.none) {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
        if (!initialResponse.success!) {
          emit(state.copyWith(status: ComplaintsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
        } else {
          state.imageProof.removeAt(event.index);
          emit(state.copyWith(status: ComplaintsModalStatus.mediaDeleteSuccess, imageProof: [...state.imageProof]));
        }
      } else {
        Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
        ServerErrorModel data = ServerErrorModel.fromJson(myMap);
        emit(state.copyWith(status: ComplaintsModalStatus.mediaDeleteFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
      }
    } catch (e, stacktrace) {
      emit(state.copyWith(status: ComplaintsModalStatus.mediaDeleteFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stacktrace);
      }
    }
  }

  FutureOr<void> _onComplaintModalSubmittedEvent(ComplaintModalSubmittedEvent event, Emitter<ComplaintsModalState> emit) async {
    final title = ComplaintsTitleField.dirty(state.complaintTitle.value);
    final brief = ComplaintsBriefField.dirty(state.complaintBrief.value);
    emit(state.copyWith(complaintTitle: title, complaintBrief: brief, isValid: Formz.validate([title, brief])));
    if (state.isValid && state.complaintTitle.value.isNotEmpty && state.complaintBrief.value.isNotEmpty) {
      try {
        final String userId = await _historyRepository.userId();
        final String orderId = state.orderId;
        String complaintsReasonId = state.reason.id!.isNotEmpty ? state.reason.id! : '';
        final String title = state.complaintTitle.value;
        final String brief = state.complaintBrief.value;
        final String proof = state.imageProof.join(',');
        final String issueFrom = state.complaintTo.value!;
        String driverId = '';
        String foodId = '';
        final String restaurantId = state.details.details!.restaurant!.id!;
        if (issueFrom == 'product') {
          foodId = state.food.id!;
        } else if (issueFrom == 'deliveryman') {
          driverId = state.details.details!.driverInfo!.id!;
        }
        SaveComplaintsRequestModel param = SaveComplaintsRequestModel(
          user: userId,
          orders: orderId,
          reason: complaintsReasonId,
          title: title,
          brief: brief,
          proof: proof,
          issueWith: issueFrom,
          restaurant: restaurantId,
          driver: driverId,
          product: foodId,
        );
        emit(state.copyWith(status: ComplaintsModalStatus.inProgress));
        DioApiResponse response = await _historyRepository.saveComplaints(param);
        if (response.errorType == NetErrorType.none) {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ApiStatusResponseModel initialResponse = ApiStatusResponseModel.fromJson(myMap);
          if (!initialResponse.success!) {
            emit(state.copyWith(status: ComplaintsModalStatus.submitFailed, statusCode: 0, alertMessage: 'Something went wrong', extraMessage: ''));
          } else {
            emit(state.copyWith(status: ComplaintsModalStatus.submitSuccess));
          }
        } else {
          Map<String, dynamic>? myMap = jsonDecode(response.body) as Map<String, dynamic>;
          ServerErrorModel data = ServerErrorModel.fromJson(myMap);
          emit(state.copyWith(status: ComplaintsModalStatus.submitFailed, statusCode: data.code, alertMessage: data.message.toString(), extraMessage: data.extra.toString()));
        }
      } catch (e, stacktrace) {
        emit(state.copyWith(status: ComplaintsModalStatus.submitFailed, statusCode: 0, alertMessage: e.toString(), extraMessage: ''));
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(e, stacktrace);
        }
      }
    }
  }
}

