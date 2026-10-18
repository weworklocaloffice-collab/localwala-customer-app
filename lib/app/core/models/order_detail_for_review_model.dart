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

class OrderDetailForReviewModel {
  OrderDetailConfigModel? details;
  OrderSettingsModel? orderSettings;
  List<OrderRatingMessagesConfigModel>? messages;
  int? driverOrderCount;
  bool? success;
  final String locale;
  OrderDetailForReviewModel({this.details, this.orderSettings, this.messages, this.driverOrderCount, this.success, required this.locale});

  OrderDetailForReviewModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? OrderDetailConfigModel.fromJson(json['details'], locale) : null;
    if (json['driverOrderCount'] != null && json['driverOrderCount'] != '') {
      driverOrderCount = int.parse(json['driverOrderCount'].toString());
    } else {
      driverOrderCount = 0;
    }
    if (json['messages'] != null) {
      messages = <OrderRatingMessagesConfigModel>[];
      json['messages'].forEach((v) {
        messages!.add(OrderRatingMessagesConfigModel.fromJson(v, locale));
      });
    } else {
      messages = [];
    }
    orderSettings = json['orderSettings'] != null ? OrderSettingsModel.fromJson(json['orderSettings']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (orderSettings != null) {
      data['orderSettings'] = orderSettings!.toJson();
    }
    data['driverOrderCount'] = driverOrderCount;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class OrderDetailConfigModel {
  String? user;
  RestaurantConfigModel? restaurant;
  String? status;
  String? id;
  List<FoodInCartModel>? cartItem;
  DriverInfoModel? driverInfo;
  String? orderTo;
  final String locale;
  OrderDetailConfigModel({this.user, this.restaurant, this.status, this.id, this.cartItem, this.driverInfo, this.orderTo, required this.locale});

  OrderDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['user'] != null && json['user'] != '') {
      user = json['user'];
    } else {
      user = '';
    }
    restaurant = json['restaurant'] != null ? RestaurantConfigModel.fromJson(json['restaurant'], locale) : null;

    status = json['status'];
    id = json['id'];
    if (json['cartItem'] != null) {
      cartItem = <FoodInCartModel>[];
      json['cartItem'].forEach((v) {
        cartItem!.add(FoodInCartModel.fromJson(v, locale));
      });
    } else {
      cartItem = [];
    }
    driverInfo = json['driverInfo'] != null ? DriverInfoModel.fromJson(json['driverInfo']) : null;
    orderTo = json['orderTo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['status'] = status;
    data['id'] = id;
    if (cartItem != null) {
      data['cartItem'] = cartItem!.map((v) => v.toJson()).toList();
    }
    if (driverInfo != null) {
      data['driverInfo'] = driverInfo!.toJson();
    }
    data['orderTo'] = orderTo;
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
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.translations, required this.locale});

  RestaurantConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    slug = json['slug'];
    address = json['address'];
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
  LocationConfigModel? location;

  DriverInfoModel({this.id, this.firstName, this.lastName, this.image, this.role, this.location});

  DriverInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
    role = json['role'];
    location = json['location'] != null ? LocationConfigModel.fromJson(json['location']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    data['role'] = role;
    if (location != null) {
      data['location'] = location!.toJson();
    }
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

class OrderSettingsModel {
  String? ratingStyle;
  String? id;

  OrderSettingsModel({this.ratingStyle, this.id});

  OrderSettingsModel.fromJson(Map<String, dynamic> json) {
    ratingStyle = json['ratingStyle'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ratingStyle'] = ratingStyle;
    data['id'] = id;
    return data;
  }
}

class OrderRatingMessagesConfigModel {
  String? name;
  int? rateNumber;
  String? type;
  List<MessageTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  OrderRatingMessagesConfigModel({this.name, this.rateNumber, this.type, this.translations, this.status, this.id, required this.locale});

  OrderRatingMessagesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['rateNumber'] != null && json['rateNumber'] != '') {
      rateNumber = int.parse(json['rateNumber'].toString());
    } else {
      rateNumber = 1;
    }
    type = json['type'];
    if (json['translations'] != null) {
      translations = <MessageTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(MessageTranslations.fromJson(v));
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
    data['rateNumber'] = rateNumber;
    data['type'] = type;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class MessageTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  MessageTranslations({this.name, this.code, this.nativeName, this.value});

  MessageTranslations.fromJson(Map<String, dynamic> json) {
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

