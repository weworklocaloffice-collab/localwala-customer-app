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

class PlaceOrderRequestModel {
  String? user;
  String? payment;
  String? restaurant;
  String? trackingId;
  String? coupon;
  String? orderTo;
  String? cookingInstruction;
  String? deliveryInstruction;
  String? deliveryAddress;
  String? receiverName;
  String? countryCode;
  String? receiverContact;
  bool? walletUsed;
  bool? instantOrder;
  bool? scheduleOrder;
  String? scheduleDate;
  String? scheduleTime;
  String? orderAt;
  String? locale;
  double? deliveryTip;
  List<LocalCartItemArrayRequestModel>? localCartItem;

  PlaceOrderRequestModel({
    this.user,
    this.payment,
    this.restaurant,
    this.trackingId,
    this.coupon,
    this.orderTo,
    this.cookingInstruction,
    this.deliveryInstruction,
    this.deliveryAddress,
    this.receiverName,
    this.countryCode,
    this.receiverContact,
    this.walletUsed,
    this.instantOrder,
    this.scheduleOrder,
    this.scheduleDate,
    this.scheduleTime,
    this.orderAt,
    this.locale,
    this.deliveryTip,
    this.localCartItem,
  });

  PlaceOrderRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    payment = json['payment'];
    restaurant = json['restaurant'];
    trackingId = json['trackingId'];
    coupon = json['coupon'];
    orderTo = json['orderTo'];
    cookingInstruction = json['cookingInstruction'];
    deliveryInstruction = json['deliveryInstruction'];
    deliveryAddress = json['deliveryAddress'];
    receiverName = json['receiverName'];
    countryCode = json['countryCode'];
    receiverContact = json['receiverContact'];
    walletUsed = json['walletUsed'];
    instantOrder = json['instantOrder'];
    scheduleOrder = json['scheduleOrder'];
    scheduleDate = json['scheduleDate'];
    scheduleTime = json['scheduleTime'];
    orderAt = json['orderAt'];
    locale = json['locale'];
    deliveryTip = json['deliveryTip'];
    if (json['localCartItem'] != null) {
      localCartItem = <LocalCartItemArrayRequestModel>[];
      json['localCartItem'].forEach((v) {
        localCartItem!.add(LocalCartItemArrayRequestModel.fromJson(v));
      });
    } else {
      localCartItem = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['payment'] = payment;
    data['restaurant'] = restaurant;
    data['trackingId'] = trackingId;
    data['coupon'] = coupon;
    data['orderTo'] = orderTo;
    data['cookingInstruction'] = cookingInstruction;
    data['deliveryInstruction'] = deliveryInstruction;
    data['deliveryAddress'] = deliveryAddress;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['walletUsed'] = walletUsed;
    data['instantOrder'] = instantOrder;
    data['scheduleOrder'] = scheduleOrder;
    data['scheduleDate'] = scheduleDate;
    data['scheduleTime'] = scheduleTime;
    data['orderAt'] = orderAt;
    data['locale'] = locale;
    data['deliveryTip'] = deliveryTip;
    if (localCartItem != null) {
      data['localCartItem'] = localCartItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocalCartItemArrayRequestModel {
  String? uuid;
  int? quantity;

  LocalCartItemArrayRequestModel({this.uuid, this.quantity});

  LocalCartItemArrayRequestModel.fromJson(Map<String, dynamic> json) {
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

