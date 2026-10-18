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

class ReferralCodeResponseModel {
  ReferralCodeConfigModel? referralCode;
  ReferralDetailConfigModel? detail;
  bool? success;

  ReferralCodeResponseModel({this.referralCode, this.detail, this.success});

  ReferralCodeResponseModel.fromJson(Map<String, dynamic> json) {
    referralCode = json['referralCode'] != null ? ReferralCodeConfigModel.fromJson(json['referralCode']) : null;
    detail = json['detail'] != null ? ReferralDetailConfigModel.fromJson(json['detail']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (referralCode != null) {
      data['referralCode'] = referralCode!.toJson();
    }
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class ReferralCodeConfigModel {
  String? code;
  String? id;

  ReferralCodeConfigModel({this.code, this.id});

  ReferralCodeConfigModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['id'] = id;
    return data;
  }
}

class ReferralDetailConfigModel {
  double? earnPerReferral;
  String? whoEarnReferral;
  String? referralTitle;
  String? referralMessage;
  List<ReferralTranslations>? referralTranslations;
  String? id;

  ReferralDetailConfigModel({this.earnPerReferral, this.whoEarnReferral, this.referralTitle, this.referralMessage, this.referralTranslations, this.id});

  ReferralDetailConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['earnPerReferral'] != null && json['earnPerReferral'] != '') {
      earnPerReferral = double.parse(json['earnPerReferral'].toString());
    } else {
      earnPerReferral = 0.0;
    }
    whoEarnReferral = json['whoEarnReferral'];
    referralTitle = json['referralTitle'];
    referralMessage = json['referralMessage'];
    if (json['referralTranslations'] != null) {
      referralTranslations = <ReferralTranslations>[];
      json['referralTranslations'].forEach((v) {
        referralTranslations!.add(ReferralTranslations.fromJson(v));
      });
    } else {
      referralTranslations = [];
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['earnPerReferral'] = earnPerReferral;
    data['whoEarnReferral'] = whoEarnReferral;
    data['referralTitle'] = referralTitle;
    data['referralMessage'] = referralMessage;
    if (referralTranslations != null) {
      data['referralTranslations'] = referralTranslations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class ReferralTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? message;

  ReferralTranslations({this.name, this.code, this.nativeName, this.title, this.message});

  ReferralTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['message'] = message;
    return data;
  }
}

