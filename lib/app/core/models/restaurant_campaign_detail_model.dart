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

class RestaurantCampaignDetailModel {
  Detail? detail;
  String? findMode;
  List<InCampaignRestaurantModel>? inCampaign;
  final String locale;
  RestaurantCampaignDetailModel({this.detail, this.findMode, this.inCampaign, required this.locale});

  RestaurantCampaignDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    detail = json['detail'] != null ? Detail.fromJson(json['detail'], locale) : null;
    findMode = json['findMode'];
    if (json['inCampaign'] != null) {
      inCampaign = <InCampaignRestaurantModel>[];
      json['inCampaign'].forEach((v) {
        inCampaign!.add(InCampaignRestaurantModel.fromJson(v, locale));
      });
    } else {
      inCampaign = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    data['findMode'] = findMode;
    if (inCampaign != null) {
      data['inCampaign'] = inCampaign!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detail {
  String? title;
  String? shortDescription;
  String? city;
  List<String>? restaurant;
  String? image;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  List<Translations>? translations;
  bool? status;
  String? id;
  final String locale;
  Detail({this.title, this.shortDescription, this.city, this.restaurant, this.image, this.startDate, this.endDate, this.startTime, this.endTime, this.translations, this.status, this.id, required this.locale});

  Detail.fromJson(Map<String, dynamic> json, this.locale) {
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
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
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

class Translations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  Translations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  Translations.fromJson(Map<String, dynamic> json) {
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

class InCampaignRestaurantModel {
  String? name;
  List<CuisineModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  double? dishPriceForTwo;
  List<RestaurantTranslations>? translations;
  String? rating;
  bool? status;
  String? slug;
  List<Slots>? slots;
  bool? promote = false;
  String? distance;
  String? cuisineName;
  bool? isFavourite = false;
  bool? isHidden = false;
  String? id;
  final String locale;
  InCampaignRestaurantModel({
    this.name,
    this.cuisine,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.dishPriceForTwo,
    this.translations,
    this.rating,
    this.status,
    this.slug,
    this.slots,
    this.promote,
    this.distance,
    this.cuisineName,
    this.isFavourite,
    this.isHidden,
    this.id,
    required this.locale,
  });

  InCampaignRestaurantModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
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
    approxDeliveryTime = json['approxDeliveryTime'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
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
    if (json['slots'] != null) {
      slots = <Slots>[];
      json['slots'].forEach((v) {
        slots!.add(Slots.fromJson(v));
      });
    } else {
      slots = [];
    }

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
    if (json['promote'] != null && json['promote'] != '') {
      promote = json['promote'];
    } else {
      promote = false;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    data['logo'] = logo;
    data['cover'] = cover;
    data['approxDeliveryTime'] = approxDeliveryTime;
    data['dishPriceForTwo'] = dishPriceForTwo;

    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['status'] = status;
    data['slug'] = slug;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    data['promote'] = promote;
    data['distance'] = distance;
    data['cuisineName'] = cuisineName;
    data['isFavourite'] = isFavourite;
    data['isHidden'] = isHidden;
    data['id'] = id;
    return data;
  }
}

class CuisineModel {
  String? name;
  String? image;
  List<CuisineTranslations>? translations;
  bool? status;
  String? slug;
  final String locale;
  CuisineModel({this.name, this.image, this.translations, this.status, this.slug, required this.locale});

  CuisineModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <CuisineTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CuisineTranslations.fromJson(v));
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
    return data;
  }
}

class RestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  RestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  RestaurantTranslations.fromJson(Map<String, dynamic> json) {
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

class Slots {
  int? day;
  List<Times>? times;

  Slots({this.day, this.times});

  Slots.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['times'] != null) {
      times = <Times>[];
      json['times'].forEach((v) {
        times!.add(Times.fromJson(v));
      });
    } else {
      times = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    if (times != null) {
      data['times'] = times!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Times {
  String? start;
  String? end;

  Times({this.start, this.end});

  Times.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class CuisineTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CuisineTranslations({this.name, this.code, this.nativeName, this.value});

  CuisineTranslations.fromJson(Map<String, dynamic> json) {
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

