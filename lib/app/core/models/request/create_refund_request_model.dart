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

class CreateRefundRequestModel {
  String? reason;
  String? user;
  String? orders;
  String? restaurant;
  String? payment;

  CreateRefundRequestModel({this.reason, this.user, this.orders, this.restaurant, this.payment});

  CreateRefundRequestModel.fromJson(Map<String, dynamic> json) {
    reason = json['reason'];
    user = json['user'];
    orders = json['orders'];
    restaurant = json['restaurant'];
    payment = json['payment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reason'] = reason;
    data['user'] = user;
    data['orders'] = orders;
    data['restaurant'] = restaurant;
    data['payment'] = payment;
    return data;
  }
}

