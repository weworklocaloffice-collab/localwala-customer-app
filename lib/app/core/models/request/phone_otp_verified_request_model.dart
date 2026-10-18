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

class PhoneOTPVerifiedLoginRequestModel {
  String? id;
  bool? remember;
  String? locale;
  String? userAgent;

  PhoneOTPVerifiedLoginRequestModel({this.id, this.remember, this.locale, this.userAgent});

  PhoneOTPVerifiedLoginRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    remember = json['remember'];
    locale = json['locale'];
    userAgent = json['userAgent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['remember'] = remember;
    data['locale'] = locale;
    data['userAgent'] = userAgent;
    return data;
  }
}

