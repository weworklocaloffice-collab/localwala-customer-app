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

class WebSMSOTPVerificationResponseModel {
  bool? action;
  bool? success;
  String? dummyOTP;
  String? id;

  WebSMSOTPVerificationResponseModel({this.action, this.success, this.dummyOTP, this.id});

  WebSMSOTPVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    action = json['action'];
    success = json['success'];
    dummyOTP = json['dummyOTP'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['action'] = action;
    data['success'] = success;
    data['dummyOTP'] = dummyOTP;
    data['id'] = id;
    return data;
  }
}

