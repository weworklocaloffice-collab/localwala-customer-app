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

class UserProfileReponseModel {
  UserInformationConfigModel? info;
  bool? success;

  UserProfileReponseModel({this.info, this.success});

  UserProfileReponseModel.fromJson(Map<String, dynamic> json) {
    info = json['info'] != null ? UserInformationConfigModel.fromJson(json['info']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (info != null) {
      data['info'] = info!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class UserInformationConfigModel {
  String? firstName;
  String? lastName;
  String? email;
  bool? isEmailVerified;
  String? image;
  String? countryCode;
  String? mobile;
  bool? isMobileVerified;
  String? gender;
  String? id;

  UserInformationConfigModel({this.firstName, this.lastName, this.email, this.isEmailVerified, this.image, this.countryCode, this.mobile, this.isMobileVerified, this.gender, this.id});

  UserInformationConfigModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    isEmailVerified = json['isEmailVerified'];
    image = json['image'];
    countryCode = json['countryCode'].toString();
    mobile = json['mobile'];
    isMobileVerified = json['isMobileVerified'];
    gender = json['gender'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['isEmailVerified'] = isEmailVerified;
    data['image'] = image;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['isMobileVerified'] = isMobileVerified;
    data['gender'] = gender;
    data['id'] = id;
    return data;
  }
}

