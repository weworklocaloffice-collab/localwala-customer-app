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

class PurchasedTiffinSubscriptionPackageResponseModel {
  List<PurchasedTiffinSubscriptionPackageModel>? purchased;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  bool? success;
  final String locale;
  PurchasedTiffinSubscriptionPackageResponseModel({this.purchased, this.page, this.limit, this.totalPages, this.totalResults, this.success, required this.locale});

  PurchasedTiffinSubscriptionPackageResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['purchased'] != null) {
      purchased = <PurchasedTiffinSubscriptionPackageModel>[];
      json['purchased'].forEach((v) {
        purchased!.add(PurchasedTiffinSubscriptionPackageModel.fromJson(v, locale));
      });
    } else {
      purchased = [];
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
    if (purchased != null) {
      data['purchased'] = purchased!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class PurchasedTiffinSubscriptionPackageModel {
  RestaurantInfoConfigModel? restaurant;
  String? slot;
  String? orderAt;
  String? orderTo;
  int? totalOrder;
  List<String>? ordersDates;
  String? status;
  String? id;
  double? grandTotal;
  PackageDetailConfigModel? package;
  final String locale;
  PurchasedTiffinSubscriptionPackageModel({this.restaurant, this.slot, this.orderAt, this.orderTo, this.totalOrder, this.ordersDates, this.status, this.id, this.grandTotal, this.package, required this.locale});

  PurchasedTiffinSubscriptionPackageModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? RestaurantInfoConfigModel.fromJson(json['restaurant'], locale) : null;
    slot = json['slot'];
    orderAt = json['orderAt'];
    orderTo = json['orderTo'];
    if (json['totalOrder'] != null && json['totalOrder'] != '') {
      totalOrder = int.parse(json['totalOrder'].toString());
    } else {
      totalOrder = 0;
    }
    ordersDates = json['ordersDates'].cast<String>();
    status = json['status'];
    id = json['id'];
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0;
    }
    package = json['package'] != null ? PackageDetailConfigModel.fromJson(json['package'], locale) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['slot'] = slot;
    data['orderAt'] = orderAt;
    data['orderTo'] = orderTo;
    data['totalOrder'] = totalOrder;
    data['ordersDates'] = ordersDates;
    data['status'] = status;
    data['id'] = id;
    data['grandTotal'] = grandTotal;
    if (package != null) {
      data['package'] = package!.toJson();
    }
    return data;
  }
}

class RestaurantInfoConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  List<Translations>? translations;
  final String locale;
  RestaurantInfoConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.translations, required this.locale});

  RestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    slug = json['slug'];
    address = json['address'];
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

class PackageTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  PackageTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  PackageTranslations.fromJson(Map<String, dynamic> json) {
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

class Translations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  Translations({this.name, this.code, this.nativeName, this.title, this.address});

  Translations.fromJson(Map<String, dynamic> json) {
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

class PackageDetailConfigModel {
  String? id;
  String? name;
  String? shortDescription;
  String? image;
  List<PackageTranslations>? translations;
  final String locale;
  PackageDetailConfigModel({this.id, this.name, this.shortDescription, this.image, this.translations, required this.locale});

  PackageDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <PackageTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(PackageTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

