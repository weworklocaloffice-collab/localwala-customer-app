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

class TiffinSubscriptionRefundRequestModel {
  String? user;
  String? purchaseId;
  String? reason;
  String? subscriptionPackage;
  String? restaurant;
  String? payment;

  TiffinSubscriptionRefundRequestModel({this.user, this.purchaseId, this.reason, this.subscriptionPackage, this.restaurant, this.payment});

  TiffinSubscriptionRefundRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    purchaseId = json['purchaseId'];
    reason = json['reason'];
    subscriptionPackage = json['subscriptionPackage'];
    restaurant = json['restaurant'];
    payment = json['payment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['purchaseId'] = purchaseId;
    data['reason'] = reason;
    data['subscriptionPackage'] = subscriptionPackage;
    data['restaurant'] = restaurant;
    data['payment'] = payment;
    return data;
  }
}

