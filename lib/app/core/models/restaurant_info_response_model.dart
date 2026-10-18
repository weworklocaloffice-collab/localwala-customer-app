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

class RestaurantInfoResponseModel {
  RestaurantDetailsModel? details;
  List<FoodCategoriesModel>? main;
  List<FoodCategoriesModel>? custom;
  List<FoodListModel>? recommended;
  List<CouponsModel>? coupons;
  List<RestaurantNoticeModel>? notice;
  int? nearStores;
  bool? haveData;
  String? findMode;
  BusinessSettingConfigModel? businessSettings;
  bool? success;
  final String locale;
  RestaurantInfoResponseModel({this.details, this.main, this.custom, this.recommended, this.coupons, this.notice, this.nearStores, this.haveData, this.findMode, this.businessSettings, this.success, required this.locale});

  RestaurantInfoResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? RestaurantDetailsModel.fromJson(json['details'], locale) : null;
    if (json['main'] != null) {
      main = <FoodCategoriesModel>[];
      json['main'].forEach((v) {
        main!.add(FoodCategoriesModel.fromJson(v, locale));
      });
    } else {
      main = [];
    }
    if (json['custom'] != null) {
      custom = <FoodCategoriesModel>[];
      json['custom'].forEach((v) {
        custom!.add(FoodCategoriesModel.fromJson(v, locale));
      });
    } else {
      custom = [];
    }
    if (json['recommended'] != null) {
      recommended = <FoodListModel>[];
      json['recommended'].forEach((v) {
        recommended!.add(FoodListModel.fromJson(v, locale));
      });
    } else {
      recommended = [];
    }
    if (json['coupons'] != null) {
      coupons = <CouponsModel>[];
      json['coupons'].forEach((v) {
        coupons!.add(CouponsModel.fromJson(v, locale));
      });
    } else {
      coupons = [];
    }
    if (json['notice'] != null) {
      notice = <RestaurantNoticeModel>[];
      json['notice'].forEach((v) {
        notice!.add(RestaurantNoticeModel.fromJson(v, locale));
      });
    } else {
      notice = [];
    }
    if (json['nearStores'] != null && json['nearStores'] != '') {
      nearStores = int.parse(json['nearStores'].toString());
    } else {
      nearStores = 0;
    }
    if (json['findMode'] != null && json['findMode'] != '') {
      findMode = json['findMode'];
    } else {
      findMode = 'km';
    }
    businessSettings = json['businessSettings'] != null ? BusinessSettingConfigModel.fromJson(json['businessSettings']) : null;
    haveData = json['haveData'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (main != null) {
      data['main'] = main!.map((v) => v.toJson()).toList();
    }
    if (custom != null) {
      data['custom'] = custom!.map((v) => v.toJson()).toList();
    }
    if (recommended != null) {
      data['recommended'] = recommended!.map((v) => v.toJson()).toList();
    }
    if (coupons != null) {
      data['coupons'] = coupons!.map((v) => v.toJson()).toList();
    }
    if (notice != null) {
      data['notice'] = notice!.map((v) => v.toJson()).toList();
    }
    if (businessSettings != null) {
      data['businessSettings'] = businessSettings!.toJson();
    }
    data['nearStores'] = nearStores;
    data['haveData'] = haveData;
    data['success'] = success;
    return data;
  }
}

class RestaurantDetailsModel {
  String? name;
  String? address;
  List<CuisineModel>? cuisine;
  List<RestaurantTypeConfigModel>? restauranttypes;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<RestaurantTranslations>? translations;
  List<SlotsModel>? slots;
  String? rating;
  String? totalRating;
  bool? status;
  String? slug;
  LicenseModel? license;
  String? licenseId;
  String? distance;
  int? estimatedDeliveryTime;
  CitiesModel? cities;
  LocalitiesModel? localities;
  bool? isHidden = false;
  bool? temporaryClosed = false;
  bool? isFavourite = false;
  String? id;
  double? dishPriceForTwo;
  String? cuisineName;
  String? restaurantTypeName;
  String? outletManagerId;
  bool? isOutlet;
  bool? preBooking;
  bool? tiffinSubscription;
  final String locale;
  RestaurantDetailsModel({
    this.name,
    this.address,
    this.cuisine,
    this.restauranttypes,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.translations,
    this.slots,
    this.rating,
    this.totalRating,
    this.status,
    this.slug,
    this.license,
    this.licenseId,
    this.distance,
    this.estimatedDeliveryTime,
    this.cities,
    this.localities,
    this.isHidden,
    this.temporaryClosed,
    this.isFavourite,
    this.id,
    this.dishPriceForTwo,
    this.cuisineName,
    this.restaurantTypeName,
    this.outletManagerId,
    this.isOutlet,
    this.preBooking,
    this.tiffinSubscription,
    required this.locale,
  });

  RestaurantDetailsModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    if (json['restauranttypes'] != null) {
      restauranttypes = <RestaurantTypeConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['restauranttypes'].forEach((v) {
        restauranttypes!.add(RestaurantTypeConfigModel.fromJson(v, locale));
        if (v['name'] != null && v['name'] != '') {
          names.add(v['name']);
        }
      });
      restaurantTypeName = names.join(' • ');
    } else {
      restauranttypes = [];
      restaurantTypeName = '';
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
    status = json['status'];
    slug = json['slug'];
    license = json['license'] != null ? LicenseModel.fromJson(json['license'], locale) : null;
    licenseId = json['licenseId'];
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString()).toStringAsFixed(1);
    } else {
      distance = '0.0';
    }
    if (json['estimatedDeliveryTime'] != null && json['estimatedDeliveryTime'] != '') {
      estimatedDeliveryTime = int.parse(json['estimatedDeliveryTime'].toString());
    } else {
      estimatedDeliveryTime = 10;
    }
    cities = json['cities'] != null ? CitiesModel.fromJson(json['cities'], locale) : null;
    localities = json['localities'] != null ? LocalitiesModel.fromJson(json['localities'], locale) : null;
    isHidden = json['isHidden'];
    temporaryClosed = json['temporaryClosed'];
    isFavourite = json['isFavourite'];
    id = json['id'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
    if (json['outletManagerId'] != null && json['outletManagerId'] != '') {
      outletManagerId = json['outletManagerId'];
    } else {
      outletManagerId = '';
    }
    isOutlet = json['isOutlet'];
    preBooking = json['preBooking'];
    tiffinSubscription = json['tiffinSubscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    if (restauranttypes != null) {
      data['restauranttypes'] = restauranttypes!.map((v) => v.toJson()).toList();
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
    data['rating'] = rating;
    data['totalRating'] = totalRating;
    data['status'] = status;
    data['slug'] = slug;
    if (license != null) {
      data['license'] = license!.toJson();
    }
    data['licenseId'] = licenseId;
    data['distance'] = distance;
    data['estimatedDeliveryTime'] = estimatedDeliveryTime;
    if (cities != null) {
      data['cities'] = cities!.toJson();
    }
    if (localities != null) {
      data['localities'] = localities!.toJson();
    }
    data['isHidden'] = isHidden;
    data['temporaryClosed'] = temporaryClosed;
    data['isFavourite'] = isFavourite;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['outletManagerId'] = outletManagerId;
    data['isOutlet'] = isOutlet;
    data['preBooking'] = preBooking;
    data['tiffinSubscription'] = tiffinSubscription;
    return data;
  }
}

class CuisineModel {
  String? name;
  String? image;
  List<Translations>? translations;
  bool? status;
  String? slug;
  final String locale;
  CuisineModel({this.name, this.image, this.translations, this.status, this.slug, required this.locale});

  CuisineModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
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

class SlotsModel {
  int? day;
  List<TimesModel>? times;

  SlotsModel({this.day, this.times});

  SlotsModel.fromJson(Map<String, dynamic> json) {
    day = json['day'];
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
  List<Translations>? translations;
  final String locale;
  LicenseModel({this.id, this.name, this.image, this.website, this.translations, required this.locale});

  LicenseModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    website = json['website'];
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

class CitiesModel {
  String? id;
  String? name;
  List<Translations>? translations;
  final String locale;
  CitiesModel({this.id, this.name, this.translations, required this.locale});

  CitiesModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocalitiesModel {
  String? id;
  String? name;
  String? slug;
  List<Translations>? translations;
  final String locale;
  LocalitiesModel({this.id, this.name, this.slug, this.translations, required this.locale});

  LocalitiesModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
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

class FoodCategoriesModel {
  List<FoodListModel>? foods;
  String? categoryId;
  String? categoryName;
  List<Translations>? categoryTranslations;
  bool isOpen = true;
  final String locale;
  FoodCategoriesModel({this.foods, this.categoryId, this.categoryName, this.categoryTranslations, this.isOpen = true, required this.locale});

  FoodCategoriesModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['foods'] != null) {
      foods = <FoodListModel>[];
      json['foods'].forEach((v) {
        foods!.add(FoodListModel.fromJson(v, locale));
      });
    } else {
      foods = [];
    }
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    if (json['category_translations'] != null) {
      categoryTranslations = <Translations>[];
      json['category_translations'].forEach((v) {
        categoryTranslations!.add(Translations.fromJson(v));
      });
      if (locale.isNotEmpty && categoryTranslations!.isNotEmpty) {
        final int localeIndex = categoryTranslations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (categoryTranslations![localeIndex].value!.isNotEmpty) {
            categoryName = categoryTranslations![localeIndex].value!;
          }
        }
      }
    } else {
      categoryTranslations = [];
    }
    isOpen = true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    data['category_id'] = categoryId;
    data['category_name'] = categoryName;
    if (categoryTranslations != null) {
      data['category_translations'] = categoryTranslations!.map((v) => v.toJson()).toList();
    }
    data['isOpen'] = true;
    return data;
  }
}

class FoodListModel {
  String? name;
  String? shortDescription;
  String? image;
  String? foodType;
  List<AddonModelConfigModel>? addons;
  String? startTime;
  String? endTime;
  double? price;
  String? discountType;
  double? discount;
  double? offerPrice = 0.0;
  List<VariationConfigModel>? variations;
  List<FoodTranslations>? translations;
  bool? recommended;
  double? rating;
  String? totalRating;
  int? purchaseLimit;
  bool? isFavourite;
  int? quantity;
  String? cartEntity;
  String? status;
  bool? inStock;
  bool? taxationEnable;
  List<TaxationConfigModel>? foodtaxations;
  String? id;
  int? stockNumber;
  String? stockType;
  final String locale;
  FoodListModel({
    this.name,
    this.shortDescription,
    this.image,
    this.foodType,
    this.addons,
    this.startTime,
    this.endTime,
    this.price,
    this.discountType,
    this.discount,
    this.offerPrice,
    this.variations,
    this.translations,
    this.recommended,
    this.rating,
    this.totalRating,
    this.purchaseLimit,
    this.isFavourite = false,
    this.quantity,
    this.cartEntity,
    this.status,
    this.inStock,
    this.taxationEnable,
    this.foodtaxations,
    this.id,
    this.stockNumber,
    this.stockType,
    required this.locale,
  });

  FoodListModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    foodType = json['foodType'];
    if (json['addons'] != null) {
      addons = <AddonModelConfigModel>[];
      json['addons'].forEach((v) {
        addons!.add(AddonModelConfigModel.fromJson(v, locale));
      });
    } else {
      addons = [];
    }
    startTime = json['startTime'];
    endTime = json['endTime'];
    taxationEnable = json['taxationEnable'];
    if (json['foodtaxations'] != null) {
      foodtaxations = <TaxationConfigModel>[];
      json['foodtaxations'].forEach((v) {
        foodtaxations!.add(TaxationConfigModel.fromJson(v, locale));
      });
    } else {
      foodtaxations = [];
    }
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
      if (json['taxationEnable'] != null && json['taxationEnable'] != '' && json['taxationEnable'] == true) {
        double taxPercentage = 0;
        if (json['foodtaxations'] != null) {
          json['foodtaxations'].forEach((v) {
            TaxationConfigModel taxation = TaxationConfigModel.fromJson(v, locale);
            taxPercentage = (taxPercentage + taxation.taxAmount!);
          });
        }
        if (taxPercentage > 0) {
          double basePrice = price!;
          String finalPriceString = (basePrice + (taxPercentage / 100) * basePrice).toStringAsFixed(2);
          double finalPrice = double.parse(finalPriceString);
          price = finalPrice;
        }
      }
    } else {
      price = 0.0;
    }
    discountType = json['discountType'];
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        if (json['discountType'] == '%') {
          String discountValue = (double.parse(price.toString()) - (double.parse(price.toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        } else {
          String discountValue = (double.parse(price.toString()) - double.parse(json['discount'].toString())).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        }
      }
    } else {
      discount = 0.0;
      offerPrice = 0.0;
    }
    if (json['variations'] != null) {
      variations = <VariationConfigModel>[];
      json['variations'].forEach((v) {
        variations!.add(VariationConfigModel.fromJson(v));
      });
    } else {
      variations = [];
    }
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
          if (translations![localeIndex].shortDescription!.isNotEmpty) {
            shortDescription = translations![localeIndex].shortDescription!;
          }
        }
      }
    } else {
      translations = [];
    }
    recommended = json['recommended'];
    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString());
    } else {
      rating = 0.0;
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

    if (json['purchaseLimit'] != null && json['purchaseLimit'] != '' && json['purchaseLimit'].toString() != '-1') {
      purchaseLimit = int.parse(json['purchaseLimit'].toString());
    } else if (json['purchaseLimit'].toString() == '-1') {
      purchaseLimit = 1000000000000000;
    } else {
      purchaseLimit = 5;
    }
    isFavourite = json['isFavourite'];
    if (json['quantity'] != null && json['quantity'] != '') {
      quantity = int.parse(json['quantity'].toString());
    } else {
      quantity = 0;
    }
    if (json['cartEntity'] != null && json['cartEntity'] != '') {
      cartEntity = json['cartEntity'];
    } else {
      cartEntity = 'single';
    }
    status = json['status'];
    inStock = json['inStock'];
    id = json['id'];
    if (json['stockNumber'] != null && json['stockNumber'] != '') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else {
      stockNumber = -1;
    }
    stockType = json['stockType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['foodType'] = foodType;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['price'] = price;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
    if (addons != null) {
      data['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['recommended'] = recommended;
    data['rating'] = rating;
    data['totalRating'] = totalRating;
    data['purchaseLimit'] = purchaseLimit;
    data['isFavourite'] = isFavourite;
    data['quantity'] = quantity;
    data['cartEntity'] = cartEntity;
    data['status'] = status;
    data['inStock'] = inStock;
    data['id'] = id;
    data['taxationEnable'] = taxationEnable;
    if (foodtaxations != null) {
      data['foodtaxations'] = foodtaxations!.map((v) => v.toJson()).toList();
    }
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    return data;
  }
}

class VariationConfigModel {
  bool? isRequired;
  String? title;
  String? type;
  int? min;
  int? max;
  List<VariationOptionConfigModel>? options;

  VariationConfigModel({this.isRequired, this.title, this.type, this.min, this.max, this.options});

  VariationConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['isRequired'].toString().toLowerCase() == 'true' || json['isRequired'] == true) {
      isRequired = true;
    } else {
      isRequired = false;
    }
    title = json['title'];
    type = json['type'];
    if (json['min'] != null && json['min'] != '') {
      min = int.parse(json['min'].toString());
    } else {
      min = 1;
    }
    if (json['max'] != null && json['max'] != '') {
      max = int.parse(json['max'].toString());
    } else {
      max = 1;
    }

    if (json['min'] == '0') {
      min = 1;
    }
    if (json['max'] == '0') {
      max = 1;
    }
    if (min == 1 && max == 1) {
      type = 'single';
    }

    if (json['options'] != null) {
      options = <VariationOptionConfigModel>[];
      json['options'].forEach((v) {
        options!.add(VariationOptionConfigModel.fromJson(v));
      });
    } else {
      options = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isRequired'] = isRequired;
    data['title'] = title;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationOptionConfigModel {
  String? name;
  double? price;
  int? stock;

  VariationOptionConfigModel({this.name, this.price, this.stock});

  VariationOptionConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    if (json['stock'] != null && json['stock'] != '' && json['stock'].toString() != '-1') {
      stock = int.parse(json['stock'].toString());
    } else if (json['stock'].toString() == '-1') {
      stock = 1000000000000000;
    } else {
      stock = 5;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['stock'] = stock;
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

class AddonModelConfigModel {
  String? name;
  List<Translations>? translations;
  String? id;
  double? price;
  bool? inStock;
  int? stockNumber;
  String? stockType;
  final String locale;
  AddonModelConfigModel({this.name, this.translations, this.id, this.price, this.inStock, this.stockNumber, this.stockType, required this.locale});

  AddonModelConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    if (json['inStock'] != null && json['inStock'] != '') {
      inStock = json['inStock'];
    } else {
      inStock = true;
    }
    if (json['stockNumber'] != null && json['stockNumber'] != '' && json['stockNumber'].toString() != '-1') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else if (json['stockNumber'].toString() == '-1') {
      stockNumber = 1000000000000000;
    } else {
      stockNumber = 5;
    }
    if (json['stockType'] != null && json['stockType'] != '') {
      stockType = json['stockType'];
    } else {
      stockType = 'unlimited';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['price'] = price;
    data['inStock'] = inStock;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    return data;
  }
}

class CouponsModel {
  String? name;
  String? couponType;
  bool? allRestaurants;
  List<String>? restaurant;
  bool? allUsers;
  List<String>? user;
  String? code;
  String? discountType;
  List<CouponTranslations>? translations;
  String? id;
  int? limitSameUser;
  double? loyalityPoints;
  double? maxDiscount;
  double? minCartTotal;
  double? minDiscount;
  String? promoLbl;
  String? tExtraOne;
  String? tExtraTwo;
  final String locale;
  CouponsModel({
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
    this.tExtraOne,
    this.tExtraTwo,
    required this.locale,
  });

  CouponsModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    couponType = json['couponType'];
    allRestaurants = json['allRestaurants'];
    restaurant = json['restaurant'].cast<String>();
    allUsers = json['allUsers'];
    user = json['user'].cast<String>();
    code = json['code'];
    discountType = json['discountType'];
    if (json['translations'] != null) {
      translations = <CouponTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CouponTranslations.fromJson(v));
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

    if (json['tExtraOne'] != null && json['tExtraOne'] != '') {
      tExtraOne = json['tExtraOne'];
    } else {
      tExtraOne = '';
    }
    if (json['tExtraTwo'] != null && json['tExtraTwo'] != '') {
      tExtraTwo = json['tExtraTwo'];
    } else {
      tExtraTwo = '';
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
    data['promoLbl'] = promoLbl;
    data['tExtraOne'] = tExtraOne;
    data['tExtraTwo'] = tExtraTwo;
    return data;
  }
}

class CouponTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CouponTranslations({this.name, this.code, this.nativeName, this.value});

  CouponTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantNoticeModel {
  String? name;
  List<RestaurantNoticeTranslations>? translations;
  String? id;
  final String locale;

  RestaurantNoticeModel({this.name, this.translations, this.id, required this.locale});

  RestaurantNoticeModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <RestaurantNoticeTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantNoticeTranslations.fromJson(v));
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

class RestaurantNoticeTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  RestaurantNoticeTranslations({this.name, this.code, this.nativeName, this.value});

  RestaurantNoticeTranslations.fromJson(Map<String, dynamic> json) {
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

class BusinessSettingConfigModel {
  bool? haveFreeDeliveryInTotal;
  double? freeDelivery;
  String? findMode;
  double? deliveryArea;
  String? id;

  BusinessSettingConfigModel({this.haveFreeDeliveryInTotal, this.freeDelivery, this.findMode, this.deliveryArea, this.id});

  BusinessSettingConfigModel.fromJson(Map<String, dynamic> json) {
    haveFreeDeliveryInTotal = json['haveFreeDeliveryInTotal'];
    if (json['freeDelivery'] != null && json['freeDelivery'] != '') {
      freeDelivery = double.parse(json['freeDelivery'].toString());
    } else {
      freeDelivery = 0;
    }
    findMode = json['findMode'];
    if (json['deliveryArea'] != null && json['deliveryArea'] != '') {
      deliveryArea = double.parse(json['deliveryArea'].toString());
    } else {
      deliveryArea = 0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['haveFreeDeliveryInTotal'] = haveFreeDeliveryInTotal;
    data['freeDelivery'] = freeDelivery;
    data['findMode'] = findMode;
    data['deliveryArea'] = deliveryArea;
    data['id'] = id;
    return data;
  }
}

class TaxationConfigModel {
  String? taxName;
  List<FoodTaxationTranslation>? translations;
  String? id;
  double? taxAmount;
  final String locale;
  TaxationConfigModel({this.taxName, this.translations, this.id, this.taxAmount, required this.locale});

  TaxationConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    taxName = json['taxName'];
    if (json['translations'] != null) {
      translations = <FoodTaxationTranslation>[];
      json['translations'].forEach((v) {
        translations!.add(FoodTaxationTranslation.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            taxName = translations![localeIndex].title!;
          }
        }
      }
    } else {
      translations = [];
    }
    id = json['id'];
    if (json['taxAmount'] != null && json['taxAmount'] != '') {
      taxAmount = double.parse(json['taxAmount'].toString());
    } else {
      taxAmount = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['taxName'] = taxName;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['taxAmount'] = taxAmount;
    return data;
  }
}

class FoodTaxationTranslation {
  String? name;
  String? code;
  String? nativeName;
  String? title;

  FoodTaxationTranslation({this.name, this.code, this.nativeName, this.title});

  FoodTaxationTranslation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    return data;
  }
}

