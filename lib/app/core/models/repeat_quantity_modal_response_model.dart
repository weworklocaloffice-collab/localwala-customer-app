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

class RepeatQuantityModalResponseModel {
  String? action;
  Data? data;

  RepeatQuantityModalResponseModel({this.action, this.data});

  RepeatQuantityModalResponseModel.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? id;
  List<FoodUuidAndQuantity>? list;

  Data({this.id, this.list});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['list'] != null) {
      list = <FoodUuidAndQuantity>[];
      json['list'].forEach((v) {
        list!.add(FoodUuidAndQuantity.fromJson(v));
      });
    } else {
      list = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FoodUuidAndQuantity {
  String? uuid;
  int? quantity;

  FoodUuidAndQuantity({this.uuid, this.quantity});

  FoodUuidAndQuantity.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['quantity'] = quantity;
    return data;
  }
}

