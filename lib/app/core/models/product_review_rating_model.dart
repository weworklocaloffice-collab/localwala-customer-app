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

import 'package:user/app/core/models/order_detail_for_review_model.dart';

class ProductReviewRatingModel {
  String? id;
  String? name;
  int? rate;
  List<String>? msg;
  List<OrderRatingMessagesConfigModel>? messages;
  final String locale;
  ProductReviewRatingModel({this.id, this.name, this.rate, this.msg, this.messages, required this.locale});

  ProductReviewRatingModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
    msg = json['msg'].cast<String>();
    if (json['messages'] != null) {
      messages = <OrderRatingMessagesConfigModel>[];
      json['messages'].forEach((v) {
        messages!.add(OrderRatingMessagesConfigModel.fromJson(v, locale));
      });
    } else {
      messages = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['rate'] = rate;
    data['msg'] = msg;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

