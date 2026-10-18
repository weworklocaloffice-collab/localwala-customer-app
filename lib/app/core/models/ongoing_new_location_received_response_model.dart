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

class OngoingNewLocationReceivedLocationResponseModel {
  String? driverId;
  double? latitude;
  double? longitude;

  OngoingNewLocationReceivedLocationResponseModel({this.driverId, this.latitude, this.longitude});

  OngoingNewLocationReceivedLocationResponseModel.fromJson(Map<String, dynamic> json) {
    driverId = json['driverId'];
    if (json['latitude'] != null && json['latitude'] != '') {
      latitude = double.parse(json['latitude'].toString());
    } else {
      latitude = 0.0;
    }
    if (json['longitude'] != null && json['longitude'] != '') {
      longitude = double.parse(json['longitude'].toString());
    } else {
      longitude = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driverId'] = driverId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

