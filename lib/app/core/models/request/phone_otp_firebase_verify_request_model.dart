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

class PhoneOTPFirebaseVerifyRequestModel {
  String? countryCode;
  int? mobileNumber;
  String? token;
  String? locale;
  bool? remember;
  String? userAgent;

  PhoneOTPFirebaseVerifyRequestModel({this.countryCode, this.mobileNumber, this.token, this.locale, this.remember, this.userAgent});

  PhoneOTPFirebaseVerifyRequestModel.fromJson(Map<String, dynamic> json) {
    countryCode = json['countryCode'];
    mobileNumber = json['mobileNumber'];
    token = json['token'];
    locale = json['locale'];
    remember = json['remember'];
    userAgent = json['userAgent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryCode'] = countryCode;
    data['mobileNumber'] = mobileNumber;
    data['token'] = token;
    data['locale'] = locale;
    data['remember'] = remember;
    data['userAgent'] = userAgent;
    return data;
  }
}

