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
import 'package:user/app/services/titlecase_string.dart';

class BuySubscriptionTiffinPackageResponseModel {
  SubscriptionTiffinPackageDetailModel? details;
  List<FoodInSubscriptionPackageInfoModel>? foods;
  List<PaymentConfigModel>? payments;
  PaymentConfigModel? primary;
  List<InstructionConfigModel>? instruction;
  OrderSettingConfigModel? orderSettings;
  BusinessConfigModel? businessSettings;
  PackagingConfigModel? restaurantSettings;
  String? findMode;
  final String locale;
  BuySubscriptionTiffinPackageResponseModel({this.details, this.foods, this.payments, this.primary, this.instruction, this.orderSettings, this.businessSettings, this.restaurantSettings, this.findMode, required this.locale});

  BuySubscriptionTiffinPackageResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? SubscriptionTiffinPackageDetailModel.fromJson(json['details'], locale) : null;
    if (json['foods'] != null) {
      foods = <FoodInSubscriptionPackageInfoModel>[];
      json['foods'].forEach((v) {
        foods!.add(FoodInSubscriptionPackageInfoModel.fromJson(v, locale));
      });
    } else {
      foods = [];
    }
    if (json['payments'] != null) {
      payments = <PaymentConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(PaymentConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    primary = json['primary'] != null ? PaymentConfigModel.fromJson(json['primary'], locale) : null;
    if (json['instruction'] != null) {
      instruction = <InstructionConfigModel>[];
      json['instruction'].forEach((v) {
        instruction!.add(InstructionConfigModel.fromJson(v, locale));
      });
    } else {
      instruction = [];
    }
    orderSettings = json['orderSettings'] != null ? OrderSettingConfigModel.fromJson(json['orderSettings']) : null;
    businessSettings = json['businessSettings'] != null ? BusinessConfigModel.fromJson(json['businessSettings']) : null;
    restaurantSettings = json['restaurantSettings'] != null ? PackagingConfigModel.fromJson(json['restaurantSettings'], locale) : null;
    findMode = json['findMode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
    if (instruction != null) {
      data['instruction'] = instruction!.map((v) => v.toJson()).toList();
    }
    if (orderSettings != null) {
      data['orderSettings'] = orderSettings!.toJson();
    }
    if (businessSettings != null) {
      data['businessSettings'] = businessSettings!.toJson();
    }
    if (restaurantSettings != null) {
      data['restaurantSettings'] = restaurantSettings!.toJson();
    }
    data['findMode'] = findMode;
    return data;
  }
}

class SubscriptionTiffinPackageDetailModel {
  String? name;
  String? shortDescription;
  String? image;
  List<String>? foods;
  String? interval;
  List<String>? offDays;
  String? offDayName;
  int? totalOrder;
  String? orderTo;
  double? deliveryArea;
  String? available;
  List<TimeSlotsConfigModel>? timeSlots;
  bool? canSelectAddon;
  bool? canSelectVariation;
  String? discountType;
  List<NoticeConfigModel>? notice;
  List<PackageTranslations>? translations;
  String? status;
  RestaurantsInfoConfigModel? restaurants;
  String? id;
  double? price;
  double? discount;
  double? offerPrice = 0.0;
  final String locale;
  SubscriptionTiffinPackageDetailModel({
    this.name,
    this.shortDescription,
    this.image,
    this.foods,
    this.interval,
    this.offDays,
    this.offDayName,
    this.totalOrder,
    this.orderTo,
    this.deliveryArea,
    this.available,
    this.timeSlots,
    this.canSelectAddon,
    this.canSelectVariation,
    this.discountType,
    this.notice,
    this.translations,
    this.status,
    this.restaurants,
    this.id,
    this.price,
    this.discount,
    this.offerPrice,
    required this.locale,
  });

  SubscriptionTiffinPackageDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    foods = json['foods'].cast<String>();
    interval = json['interval'];
    offDays = json['offDays'].cast<String>();
    if (json['offDays'] != null) {
      List<String> names = <String>[];
      names.clear();
      json['offDays'].forEach((v) {
        if (v != null && v != '') {
          names.add(v.toString().capitalize());
        }
      });
      offDayName = names.join(' • ');
    } else {
      offDays = [];
      offDayName = '';
    }
    totalOrder = json['totalOrder'];
    orderTo = json['orderTo'];
    if (json['deliveryArea'] != null && json['deliveryArea'] != '') {
      deliveryArea = double.parse(json['deliveryArea'].toString());
    } else {
      deliveryArea = 5.0;
    }
    available = json['available'];
    if (json['timeSlots'] != null) {
      timeSlots = <TimeSlotsConfigModel>[];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(TimeSlotsConfigModel.fromJson(v, locale));
      });
    } else {
      timeSlots = [];
    }
    canSelectAddon = json['canSelectAddon'];
    canSelectVariation = json['canSelectVariation'];
    discountType = json['discountType'];
    if (json['notice'] != null) {
      notice = <NoticeConfigModel>[];
      json['notice'].forEach((v) {
        notice!.add(NoticeConfigModel.fromJson(v, locale));
      });
    } else {
      notice = [];
    }
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
    status = json['status'];
    restaurants = json['restaurants'] != null ? RestaurantsInfoConfigModel.fromJson(json['restaurants'], locale) : null;
    id = json['id'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    discountType = json['discountType'];
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        if (json['discountType'] == '%') {
          String discountValue = (double.parse(json['price'].toString()) - (double.parse(json['price'].toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        } else {
          String discountValue = (double.parse(json['price'].toString()) - double.parse(json['discount'].toString())).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        }
      }
    } else {
      discount = 0.0;
      offerPrice = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['foods'] = foods;
    data['interval'] = interval;
    data['offDays'] = offDays;
    data['offDayName'] = offDayName;
    data['totalOrder'] = totalOrder;
    data['orderTo'] = orderTo;
    data['deliveryArea'] = deliveryArea;
    data['available'] = available;
    if (timeSlots != null) {
      data['timeSlots'] = timeSlots!.map((v) => v.toJson()).toList();
    }
    data['canSelectAddon'] = canSelectAddon;
    data['canSelectVariation'] = canSelectVariation;
    data['discountType'] = discountType;
    if (notice != null) {
      data['notice'] = notice!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    data['id'] = id;
    data['price'] = price;
    data['discount'] = discount;
    return data;
  }
}

class TimeSlotsConfigModel {
  String? startTime;
  String? endTime;
  String? displayStartTime;
  String? displayEndTime;
  final String locale;

  TimeSlotsConfigModel({this.startTime, this.endTime, this.displayStartTime, this.displayEndTime, required this.locale});

  TimeSlotsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    String convertTo12Hour(String time24, locale) {
      final date = DateFormat('HH:mm', locale).parse(time24);
      return DateFormat('hh:mm a', locale).format(date);
    }

    displayStartTime = convertTo12Hour(json['startTime'], locale);
    displayEndTime = convertTo12Hour(json['endTime'], locale);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['displayStartTime'] = displayStartTime;
    data['displayEndTime'] = displayEndTime;
    return data;
  }
}

class NoticeConfigModel {
  String? name;
  List<NoticeTranslations>? translations;
  final String locale;
  NoticeConfigModel({this.name, this.translations, required this.locale});

  NoticeConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <NoticeTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(NoticeTranslations.fromJson(v));
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
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NoticeTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  NoticeTranslations({this.name, this.code, this.nativeName, this.value});

  NoticeTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantsInfoConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantsInfoConfigModel({this.id, this.name, this.logo, this.cover, this.translations, required this.locale});

  RestaurantsInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
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

class FoodInSubscriptionPackageInfoModel {
  String? name;
  String? shortDescription;
  String? image;
  String? restaurant;
  List<AddonModelConfigModel>? addons;
  String? startTime;
  String? endTime;
  String? foodType;
  double? price;
  String? discountType;
  double? discount;
  double? offerPrice = 0.0;
  List<VariationConfigModel>? variations;
  List<FoodTranslations>? translations;
  FoodRestaurantInfo? restaurants;
  bool? recommended;
  int? purchaseLimit;
  bool? inStock;
  double? rating;
  String? totalRating;
  int? quantity;
  String? cartEntity;
  String? status;
  String? id;
  bool? taxationEnable;
  List<TaxationConfigModel>? foodtaxations;
  final String locale;
  FoodInSubscriptionPackageInfoModel({
    this.name,
    this.shortDescription,
    this.restaurant,
    this.restaurants,
    this.startTime,
    this.endTime,
    this.recommended,
    this.purchaseLimit,
    this.inStock,
    this.image,
    this.addons,
    this.foodType,
    this.price,
    this.discountType,
    this.discount,
    this.offerPrice,
    this.variations,
    this.translations,
    this.rating,
    this.totalRating,
    this.quantity,
    this.cartEntity,
    this.status,
    this.id,
    this.taxationEnable,
    this.foodtaxations,
    required this.locale,
  });

  FoodInSubscriptionPackageInfoModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    if (json['addons'] != null) {
      addons = <AddonModelConfigModel>[];
      json['addons'].forEach((v) {
        addons!.add(AddonModelConfigModel.fromJson(v, locale));
      });
    } else {
      addons = [];
    }
    restaurant = json['restaurant'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    restaurants = json['restaurants'] != null ? FoodRestaurantInfo.fromJson(json['restaurants'], locale) : null;
    recommended = json['recommended'];
    if (json['purchaseLimit'] != null && json['purchaseLimit'] != '' && json['purchaseLimit'].toString() != '-1') {
      purchaseLimit = int.parse(json['purchaseLimit'].toString());
    } else if (json['purchaseLimit'].toString() == '-1') {
      purchaseLimit = 1000000000000000;
    } else {
      purchaseLimit = 5;
    }
    inStock = json['inStock'];
    foodType = json['foodType'];
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
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['price'] = price;
    data['restaurant'] = restaurant;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    data['recommended'] = recommended;
    data['purchaseLimit'] = purchaseLimit;
    data['inStock'] = inStock;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
    if (addons != null) {
      data['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    data['foodType'] = foodType;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['totalRating'] = totalRating;
    data['quantity'] = quantity;
    data['cartEntity'] = cartEntity;
    data['status'] = status;
    data['id'] = id;
    data['taxationEnable'] = taxationEnable;
    if (foodtaxations != null) {
      data['foodtaxations'] = foodtaxations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FoodRestaurantInfo {
  String? id;
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  final String locale;
  FoodRestaurantInfo({this.id, this.name, this.logo, this.cover, this.translations, required this.locale});

  FoodRestaurantInfo.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddonModelConfigModel {
  String? name;
  List<AddonTranslations>? translations;
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
      translations = <AddonTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(AddonTranslations.fromJson(v));
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

class AddonTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  AddonTranslations({this.name, this.code, this.nativeName, this.value});

  AddonTranslations.fromJson(Map<String, dynamic> json) {
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

class PaymentConfigModel {
  String? name;
  String? slug;
  String? image;
  List<PaymentTranslations>? translations;
  bool? isDefault;
  String? id;
  final String locale;
  PaymentConfigModel({this.name, this.slug, this.image, this.translations, this.isDefault, this.id, required this.locale});

  PaymentConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <PaymentTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(PaymentTranslations.fromJson(v));
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
    isDefault = json['isDefault'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['isDefault'] = isDefault;
    data['id'] = id;
    return data;
  }
}

class PaymentTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  PaymentTranslations({this.name, this.code, this.nativeName, this.value});

  PaymentTranslations.fromJson(Map<String, dynamic> json) {
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

class InstructionConfigModel {
  String? name;
  String? image;
  List<InstructionTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  InstructionConfigModel({this.name, this.image, this.translations, this.status, this.id, required this.locale});

  InstructionConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <InstructionTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(InstructionTranslations.fromJson(v));
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
    data['id'] = id;
    return data;
  }
}

class InstructionTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  InstructionTranslations({this.name, this.code, this.nativeName, this.value});

  InstructionTranslations.fromJson(Map<String, dynamic> json) {
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

class OrderSettingConfigModel {
  bool? includeChargesForSubscription;
  String? id;

  OrderSettingConfigModel({this.includeChargesForSubscription, this.id});

  OrderSettingConfigModel.fromJson(Map<String, dynamic> json) {
    includeChargesForSubscription = json['includeChargesForSubscription'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['includeChargesForSubscription'] = includeChargesForSubscription;
    data['id'] = id;
    return data;
  }
}

class BusinessConfigModel {
  bool? haveFreeDeliveryInTotal;
  double? freeDelivery;
  bool? haveFreeDeliveryInDistance;
  double? freeDeliveryInDistance;
  bool? includeTaxOnFood;
  bool? additionalServiceCharge;
  String? additionalServiceName;
  double? additionalServiceAmount;
  bool? partialPayment;
  String? partialAmountPayment;
  String? findMode;
  double? deliveryArea;
  double? foodTaxAmount;
  String? foodTaxName;
  String? foodTaxType;
  double? deliveryChargeAmount;
  String? deliveryChargeMethod;
  String? id;

  BusinessConfigModel({
    this.haveFreeDeliveryInTotal,
    this.freeDelivery,
    this.haveFreeDeliveryInDistance,
    this.freeDeliveryInDistance,
    this.includeTaxOnFood,
    this.additionalServiceCharge,
    this.additionalServiceName,
    this.additionalServiceAmount,
    this.partialPayment,
    this.partialAmountPayment,
    this.findMode,
    this.deliveryArea,
    this.foodTaxAmount,
    this.foodTaxName,
    this.foodTaxType,
    this.deliveryChargeAmount,
    this.deliveryChargeMethod,
    this.id,
  });

  BusinessConfigModel.fromJson(Map<String, dynamic> json) {
    haveFreeDeliveryInTotal = json['haveFreeDeliveryInTotal'];
    if (json['freeDelivery'] != null && json['freeDelivery'] != '') {
      freeDelivery = double.parse(json['freeDelivery'].toString());
    } else {
      freeDelivery = 0.0;
    }
    haveFreeDeliveryInDistance = json['haveFreeDeliveryInDistance'];
    if (json['freeDeliveryInDistance'] != null && json['freeDeliveryInDistance'] != '') {
      freeDeliveryInDistance = double.parse(json['freeDeliveryInDistance'].toString());
    } else {
      freeDeliveryInDistance = 0.0;
    }
    includeTaxOnFood = json['includeTaxOnFood'];
    additionalServiceCharge = json['additionalServiceCharge'];
    additionalServiceName = json['additionalServiceName'];
    if (json['additionalServiceAmount'] != null && json['additionalServiceAmount'] != '') {
      additionalServiceAmount = double.parse(json['additionalServiceAmount'].toString());
    } else {
      additionalServiceAmount = 0.0;
    }
    partialPayment = json['partialPayment'];
    partialAmountPayment = json['partialAmountPayment'];
    findMode = json['findMode'];
    if (json['deliveryArea'] != null && json['deliveryArea'] != '') {
      deliveryArea = double.parse(json['deliveryArea'].toString());
    } else {
      deliveryArea = 0.0;
    }
    if (json['foodTaxAmount'] != null && json['foodTaxAmount'] != '') {
      foodTaxAmount = double.parse(json['foodTaxAmount'].toString());
    } else {
      foodTaxAmount = 0.0;
    }
    foodTaxName = json['foodTaxName'];
    foodTaxType = json['foodTaxType'];
    if (json['deliveryChargeAmount'] != null && json['deliveryChargeAmount'] != '') {
      deliveryChargeAmount = double.parse(json['deliveryChargeAmount'].toString());
    } else {
      deliveryChargeAmount = 0.0;
    }
    deliveryChargeMethod = json['deliveryChargeMethod'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['haveFreeDeliveryInTotal'] = haveFreeDeliveryInTotal;
    data['freeDelivery'] = freeDelivery;
    data['haveFreeDeliveryInDistance'] = haveFreeDeliveryInDistance;
    data['freeDeliveryInDistance'] = freeDeliveryInDistance;
    data['includeTaxOnFood'] = includeTaxOnFood;
    data['additionalServiceCharge'] = additionalServiceCharge;
    data['additionalServiceName'] = additionalServiceName;
    data['additionalServiceAmount'] = additionalServiceAmount;
    data['partialPayment'] = partialPayment;
    data['partialAmountPayment'] = partialAmountPayment;
    data['findMode'] = findMode;
    data['deliveryArea'] = deliveryArea;
    data['foodTaxAmount'] = foodTaxAmount;
    data['foodTaxName'] = foodTaxName;
    data['foodTaxType'] = foodTaxType;
    data['deliveryChargeAmount'] = deliveryChargeAmount;
    data['deliveryChargeMethod'] = deliveryChargeMethod;
    data['id'] = id;
    return data;
  }
}

class PackagingConfigModel {
  bool? havePackagingCharges;
  bool? includePackagesChargesInTax;
  double? packagingCharges;
  double? packagingChargesTax;
  String? id;
  final String locale;
  PackagingConfigModel({this.havePackagingCharges, this.includePackagesChargesInTax, this.packagingCharges, this.packagingChargesTax, this.id, required this.locale});

  PackagingConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    havePackagingCharges = json['havePackagingCharges'];
    includePackagesChargesInTax = json['includePackagesChargesInTax'];
    if (json['packagingCharges'] != null && json['packagingCharges'] != '') {
      packagingCharges = double.parse(json['packagingCharges'].toString());
    } else {
      packagingCharges = 0.0;
    }
    if (json['packagingChargesTax'] != null && json['packagingChargesTax'] != '') {
      packagingChargesTax = double.parse(json['packagingChargesTax'].toString());
    } else {
      packagingChargesTax = 0.0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['havePackagingCharges'] = havePackagingCharges;
    data['includePackagesChargesInTax'] = includePackagesChargesInTax;
    data['packagingCharges'] = packagingCharges;
    data['packagingChargesTax'] = packagingChargesTax;
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

