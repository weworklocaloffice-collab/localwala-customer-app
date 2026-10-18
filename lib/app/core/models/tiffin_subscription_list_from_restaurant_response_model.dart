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

class TiffinSubscriptionFromListRestaurantResponseModel {
  List<TiffinSubscriptionInfoConfigModel>? results;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  bool? success;
  final String locale;
  TiffinSubscriptionFromListRestaurantResponseModel({this.results, this.page, this.limit, this.totalPages, this.totalResults, this.success, required this.locale});

  TiffinSubscriptionFromListRestaurantResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['results'] != null) {
      results = <TiffinSubscriptionInfoConfigModel>[];
      json['results'].forEach((v) {
        results!.add(TiffinSubscriptionInfoConfigModel.fromJson(v, locale));
      });
    } else {
      results = [];
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class TiffinSubscriptionInfoConfigModel {
  String? name;
  String? shortDescription;
  String? image;
  String? interval;
  String? orderTo;
  String? available;
  String? discountType;
  List<Translations>? translations;
  String? status;
  String? id;
  double? price;
  double? discount;
  double? offerPrice = 0.0;
  final String locale;
  TiffinSubscriptionInfoConfigModel({
    this.name,
    this.shortDescription,
    this.image,
    this.interval,
    this.orderTo,
    this.available,
    this.discountType,
    this.translations,
    this.status,
    this.id,
    this.price,
    this.discount,
    this.offerPrice,
    required this.locale,
  });

  TiffinSubscriptionInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    interval = json['interval'];
    orderTo = json['orderTo'];
    available = json['available'];
    discountType = json['discountType'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            name = translations![localeIndex].title!;
          }
          if (translations![localeIndex].shortDescription!.isNotEmpty) {
            shortDescription = translations![localeIndex].shortDescription!;
          }
        }
      }
    } else {
      translations = [];
    }
    status = json['status'];
    id = json['id'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    discountType = json['discountType'];
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        if (json['discountType'] == '%') {
          String discountValue = (double.parse(json['price'].toString()) - (double.parse(json['price'].toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        } else {
          String discountValue = (double.parse(json['price'].toString()) - double.parse(json['discount'].toString())).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        }
      }
    } else {
      discount = 0.0;
      offerPrice = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['interval'] = interval;
    data['orderTo'] = orderTo;
    data['available'] = available;
    data['discountType'] = discountType;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    data['price'] = price;
    data['discount'] = discount;
    return data;
  }
}

class Translations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  Translations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  Translations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    shortDescription = json['shortDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['shortDescription'] = shortDescription;
    return data;
  }
}

