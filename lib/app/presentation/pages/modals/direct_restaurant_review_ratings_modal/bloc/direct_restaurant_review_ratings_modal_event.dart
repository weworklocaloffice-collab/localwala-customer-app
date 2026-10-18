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

sealed class DirectRestaurantReviewRatingsModalEvent {}

final class DirectRestaurantReviewRatingsModalInitialEvent extends DirectRestaurantReviewRatingsModalEvent {
  final String restaurant;
  DirectRestaurantReviewRatingsModalInitialEvent({required this.restaurant});
}

final class DirectRestaurantReviewRatingsModalSubmitEvent extends DirectRestaurantReviewRatingsModalEvent {}

final class DirectRestaurantReviewRatingsModalShortReviewTextChangeEvent extends DirectRestaurantReviewRatingsModalEvent {
  final String txt;
  DirectRestaurantReviewRatingsModalShortReviewTextChangeEvent({required this.txt});
}

final class DirectRestaurantReviewRatingsModalRemoveUploadImageEvent extends DirectRestaurantReviewRatingsModalEvent {
  final int index;
  DirectRestaurantReviewRatingsModalRemoveUploadImageEvent({required this.index});
}

final class DirectRestaurantReviewRatingsModalUploadImageEvent extends DirectRestaurantReviewRatingsModalEvent {
  final XFile newImage;
  DirectRestaurantReviewRatingsModalUploadImageEvent({required this.newImage});
}

final class DirectRestaurantReviewRatingsModalIconPressEvent extends DirectRestaurantReviewRatingsModalEvent {
  final int rate;
  DirectRestaurantReviewRatingsModalIconPressEvent({required this.rate});
}

final class DirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent extends DirectRestaurantReviewRatingsModalEvent {
  final String id;
  DirectRestaurantReviewRatingsModalRestaurantMessageSelectEvent({required this.id});
}

