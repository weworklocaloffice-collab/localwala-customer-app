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

class GlobalDiningSearchInitialResponseModel {
  DiningSearchCityConfigModel? city;
  List<DiningSearchCategoryConfigModel>? category;
  bool? success;
  final String locale;
  GlobalDiningSearchInitialResponseModel({this.city, this.category, this.success, required this.locale});

  GlobalDiningSearchInitialResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    city = json['city'] != null ? DiningSearchCityConfigModel.fromJson(json['city'], locale) : null;
    if (json['category'] != null) {
      category = <DiningSearchCategoryConfigModel>[];
      json['category'].forEach((v) {
        category!.add(DiningSearchCategoryConfigModel.fromJson(v, locale));
      });
    } else {
      category = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class DiningSearchCityConfigModel {
  LocationCoordinatesModel? location;
  String? name;
  String? image;
  List<DiningSearchCityTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningSearchCityConfigModel({this.location, this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningSearchCityConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    location = json['location'] != null ? LocationCoordinatesModel.fromJson(json['location']) : null;
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningSearchCityTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningSearchCityTranslations.fromJson(v));
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
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class DiningSearchCategoryConfigModel {
  String? name;
  String? image;
  List<DiningSearchCategoryTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningSearchCategoryConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningSearchCategoryConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningSearchCategoryTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningSearchCategoryTranslations.fromJson(v));
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
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class LocationCoordinatesModel {
  String? type;
  List<double>? coordinates;

  LocationCoordinatesModel({this.type, this.coordinates});

  LocationCoordinatesModel.fromJson(Map<String, dynamic> json) {
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

class DiningSearchCityTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningSearchCityTranslations({this.name, this.code, this.nativeName, this.value});

  DiningSearchCityTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningSearchCategoryTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningSearchCategoryTranslations({this.name, this.code, this.nativeName, this.value});

  DiningSearchCategoryTranslations.fromJson(Map<String, dynamic> json) {
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

