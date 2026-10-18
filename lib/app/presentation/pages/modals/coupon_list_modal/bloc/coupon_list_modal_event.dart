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

part of 'coupon_list_modal_bloc.dart';

sealed class CouponListModalEvent {}

final class CouponListModalInitialEvent extends CouponListModalEvent {
  final String restaurant;
  final double itemTotal;
  final double latitude;
  final double longitude;
  final String trackingId;
  CouponListModalInitialEvent({required this.restaurant, required this.itemTotal, required this.latitude, required this.longitude, required this.trackingId});
}

final class CouponListModalOpenDiscriptionEvent extends CouponListModalEvent {
  final int index;
  CouponListModalOpenDiscriptionEvent({required this.index});
}

final class CouponListModalSelectCouponEvent extends CouponListModalEvent {
  final int index;
  CouponListModalSelectCouponEvent({required this.index});
}

