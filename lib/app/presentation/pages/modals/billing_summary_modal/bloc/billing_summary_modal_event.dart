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

part of 'billing_summary_modal_bloc.dart';

sealed class BillingSummaryModalEvent {}

final class BillingSummaryModalInitialEvent extends BillingSummaryModalEvent {
  final String orderTo;
  final double realTotal;
  final double itemTotal;
  final double itemDiscount;
  final double couponDiscount;
  final String couponCode;
  final double walletAmount;
  final double serviceCharge;
  final String serviceChargeName;
  final double foodServiceCharge;
  final String foodServiceChargeName;
  final String deliveryGratitude;
  final double deliveryTip;
  final double extraCharge;
  final double deliveryCharge;
  final double packagingCharges;
  final double packagingChargesTax;
  final double grandTotal;
  BillingSummaryModalInitialEvent({
    required this.orderTo,
    required this.realTotal,
    required this.itemTotal,
    required this.itemDiscount,
    required this.couponDiscount,
    required this.couponCode,
    required this.walletAmount,
    required this.serviceCharge,
    required this.serviceChargeName,
    required this.foodServiceCharge,
    required this.foodServiceChargeName,
    required this.deliveryGratitude,
    required this.deliveryTip,
    required this.extraCharge,
    required this.deliveryCharge,
    required this.packagingCharges,
    required this.packagingChargesTax,
    required this.grandTotal,
  });
}

final class BillingSummaryModalDeliveryGratitudeEvent extends BillingSummaryModalEvent {
  final double tip;
  BillingSummaryModalDeliveryGratitudeEvent({required this.tip});
}

