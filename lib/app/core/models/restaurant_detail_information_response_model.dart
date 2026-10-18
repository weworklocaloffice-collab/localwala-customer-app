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
import 'package:timeago/timeago.dart' as timeago;

class RestaurantDetailInformationResponseModel {
  RestaurantDetailConfigModel? details;
  List<BestSellingFoodTranslations>? bestFoods;
  List<OrderCouponsConfigModel>? orderCoupons;
  List<DiningCouponConfigModel>? diningCoupons;
  List<RestaurantReviewListConfigModel>? reviews;
  List<DiningMenuConfigModel>? menuDetail;
  List<String>? diningPhotos;
  String? findMode;
  bool? success;
  final String locale;
  RestaurantDetailInformationResponseModel({this.details, this.bestFoods, this.orderCoupons, this.diningCoupons, this.reviews, this.menuDetail, this.diningPhotos, this.findMode, this.success, required this.locale});

  RestaurantDetailInformationResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? RestaurantDetailConfigModel.fromJson(json['details'], locale) : null;
    if (json['bestFoods'] != null) {
      bestFoods = <BestSellingFoodTranslations>[];
      json['bestFoods'].forEach((v) {
        bestFoods!.add(BestSellingFoodTranslations.fromJson(v));
      });
    } else {
      bestFoods = [];
    }
    if (json['orderCoupons'] != null) {
      orderCoupons = <OrderCouponsConfigModel>[];
      json['orderCoupons'].forEach((v) {
        orderCoupons!.add(OrderCouponsConfigModel.fromJson(v, locale));
      });
    } else {
      orderCoupons = [];
    }
    if (json['diningCoupons'] != null) {
      diningCoupons = <DiningCouponConfigModel>[];
      json['diningCoupons'].forEach((v) {
        diningCoupons!.add(DiningCouponConfigModel.fromJson(v, locale));
      });
    } else {
      diningCoupons = [];
    }
    if (json['reviews'] != null) {
      reviews = <RestaurantReviewListConfigModel>[];
      json['reviews'].forEach((v) {
        reviews!.add(RestaurantReviewListConfigModel.fromJson(v, locale));
      });
    } else {
      reviews = [];
    }
    if (json['menuDetail'] != null) {
      menuDetail = <DiningMenuConfigModel>[];
      json['menuDetail'].forEach((v) {
        menuDetail!.add(DiningMenuConfigModel.fromJson(v, locale));
      });
    } else {
      menuDetail = [];
    }
    diningPhotos = json['diningPhotos'].cast<String>();
    findMode = json['findMode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (bestFoods != null) {
      data['bestFoods'] = bestFoods!.map((v) => v.toJson()).toList();
    }
    if (orderCoupons != null) {
      data['orderCoupons'] = orderCoupons!.map((v) => v.toJson()).toList();
    }
    if (diningCoupons != null) {
      data['diningCoupons'] = diningCoupons!.map((v) => v.toJson()).toList();
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    if (menuDetail != null) {
      data['menuDetail'] = menuDetail!.map((v) => v.toJson()).toList();
    }
    data['diningPhotos'] = diningPhotos;
    data['findMode'] = findMode;
    data['success'] = success;
    return data;
  }
}

class RestaurantDetailConfigModel {
  String? name;
  String? address;
  String? shortDescription;
  List<CuisineModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<RestaurantTranslations>? translations;
  List<SlotsModel>? slots;
  bool? isOutlet;
  String? outletManagerId;
  LicenseModel? license;
  String? licenseId;
  bool? status;
  String? slug;
  bool? temporaryClosed;
  String? distance;
  List<RestaurantTypeConfigModel>? restauranttypes;
  List<RestaurantFacilitiesConfigModel>? restaurantfacilities;
  List<DiningCategoriesConfigModel>? diningcategories;
  int? estimatedDeliveryTime;
  bool? isFavourite;
  bool? isHidden;
  String? id;
  double? dishPriceForTwo;
  String? rating;
  String? totalRating;
  bool? tiffinSubscription;
  bool? preBooking;
  String? cuisineName;
  String? restaurantTypeName;
  String? createdAt;
  OwerInfoConfigModel? owerInfo;
  LocationCoordinates? location;
  String? socialFacebook;
  String? socialInstagram;
  String? socialX;
  String? socialYoutube;
  String? socialLinkedIn;
  String? socialPinterest;
  final String locale;
  RestaurantDetailConfigModel({
    this.name,
    this.address,
    this.shortDescription,
    this.cuisine,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.translations,
    this.slots,
    this.isOutlet,
    this.outletManagerId,
    this.rating,
    this.license,
    this.licenseId,
    this.status,
    this.slug,
    this.temporaryClosed,
    this.distance,
    this.restauranttypes,
    this.restaurantfacilities,
    this.diningcategories,
    this.estimatedDeliveryTime,
    this.isFavourite,
    this.isHidden,
    this.id,
    this.dishPriceForTwo,
    this.totalRating,
    this.tiffinSubscription,
    this.preBooking,
    this.cuisineName,
    this.restaurantTypeName,
    this.createdAt,
    this.owerInfo,
    this.location,
    this.socialFacebook,
    this.socialInstagram,
    this.socialX,
    this.socialYoutube,
    this.socialLinkedIn,
    this.socialPinterest,
    required this.locale,
  });

  RestaurantDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    shortDescription = json['shortDescription'];
    if (json['cuisine'] != null) {
      cuisine = <CuisineModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(CuisineModel.fromJson(v, locale));
        CuisineModel cuisineData = CuisineModel.fromJson(v, locale);
        if (locale.isNotEmpty && cuisineData.name!.isNotEmpty && cuisineData.translations!.isNotEmpty) {
          final int localeIndex = cuisineData.translations!.indexWhere((tLocale) => tLocale.code! == locale);
          if (localeIndex != -1) {
            if (cuisineData.translations![localeIndex].value!.isNotEmpty) {
              names.add(cuisineData.translations![localeIndex].value!);
            }
          } else {
            names.add(cuisineData.name!);
          }
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
          if (translations![localeIndex].shortDescription!.isNotEmpty) {
            shortDescription = translations![localeIndex].shortDescription!;
          }
          if (translations![localeIndex].address!.isNotEmpty) {
            address = translations![localeIndex].address!;
          }
        }
      }
    } else {
      translations = [];
    }
    if (json['slots'] != null) {
      slots = <SlotsModel>[];
      json['slots'].forEach((v) {
        slots!.add(SlotsModel.fromJson(v));
      });
    } else {
      slots = [];
    }
    isOutlet = json['isOutlet'];
    outletManagerId = json['outletManagerId'];
    license = json['license'] != null ? LicenseModel.fromJson(json['license'], locale) : null;
    licenseId = json['licenseId'];
    status = json['status'];
    slug = json['slug'];
    temporaryClosed = json['temporaryClosed'];
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString()).toStringAsFixed(1);
    } else {
      distance = '0.0';
    }
    if (json['restauranttypes'] != null) {
      restauranttypes = <RestaurantTypeConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['restauranttypes'].forEach((v) {
        restauranttypes!.add(RestaurantTypeConfigModel.fromJson(v, locale));
        RestaurantTypeConfigModel restauranttypesData = RestaurantTypeConfigModel.fromJson(v, locale);
        if (locale.isNotEmpty && restauranttypesData.name!.isNotEmpty && restauranttypesData.translations!.isNotEmpty) {
          final int localeIndex = restauranttypesData.translations!.indexWhere((tLocale) => tLocale.code! == locale);
          if (localeIndex != -1) {
            if (restauranttypesData.translations![localeIndex].value!.isNotEmpty) {
              names.add(restauranttypesData.translations![localeIndex].value!);
            }
          } else {
            names.add(restauranttypesData.name!);
          }
        }
      });
      restaurantTypeName = names.join(' • ');
    } else {
      restauranttypes = [];
      restaurantTypeName = '';
    }
    if (json['restaurantfacilities'] != null) {
      restaurantfacilities = <RestaurantFacilitiesConfigModel>[];
      json['restaurantfacilities'].forEach((v) {
        restaurantfacilities!.add(RestaurantFacilitiesConfigModel.fromJson(v, locale));
      });
    } else {
      restaurantfacilities = [];
    }
    if (json['diningcategories'] != null) {
      diningcategories = <DiningCategoriesConfigModel>[];
      json['diningcategories'].forEach((v) {
        diningcategories!.add(DiningCategoriesConfigModel.fromJson(v, locale));
      });
    } else {
      diningcategories = [];
    }
    if (json['estimatedDeliveryTime'] != null && json['estimatedDeliveryTime'] != '') {
      estimatedDeliveryTime = int.parse(json['estimatedDeliveryTime'].toString());
    } else {
      estimatedDeliveryTime = 10;
    }
    isFavourite = json['isFavourite'];
    isHidden = json['isHidden'];
    id = json['id'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString()).toStringAsFixed(1);
    } else {
      rating = '0.0';
    }
    if (json['totalRating'] != null && json['totalRating'] != '') {
      int ratingCount = int.parse(json['totalRating'].toString());
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

      totalRating = formatNumber(ratingCount);
    } else {
      totalRating = '0';
    }
    tiffinSubscription = json['tiffinSubscription'];
    preBooking = json['preBooking'];
    if (json['createdAt'] != null && json['createdAt'] != '') {
      DateTime dateTime = DateTime.parse(json['createdAt'].toString());
      String year = DateFormat('yyyy', locale).format(dateTime);
      createdAt = year;
    } else {
      createdAt = DateTime.now().year.toString();
    }
    owerInfo = json['owerInfo'] != null ? OwerInfoConfigModel.fromJson(json['owerInfo']) : null;
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    if (json['socialFacebook'] != null && json['socialFacebook'] != '') {
      socialFacebook = json['socialFacebook'];
    } else {
      socialFacebook = '';
    }
    if (json['socialInstagram'] != null && json['socialInstagram'] != '') {
      socialInstagram = json['socialInstagram'];
    } else {
      socialInstagram = '';
    }
    if (json['socialX'] != null && json['socialX'] != '') {
      socialX = json['socialX'];
    } else {
      socialX = '';
    }
    if (json['socialYoutube'] != null && json['socialYoutube'] != '') {
      socialYoutube = json['socialYoutube'];
    } else {
      socialYoutube = '';
    }
    if (json['socialLinkedIn'] != null && json['socialLinkedIn'] != '') {
      socialLinkedIn = json['socialLinkedIn'];
    } else {
      socialLinkedIn = '';
    }
    if (json['socialPinterest'] != null && json['socialPinterest'] != '') {
      socialPinterest = json['socialPinterest'];
    } else {
      socialPinterest = '';
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
    data['approxDeliveryTime'] = approxDeliveryTime;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    data['isOutlet'] = isOutlet;
    data['outletManagerId'] = outletManagerId;
    data['rating'] = rating;
    if (license != null) {
      data['license'] = license!.toJson();
    }
    data['licenseId'] = licenseId;
    data['status'] = status;
    data['slug'] = slug;
    data['temporaryClosed'] = temporaryClosed;
    data['distance'] = distance;
    if (restauranttypes != null) {
      data['restauranttypes'] = restauranttypes!.map((v) => v.toJson()).toList();
    }
    if (restaurantfacilities != null) {
      data['restaurantfacilities'] = restaurantfacilities!.map((v) => v.toJson()).toList();
    }
    if (diningcategories != null) {
      data['diningcategories'] = diningcategories!.map((v) => v.toJson()).toList();
    }
    data['estimatedDeliveryTime'] = estimatedDeliveryTime;
    data['isFavourite'] = isFavourite;
    data['isHidden'] = isHidden;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['totalRating'] = totalRating;
    data['tiffinSubscription'] = tiffinSubscription;
    data['preBooking'] = preBooking;
    data['createdAt'] = createdAt;
    if (owerInfo != null) {
      data['owerInfo'] = owerInfo!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['socialFacebook'] = socialFacebook;
    data['socialInstagram'] = socialInstagram;
    data['socialX'] = socialX;
    data['socialYoutube'] = socialYoutube;
    data['socialLinkedIn'] = socialLinkedIn;
    data['socialPinterest'] = socialPinterest;
    return data;
  }
}

class LocationCoordinates {
  String? type;
  List<double>? coordinates;

  LocationCoordinates({this.type, this.coordinates});

  LocationCoordinates.fromJson(Map<String, dynamic> json) {
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

class RestaurantTypeConfigModel {
  String? name;
  String? image;
  List<RestaurantTypeTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  RestaurantTypeConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  RestaurantTypeConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <RestaurantTypeTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantTypeTranslations.fromJson(v));
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

class RestaurantTypeTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  RestaurantTypeTranslations({this.name, this.code, this.nativeName, this.value});

  RestaurantTypeTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;
  String? address;

  RestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription, this.address});

  RestaurantTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    shortDescription = json['shortDescription'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['shortDescription'] = shortDescription;
    data['address'] = address;
    return data;
  }
}

class SlotsModel {
  int? day;
  bool? isShowMore;
  List<TimesModel>? times;

  SlotsModel({this.day, this.isShowMore, this.times});

  SlotsModel.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    isShowMore = false;
    if (json['times'] != null) {
      times = <TimesModel>[];
      json['times'].forEach((v) {
        times!.add(TimesModel.fromJson(v));
      });
    } else {
      times = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['isShowMore'] = isShowMore;
    if (times != null) {
      data['times'] = times!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TimesModel {
  String? start;
  String? end;

  TimesModel({this.start, this.end});

  TimesModel.fromJson(Map<String, dynamic> json) {
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

class LicenseModel {
  String? id;
  String? name;
  String? image;
  String? website;
  List<LicenseTranslations>? translations;
  final String locale;
  LicenseModel({this.id, this.name, this.image, this.website, this.translations, required this.locale});

  LicenseModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    website = json['website'];
    if (json['translations'] != null) {
      translations = <LicenseTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(LicenseTranslations.fromJson(v));
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
    data['name'] = name;
    data['image'] = image;
    data['website'] = website;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LicenseTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  LicenseTranslations({this.name, this.code, this.nativeName, this.value});

  LicenseTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantFacilitiesConfigModel {
  String? name;
  List<FacilitiesTranslations>? translations;
  String? id;
  final String locale;
  RestaurantFacilitiesConfigModel({this.name, this.translations, this.id, required this.locale});

  RestaurantFacilitiesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <FacilitiesTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(FacilitiesTranslations.fromJson(v));
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

class FacilitiesTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  FacilitiesTranslations({this.name, this.code, this.nativeName, this.value});

  FacilitiesTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningCategoriesConfigModel {
  String? name;
  String? image;
  List<DiningCategoryTranslations>? translations;
  String? id;
  final String locale;
  DiningCategoriesConfigModel({this.name, this.image, this.translations, this.id, required this.locale});

  DiningCategoriesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningCategoryTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCategoryTranslations.fromJson(v));
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
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class DiningCategoryTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningCategoryTranslations({this.name, this.code, this.nativeName, this.value});

  DiningCategoryTranslations.fromJson(Map<String, dynamic> json) {
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

class BestSellingFoodConfigModel {
  String? name;
  List<BestSellingFoodTranslations>? translations;
  String? id;
  final String locale;
  BestSellingFoodConfigModel({this.name, this.translations, this.id, required this.locale});

  BestSellingFoodConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <BestSellingFoodTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(BestSellingFoodTranslations.fromJson(v));
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

class BestSellingFoodTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  BestSellingFoodTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  BestSellingFoodTranslations.fromJson(Map<String, dynamic> json) {
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

class OrderCouponsConfigModel {
  String? name;
  String? couponType;
  bool? allRestaurants;
  List<String>? restaurant;
  bool? allUsers;
  List<String>? user;
  String? code;
  String? discountType;
  List<OrderCouponTranslations>? translations;
  String? id;
  int? limitSameUser;
  double? loyalityPoints;
  double? maxDiscount;
  double? minCartTotal;
  double? minDiscount;
  String? promoLbl;
  final String locale;
  OrderCouponsConfigModel({
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
    this.promoLbl,
    required this.locale,
  });

  OrderCouponsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    couponType = json['couponType'];
    allRestaurants = json['allRestaurants'];
    restaurant = json['restaurant'].cast<String>();
    allUsers = json['allUsers'];
    user = json['user'].cast<String>();
    code = json['code'];
    discountType = json['discountType'];
    if (json['translations'] != null) {
      translations = <OrderCouponTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(OrderCouponTranslations.fromJson(v));
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
    limitSameUser = json['limitSameUser'];
    if (json['loyalityPoints'] != null && json['loyalityPoints'] != '') {
      loyalityPoints = double.parse(json['loyalityPoints'].toString());
    } else {
      loyalityPoints = 0.0;
    }
    if (json['maxDiscount'] != null && json['maxDiscount'] != '') {
      maxDiscount = double.parse(json['maxDiscount'].toString());
    } else {
      maxDiscount = 0.0;
    }
    if (json['minCartTotal'] != null && json['minCartTotal'] != '') {
      minCartTotal = double.parse(json['minCartTotal'].toString());
    } else {
      minCartTotal = 0.0;
    }
    if (json['minDiscount'] != null && json['minDiscount'] != '') {
      minDiscount = double.parse(json['minDiscount'].toString());
    } else {
      minDiscount = 0.0;
    }

    if (json['promoLbl'] != null && json['promoLbl'] != '') {
      promoLbl = json['promoLbl'];
    } else {
      promoLbl = '';
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
    return data;
  }
}

class OrderCouponTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  OrderCouponTranslations({this.name, this.code, this.nativeName, this.value});

  OrderCouponTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningCouponConfigModel {
  String? name;
  bool? allRestaurants;
  List<String>? restaurant;
  bool? allUsers;
  List<String>? user;
  String? code;
  String? discountType;
  String? availability;
  bool? preBookingChargeRequired;
  List<DiningCouponTranslations>? translations;
  String? id;
  double? preBookingChargeAmount;
  int? limitSameUser;
  double? maxDiscount;
  double? minDiscount;
  String? promoLbl;
  final String locale;
  DiningCouponConfigModel({
    this.name,
    this.allRestaurants,
    this.restaurant,
    this.allUsers,
    this.user,
    this.code,
    this.discountType,
    this.availability,
    this.preBookingChargeRequired,
    this.translations,
    this.id,
    this.preBookingChargeAmount,
    this.limitSameUser,
    this.maxDiscount,
    this.minDiscount,
    this.promoLbl,
    required this.locale,
  });

  DiningCouponConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    allRestaurants = json['allRestaurants'];
    restaurant = json['restaurant'].cast<String>();
    allUsers = json['allUsers'];
    user = json['user'].cast<String>();
    code = json['code'];
    discountType = json['discountType'];
    availability = json['availability'];
    preBookingChargeRequired = json['preBookingChargeRequired'];
    if (json['translations'] != null) {
      translations = <DiningCouponTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCouponTranslations.fromJson(v));
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
    if (json['maxDiscount'] != null && json['maxDiscount'] != '') {
      maxDiscount = double.parse(json['maxDiscount'].toString());
    } else {
      maxDiscount = 0.0;
    }
    if (json['preBookingChargeAmount'] != null && json['preBookingChargeAmount'] != '') {
      preBookingChargeAmount = double.parse(json['preBookingChargeAmount'].toString());
    } else {
      preBookingChargeAmount = 0.0;
    }
    if (json['minDiscount'] != null && json['minDiscount'] != '') {
      minDiscount = double.parse(json['minDiscount'].toString());
    } else {
      minDiscount = 0.0;
    }

    if (json['promoLbl'] != null && json['promoLbl'] != '') {
      promoLbl = json['promoLbl'];
    } else {
      promoLbl = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['allRestaurants'] = allRestaurants;
    data['restaurant'] = restaurant;
    data['allUsers'] = allUsers;
    data['user'] = user;
    data['code'] = code;
    data['discountType'] = discountType;
    data['availability'] = availability;
    data['preBookingChargeRequired'] = preBookingChargeRequired;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['preBookingChargeAmount'] = preBookingChargeAmount;
    data['limitSameUser'] = limitSameUser;
    data['maxDiscount'] = maxDiscount;
    data['minDiscount'] = minDiscount;
    data['promoLbl'] = promoLbl;
    return data;
  }
}

class DiningCouponTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningCouponTranslations({this.name, this.code, this.nativeName, this.value});

  DiningCouponTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningMenuConfigModel {
  String? name;
  List<MenuTranslations>? translations;
  List<String>? photos;
  final String locale;
  DiningMenuConfigModel({this.name, this.translations, this.photos, required this.locale});

  DiningMenuConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <MenuTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(MenuTranslations.fromJson(v));
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
    photos = json['photos'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['photos'] = photos;
    return data;
  }
}

class MenuTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  MenuTranslations({this.name, this.code, this.nativeName, this.value});

  MenuTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantReviewListConfigModel {
  int? ratingCount;
  List<String>? images;
  String? shortReview;
  String? createdAt;
  List<HashtagsConfigModel>? hashtags;
  String? id;
  UserInfoConfigModel? userInfo;
  final String locale;
  RestaurantReviewListConfigModel({this.ratingCount, this.images, this.shortReview, this.createdAt, this.hashtags, this.id, this.userInfo, required this.locale});

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
    return data;
  }
}

class HashtagsConfigModel {
  String? name;
  List<HashTagTranslations>? translations;
  String? id;
  final String locale;
  HashtagsConfigModel({this.name, this.translations, this.id, required this.locale});

  HashtagsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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

class OwerInfoConfigModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;
  String? countryCode;
  String? contactNumber;
  String? contactEmail;

  OwerInfoConfigModel({this.id, this.firstName, this.lastName, this.image, this.countryCode, this.contactNumber, this.contactEmail});

  OwerInfoConfigModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
    if (json['countryCode'] != null && json['countryCode'] != '') {
      countryCode = json['countryCode'].toString();
    } else {
      countryCode = '91';
    }
    contactNumber = json['contactNumber'];
    contactEmail = json['contactEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    data['countryCode'] = countryCode;
    data['contactNumber'] = contactNumber;
    data['contactEmail'] = contactEmail;
    return data;
  }
}

