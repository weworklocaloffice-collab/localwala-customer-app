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

class CallNumberFetchedResponseModel {
  bool? success;
  CallerDetailConfig? detail;

  CallNumberFetchedResponseModel({this.success, this.detail});

  CallNumberFetchedResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    detail = json['detail'] != null ? CallerDetailConfig.fromJson(json['detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    return data;
  }
}

class CallerDetailConfig {
  String? id;
  ContactInfoConfigModel? contactInfo;

  CallerDetailConfig({this.id, this.contactInfo});

  CallerDetailConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    contactInfo = json['contactInfo'] != null ? ContactInfoConfigModel.fromJson(json['contactInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (contactInfo != null) {
      data['contactInfo'] = contactInfo!.toJson();
    }
    return data;
  }
}

class ContactInfoConfigModel {
  String? countryCode;
  String? contactNumber;

  ContactInfoConfigModel({this.countryCode, this.contactNumber});

  ContactInfoConfigModel.fromJson(Map<String, dynamic> json) {
    countryCode = json['countryCode'].toString();
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['countryCode'] = countryCode;
    data['contactNumber'] = contactNumber;
    return data;
  }
}

