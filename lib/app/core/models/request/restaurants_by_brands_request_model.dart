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

class RestaurantsByBrandsRequestModel {
  String? outlet;
  double? latitude;
  double? longitude;
  String? uid = '';

  RestaurantsByBrandsRequestModel({this.outlet, this.latitude, this.longitude, this.uid});

  RestaurantsByBrandsRequestModel.fromJson(Map<String, dynamic> json) {
    outlet = json['outlet'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['outlet'] = outlet;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['uid'] = uid;
    return data;
  }
}

