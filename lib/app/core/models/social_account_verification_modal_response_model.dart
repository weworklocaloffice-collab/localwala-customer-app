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

class SocialAccountVerificationModalResponseModel {
  bool? success;
  String? firstName;
  String? lastName;
  String? countryCode;
  String? mobile;

  SocialAccountVerificationModalResponseModel({this.success, this.firstName, this.lastName, this.countryCode, this.mobile});

  SocialAccountVerificationModalResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    countryCode = json['country_code'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['country_code'] = countryCode;
    data['mobile'] = mobile;
    return data;
  }
}

