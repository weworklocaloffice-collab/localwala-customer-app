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

class TiffinSubscriptionFoodConfigRequestModel {
  String? id;
  String? addon;
  List<SelectedVariationConfigModel>? variations;

  TiffinSubscriptionFoodConfigRequestModel({this.id, this.addon, this.variations});

  TiffinSubscriptionFoodConfigRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addon = json['addon'];
    if (json['variations'] != null) {
      variations = <SelectedVariationConfigModel>[];
      json['variations'].forEach((v) {
        variations!.add(SelectedVariationConfigModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['addon'] = addon;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SelectedVariationConfigModel {
  String? variation;
  List<String>? selected;

  SelectedVariationConfigModel({this.variation, this.selected});

  SelectedVariationConfigModel.fromJson(Map<String, dynamic> json) {
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

