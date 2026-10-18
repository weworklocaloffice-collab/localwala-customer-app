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

class ReportIssueRestaurantRequestModel {
  String? user;
  String? restaurant;
  String? reason;
  String? message;

  ReportIssueRestaurantRequestModel({this.user, this.restaurant, this.reason, this.message});

  ReportIssueRestaurantRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    restaurant = json['restaurant'];
    reason = json['reason'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['restaurant'] = restaurant;
    data['reason'] = reason;
    data['message'] = message;
    return data;
  }
}

