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

class OtpVerificationResponseModel {
  bool? sent;
  String? provider;
  String? mode;
  int? otpLength;
  bool? canResendOtp;
  String? target;
  String? method;
  String? id;

  OtpVerificationResponseModel({this.sent, this.provider, this.mode, this.otpLength, this.canResendOtp, this.target, this.method, this.id});

  OtpVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    sent = json['sent'];
    provider = json['provider'];
    mode = json['mode'];
    if (json['otpLength'] != null && json['otpLength'] != '') {
      otpLength = int.parse(json['otpLength'].toString());
    } else {
      otpLength = 4;
    }
    canResendOtp = json['canResendOtp'];
    target = json['target'];
    method = json['method'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sent'] = sent;
    data['provider'] = provider;
    data['mode'] = mode;
    data['otpLength'] = otpLength;
    data['canResendOtp'] = canResendOtp;
    data['target'] = target;
    data['method'] = method;
    data['id'] = id;
    return data;
  }
}

