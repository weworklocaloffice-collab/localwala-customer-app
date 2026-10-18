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

sealed class OrderReviewRatingsModalEvent {}

final class OrderReviewRatingsModalInitialEvent extends OrderReviewRatingsModalEvent {
  final String orderId;
  OrderReviewRatingsModalInitialEvent({required this.orderId});
}

final class OrderReviewRatingIconPressEvent extends OrderReviewRatingsModalEvent {
  final String to;
  final String id;
  final int rate;
  OrderReviewRatingIconPressEvent({required this.to, required this.id, required this.rate});
}

final class OrderReviewRatingDriverMessageSelectEvent extends OrderReviewRatingsModalEvent {
  final String id;
  OrderReviewRatingDriverMessageSelectEvent({required this.id});
}

final class OrderReviewRatingRestaurantMessageSelectEvent extends OrderReviewRatingsModalEvent {
  final String id;
  OrderReviewRatingRestaurantMessageSelectEvent({required this.id});
}

final class OrderReviewRatingProductMessageSelectEvent extends OrderReviewRatingsModalEvent {
  final String productId;
  final String msgId;
  OrderReviewRatingProductMessageSelectEvent({required this.productId, required this.msgId});
}

final class OrderReviewRatingUploadImageEvent extends OrderReviewRatingsModalEvent {
  final XFile newImage;
  OrderReviewRatingUploadImageEvent({required this.newImage});
}

final class OrderReviewRatingRemoveUploadImageEvent extends OrderReviewRatingsModalEvent {
  final int index;
  OrderReviewRatingRemoveUploadImageEvent({required this.index});
}

final class OrderReviewShortReviewTextChangeEvent extends OrderReviewRatingsModalEvent {
  final String txt;
  OrderReviewShortReviewTextChangeEvent({required this.txt});
}

final class OrderReviewRatingSubmitEvent extends OrderReviewRatingsModalEvent {}

