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

import 'package:user/app/core/models/translations/restaurant_register_request_form_translation.dart';

class RestaurantJoiningRequestModel {
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? countryCode;
  String? mobile;
  String? name;
  String? address;
  String? shortDescription;
  String? cuisine;
  String? logo;
  String? cover;
  String? city;
  String? locality;
  String? latitude;
  String? longitude;
  String? locationType;
  String? approxDeliveryTime;
  String? dishPriceForTwo;
  bool? takeAway;
  List<RestaurantRegisterRequestFormTranslations>? translations;
  String? restaurantType;
  String? restaurantFacility;
  bool? acceptScheduleDelivery;
  bool? acceptHomeDelivery;
  String? minOrderAmount;
  String? license;
  String? licenseId;
  String? businessType;
  String? subscriptionId;
  String? paymentId;
  String? locale;
  String? socialFacebook;
  String? socialInstagram;
  String? socialX;
  String? socialYoutube;
  String? socialLinkedIn;
  String? socialPinterest;
  List<RestaurantJoiningFormElementModel>? formElement;
  RestaurantJoiningRequestModel({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.mobile,
    this.name,
    this.address,
    this.shortDescription,
    this.cuisine,
    this.logo,
    this.cover,
    this.city,
    this.locality,
    this.latitude,
    this.longitude,
    this.locationType,
    this.approxDeliveryTime,
    this.dishPriceForTwo,
    this.takeAway,
    this.translations,
    this.restaurantType,
    this.restaurantFacility,
    this.acceptScheduleDelivery,
    this.acceptHomeDelivery,
    this.minOrderAmount,
    this.license,
    this.licenseId,
    this.businessType,
    this.subscriptionId,
    this.paymentId,
    this.locale,
    this.socialFacebook,
    this.socialInstagram,
    this.socialX,
    this.socialYoutube,
    this.socialLinkedIn,
    this.socialPinterest,
    this.formElement,
  });

  RestaurantJoiningRequestModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    name = json['name'];
    address = json['address'];
    shortDescription = json['shortDescription'];
    cuisine = json['cuisine'];
    logo = json['logo'];
    cover = json['cover'];
    city = json['city'];
    locality = json['locality'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    locationType = json['locationType'];
    approxDeliveryTime = json['approxDeliveryTime'];
    dishPriceForTwo = json['dishPriceForTwo'];
    takeAway = json['takeAway'];
    if (json['translations'] != null) {
      translations = <RestaurantRegisterRequestFormTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantRegisterRequestFormTranslations.fromJson(v));
      });
    } else {
      translations = [];
    }
    restaurantType = json['restaurantType'];
    restaurantFacility = json['restaurantFacility'];
    acceptScheduleDelivery = json['acceptScheduleDelivery'];
    acceptHomeDelivery = json['acceptHomeDelivery'];
    minOrderAmount = json['minOrderAmount'];
    license = json['license'];
    licenseId = json['licenseId'];
    businessType = json['businessType'];
    subscriptionId = json['subscriptionId'];
    paymentId = json['paymentId'];
    locale = json['locale'];
    if (json['socialFacebook'] != null && json['socialFacebook'] != '') {
      socialFacebook = json['socialFacebook'];
    } else {
      socialFacebook = '';
    }
    if (json['socialInstagram'] != null && json['socialInstagram'] != '') {
      socialInstagram = json['socialInstagram'];
    } else {
      socialInstagram = '';
    }
    if (json['socialX'] != null && json['socialX'] != '') {
      socialX = json['socialX'];
    } else {
      socialX = '';
    }
    if (json['socialYoutube'] != null && json['socialYoutube'] != '') {
      socialYoutube = json['socialYoutube'];
    } else {
      socialYoutube = '';
    }
    if (json['socialLinkedIn'] != null && json['socialLinkedIn'] != '') {
      socialLinkedIn = json['socialLinkedIn'];
    } else {
      socialLinkedIn = '';
    }
    if (json['socialPinterest'] != null && json['socialPinterest'] != '') {
      socialPinterest = json['socialPinterest'];
    } else {
      socialPinterest = '';
    }
    if (json['formElement'] != null) {
      formElement = <RestaurantJoiningFormElementModel>[];
      json['formElement'].forEach((v) {
        formElement!.add(RestaurantJoiningFormElementModel.fromJson(v));
      });
    } else {
      formElement = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['name'] = name;
    data['address'] = address;
    data['shortDescription'] = shortDescription;
    data['cuisine'] = cuisine;
    data['logo'] = logo;
    data['cover'] = cover;
    data['city'] = city;
    data['locality'] = locality;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['locationType'] = locationType;
    data['approxDeliveryTime'] = approxDeliveryTime;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['takeAway'] = takeAway;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['restaurantType'] = restaurantType;
    data['restaurantFacility'] = restaurantFacility;
    data['acceptScheduleDelivery'] = acceptScheduleDelivery;
    data['acceptHomeDelivery'] = acceptHomeDelivery;
    data['minOrderAmount'] = minOrderAmount;
    data['license'] = license;
    data['licenseId'] = licenseId;
    data['businessType'] = businessType;
    data['subscriptionId'] = subscriptionId;
    data['paymentId'] = paymentId;
    data['locale'] = locale;
    data['socialFacebook'] = socialFacebook;
    data['socialInstagram'] = socialInstagram;
    data['socialX'] = socialX;
    data['socialYoutube'] = socialYoutube;
    data['socialLinkedIn'] = socialLinkedIn;
    data['socialPinterest'] = socialPinterest;
    if (formElement != null) {
      data['formElement'] = formElement!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantJoiningFormElementModel {
  String? fieldName;
  String? fieldType;
  String? fieldValue;
  List<RestaurantJoiningFormElementOptionModel>? fieldItems;

  RestaurantJoiningFormElementModel({this.fieldName, this.fieldType, this.fieldValue, this.fieldItems});

  RestaurantJoiningFormElementModel.fromJson(Map<String, dynamic> json) {
    fieldName = json['fieldName'];
    fieldType = json['fieldType'];
    fieldValue = json['fieldValue'];
    if (json['fieldItems'] != null) {
      fieldItems = <RestaurantJoiningFormElementOptionModel>[];
      json['fieldItems'].forEach((v) {
        fieldItems!.add(RestaurantJoiningFormElementOptionModel.fromJson(v));
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

class RestaurantJoiningFormElementOptionModel {
  String? name;
  bool? value;

  RestaurantJoiningFormElementOptionModel({this.name, this.value});

  RestaurantJoiningFormElementOptionModel.fromJson(Map<String, dynamic> json) {
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

