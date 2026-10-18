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

class HiddenRestaurantListModel {
  List<HiddenRestaurantsModel>? restaurants;
  bool? success;
  final String locale;
  HiddenRestaurantListModel({this.restaurants, this.success, required this.locale});

  HiddenRestaurantListModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['restaurants'] != null) {
      restaurants = <HiddenRestaurantsModel>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(HiddenRestaurantsModel.fromJson(v, locale));
      });
    } else {
      restaurants = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class HiddenRestaurantsModel {
  String? name;
  String? address;
  List<CuisineModel>? cuisine;
  String? cuisineName;
  String? logo;
  String? cover;
  List<RestaurantTranslationsModel>? translations;
  String? rating;
  bool? status;
  String? slug;
  String? id;
  double? dishPriceForTwo;
  bool? isHidden = true;
  final String locale;
  HiddenRestaurantsModel({
    this.name,
    this.address,
    this.cuisine,
    this.cuisineName,
    this.logo,
    this.cover,
    this.translations,
    this.rating,
    this.status,
    this.slug,
    this.id,
    this.dishPriceForTwo,
    this.isHidden,
    required this.locale,
  });

  HiddenRestaurantsModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    if (json['cuisine'] != null) {
      cuisine = <CuisineModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(CuisineModel.fromJson(v, locale));
        if (v['name'] != null && v['name'] != '') {
          names.add(v['name']);
        }
      });
      cuisineName = names.join(' • ');
    } else {
      cuisine = [];
      cuisineName = '';
    }
    logo = json['logo'];
    cover = json['cover'];
    if (json['translations'] != null) {
      translations = <RestaurantTranslationsModel>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantTranslationsModel.fromJson(v));
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
    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString()).toStringAsFixed(1);
    } else {
      rating = '0.0';
    }
    status = json['status'];
    slug = json['slug'];
    id = json['id'];
    if (json['isHidden'] != null && json['isHidden'] != '') {
      isHidden = json['isHidden'];
    } else {
      isHidden = true;
    }
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['status'] = status;
    data['slug'] = slug;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['isHidden'] = isHidden;
    data['cuisineName'] = cuisineName;
    return data;
  }
}

class CuisineModel {
  String? name;
  String? image;
  List<CuisineTranslationsModel>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  CuisineModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  CuisineModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <CuisineTranslationsModel>[];
      json['translations'].forEach((v) {
        translations!.add(CuisineTranslationsModel.fromJson(v));
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

class CuisineTranslationsModel {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CuisineTranslationsModel({this.name, this.code, this.nativeName, this.value});

  CuisineTranslationsModel.fromJson(Map<String, dynamic> json) {
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

class RestaurantTranslationsModel {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  RestaurantTranslationsModel({this.name, this.code, this.nativeName, this.title, this.address});

  RestaurantTranslationsModel.fromJson(Map<String, dynamic> json) {
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

