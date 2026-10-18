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

class WalletPaymentResponseModel {
  String? user;
  String? payment;
  double? amount;
  String? paymentFrom;
  String? paymentRef;
  String? status;
  String? id;

  WalletPaymentResponseModel({this.user, this.payment, this.amount, this.paymentFrom, this.paymentRef, this.status, this.id});

  WalletPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    payment = json['payment'];
    if (json['amount'] != null && json['amount'] != '') {
      amount = double.parse(json['amount'].toString());
    } else {
      amount = 0.0;
    }
    paymentFrom = json['paymentFrom'];
    paymentRef = json['paymentRef'];
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['payment'] = payment;
    data['amount'] = amount;
    data['paymentFrom'] = paymentFrom;
    data['paymentRef'] = paymentRef;
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

