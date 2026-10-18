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

class UserLoginResponseModel {
  UserInfoConfig? user;
  AccessTokenConfigModel? tokens;
  bool? success;

  UserLoginResponseModel({this.user, this.tokens, this.success});

  UserLoginResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserInfoConfig.fromJson(json['user']) : null;
    tokens = json['tokens'] != null ? AccessTokenConfigModel.fromJson(json['tokens']) : null;
    if (json['success'] != '' && json['success'] != null) {
      success = json['success'];
    } else {
      json['success'] = true;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (tokens != null) {
      data['tokens'] = tokens!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class UserInfoConfig {
  LocationCoordinates? location;
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  bool? isEmailVerified;
  String? image;
  String? countryCode;
  String? mobile;
  bool? isMobileVerified;
  String? gender;
  bool? status;
  String? id;

  UserInfoConfig({this.location, this.firstName, this.lastName, this.email, this.role, this.isEmailVerified, this.image, this.countryCode, this.mobile, this.isMobileVerified, this.gender, this.status, this.id});

  UserInfoConfig.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    role = json['role'];
    isEmailVerified = json['isEmailVerified'];
    image = json['image'];
    countryCode = json['countryCode'].toString();
    mobile = json['mobile'];
    isMobileVerified = json['isMobileVerified'];
    gender = json['gender'];
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['role'] = role;
    data['isEmailVerified'] = isEmailVerified;
    data['image'] = image;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['isMobileVerified'] = isMobileVerified;
    data['gender'] = gender;
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class LocationCoordinates {
  String? type;
  List<double>? coordinates;

  LocationCoordinates({this.type, this.coordinates});

  LocationCoordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null && json['coordinates'] is List) {
      coordinates = List<double>.from(json['coordinates'].map((x) => x.toDouble()));
    } else {
      coordinates = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class AccessTokenConfigModel {
  TokenConfigModel? access;
  TokenConfigModel? refresh;

  AccessTokenConfigModel({this.access, this.refresh});

  AccessTokenConfigModel.fromJson(Map<String, dynamic> json) {
    access = json['access'] != null ? TokenConfigModel.fromJson(json['access']) : null;
    refresh = json['refresh'] != null ? TokenConfigModel.fromJson(json['refresh']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (access != null) {
      data['access'] = access!.toJson();
    }
    if (refresh != null) {
      data['refresh'] = refresh!.toJson();
    }
    return data;
  }
}

class TokenConfigModel {
  String? token;
  String? expires;

  TokenConfigModel({this.token, this.expires});

  TokenConfigModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['expires'] = expires;
    return data;
  }
}

