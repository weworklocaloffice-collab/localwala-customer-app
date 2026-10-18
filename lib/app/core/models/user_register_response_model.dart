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

class UserRegisterResponseModel {
  User? user;
  Tokens? tokens;
  Referral? referral;

  UserRegisterResponseModel({this.user, this.tokens, this.referral});

  UserRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    tokens = json['tokens'] != null ? Tokens.fromJson(json['tokens']) : null;
    referral = json['referral'] != null ? Referral.fromJson(json['referral']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (tokens != null) {
      data['tokens'] = tokens!.toJson();
    }
    if (referral != null) {
      data['referral'] = referral!.toJson();
    }
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  bool? isEmailVerified;
  String? image;
  int? countryCode;
  String? mobile;
  bool? isMobileVerified;
  String? gender;
  LocationCoordinates? location;
  bool? status;
  String? id;

  User({this.firstName, this.lastName, this.email, this.role, this.isEmailVerified, this.image, this.countryCode, this.mobile, this.isMobileVerified, this.gender, this.location, this.status, this.id});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    role = json['role'];
    isEmailVerified = json['isEmailVerified'];
    image = json['image'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    isMobileVerified = json['isMobileVerified'];
    gender = json['gender'];
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    if (location != null) {
      data['location'] = location!.toJson();
    }
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

class Tokens {
  Access? access;
  Access? refresh;

  Tokens({this.access, this.refresh});

  Tokens.fromJson(Map<String, dynamic> json) {
    access = json['access'] != null ? Access.fromJson(json['access']) : null;
    refresh = json['refresh'] != null ? Access.fromJson(json['refresh']) : null;
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

class Access {
  String? token;
  String? expires;

  Access({this.token, this.expires});

  Access.fromJson(Map<String, dynamic> json) {
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

class Referral {
  bool? status;
  double? amount;
  String? received;

  Referral({this.status, this.amount, this.received});

  Referral.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    amount = double.parse(json['amount'].toString());
    received = json['received'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['amount'] = amount;
    data['received'] = received;
    return data;
  }
}

