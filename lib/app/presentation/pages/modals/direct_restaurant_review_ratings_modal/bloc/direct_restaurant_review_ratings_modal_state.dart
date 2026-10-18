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

part of 'direct_restaurant_review_ratings_modal_bloc.dart';

enum DirectRestaurantReviewRatingsModalStatus { loading, success, failure, inProgress, submitFailed, submitSuccess, uploadStarted, uploadSuccess, uploadFailed, mediaDeleteStarted, mediaDeleteSuccess, mediaDeleteFailed }

extension DirectRestaurantReviewRatingsModalStatusX on DirectRestaurantReviewRatingsModalStatus {
  bool get isLoading => this == DirectRestaurantReviewRatingsModalStatus.loading;
  bool get isSuccess => this == DirectRestaurantReviewRatingsModalStatus.success;
  bool get isFailure => this == DirectRestaurantReviewRatingsModalStatus.failure;
  bool get isInProgress => this == DirectRestaurantReviewRatingsModalStatus.inProgress;
  bool get isSubmitFailed => this == DirectRestaurantReviewRatingsModalStatus.submitFailed;
  bool get isSubmitSuccess => this == DirectRestaurantReviewRatingsModalStatus.submitSuccess;
  bool get isUploadStarted => this == DirectRestaurantReviewRatingsModalStatus.uploadStarted;
  bool get isUploadSuccess => this == DirectRestaurantReviewRatingsModalStatus.uploadSuccess;
  bool get isUploadFailed => this == DirectRestaurantReviewRatingsModalStatus.uploadFailed;
  bool get isMediaDeleteStarted => this == DirectRestaurantReviewRatingsModalStatus.mediaDeleteStarted;
  bool get isMediaDeleteSuccess => this == DirectRestaurantReviewRatingsModalStatus.mediaDeleteSuccess;
  bool get isMediaDeleteFailed => this == DirectRestaurantReviewRatingsModalStatus.mediaDeleteFailed;
}

final class DirectRestaurantReviewRatingsModalState {
  final String restaurant;
  final RestaurantInfoForDirectReviewResponseModel model;
  final List<String> imageProof;
  final int mediaDeleteIndex;
  final String shortReview;
  final int restauratnRating;
  final List<String> restaurantMessage;
  final List<RestaurantMessagesConfigModel> restaurantMessageList;
  final bool canSubmit;
  final DirectRestaurantReviewRatingsModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DirectRestaurantReviewRatingsModalState({
    this.restaurant = '',
    required this.model,
    this.imageProof = const [],
    this.mediaDeleteIndex = 0,
    this.shortReview = '',
    this.restauratnRating = 0,
    this.restaurantMessage = const [],
    this.restaurantMessageList = const [],
    this.canSubmit = false,
    this.status = DirectRestaurantReviewRatingsModalStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DirectRestaurantReviewRatingsModalState copyWith({
    String? restaurant,
    RestaurantInfoForDirectReviewResponseModel? model,
    List<String>? imageProof,
    int? mediaDeleteIndex,
    String? shortReview,
    int? restauratnRating,
    List<String>? restaurantMessage,
    List<RestaurantMessagesConfigModel>? restaurantMessageList,
    bool? canSubmit,
    DirectRestaurantReviewRatingsModalStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DirectRestaurantReviewRatingsModalState(
      restaurant: restaurant ?? this.restaurant,
      model: model ?? this.model,
      imageProof: imageProof ?? this.imageProof,
      mediaDeleteIndex: mediaDeleteIndex ?? this.mediaDeleteIndex,
      shortReview: shortReview ?? this.shortReview,
      restauratnRating: restauratnRating ?? this.restauratnRating,
      restaurantMessage: restaurantMessage ?? this.restaurantMessage,
      restaurantMessageList: restaurantMessageList ?? this.restaurantMessageList,
      canSubmit: canSubmit ?? this.canSubmit,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

