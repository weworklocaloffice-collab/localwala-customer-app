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

class CartSummaryModel {
  FoodRestaurantInfo? restaurantInfo;
  String? restId;
  List<FoodInCartSummaryModel>? summary;
  double? totalRestPrice;
  double? realRestPrice;
  double? restItemDiscount;
  int? totalItemInCart;
  final String locale;
  CartSummaryModel({this.restaurantInfo, this.restId, this.summary, this.totalRestPrice, this.realRestPrice, this.restItemDiscount, this.totalItemInCart, required this.locale});

  CartSummaryModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurantInfo = json['restaurantInfo'] != null ? FoodRestaurantInfo.fromJson(json['restaurantInfo'], locale) : null;
    if (json['restId'] != null && json['restId'] != '') {
      restId = json['restId'];
    } else {
      restId = '';
    }
    if (json['summary'] != null) {
      summary = <FoodInCartSummaryModel>[];
      json['summary'].forEach((v) {
        summary!.add(FoodInCartSummaryModel.fromJson(v, locale));
      });
    } else {
      summary = [];
    }
    if (json['totalRestPrice'] != null && json['totalRestPrice'] != '') {
      totalRestPrice = double.parse(json['totalRestPrice'].toString());
    } else {
      totalRestPrice = 0.0;
    }
    if (json['realRestPrice'] != null && json['realRestPrice'] != '') {
      realRestPrice = double.parse(json['realRestPrice'].toString());
    } else {
      realRestPrice = 0.0;
    }
    if (json['restItemDiscount'] != null && json['restItemDiscount'] != '') {
      restItemDiscount = double.parse(json['restItemDiscount'].toString());
    } else {
      restItemDiscount = 0.0;
    }
    if (json['totalItemInCart'] != null && json['totalItemInCart'] != '') {
      totalItemInCart = int.parse(json['totalItemInCart'].toString());
    } else {
      totalItemInCart = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurantInfo != null) {
      data['restaurantInfo'] = restaurantInfo!.toJson();
    }
    data['restId'] = restId;
    if (summary != null) {
      data['summary'] = summary!.map((v) => v.toJson()).toList();
    }
    data['totalRestPrice'] = totalRestPrice;
    data['realRestPrice'] = realRestPrice;
    data['restItemDiscount'] = restItemDiscount;
    data['totalItemInCart'] = totalItemInCart;
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

class FoodInCartSummaryModel {
  String? uuid;
  String? name;
  String? shortDescription;
  String? image;
  String? restaurant;
  String? foodType;
  double? price;
  String? discountType;
  double? discount;
  double? offerPrice = 0.0;
  int? purchaseLimit;
  int? stockNumber;
  String? stockType;
  List<FoodTranslations>? translations;
  List<AddonConfigModel>? addons;
  List<VariationConfigModel>? variations;
  FoodRestaurantInfo? restaurantInfo;
  int? quantity;
  String? optionName;
  double? totalPrice;
  String? status;
  bool? inStock;
  String? id;
  final String locale;
  FoodInCartSummaryModel({
    this.uuid,
    this.name,
    this.shortDescription,
    this.image,
    this.restaurant,
    this.foodType,
    this.addons,
    this.price,
    this.discountType,
    this.discount,
    this.offerPrice,
    this.translations,
    this.purchaseLimit,
    this.stockNumber,
    this.stockType,
    this.variations,
    this.restaurantInfo,
    this.quantity,
    this.optionName,
    this.totalPrice,
    this.status,
    this.inStock,
    this.id,
    required this.locale,
  });

  FoodInCartSummaryModel.fromJson(Map<String, dynamic> json, this.locale) {
    List<String> optionNameList = <String>[];
    optionNameList.clear();
    if (json['uuid'] != null && json['uuid'] != '') {
      uuid = json['uuid'];
    } else {
      uuid = '';
    }
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    restaurant = json['restaurant'];
    foodType = json['foodType'];
    if (json['addons'] != null) {
      addons = <AddonConfigModel>[];
      json['addons'].forEach((v) {
        addons!.add(AddonConfigModel.fromJson(v, locale));
      });
    } else {
      addons = [];
    }
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
    if (json['variations'] != null) {
      variations = <VariationConfigModel>[];
      json['variations'].forEach((v) {
        variations!.add(VariationConfigModel.fromJson(v));
        VariationConfigModel variationInfo = VariationConfigModel.fromJson(v);
        for (var element in variationInfo.options!) {
          optionNameList.add(element.name!);
        }
      });
    } else {
      variations = [];
    }

    if (json['addons'] != null) {
      json['addons'].forEach((v) {
        AddonConfigModel addonInfo = AddonConfigModel.fromJson(v, locale);
        optionNameList.add(addonInfo.name!);
      });
    } else {
      addons = [];
    }
    optionName = optionNameList.join(',');
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

    if (json['purchaseLimit'] != null && json['purchaseLimit'] != '' && json['purchaseLimit'].toString() != '-1') {
      purchaseLimit = int.parse(json['purchaseLimit'].toString());
    } else if (json['purchaseLimit'].toString() == '-1') {
      purchaseLimit = 1000000000000000;
    } else {
      purchaseLimit = 5;
    }
    if (json['stockNumber'] != null && json['stockNumber'] != '' && json['stockNumber'].toString() != '-1') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else if (json['stockNumber'].toString() == '-1') {
      stockNumber = 1000000000000000;
    } else {
      stockNumber = 5;
    }
    stockType = json['stockType'];
    restaurantInfo = json['restaurantInfo'] != null ? FoodRestaurantInfo.fromJson(json['restaurantInfo'], locale) : null;
    if (json['quantity'] != null && json['quantity'] != '') {
      quantity = int.parse(json['quantity'].toString());
    } else {
      quantity = 1;
    }
    if (json['totalPrice'] != null && json['totalPrice'] != '') {
      totalPrice = double.parse(json['totalPrice'].toString());
    } else {
      totalPrice = 0;
    }
    status = json['status'];
    inStock = json['inStock'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['restaurant'] = restaurant;
    data['foodType'] = foodType;
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

    data['purchaseLimit'] = purchaseLimit;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    if (restaurantInfo != null) {
      data['restaurantInfo'] = restaurantInfo!.toJson();
    }
    data['quantity'] = quantity;
    data['optionName'] = optionName;
    data['totalPrice'] = totalPrice;
    data['status'] = status;
    data['inStock'] = inStock;
    data['id'] = id;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodInCartSummaryModel && runtimeType == other.runtimeType && id == other.id && restaurant == other.restaurant && addons == other.addons && variations == other.variations && uuid == other.uuid;

  @override
  int get hashCode => id.hashCode ^ restaurant.hashCode ^ addons.hashCode ^ variations.hashCode ^ uuid.hashCode;
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

class AddonConfigModel {
  String? name;
  List<AddonTranslations>? translations;
  String? id;
  double? price;
  bool? inStock;
  int? stockNumber;
  String? stockType;
  String? discountType;
  double? discount = 0.0;
  double? offerPrice = 0.0;
  final String locale;
  AddonConfigModel({this.name, this.translations, this.id, this.price, this.inStock, this.stockNumber, this.stockType, this.discountType, this.discount, this.offerPrice, required this.locale});

  AddonConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    discountType = '%';
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
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['price'] = price;
    data['inStock'] = inStock;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
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
  String? discountType;
  double? discount = 0.0;
  double? offerPrice = 0.0;
  bool? enable;
  int? stock;

  VariationOptionConfigModel({this.name, this.price, this.discountType, this.discount, this.offerPrice, this.enable, this.stock});

  VariationOptionConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    discountType = '%';
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
    if (json['enable'] != null && json['enable'] != '') {
      enable = json['enable'];
    } else {
      enable = true;
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
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
    data['enable'] = enable;
    data['stock'] = stock;
    return data;
  }
}

