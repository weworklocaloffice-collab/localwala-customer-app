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

class SaveAddressRequestModel {
  String? user;
  int? title;
  String? receiverName;
  String? countryCode;
  String? receiverContact;
  String? flatHouse;
  String? locality;
  String? landmark;
  String? type;
  String? longitude;
  String? latitude;

  SaveAddressRequestModel({this.user, this.title, this.receiverName, this.countryCode, this.receiverContact, this.flatHouse, this.locality, this.landmark, this.type, this.longitude, this.latitude});

  SaveAddressRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    title = json['title'];
    receiverName = json['receiverName'];
    countryCode = json['countryCode'];
    receiverContact = json['receiverContact'];
    flatHouse = json['flatHouse'];
    locality = json['locality'];
    landmark = json['landmark'];
    type = json['type'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['title'] = title;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['flatHouse'] = flatHouse;
    data['locality'] = locality;
    data['landmark'] = landmark;
    data['type'] = type;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    return data;
  }
}

