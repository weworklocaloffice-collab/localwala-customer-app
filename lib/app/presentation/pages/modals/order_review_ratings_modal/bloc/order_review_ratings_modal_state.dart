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

part of 'order_review_ratings_modal_bloc.dart';

enum OrderReviewRatingsModalStatus { loading, success, failure, inProgress, submitFailed, submitSuccess, uploadStarted, uploadSuccess, uploadFailed, mediaDeleteStarted, mediaDeleteSuccess, mediaDeleteFailed }

extension OrderReviewRatingsModalStatusX on OrderReviewRatingsModalStatus {
  bool get isLoading => this == OrderReviewRatingsModalStatus.loading;
  bool get isSuccess => this == OrderReviewRatingsModalStatus.success;
  bool get isFailure => this == OrderReviewRatingsModalStatus.failure;
  bool get isInProgress => this == OrderReviewRatingsModalStatus.inProgress;
  bool get isSubmitFailed => this == OrderReviewRatingsModalStatus.submitFailed;
  bool get isSubmitSuccess => this == OrderReviewRatingsModalStatus.submitSuccess;
  bool get isUploadStarted => this == OrderReviewRatingsModalStatus.uploadStarted;
  bool get isUploadSuccess => this == OrderReviewRatingsModalStatus.uploadSuccess;
  bool get isUploadFailed => this == OrderReviewRatingsModalStatus.uploadFailed;
  bool get isMediaDeleteStarted => this == OrderReviewRatingsModalStatus.mediaDeleteStarted;
  bool get isMediaDeleteSuccess => this == OrderReviewRatingsModalStatus.mediaDeleteSuccess;
  bool get isMediaDeleteFailed => this == OrderReviewRatingsModalStatus.mediaDeleteFailed;
}

final class OrderReviewRatingsModalState {
  final String orderId;
  final OrderDetailForReviewModel details;
  final bool canGiveRatingToDriver;
  final int driverRating;
  final List<String> driverMessage;
  final List<OrderRatingMessagesConfigModel> driverMessageList;
  final int restauratnRating;
  final List<String> restaurantMessage;
  final List<OrderRatingMessagesConfigModel> restaurantMessageList;
  final List<ProductReviewRatingModel> products;
  final bool canSubmit;
  final List<String> imageProof;
  final int mediaDeleteIndex;
  final String shortReview;
  final OrderReviewRatingsModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const OrderReviewRatingsModalState({
    this.orderId = '',
    required this.details,
    this.canGiveRatingToDriver = false,
    this.driverRating = 0,
    this.driverMessage = const [],
    this.driverMessageList = const [],
    this.restauratnRating = 0,
    this.restaurantMessage = const [],
    this.restaurantMessageList = const [],
    this.products = const [],
    this.canSubmit = false,
    this.imageProof = const [],
    this.mediaDeleteIndex = 0,
    this.shortReview = '',
    this.status = OrderReviewRatingsModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  OrderReviewRatingsModalState copyWith({
    String? orderId,
    OrderDetailForReviewModel? details,
    bool? canGiveRatingToDriver,
    int? driverRating,
    List<String>? driverMessage,
    List<OrderRatingMessagesConfigModel>? driverMessageList,
    int? restauratnRating,
    List<String>? restaurantMessage,
    List<OrderRatingMessagesConfigModel>? restaurantMessageList,
    List<ProductReviewRatingModel>? products,
    bool? canSubmit,
    List<String>? imageProof,
    int? mediaDeleteIndex,
    String? shortReview,
    OrderReviewRatingsModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return OrderReviewRatingsModalState(
      orderId: orderId ?? this.orderId,
      details: details ?? this.details,
      canGiveRatingToDriver: canGiveRatingToDriver ?? this.canGiveRatingToDriver,
      driverRating: driverRating ?? this.driverRating,
      driverMessage: driverMessage ?? this.driverMessage,
      driverMessageList: driverMessageList ?? this.driverMessageList,
      restauratnRating: restauratnRating ?? this.restauratnRating,
      restaurantMessage: restaurantMessage ?? this.restaurantMessage,
      restaurantMessageList: restaurantMessageList ?? this.restaurantMessageList,
      products: products ?? this.products,
      canSubmit: canSubmit ?? this.canSubmit,
      imageProof: imageProof ?? this.imageProof,
      mediaDeleteIndex: mediaDeleteIndex ?? this.mediaDeleteIndex,
      shortReview: shortReview ?? this.shortReview,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

