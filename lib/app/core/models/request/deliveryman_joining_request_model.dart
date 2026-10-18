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

class DeliverymanJoiningRequestModel {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? countryCode;
  String? mobile;
  String? city;
  String? locality;
  String? latitude;
  String? longitude;
  String? locationType;
  String? vehicle;
  String? cover;
  String? age;
  String? dob;
  String? type;
  String? identity;
  String? identityNumber;
  String? identityProof;
  String? drivingLicense;
  List<DeliverymanJoiningFormElementModel>? formElement;
  String? locale;

  DeliverymanJoiningRequestModel({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.mobile,
    this.city,
    this.locality,
    this.latitude,
    this.longitude,
    this.locationType,
    this.vehicle,
    this.cover,
    this.age,
    this.dob,
    this.type,
    this.identity,
    this.identityNumber,
    this.identityProof,
    this.drivingLicense,
    this.formElement,
    this.locale,
  });

  DeliverymanJoiningRequestModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    city = json['city'];
    locality = json['locality'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    locationType = json['locationType'];
    vehicle = json['vehicle'];
    cover = json['cover'];
    age = json['age'];
    dob = json['dob'];
    type = json['type'];
    identity = json['identity'];
    identityNumber = json['identityNumber'];
    identityProof = json['identityProof'];
    drivingLicense = json['drivingLicense'];
    if (json['formElement'] != null) {
      formElement = <DeliverymanJoiningFormElementModel>[];
      json['formElement'].forEach((v) {
        formElement!.add(DeliverymanJoiningFormElementModel.fromJson(v));
      });
    } else {
      formElement = [];
    }
    locale = json['locale'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['city'] = city;
    data['locality'] = locality;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['locationType'] = locationType;
    data['vehicle'] = vehicle;
    data['cover'] = cover;
    data['age'] = age;
    data['dob'] = dob;
    data['type'] = type;
    data['identity'] = identity;
    data['identityNumber'] = identityNumber;
    data['identityProof'] = identityProof;
    data['drivingLicense'] = drivingLicense;
    if (formElement != null) {
      data['formElement'] = formElement!.map((v) => v.toJson()).toList();
    }
    data['locale'] = locale;
    return data;
  }
}

class DeliverymanJoiningFormElementModel {
  String? fieldName;
  String? fieldType;
  String? fieldValue;
  List<DeliverymanJoiningFormElementOptionModel>? fieldItems;

  DeliverymanJoiningFormElementModel({this.fieldName, this.fieldType, this.fieldValue, this.fieldItems});

  DeliverymanJoiningFormElementModel.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    fieldType = json['fieldType'];
    fieldValue = json['fieldValue'];
    if (json['fieldItems'] != null) {
      fieldItems = <DeliverymanJoiningFormElementOptionModel>[];
      json['fieldItems'].forEach((v) {
        fieldItems!.add(DeliverymanJoiningFormElementOptionModel.fromJson(v));
      });
    } else {
      fieldItems = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fieldName'] = fieldName;
    data['fieldType'] = fieldType;
    data['fieldValue'] = fieldValue;
    if (fieldItems != null) {
      data['fieldItems'] = fieldItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliverymanJoiningFormElementOptionModel {
  String? name;
  bool? value;

  DeliverymanJoiningFormElementOptionModel({this.name, this.value});

  DeliverymanJoiningFormElementOptionModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

