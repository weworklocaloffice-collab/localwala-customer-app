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

class UserFoodSubscriptionTransactionResponseModel {
  List<UserFoodSubscriptionTransactionConfigModel>? transactions;
  int? totalPages;
  int? totalResults;
  int? page;
  int? limit;
  bool? success;
  final String locale;
  UserFoodSubscriptionTransactionResponseModel({this.transactions, this.totalPages, this.totalResults, this.page, this.limit, this.success, required this.locale});

  UserFoodSubscriptionTransactionResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['transactions'] != null) {
      transactions = <UserFoodSubscriptionTransactionConfigModel>[];
      json['transactions'].forEach((v) {
        transactions!.add(UserFoodSubscriptionTransactionConfigModel.fromJson(v, locale));
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

class UserFoodSubscriptionTransactionConfigModel {
  String? paymentRef;
  String? status;
  String? createdAt;
  String? id;
  double? amount;
  PaymentInfoConfig? paymentInfo;
  SubscriptionPackageConfigModel? subscription;
  String? tiffinSubscription;
  final String locale;

  UserFoodSubscriptionTransactionConfigModel({this.paymentRef, this.status, this.createdAt, this.id, this.amount, this.paymentInfo, this.subscription, this.tiffinSubscription, required this.locale});

  UserFoodSubscriptionTransactionConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
      amount = 0.0;
    }
    paymentInfo = json['paymentInfo'] != null ? PaymentInfoConfig.fromJson(json['paymentInfo'], locale) : null;
    subscription = json['subscription'] != null ? SubscriptionPackageConfigModel.fromJson(json['subscription'], locale) : null;
    tiffinSubscription = json['tiffinSubscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentRef'] = paymentRef;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['amount'] = amount;
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    data['tiffinSubscription'] = tiffinSubscription;
    return data;
  }
}

class PaymentInfoConfig {
  String? id;
  String? slug;
  String? name;
  String? paymentWay;
  List<PaymentTranslations>? translations;
  final String locale;
  PaymentInfoConfig({this.id, this.slug, this.name, this.paymentWay, this.translations, required this.locale});

  PaymentInfoConfig.fromJson(Map<String, dynamic> json, this.locale) {
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

class SubscriptionPackageConfigModel {
  String? id;
  String? displayId;
  String? name;
  String? image;
  String? interval;
  int? totalOrder;
  String? available;
  List<SubscriptionTranslations>? translations;
  final String locale;
  SubscriptionPackageConfigModel({this.id, this.displayId, this.name, this.image, this.interval, this.totalOrder, this.available, this.translations, required this.locale});

  SubscriptionPackageConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    String masked = json['id'].length > 6 ? '${json['id'].substring(0, 3)}***${json['id'].substring(json['id'].length - 3)}' : json['id'];
    id = json['id'];
    displayId = masked;
    name = json['name'];
    image = json['image'];
    if (json['interval'] != null && json['interval'] != '' && json['interval'] != 0) {
      interval = json['interval'];
    } else {
      interval = 'week';
    }
    if (json['totalOrder'] != null && json['totalOrder'] != '') {
      totalOrder = int.parse(json['totalOrder'].toString());
    } else {
      totalOrder = 0;
    }
    available = json['available'];
    if (json['translations'] != null) {
      translations = <SubscriptionTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(SubscriptionTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            name = translations![localeIndex].title!;
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
    data['displayId'] = displayId;
    data['name'] = name;
    data['image'] = image;
    data['interval'] = interval;
    data['totalOrder'] = totalOrder;
    data['available'] = available;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  SubscriptionTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  SubscriptionTranslations.fromJson(Map<String, dynamic> json) {
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

