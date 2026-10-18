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

import 'package:intl/intl.dart';

class DiningBookingListResponseModel {
  List<DiningBookingDetailConfigModel>? bookings;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  bool? success;
  final String locale;
  DiningBookingListResponseModel({this.bookings, this.page, this.limit, this.totalPages, this.totalResults, this.success, required this.locale});

  DiningBookingListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['bookings'] != null) {
      bookings = <DiningBookingDetailConfigModel>[];
      json['bookings'].forEach((v) {
        bookings!.add(DiningBookingDetailConfigModel.fromJson(v, locale));
      });
    } else {
      bookings = [];
    }
    if (json['page'] != null && json['page'] != '') {
      page = int.parse(json['page'].toString());
    } else {
      page = 0;
    }
    if (json['limit'] != null && json['limit'] != '') {
      limit = int.parse(json['limit'].toString());
    } else {
      limit = 0;
    }
    if (json['totalPages'] != null && json['totalPages'] != '') {
      totalPages = int.parse(json['totalPages'].toString());
    } else {
      totalPages = 0;
    }
    if (json['totalResults'] != null && json['totalResults'] != '') {
      totalResults = int.parse(json['totalResults'].toString());
    } else {
      totalResults = 0;
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bookings != null) {
      data['bookings'] = bookings!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class DiningBookingDetailConfigModel {
  DiningBookingRestaurantConfigModel? restaurant;
  String? bookingDate;
  String? bookingSlot;
  int? guest;
  String? userName;
  String? userCountryCode;
  String? userContact;
  String? userEmail;
  String? status;
  String? createdAt;
  String? id;
  final String locale;
  DiningBookingDetailConfigModel({
    this.restaurant,
    this.bookingDate,
    this.bookingSlot,
    this.guest,
    this.userName,
    this.userCountryCode,
    this.userContact,
    this.userEmail,
    this.status,
    this.createdAt,
    this.id,
    required this.locale,
  });

  DiningBookingDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? DiningBookingRestaurantConfigModel.fromJson(json['restaurant'], locale) : null;
    if (json['bookingDate'] != null && json['bookingDate'] != '') {
      DateTime dateTime = DateTime.parse(json['bookingDate']);
      String formattedDate = DateFormat('dd MMM yyyy', locale).format(dateTime);
      bookingDate = formattedDate;
    } else {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat('dd MMM yyyy', locale).format(dateTime);
      bookingDate = formattedDate;
    }
    bookingSlot = json['bookingSlot'];
    if (json['guest'] != null && json['guest'] != '') {
      guest = int.parse(json['guest'].toString());
    } else {
      guest = 1;
    }
    userName = json['userName'];
    userCountryCode = json['userCountryCode'].toString();
    userContact = json['userContact'];
    userEmail = json['userEmail'];
    status = json['status'];
    createdAt = json['createdAt'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['bookingDate'] = bookingDate;
    data['guest'] = guest;
    data['userName'] = userName;
    data['userCountryCode'] = userCountryCode;
    data['userContact'] = userContact;
    data['userEmail'] = userEmail;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['id'] = id;
    return data;
  }
}

class DiningBookingRestaurantConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  List<RestaurantTranslations>? translations;
  final String locale;
  DiningBookingRestaurantConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.translations, required this.locale});

  DiningBookingRestaurantConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
  String? shortDescription;

  RestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address, this.shortDescription});

  RestaurantTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    address = json['address'];
    shortDescription = json['shortDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['address'] = address;
    data['shortDescription'] = shortDescription;
    return data;
  }
}

