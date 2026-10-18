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

class MyAddressListResponseModel {
  List<AddressDataModel>? list;
  int? total;
  MyAddressListResponseModel({this.list, this.total});

  MyAddressListResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <AddressDataModel>[];
      json['list'].forEach((v) {
        list!.add(AddressDataModel.fromJson(v));
      });
    } else {
      list = [];
    }
    if (json['total'] != null && json['total'] != '') {
      total = int.parse(json['total'].toString());
    } else {
      total = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    return data;
  }
}

class AddressDataModel {
  LocationCoordinates? location;
  int? title;
  String? receiverName;
  String? countryCode;
  String? receiverContact;
  String? flatHouse;
  String? locality;
  String? landmark;
  bool? willShow = true;
  String? id;

  AddressDataModel({this.location, this.title, this.receiverName, this.countryCode, this.receiverContact, this.flatHouse, this.locality, this.landmark, this.id, this.willShow = true});

  AddressDataModel.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    title = int.parse(json['title'].toString());
    receiverName = json['receiverName'];
    countryCode = json['countryCode'].toString();
    receiverContact = json['receiverContact'];
    flatHouse = json['flatHouse'];
    locality = json['locality'];
    landmark = json['landmark'];
    if (json['willShow'] != null && json['willShow'] != '') {
      willShow = json['willShow'];
    } else {
      willShow = true;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['title'] = title;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['flatHouse'] = flatHouse;
    data['locality'] = locality;
    data['landmark'] = landmark;
    data['willShow'] = willShow;
    data['id'] = id;
    return data;
  }
}

class LocationCoordinates {
  String? type;
  List<double>? coordinates;

  LocationCoordinates({this.type, this.coordinates});

  LocationCoordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coordinates = List<double>.from(json['coordinates'].map((x) => x.toDouble()));
    } else {
      coordinates = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

