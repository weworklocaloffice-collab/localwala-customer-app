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

class CouponListResponseModel {
  List<CouponConfigModel>? coupons;
  int? totalResults;
  bool? success;
  final String locale;
  CouponListResponseModel({this.coupons, this.totalResults, this.success, required this.locale});

  CouponListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['coupons'] != null) {
      coupons = <CouponConfigModel>[];
      json['coupons'].forEach((v) {
        coupons!.add(CouponConfigModel.fromJson(v, locale));
      });
    } else {
      coupons = [];
    }
    totalResults = json['totalResults'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class CouponConfigModel {
  String? name;
  String? couponType;
  bool? allRestaurants;
  List<String>? restaurant;
  bool? allUsers;
  List<String>? user;
  String? code;
  String? discountType;
  List<Translations>? translations;
  String? id;
  int? limitSameUser;
  double? loyalityPoints;
  double? maxDiscount;
  double? minCartTotal;
  double? minDiscount;
  bool? isOpened;
  bool? enabled;
  double? requiredAmount;
  String? promoLbl;
  double? minSave;
  double? maxSave;
  final String locale;
  CouponConfigModel({
    this.name,
    this.couponType,
    this.allRestaurants,
    this.restaurant,
    this.allUsers,
    this.user,
    this.code,
    this.discountType,
    this.translations,
    this.id,
    this.limitSameUser,
    this.loyalityPoints,
    this.maxDiscount,
    this.minCartTotal,
    this.minDiscount,
    this.isOpened,
    this.enabled,
    this.requiredAmount,
    this.promoLbl,
    this.minSave,
    this.maxSave,
    required this.locale,
  });

  CouponConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    couponType = json['couponType'];
    allRestaurants = json['allRestaurants'];
    restaurant = json['restaurant'].cast<String>();
    allUsers = json['allUsers'];
    user = json['user'].cast<String>();
    code = json['code'];
    discountType = json['discountType'];
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
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
    id = json['id'];
    if (json['limitSameUser'] != null && json['limitSameUser'] != '') {
      limitSameUser = int.parse(json['limitSameUser'].toString());
    } else {
      limitSameUser = 1;
    }

    if (json['loyalityPoints'] != null && json['loyalityPoints'] != '') {
      loyalityPoints = double.parse(json['loyalityPoints'].toString());
    } else {
      loyalityPoints = 0;
    }

    if (json['maxDiscount'] != null && json['maxDiscount'] != '') {
      maxDiscount = double.parse(json['maxDiscount'].toString());
    } else {
      maxDiscount = 0;
    }

    if (json['minCartTotal'] != null && json['minCartTotal'] != '') {
      minCartTotal = double.parse(json['minCartTotal'].toString());
    } else {
      minCartTotal = 0;
    }

    if (json['minDiscount'] != null && json['minDiscount'] != '') {
      minDiscount = double.parse(json['minDiscount'].toString());
    } else {
      minDiscount = 0;
    }

    if (json['isOpened'] != null && json['isOpened'] != '') {
      isOpened = json['isOpened'];
    } else {
      isOpened = false;
    }

    if (json['enabled'] != null && json['enabled'] != '') {
      enabled = json['enabled'];
    } else {
      enabled = true;
    }

    if (json['requiredAmount'] != null && json['requiredAmount'] != '') {
      requiredAmount = double.parse(json['requiredAmount'].toString());
    } else {
      requiredAmount = 0.0;
    }

    if (json['promoLbl'] != null && json['promoLbl'] != '') {
      promoLbl = json['promoLbl'];
    } else {
      promoLbl = '';
    }

    if (json['minSave'] != null && json['minSave'] != '') {
      minSave = double.parse(json['minSave'].toString());
    } else {
      minSave = 0.0;
    }

    if (json['maxSave'] != null && json['maxSave'] != '') {
      maxSave = double.parse(json['maxSave'].toString());
    } else {
      maxSave = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['couponType'] = couponType;
    data['allRestaurants'] = allRestaurants;
    data['restaurant'] = restaurant;
    data['allUsers'] = allUsers;
    data['user'] = user;
    data['code'] = code;
    data['discountType'] = discountType;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['limitSameUser'] = limitSameUser;
    data['loyalityPoints'] = loyalityPoints;
    data['maxDiscount'] = maxDiscount;
    data['minCartTotal'] = minCartTotal;
    data['minDiscount'] = minDiscount;
    data['isOpened'] = isOpened;
    data['enabled'] = enabled;
    data['requiredAmount'] = requiredAmount;
    data['promoLbl'] = promoLbl;
    data['minSave'] = minSave;
    data['maxSave'] = maxSave;
    return data;
  }
}

class Translations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  Translations({this.name, this.code, this.nativeName, this.value});

  Translations.fromJson(Map<String, dynamic> json) {
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

