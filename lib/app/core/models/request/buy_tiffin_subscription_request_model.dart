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

import 'package:user/app/core/models/request/tiffin_subscription_food_config_request_model.dart';

class BuyTiffinSubscriptionRequestModel {
  String? user;
  String? subscriptionPackage;
  String? payment;
  List<TiffinSubscriptionFoodConfigRequestModel>? food;
  String? slot;
  String? cookingInstruction;
  String? deliveryInstruction;
  String? deliveryAddress;
  String? receiverName;
  String? countryCode;
  String? receiverContact;

  BuyTiffinSubscriptionRequestModel({
    this.user,
    this.subscriptionPackage,
    this.payment,
    this.food,
    this.slot,
    this.cookingInstruction,
    this.deliveryInstruction,
    this.deliveryAddress,
    this.receiverName,
    this.countryCode,
    this.receiverContact,
  });

  BuyTiffinSubscriptionRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    subscriptionPackage = json['subscriptionPackage'];
    payment = json['payment'];
    if (json['food'] != null) {
      food = <TiffinSubscriptionFoodConfigRequestModel>[];
      json['food'].forEach((v) {
        food!.add(TiffinSubscriptionFoodConfigRequestModel.fromJson(v));
      });
    }
    slot = json['slot'];
    cookingInstruction = json['cookingInstruction'];
    deliveryInstruction = json['deliveryInstruction'];
    deliveryAddress = json['deliveryAddress'];
    receiverName = json['receiverName'];
    countryCode = json['countryCode'];
    receiverContact = json['receiverContact'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['subscriptionPackage'] = subscriptionPackage;
    data['payment'] = payment;
    if (food != null) {
      data['food'] = food!.map((v) => v.toJson()).toList();
    }
    data['slot'] = slot;
    data['cookingInstruction'] = cookingInstruction;
    data['deliveryInstruction'] = deliveryInstruction;
    data['deliveryAddress'] = deliveryAddress;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    return data;
  }
}

