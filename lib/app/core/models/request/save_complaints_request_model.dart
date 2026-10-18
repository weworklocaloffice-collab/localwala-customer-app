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

class SaveComplaintsRequestModel {
  String? user;
  String? orders;
  String? reason;
  String? title;
  String? brief;
  String? proof;
  String? issueWith;
  String? restaurant;
  String? driver;
  String? product;

  SaveComplaintsRequestModel({this.user, this.orders, this.reason, this.title, this.brief, this.proof, this.issueWith, this.restaurant, this.driver, this.product});

  SaveComplaintsRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    orders = json['orders'];
    reason = json['reason'];
    title = json['title'];
    brief = json['brief'];
    proof = json['proof'];
    issueWith = json['issueWith'];
    restaurant = json['restaurant'];
    driver = json['driver'];
    product = json['product'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['orders'] = orders;
    data['reason'] = reason;
    data['title'] = title;
    data['brief'] = brief;
    data['proof'] = proof;
    data['issueWith'] = issueWith;
    data['restaurant'] = restaurant;
    data['driver'] = driver;
    data['product'] = product;
    return data;
  }
}

