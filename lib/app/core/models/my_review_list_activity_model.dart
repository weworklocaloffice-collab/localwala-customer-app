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

import 'package:timeago/timeago.dart' as timeago;

class MyReviewListActivityModel {
  List<FoodReviewConfigModel>? foodReviews;
  List<DriverReviewConfigModel>? driverReviews;
  List<RestaurantReviewConfigModel>? restaurantReviews;
  bool? success;
  final String locale;
  MyReviewListActivityModel({this.foodReviews, this.driverReviews, this.restaurantReviews, this.success, required this.locale});

  MyReviewListActivityModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['foodReviews'] != null) {
      foodReviews = <FoodReviewConfigModel>[];
      json['foodReviews'].forEach((v) {
        foodReviews!.add(FoodReviewConfigModel.fromJson(v, locale));
      });
    } else {
      foodReviews = [];
    }
    if (json['driverReviews'] != null) {
      driverReviews = <DriverReviewConfigModel>[];
      json['driverReviews'].forEach((v) {
        driverReviews!.add(DriverReviewConfigModel.fromJson(v, locale));
      });
    } else {
      driverReviews = [];
    }
    if (json['restaurantReviews'] != null) {
      restaurantReviews = <RestaurantReviewConfigModel>[];
      json['restaurantReviews'].forEach((v) {
        restaurantReviews!.add(RestaurantReviewConfigModel.fromJson(v, locale));
      });
    } else {
      restaurantReviews = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foodReviews != null) {
      data['foodReviews'] = foodReviews!.map((v) => v.toJson()).toList();
    }
    if (driverReviews != null) {
      data['driverReviews'] = driverReviews!.map((v) => v.toJson()).toList();
    }
    if (restaurantReviews != null) {
      data['restaurantReviews'] = restaurantReviews!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class FoodReviewConfigModel {
  int? ratingCount;
  List<String>? images;
  String? shortReview;
  String? createdAt;
  FoodInfoConfig? foods;
  List<HashTagConfigModel>? hashtags;
  String? id;
  final String locale;
  FoodReviewConfigModel({this.ratingCount, this.images, this.shortReview, this.createdAt, this.foods, this.hashtags, this.id, required this.locale});

  FoodReviewConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['ratingCount'] != null && json['ratingCount'] != '') {
      ratingCount = int.parse(json['ratingCount'].toString());
    } else {
      ratingCount = 0;
    }
    images = json['images'].cast<String>();
    shortReview = json['shortReview'];

    if (json['createdAt'] != null && json['createdAt'] != '') {
      String apiDate = json['createdAt'];
      DateTime parsedDate = DateTime.parse(apiDate);
      String timeAgoEn = timeago.format(parsedDate, locale: locale);
      createdAt = timeAgoEn;
    } else {
      createdAt = 'just now';
    }
    foods = json['foods'] != null ? FoodInfoConfig.fromJson(json['foods'], locale) : null;
    if (json['hashtags'] != null) {
      hashtags = <HashTagConfigModel>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(HashTagConfigModel.fromJson(v, locale));
      });
    } else {
      hashtags = [];
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ratingCount'] = ratingCount;
    data['images'] = images;
    data['shortReview'] = shortReview;
    data['createdAt'] = createdAt;
    if (foods != null) {
      data['foods'] = foods!.toJson();
    }
    if (hashtags != null) {
      data['hashtags'] = hashtags!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class FoodInfoConfig {
  String? id;
  String? name;
  String? image;
  List<FoodTranslations>? translations;
  final String locale;
  FoodInfoConfig({this.id, this.name, this.image, this.translations, required this.locale});

  FoodInfoConfig.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <FoodTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(FoodTranslations.fromJson(v));
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
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FoodTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  FoodTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  FoodTranslations.fromJson(Map<String, dynamic> json) {
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

class HashTagConfigModel {
  String? name;
  List<HashTagTranslations>? translations;
  String? id;
  final String locale;
  HashTagConfigModel({this.name, this.translations, this.id, required this.locale});

  HashTagConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <HashTagTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(HashTagTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class HashTagTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  HashTagTranslations({this.name, this.code, this.nativeName, this.value});

  HashTagTranslations.fromJson(Map<String, dynamic> json) {
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

class DriverReviewConfigModel {
  int? ratingCount;
  List<String>? images;
  String? shortReview;
  String? createdAt;
  List<HashTagConfigModel>? hashtags;
  String? id;
  DriverInfo? driverInfo;
  final String locale;
  DriverReviewConfigModel({this.ratingCount, this.images, this.shortReview, this.createdAt, this.hashtags, this.id, this.driverInfo, required this.locale});

  DriverReviewConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['ratingCount'] != null && json['ratingCount'] != '') {
      ratingCount = int.parse(json['ratingCount'].toString());
    } else {
      ratingCount = 0;
    }
    images = json['images'].cast<String>();
    shortReview = json['shortReview'];

    if (json['createdAt'] != null && json['createdAt'] != '') {
      String apiDate = json['createdAt'];
      DateTime parsedDate = DateTime.parse(apiDate);
      String timeAgoEn = timeago.format(parsedDate, locale: locale);
      createdAt = timeAgoEn;
    } else {
      createdAt = 'just now';
    }
    if (json['hashtags'] != null) {
      hashtags = <HashTagConfigModel>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(HashTagConfigModel.fromJson(v, locale));
      });
    } else {
      hashtags = [];
    }
    id = json['id'];
    driverInfo = json['driverInfo'] != null ? DriverInfo.fromJson(json['driverInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ratingCount'] = ratingCount;
    data['images'] = images;
    data['shortReview'] = shortReview;
    data['createdAt'] = createdAt;
    if (hashtags != null) {
      data['hashtags'] = hashtags!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    if (driverInfo != null) {
      data['driverInfo'] = driverInfo!.toJson();
    }
    return data;
  }
}

class DriverInfo {
  String? id;
  String? firstName;
  String? lastName;
  String? image;

  DriverInfo({this.id, this.firstName, this.lastName, this.image});

  DriverInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    return data;
  }
}

class RestaurantReviewConfigModel {
  String? orders;
  int? ratingCount;
  List<String>? images;
  String? shortReview;
  String? createdAt;
  RestaurantInfoConfigModel? restaurants;
  List<HashTagConfigModel>? hashtags;
  String? id;
  final String locale;
  RestaurantReviewConfigModel({this.orders, this.ratingCount, this.images, this.shortReview, this.createdAt, this.restaurants, this.hashtags, this.id, required this.locale});

  RestaurantReviewConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['orders'] != null && json['orders'] != '') {
      orders = json['orders'];
    } else {
      orders = '';
    }
    if (json['ratingCount'] != null && json['ratingCount'] != '') {
      ratingCount = int.parse(json['ratingCount'].toString());
    } else {
      ratingCount = 0;
    }
    images = json['images'].cast<String>();
    shortReview = json['shortReview'];

    if (json['createdAt'] != null && json['createdAt'] != '') {
      String apiDate = json['createdAt'];
      DateTime parsedDate = DateTime.parse(apiDate);
      String timeAgoEn = timeago.format(parsedDate, locale: locale);
      createdAt = timeAgoEn;
    } else {
      createdAt = 'just now';
    }
    restaurants = json['restaurants'] != null ? RestaurantInfoConfigModel.fromJson(json['restaurants'], locale) : null;
    if (json['hashtags'] != null) {
      hashtags = <HashTagConfigModel>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(HashTagConfigModel.fromJson(v, locale));
      });
    } else {
      hashtags = [];
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders;
    data['ratingCount'] = ratingCount;
    data['images'] = images;
    data['shortReview'] = shortReview;
    data['createdAt'] = createdAt;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    if (hashtags != null) {
      data['hashtags'] = hashtags!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class RestaurantInfoConfigModel {
  String? id;
  String? name;
  String? address;
  String? cover;
  String? logo;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantInfoConfigModel({this.id, this.name, this.address, this.cover, this.logo, this.translations, required this.locale});

  RestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    cover = json['cover'];
    logo = json['logo'];
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
    data['address'] = address;
    data['cover'] = cover;
    data['logo'] = logo;
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

