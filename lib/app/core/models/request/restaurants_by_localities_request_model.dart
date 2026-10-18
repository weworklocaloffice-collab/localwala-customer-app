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

class RestaurantsByLocalitiesRequestModel {
  String? from;
  String? slug;
  double? latitude;
  double? longitude;
  String? uid;
  int? limit;
  int? page;

  RestaurantsByLocalitiesRequestModel({this.from, this.slug, this.latitude, this.longitude, this.uid, this.limit, this.page});

  RestaurantsByLocalitiesRequestModel.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    slug = json['slug'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    uid = json['uid'];
    limit = json['limit'];
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['slug'] = slug;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['uid'] = uid;
    data['limit'] = limit;
    data['page'] = page;
    return data;
  }
}

