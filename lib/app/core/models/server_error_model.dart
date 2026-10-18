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

class ServerErrorModel {
  int? code;
  String? message;
  String? stack;
  String? extra;

  ServerErrorModel({this.code, this.message, this.stack, this.extra});

  ServerErrorModel.fromJson(Map<String, dynamic> json) {
    if (json['code'] != null && json['code'] != '') {
      code = json['code'];
    } else {
      code = 0;
    }
    if (json['message'] != null && json['message'] != '') {
      message = json['message'];
    } else {
      message = '';
    }

    if (json['stack'] != null && json['stack'] != '') {
      stack = json['stack'];
    } else {
      stack = '';
    }
    if (json['extra'] != null && json['extra'] != '') {
      extra = json['extra'];
    } else {
      extra = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['stack'] = stack;
    data['extra'] = extra;
    return data;
  }
}

