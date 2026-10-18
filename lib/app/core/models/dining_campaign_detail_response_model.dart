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

class DiningCampaignDetailResponseModel {
  DiningCampaignDetailConfigModel? detail;
  List<DiningInformationInCampaignConfigModel>? inCampaign;
  String? findMode;
  bool? success;
  final String locale;
  DiningCampaignDetailResponseModel({this.detail, this.inCampaign, this.findMode, this.success, required this.locale});

  DiningCampaignDetailResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['inCampaign'] != null) {
      inCampaign = <DiningInformationInCampaignConfigModel>[];
      json['inCampaign'].forEach((v) {
        inCampaign!.add(DiningInformationInCampaignConfigModel.fromJson(v, locale));
      });
    } else {
      inCampaign = [];
    }
    detail = json['detail'] != null ? DiningCampaignDetailConfigModel.fromJson(json['detail'], locale) : null;
    findMode = json['findMode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    if (inCampaign != null) {
      data['inCampaign'] = inCampaign!.map((v) => v.toJson()).toList();
    }
    data['findMode'] = findMode;
    data['success'] = success;
    return data;
  }
}

class DiningCampaignDetailConfigModel {
  String? title;
  String? shortDescription;
  String? city;
  List<String>? restaurant;
  String? image;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  List<DiningCampaignDetailTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  DiningCampaignDetailConfigModel({
    this.title,
    this.shortDescription,
    this.city,
    this.restaurant,
    this.image,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.translations,
    this.status,
    this.id,
    required this.locale,
  });

  DiningCampaignDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    title = json['title'];
    shortDescription = json['shortDescription'];
    city = json['city'];
    restaurant = json['restaurant'].cast<String>();
    image = json['image'];
    if (json['startDate'] != null && json['startDate'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['startDate']);
      var inputDate = DateTime.parse(parseDate.toString());
      startDate = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      startDate = '-';
    }
    if (json['endDate'] != null && json['endDate'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['endDate']);
      var inputDate = DateTime.parse(parseDate.toString());
      endDate = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      endDate = '-';
    }
    if (json['startTime'] != null && json['startTime'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd hh:mm").parse("2024-01-01 ${json['startTime']}");
      var inputDate = DateTime.parse(parseDate.toString());
      startTime = DateFormat('hh:mm a', locale).format(inputDate);
    } else {
      startTime = '-';
    }
    if (json['endTime'] != null && json['endTime'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd hh:mm").parse("2024-01-01 ${json['endTime']}");
      var inputDate = DateTime.parse(parseDate.toString());
      endTime = DateFormat('hh:mm a', locale).format(inputDate);
    } else {
      endTime = '-';
    }
    if (json['translations'] != null) {
      translations = <DiningCampaignDetailTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCampaignDetailTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            title = translations![localeIndex].title!;
          }
          if (translations![localeIndex].shortDescription!.isNotEmpty) {
            shortDescription = translations![localeIndex].shortDescription!;
          }
        }
      }
    } else {
      translations = [];
    }
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['shortDescription'] = shortDescription;
    data['city'] = city;
    data['restaurant'] = restaurant;
    data['image'] = image;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class DiningCampaignDetailTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  DiningCampaignDetailTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  DiningCampaignDetailTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningInformationInCampaignConfigModel {
  String? name;
  String? address;
  List<DiningCampaignRestaurantCuisineConfigModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<DiningCampaignRestaurantTranslations>? translations;
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
  DiningInformationInCampaignConfigModel({
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

  DiningInformationInCampaignConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    if (json['cuisine'] != null) {
      cuisine = <DiningCampaignRestaurantCuisineConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(DiningCampaignRestaurantCuisineConfigModel.fromJson(v, locale));
        DiningCampaignRestaurantCuisineConfigModel cuisineData = DiningCampaignRestaurantCuisineConfigModel.fromJson(v, locale);
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
      translations = <DiningCampaignRestaurantTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCampaignRestaurantTranslations.fromJson(v));
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

class DiningCampaignRestaurantCuisineConfigModel {
  String? name;
  String? image;
  List<DiningCampaignCuisineTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningCampaignRestaurantCuisineConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningCampaignRestaurantCuisineConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningCampaignCuisineTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCampaignCuisineTranslations.fromJson(v));
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

class DiningCampaignCuisineTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningCampaignCuisineTranslations({this.name, this.code, this.nativeName, this.value});

  DiningCampaignCuisineTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningCampaignRestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  DiningCampaignRestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  DiningCampaignRestaurantTranslations.fromJson(Map<String, dynamic> json) {
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

