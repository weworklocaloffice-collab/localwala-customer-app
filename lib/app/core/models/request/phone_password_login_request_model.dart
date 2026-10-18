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

class PhonePasswordLoginRequestModel {
  String? countryCode;
  String? mobileNumber;
  String? password;
  bool? remember;
  String? userAgent;
  String? locale;

  PhonePasswordLoginRequestModel({this.countryCode, this.mobileNumber, this.password, this.remember, this.userAgent, this.locale});

  PhonePasswordLoginRequestModel.fromJson(Map<String, dynamic> json) {
    countryCode = json['countryCode'];
    mobileNumber = json['mobileNumber'];
    password = json['password'];
    remember = json['remember'];
    userAgent = json['userAgent'];
    locale = json['locale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryCode'] = countryCode;
    data['mobileNumber'] = mobileNumber;
    data['password'] = password;
    data['remember'] = remember;
    data['userAgent'] = userAgent;
    data['locale'] = locale;
    return data;
  }
}

