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

class CartItemRequestModel {
  String? user;
  String? trackingId;
  String? uuid;
  String? addons;
  String? food;
  String? restaurant;
  int? quantity;
  List<ServerSavedVariationOptionModel>? variations;
  String? campaignId;
  String? campaignType;
  String? cookingInstruction;

  CartItemRequestModel({this.user, this.trackingId, this.uuid, this.addons, this.food, this.restaurant, this.quantity, this.variations, this.campaignId, this.campaignType, this.cookingInstruction});

  CartItemRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    trackingId = json['trackingId'];
    uuid = json['uuid'];
    addons = json['addons'];
    food = json['food'];
    restaurant = json['restaurant'];
    quantity = json['quantity'];
    if (json['variations'] != null) {
      variations = <ServerSavedVariationOptionModel>[];
      json['variations'].forEach((v) {
        variations!.add(ServerSavedVariationOptionModel.fromJson(v));
      });
    } else {
      variations = [];
    }
    campaignId = json['campaignId'];
    campaignType = json['campaignType'];
    if (json['cookingInstruction'] != null && json['cookingInstruction'] != '') {
      cookingInstruction = json['cookingInstruction'];
    } else {
      cookingInstruction = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['trackingId'] = trackingId;
    data['uuid'] = uuid;
    data['addons'] = addons;
    data['food'] = food;
    data['restaurant'] = restaurant;
    data['quantity'] = quantity;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    data['campaignId'] = campaignId;
    data['campaignType'] = campaignType;
    data['cookingInstruction'] = cookingInstruction;
    return data;
  }
}

class ServerSavedVariationOptionModel {
  String? variation;
  List<String>? selected;

  ServerSavedVariationOptionModel({this.variation, this.selected});

  ServerSavedVariationOptionModel.fromJson(Map<String, dynamic> json) {
    variation = json['variation'];
    selected = json['selected'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variation'] = variation;
    data['selected'] = selected;
    return data;
  }
}

