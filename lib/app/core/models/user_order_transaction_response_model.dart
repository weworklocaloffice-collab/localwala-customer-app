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

class UserOrderTransactionResponseModel {
  List<OrderTransactionConfigModel>? transactions;
  int? totalPages;
  int? totalResults;
  int? page;
  int? limit;
  bool? success;
  final String locale;
  UserOrderTransactionResponseModel({this.transactions, this.totalPages, this.totalResults, this.page, this.limit, this.success, required this.locale});

  UserOrderTransactionResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['transactions'] != null) {
      transactions = <OrderTransactionConfigModel>[];
      json['transactions'].forEach((v) {
        transactions!.add(OrderTransactionConfigModel.fromJson(v, locale));
      });
    } else {
      transactions = [];
    }
    if (json['totalPages'] != null && json['totalPages'] != '') {
      totalPages = int.parse(json['totalPages'].toString());
    } else {
      totalPages = 1;
    }
    if (json['totalResults'] != null && json['totalResults'] != '') {
      totalResults = int.parse(json['totalResults'].toString());
    } else {
      totalResults = 1;
    }
    if (json['page'] != null && json['page'] != '') {
      page = int.parse(json['page'].toString());
    } else {
      page = 1;
    }
    if (json['limit'] != null && json['limit'] != '') {
      limit = int.parse(json['limit'].toString());
    } else {
      limit = 1;
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['page'] = page;
    data['limit'] = limit;
    data['success'] = success;
    return data;
  }
}

class OrderTransactionConfigModel {
  String? orders;
  String? paymentRef;
  String? status;
  String? createdAt;
  String? id;
  double? amount;
  OrderInfoConfigModel? orderInfo;
  TransactionPaymentConfigModel? paymentInfo;
  final String locale;
  OrderTransactionConfigModel({this.orders, this.paymentRef, this.status, this.createdAt, this.id, this.amount, this.orderInfo, this.paymentInfo, required this.locale});

  OrderTransactionConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    orders = json['orders'];
    paymentRef = json['paymentRef'];
    status = json['status'];
    if (json['createdAt'] != null && json['createdAt'] != '') {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['createdAt']);
      var inputDate = DateTime.parse(parseDate.toString());
      createdAt = DateFormat('dd MMM y', locale).format(inputDate);
    } else {
      createdAt = '-';
    }
    id = json['id'];
    if (json['amount'] != null && json['amount'] != '') {
      amount = double.parse(json['amount'].toString());
    } else {
      amount = 0;
    }
    paymentInfo = json['paymentInfo'] != null ? TransactionPaymentConfigModel.fromJson(json['paymentInfo'], locale) : null;
    orderInfo = json['orderInfo'] != null ? OrderInfoConfigModel.fromJson(json['orderInfo'], locale) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders;
    data['paymentRef'] = paymentRef;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['amount'] = amount;
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    if (orderInfo != null) {
      data['orderInfo'] = orderInfo!.toJson();
    }
    return data;
  }
}

class TransactionPaymentConfigModel {
  String? id;
  String? slug;
  String? name;
  String? paymentWay;
  List<PaymentTranslations>? translations;
  final String locale;

  TransactionPaymentConfigModel({this.id, this.slug, this.name, this.paymentWay, this.translations, required this.locale});

  TransactionPaymentConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    paymentWay = json['paymentWay'];
    if (json['translations'] != null) {
      translations = <PaymentTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(PaymentTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['name'] = name;
    data['paymentWay'] = paymentWay;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  PaymentTranslations({this.name, this.code, this.nativeName, this.value});

  PaymentTranslations.fromJson(Map<String, dynamic> json) {
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

class OrderInfoConfigModel {
  String? id;
  int? orderNo;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  List<RestaurantTranslations>? translations;
  final String locale;

  OrderInfoConfigModel({this.id, this.orderNo, this.name, this.logo, this.cover, this.slug, this.address, this.translations, required this.locale});

  OrderInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    if (json['orderNo'] != null && json['orderNo'] != '') {
      orderNo = int.parse(json['orderNo'].toString());
    } else {
      orderNo = 0;
    }
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
    data['orderNo'] = orderNo;
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

