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

class UserFirebaseRegisterRequest {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? countryCode;
  String? mobile;
  String? locale;
  String? referralCode;
  bool? isEmailVerified;
  bool? isMobileVerified;
  String? userAgent;
  String? token;

  UserFirebaseRegisterRequest({this.email, this.password, this.firstName, this.lastName, this.countryCode, this.mobile, this.locale, this.referralCode, this.isEmailVerified, this.isMobileVerified, this.userAgent, this.token});

  UserFirebaseRegisterRequest.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    locale = json['locale'];
    referralCode = json['referralCode'];
    isEmailVerified = json['isEmailVerified'];
    isMobileVerified = json['isMobileVerified'];
    userAgent = json['userAgent'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['locale'] = locale;
    data['referralCode'] = referralCode;
    data['isEmailVerified'] = isEmailVerified;
    data['isMobileVerified'] = isMobileVerified;
    data['userAgent'] = userAgent;
    data['token'] = token;
    return data;
  }
}

