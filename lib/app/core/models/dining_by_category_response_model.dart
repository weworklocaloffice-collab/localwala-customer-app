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

class DiningByCategoryResponseModel {
  List<DiningByCategoryRestaurantConfigModel>? restaurants;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  String? findMode;
  bool? success;
  final String locale;
  DiningByCategoryResponseModel({this.restaurants, this.page, this.limit, this.totalPages, this.totalResults, this.findMode, this.success, required this.locale});

  DiningByCategoryResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['restaurants'] != null) {
      restaurants = <DiningByCategoryRestaurantConfigModel>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(DiningByCategoryRestaurantConfigModel.fromJson(v, locale));
      });
    } else {
      restaurants = [];
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
    findMode = json['findMode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['findMode'] = findMode;
    data['success'] = success;
    return data;
  }
}

class DiningByCategoryRestaurantConfigModel {
  String? name;
  String? address;
  List<DiningByCategoryCuisineConfigModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<DiningByCategoryRestaurantTranslations>? translations;
  String? rating;
  bool? status;
  String? slug;
  String? distance;
  String? cuisineName;
  bool? isFavourite = false;
  bool? isHidden = false;
  String? id;
  double? dishPriceForTwo;
  bool? promote = false;
  final String locale;
  DiningByCategoryRestaurantConfigModel({
    this.name,
    this.address,
    this.cuisine,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.translations,
    this.rating,
    this.status,
    this.slug,
    this.distance,
    this.cuisineName,
    this.isFavourite,
    this.isHidden,
    this.id,
    this.dishPriceForTwo,
    this.promote,
    required this.locale,
  });

  DiningByCategoryRestaurantConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    if (json['cuisine'] != null) {
      cuisine = <DiningByCategoryCuisineConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(DiningByCategoryCuisineConfigModel.fromJson(v, locale));
        DiningByCategoryCuisineConfigModel cuisineData = DiningByCategoryCuisineConfigModel.fromJson(v, locale);
        names.add(cuisineData.name!);
      });
      cuisineName = names.join(' • ');
    } else {
      cuisine = [];
      cuisineName = '';
    }
    logo = json['logo'];
    cover = json['cover'];
    approxDeliveryTime = json['approxDeliveryTime'];
    if (json['translations'] != null) {
      translations = <DiningByCategoryRestaurantTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningByCategoryRestaurantTranslations.fromJson(v));
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
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString()).toStringAsFixed(1);
    } else {
      distance = '0.0';
    }
    if (json['isFavourite'] != null && json['isFavourite'] != '') {
      isFavourite = json['isFavourite'];
    } else {
      isFavourite = false;
    }
    if (json['isHidden'] != null && json['isHidden'] != '') {
      isHidden = json['isHidden'];
    } else {
      isHidden = false;
    }
    id = json['id'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
    promote = json['promote'];
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
    data['approxDeliveryTime'] = approxDeliveryTime;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['status'] = status;
    data['slug'] = slug;
    data['distance'] = distance;
    data['isFavourite'] = isFavourite;
    data['isHidden'] = isHidden;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['promote'] = promote;
    return data;
  }
}

class DiningByCategoryCuisineConfigModel {
  String? name;
  String? image;
  List<DiningByCategoryCuisineTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningByCategoryCuisineConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningByCategoryCuisineConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningByCategoryCuisineTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningByCategoryCuisineTranslations.fromJson(v));
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

class DiningByCategoryCuisineTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningByCategoryCuisineTranslations({this.name, this.code, this.nativeName, this.value});

  DiningByCategoryCuisineTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningByCategoryRestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  DiningByCategoryRestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  DiningByCategoryRestaurantTranslations.fromJson(Map<String, dynamic> json) {
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

