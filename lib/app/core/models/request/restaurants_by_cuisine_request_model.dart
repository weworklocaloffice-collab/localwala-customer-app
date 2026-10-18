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

class RestaurantsByCuisineRequestModel {
  String? cuisine;
  double? latitude;
  double? longitude;
  int? limit;
  int? page;
  String? uid = '';

  RestaurantsByCuisineRequestModel({this.cuisine, this.latitude, this.longitude, this.limit, this.page, this.uid});

  RestaurantsByCuisineRequestModel.fromJson(Map<String, dynamic> json) {
    cuisine = json['cuisine'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    limit = json['limit'];
    page = json['page'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cuisine'] = cuisine;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['limit'] = limit;
    data['page'] = page;
    data['uid'] = uid;
    return data;
  }
}

