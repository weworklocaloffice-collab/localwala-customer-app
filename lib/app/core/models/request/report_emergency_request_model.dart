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

class ReportEmergencyFormRequestModel {
  String? type;
  String? userName;
  String? userCountryCode;
  String? userContact;
  String? userEmail;
  String? shortDescription;

  ReportEmergencyFormRequestModel({this.type, this.userName, this.userCountryCode, this.userContact, this.userEmail, this.shortDescription});

  ReportEmergencyFormRequestModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    userName = json['userName'];
    userCountryCode = json['userCountryCode'];
    userContact = json['userContact'];
    userEmail = json['userEmail'];
    shortDescription = json['shortDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['userName'] = userName;
    data['userCountryCode'] = userCountryCode;
    data['userContact'] = userContact;
    data['userEmail'] = userEmail;
    data['shortDescription'] = shortDescription;
    return data;
  }
}

