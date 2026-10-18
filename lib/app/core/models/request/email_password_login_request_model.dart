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

class EmailPasswordLoginRequest {
  String? email;
  String? password;
  bool? remember;
  String? userAgent;
  String? locale;

  EmailPasswordLoginRequest({this.email, this.password, this.remember, this.userAgent, this.locale});

  EmailPasswordLoginRequest.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    remember = json['remember'];
    if (json['userAgent'] != null && json['userAgent'] != '') {
      userAgent = json['userAgent'];
    } else {
      userAgent = 'unknown';
    }
    if (json['locale'] != null && json['locale'] != '') {
      locale = json['locale'];
    } else {
      locale = 'en';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['remember'] = remember;
    data['userAgent'] = userAgent;
    data['locale'] = locale;
    return data;
  }
}

