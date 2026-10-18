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

class RestaurantReviewsResponseModel {
  List<RestaurantReviewListConfigModel>? reviews;
  List<RestaurantPercentagesConfigModel>? percentages;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  String? totalResultString;
  bool? success;
  final String locale;
  RestaurantReviewsResponseModel({this.reviews, this.percentages, this.page, this.limit, this.totalPages, this.totalResults, this.totalResultString, this.success, required this.locale});

  RestaurantReviewsResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['reviews'] != null) {
      reviews = <RestaurantReviewListConfigModel>[];
      json['reviews'].forEach((v) {
        reviews!.add(RestaurantReviewListConfigModel.fromJson(v, locale));
      });
    } else {
      reviews = [];
    }
    if (json['percentages'] != null) {
      percentages = <RestaurantPercentagesConfigModel>[];
      json['percentages'].forEach((v) {
        percentages!.add(RestaurantPercentagesConfigModel.fromJson(v));
      });
    } else {
      percentages = [];
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
      int ratingCount = int.parse(json['totalResults'].toString());
      String formatNumber(num number) {
        if (number >= 1000000000) {
          return '${(number / 1000000000).toStringAsFixed(1)}B';
        } else if (number >= 1000000) {
          return '${(number / 1000000).toStringAsFixed(1)}M';
        } else if (number >= 1000) {
          return '${(number / 1000).toStringAsFixed(1)}K';
        } else {
          return number.toString();
        }
      }

      totalResultString = formatNumber(ratingCount);
    } else {
      totalResults = 0;
      totalResultString = '0';
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    if (percentages != null) {
      data['percentages'] = percentages!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['totalResultString'] = totalResultString;
    data['success'] = success;
    return data;
  }
}

class RestaurantReviewListConfigModel {
  int? ratingCount;
  List<String>? images;
  String? shortReview;
  String? createdAt;
  List<HashtagsConfigModel>? hashtags;
  String? id;
  String? orders;
  UserInfoConfigModel? userInfo;
  final String locale;
  RestaurantReviewListConfigModel({this.ratingCount, this.images, this.shortReview, this.createdAt, this.hashtags, this.id, this.orders, this.userInfo, required this.locale});

  RestaurantReviewListConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
      hashtags = <HashtagsConfigModel>[];
      json['hashtags'].forEach((v) {
        hashtags!.add(HashtagsConfigModel.fromJson(v, locale));
      });
    } else {
      hashtags = [];
    }
    id = json['id'];
    if (json['orders'] != null && json['orders'] != '') {
      orders = json['orders'];
    } else {
      orders = '';
    }
    userInfo = json['userInfo'] != null ? UserInfoConfigModel.fromJson(json['userInfo']) : null;
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
    if (userInfo != null) {
      data['userInfo'] = userInfo!.toJson();
    }
    data['orders'] = orders;
    return data;
  }
}

class HashtagsConfigModel {
  String? name;
  List<Translations>? translations;
  String? id;
  final String locale;
  HashtagsConfigModel({this.name, this.translations, this.id, required this.locale});

  HashtagsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
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

class UserInfoConfigModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;

  UserInfoConfigModel({this.id, this.firstName, this.lastName, this.image});

  UserInfoConfigModel.fromJson(Map<String, dynamic> json) {
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

class RestaurantPercentagesConfigModel {
  int? star;
  double? percentage;
  String? count;

  RestaurantPercentagesConfigModel({this.star, this.percentage, this.count});

  RestaurantPercentagesConfigModel.fromJson(Map<String, dynamic> json) {
    star = json['star'];
    if (json['percentage'] != null && json['percentage'] != '') {
      percentage = double.parse(json['percentage'].toString());
    } else {
      percentage = 0.0;
    }
    if (json['count'] != null && json['count'] != '') {
      int ratingCount = int.parse(json['count'].toString());
      String formatNumber(num number) {
        if (number >= 1000000000) {
          return '${(number / 1000000000).toStringAsFixed(1)}B';
        } else if (number >= 1000000) {
          return '${(number / 1000000).toStringAsFixed(1)}M';
        } else if (number >= 1000) {
          return '${(number / 1000).toStringAsFixed(1)}K';
        } else {
          return number.toString();
        }
      }

      count = formatNumber(ratingCount);
    } else {
      count = '0';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['star'] = star;
    data['percentage'] = percentage;
    data['count'] = count;
    return data;
  }
}

