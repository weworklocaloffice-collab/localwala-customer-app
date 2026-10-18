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

class AccountSettingUpdateMobileResponseModel {
  bool? sent;
  String? target;
  String? method;
  int? otpLength;
  bool? canResendOtp;
  String? id;
  String? provider;

  AccountSettingUpdateMobileResponseModel({this.sent, this.target, this.method, this.otpLength, this.canResendOtp, this.id, this.provider});

  AccountSettingUpdateMobileResponseModel.fromJson(Map<String, dynamic> json) {
    sent = json['sent'];
    target = json['target'];
    method = json['method'];
    if (json['otpLength'] != null && json['otpLength'] != '') {
      otpLength = int.parse(json['otpLength'].toString());
    } else {
      otpLength = 4;
    }
    canResendOtp = json['canResendOtp'];
    id = json['id'];
    provider = json['provider'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sent'] = sent;
    data['target'] = target;
    data['method'] = method;
    data['otpLength'] = otpLength;
    data['canResendOtp'] = canResendOtp;
    data['id'] = id;
    data['provider'] = provider;
    return data;
  }
}

