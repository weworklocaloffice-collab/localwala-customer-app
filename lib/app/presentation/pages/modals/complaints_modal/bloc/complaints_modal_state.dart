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

part of 'complaints_modal_bloc.dart';

enum ComplaintsModalStatus { loading, success, failure, inProgress, submitFailed, submitSuccess, uploadStarted, uploadSuccess, uploadFailed, mediaDeleteStarted, mediaDeleteSuccess, mediaDeleteFailed }

extension ComplaintsModalStatusX on ComplaintsModalStatus {
  bool get isLoading => this == ComplaintsModalStatus.loading;
  bool get isSuccess => this == ComplaintsModalStatus.success;
  bool get isFailure => this == ComplaintsModalStatus.failure;
  bool get isInProgress => this == ComplaintsModalStatus.inProgress;
  bool get isSubmitFailed => this == ComplaintsModalStatus.submitFailed;
  bool get isSubmitSuccess => this == ComplaintsModalStatus.submitSuccess;
  bool get isUploadStarted => this == ComplaintsModalStatus.uploadStarted;
  bool get isUploadSuccess => this == ComplaintsModalStatus.uploadSuccess;
  bool get isUploadFailed => this == ComplaintsModalStatus.uploadFailed;
  bool get isMediaDeleteStarted => this == ComplaintsModalStatus.mediaDeleteStarted;
  bool get isMediaDeleteSuccess => this == ComplaintsModalStatus.mediaDeleteSuccess;
  bool get isMediaDeleteFailed => this == ComplaintsModalStatus.mediaDeleteFailed;
}

final class ComplaintsModalState {
  final String orderId;
  final OrderDetailComplaintResponseModel details;
  final ComplaintIssueWithListModel complaintTo;
  final List<ComplaintIssueWithListModel> complaintsWith;
  final List<ComplaintReasonListModel> reasonList;
  final ComplaintReasonListModel reason;
  final FoodInCartModel food;
  final ComplaintsTitleField complaintTitle;
  final ComplaintsBriefField complaintBrief;
  final List<String> imageProof;
  final bool isValid;
  final int mediaDeleteIndex;
  final ComplaintsModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ComplaintsModalState({
    this.orderId = '',
    required this.details,
    required this.complaintTo,
    required this.reason,
    required this.food,
    this.complaintsWith = const [],
    this.reasonList = const [],
    this.complaintTitle = const ComplaintsTitleField.pure(),
    this.complaintBrief = const ComplaintsBriefField.pure(),
    this.imageProof = const [],
    this.isValid = false,
    this.mediaDeleteIndex = 0,
    this.status = ComplaintsModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  ComplaintsModalState copyWith({
    String? orderId,
    OrderDetailComplaintResponseModel? details,
    ComplaintIssueWithListModel? complaintTo,
    List<ComplaintIssueWithListModel>? complaintsWith,
    List<ComplaintReasonListModel>? reasonList,
    ComplaintReasonListModel? reason,
    FoodInCartModel? food,
    ComplaintsTitleField? complaintTitle,
    ComplaintsBriefField? complaintBrief,
    List<String>? imageProof,
    bool? isValid,
    int? mediaDeleteIndex,
    ComplaintsModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return ComplaintsModalState(
      orderId: orderId ?? this.orderId,
      details: details ?? this.details,
      complaintTo: complaintTo ?? this.complaintTo,
      complaintsWith: complaintsWith ?? this.complaintsWith,
      reasonList: reasonList ?? this.reasonList,
      reason: reason ?? this.reason,
      food: food ?? this.food,
      complaintTitle: complaintTitle ?? this.complaintTitle,
      complaintBrief: complaintBrief ?? this.complaintBrief,
      imageProof: imageProof ?? this.imageProof,
      isValid: isValid ?? this.isValid,
      mediaDeleteIndex: mediaDeleteIndex ?? this.mediaDeleteIndex,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

