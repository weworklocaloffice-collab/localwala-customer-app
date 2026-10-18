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

class PurchaseSubscriptionTiffinPackageRequestModel {
  String? user;
  String? subscriptionPackage;
  String? payment;
  String? addons;
  String? foods;
  String? slot;
  String? orderAt;
  String? cookingInstruction;
  String? deliveryInstruction;
  String? deliveryAddress;
  String? deliveryAddressRaw;
  String? receiverName;
  String? countryCode;
  String? receiverContact;
  String? cartItemRaw;
  double? itemTotal;
  double? foodServiceCharge;
  double? serviceCharge;
  double? packageCharge;
  double? packageChargeTax;
  double? extraCharge;
  double? grandTotal;

  PurchaseSubscriptionTiffinPackageRequestModel({
    this.user,
    this.subscriptionPackage,
    this.payment,
    this.addons,
    this.foods,
    this.slot,
    this.orderAt,
    this.cookingInstruction,
    this.deliveryInstruction,
    this.deliveryAddress,
    this.deliveryAddressRaw,
    this.receiverName,
    this.countryCode,
    this.receiverContact,
    this.cartItemRaw,
    this.itemTotal,
    this.foodServiceCharge,
    this.serviceCharge,
    this.packageCharge,
    this.packageChargeTax,
    this.extraCharge,
    this.grandTotal,
  });

  PurchaseSubscriptionTiffinPackageRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    subscriptionPackage = json['subscriptionPackage'];
    payment = json['payment'];
    addons = json['addons'];
    foods = json['foods'];
    slot = json['slot'];
    orderAt = json['orderAt'];
    cookingInstruction = json['cookingInstruction'];
    deliveryInstruction = json['deliveryInstruction'];
    deliveryAddress = json['deliveryAddress'];
    deliveryAddressRaw = json['deliveryAddressRaw'];
    receiverName = json['receiverName'];
    countryCode = json['countryCode'];
    receiverContact = json['receiverContact'];
    cartItemRaw = json['cartItemRaw'];
    itemTotal = json['itemTotal'];
    foodServiceCharge = json['foodServiceCharge'];
    serviceCharge = json['serviceCharge'];
    packageCharge = json['packageCharge'];
    packageChargeTax = json['packageChargeTax'];
    extraCharge = json['extraCharge'];
    grandTotal = json['grandTotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['subscriptionPackage'] = subscriptionPackage;
    data['payment'] = payment;
    data['addons'] = addons;
    data['foods'] = foods;
    data['slot'] = slot;
    data['orderAt'] = orderAt;
    data['cookingInstruction'] = cookingInstruction;
    data['deliveryInstruction'] = deliveryInstruction;
    data['deliveryAddress'] = deliveryAddress;
    data['deliveryAddressRaw'] = deliveryAddressRaw;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['cartItemRaw'] = cartItemRaw;
    data['itemTotal'] = itemTotal;
    data['foodServiceCharge'] = foodServiceCharge;
    data['serviceCharge'] = serviceCharge;
    data['packageCharge'] = packageCharge;
    data['packageChargeTax'] = packageChargeTax;
    data['extraCharge'] = extraCharge;
    data['grandTotal'] = grandTotal;
    return data;
  }
}

