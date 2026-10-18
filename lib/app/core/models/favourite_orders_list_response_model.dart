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
import 'package:user/app/core/models/food_in_cart_model.dart';

class MyFavouriteOrderListResponseModel {
  List<OrdersListModel>? orders;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  bool? success;
  final String locale;
  MyFavouriteOrderListResponseModel({this.orders, this.page, this.limit, this.totalPages, this.totalResults, this.success, required this.locale});

  MyFavouriteOrderListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['orders'] != null) {
      orders = <OrdersListModel>[];
      json['orders'].forEach((v) {
        orders!.add(OrdersListModel.fromJson(v, locale));
      });
    } else {
      orders = [];
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
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class OrdersListModel {
  OrderRestaurantInfoModel? restaurant;
  bool? instantOrder;
  bool? scheduleOrder;
  String? scheduleDate;
  String? scheduleTime;
  String? status;
  String? createdAt;
  String? orderAt;
  String? id;
  double? grandTotal;
  List<FoodInCartModel>? cartItem;
  final String locale;
  OrdersListModel({this.restaurant, this.instantOrder, this.scheduleOrder, this.scheduleDate, this.scheduleTime, this.status, this.createdAt, this.orderAt, this.id, this.grandTotal, this.cartItem, required this.locale});

  OrdersListModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? OrderRestaurantInfoModel.fromJson(json['restaurant'], locale) : null;
    instantOrder = json['instantOrder'];
    scheduleOrder = json['scheduleOrder'];
    if (json['scheduleDate'] != null && json['scheduleDate'] != '') {
      DateTime tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['scheduleDate']);
      scheduleDate = DateFormat.yMMMd(locale).format(tempDate);
    } else {
      scheduleDate = '';
    }
    if (json['scheduleTime'] != null && json['scheduleTime'] != '') {
      DateTime parsedTime = DateFormat("h:mm a").parse(json['scheduleTime'].toString().toUpperCase());
      String formattedTime = DateFormat.jm(locale).format(parsedTime);
      scheduleTime = formattedTime;
    } else {
      scheduleTime = '';
    }
    status = json['status'];
    if (json['createdAt'] != null && json['createdAt'] != '') {
      DateTime tempDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['createdAt']);
      createdAt = DateFormat.yMMMd(locale).format(tempDate);
    } else {
      createdAt = '';
    }
    if (json['orderAt'] != null && json['orderAt'] != '') {
      DateTime parsedTime = DateFormat("h:mm a").parse(json['orderAt'].toString().toUpperCase());
      String formattedTime = DateFormat.jm(locale).format(parsedTime);
      orderAt = formattedTime;
    } else {
      orderAt = '02:00 PM';
    }
    id = json['id'];
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0;
    }
    if (json['cartItem'] != null) {
      cartItem = <FoodInCartModel>[];
      json['cartItem'].forEach((v) {
        cartItem!.add(FoodInCartModel.fromJson(v, locale));
      });
    } else {
      cartItem = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['instantOrder'] = instantOrder;
    data['scheduleOrder'] = scheduleOrder;
    data['scheduleDate'] = scheduleDate;
    data['scheduleTime'] = scheduleTime;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['orderAt'] = orderAt;
    data['id'] = id;
    data['grandTotal'] = grandTotal;
    if (cartItem != null) {
      data['cartItem'] = cartItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderRestaurantInfoModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  List<RestaurantTranslations>? translations;
  final String locale;
  OrderRestaurantInfoModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.translations, required this.locale});

  OrderRestaurantInfoModel.fromJson(Map<String, dynamic> json, this.locale) {
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

