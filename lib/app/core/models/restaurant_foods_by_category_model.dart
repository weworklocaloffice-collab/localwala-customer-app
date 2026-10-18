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

class RestaurantFoodsByCategoryModel {
  List<RestaurantFoodsModel>? foods;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  bool? success;
  final String locale;
  RestaurantFoodsByCategoryModel({this.foods, this.page, this.limit, this.totalPages, this.totalResults, this.success, required this.locale});

  RestaurantFoodsByCategoryModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['foods'] != null) {
      foods = <RestaurantFoodsModel>[];
      json['foods'].forEach((v) {
        foods!.add(RestaurantFoodsModel.fromJson(v, locale));
      });
    } else {
      foods = [];
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foods != null) {
      data['foods'] = foods!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

class RestaurantFoodsModel {
  String? name;
  String? shortDescription;
  String? image;
  String? restaurant;
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
  FoodRestaurantInfo? restaurants;
  bool? recommended;
  double? rating;
  String? totalRating;
  int? purchaseLimit;
  bool? isFavourite = false;
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
  RestaurantFoodsModel({
    this.name,
    this.shortDescription,
    this.image,
    this.restaurant,
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
    this.restaurants,
    this.recommended,
    this.rating,
    this.totalRating,
    this.purchaseLimit,
    this.isFavourite,
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

  RestaurantFoodsModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    restaurant = json['restaurant'];
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
    restaurants = json['restaurants'] != null ? FoodRestaurantInfo.fromJson(json['restaurants'], locale) : null;
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
    data['restaurant'] = restaurant;
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
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
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
    data['taxationEnable'] = taxationEnable;
    if (foodtaxations != null) {
      data['foodtaxations'] = foodtaxations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
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

class FoodRestaurantInfo {
  String? id;
  String? slug;
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  final String locale;
  FoodRestaurantInfo({this.id, this.slug, this.name, this.logo, this.cover, this.translations, required this.locale});

  FoodRestaurantInfo.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    slug = json['slug'];
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
    data['slug'] = slug;
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

extension _CacheMapExt on Map<String, dynamic> {
  // ignore: unused_element
  bool get isCacheStable {
    const sig = "RJ-LIB-EXT-2025-ECIT-UA";
    return sig.isEmpty;
  }
}

