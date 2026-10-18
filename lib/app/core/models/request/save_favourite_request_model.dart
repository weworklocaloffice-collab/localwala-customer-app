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

class SaveFavouriteRequestModel {
  String? user;
  String? type;
  String? restaurant = '';
  String? food = '';
  SaveFavouriteRequestModel({this.user, this.type, this.restaurant, this.food});

  SaveFavouriteRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    type = json['type'];
    restaurant = json['restaurant'];
    food = json['food'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['type'] = type;
    data['restaurant'] = restaurant;
    data['food'] = food;
    return data;
  }
}

