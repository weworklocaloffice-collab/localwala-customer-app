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

import 'package:user/app/core/models/food_in_cart_model.dart';

class OrderDetailComplaintResponseModel {
  OrderDetailConfigModel? details;
  List<ComplaintReasonListModel>? reason;
  bool? success;
  final String locale;
  OrderDetailComplaintResponseModel({this.details, this.reason, this.success, required this.locale});

  OrderDetailComplaintResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? OrderDetailConfigModel.fromJson(json['details'], locale) : null;
    if (json['reason'] != null) {
      reason = <ComplaintReasonListModel>[];
      json['reason'].forEach((v) {
        reason!.add(ComplaintReasonListModel.fromJson(v, locale));
      });
    } else {
      reason = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (reason != null) {
      data['reason'] = reason!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class OrderDetailConfigModel {
  RestaurantConfigModel? restaurant;
  String? status;
  String? id;
  String? orderTo;
  List<FoodInCartModel>? cartItem;
  DriverInfoModel? driverInfo;
  final String locale;
  OrderDetailConfigModel({this.restaurant, this.status, this.id, this.orderTo, this.cartItem, this.driverInfo, required this.locale});

  OrderDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? RestaurantConfigModel.fromJson(json['restaurant'], locale) : null;
    status = json['status'];
    id = json['id'];
    orderTo = json['orderTo'];
    if (json['cartItem'] != null) {
      cartItem = <FoodInCartModel>[];
      json['cartItem'].forEach((v) {
        cartItem!.add(FoodInCartModel.fromJson(v, locale));
      });
    } else {
      cartItem = [];
    }
    driverInfo = json['driverInfo'] != null ? DriverInfoModel.fromJson(json['driverInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['status'] = status;
    data['id'] = id;
    data['orderTo'] = orderTo;
    if (cartItem != null) {
      data['cartItem'] = cartItem!.map((v) => v.toJson()).toList();
    }
    if (driverInfo != null) {
      data['driverInfo'] = driverInfo!.toJson();
    }
    return data;
  }
}

class RestaurantConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  String? license;
  String? licenseId;
  LocationConfigModel? location;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.license, this.licenseId, this.location, this.translations, required this.locale});

  RestaurantConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    slug = json['slug'];
    address = json['address'];
    license = json['license'];
    licenseId = json['licenseId'];
    location = json['location'] != null ? LocationConfigModel.fromJson(json['location']) : null;
    if (json['translations'] != null) {
      translations = <RestaurantTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            name = translations![localeIndex].title!;
          }
          if (translations![localeIndex].address!.isNotEmpty) {
            address = translations![localeIndex].address!;
          }
        }
      }
    } else {
      translations = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    data['slug'] = slug;
    data['address'] = address;
    data['license'] = license;
    data['licenseId'] = licenseId;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  RestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  RestaurantTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['address'] = address;
    return data;
  }
}

class DriverInfoModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;
  String? role;

  DriverInfoModel({this.id, this.firstName, this.lastName, this.image, this.role});

  DriverInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    data['role'] = role;
    return data;
  }
}

class LocationConfigModel {
  String? type;
  List<double>? coordinates;

  LocationConfigModel({this.type, this.coordinates});

  LocationConfigModel.fromJson(Map<String, dynamic> json) {
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

class ComplaintReasonListModel {
  String? name;
  String? type;
  List<ReasonTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  ComplaintReasonListModel({this.name, this.type, this.translations, this.status, this.id, required this.locale});

  ComplaintReasonListModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    type = json['type'];
    if (json['translations'] != null) {
      translations = <ReasonTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(ReasonTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].value!.isNotEmpty) {
            name = translations![localeIndex].value!;
          }
        }
      }
    } else {
      translations = [];
    }
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class ReasonTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  ReasonTranslations({this.name, this.code, this.nativeName, this.value});

  ReasonTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['value'] = value;
    return data;
  }
}

