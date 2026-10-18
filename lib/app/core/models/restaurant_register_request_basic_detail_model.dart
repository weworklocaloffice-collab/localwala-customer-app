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

class RestaurantRegisterRequestBasicDetailModel {
  List<RestaurantRegisterRequestCitiesModel>? cities;
  List<RestaurantRegisterRequestLicenseModel>? licenses;
  RestaurantRegisterRequestJoiningFormSetupModel? joiningForm;
  List<RestaurantRegisterRequestSubscriptionPackageConfigModel>? subscriptionPackages;
  PaymentListModel? payment;
  BusinessSettingConfigModel? settings;
  bool? success;
  final String locale;
  RestaurantRegisterRequestBasicDetailModel({this.cities, this.licenses, this.joiningForm, this.subscriptionPackages, this.payment, this.settings, this.success, required this.locale});

  RestaurantRegisterRequestBasicDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['cities'] != null) {
      cities = <RestaurantRegisterRequestCitiesModel>[];
      json['cities'].forEach((v) {
        cities!.add(RestaurantRegisterRequestCitiesModel.fromJson(v, locale));
      });
    } else {
      cities = [];
    }
    if (json['licenses'] != null) {
      licenses = <RestaurantRegisterRequestLicenseModel>[];
      json['licenses'].forEach((v) {
        licenses!.add(RestaurantRegisterRequestLicenseModel.fromJson(v, locale));
      });
    } else {
      licenses = [];
    }
    joiningForm = json['joiningForm'] != null ? RestaurantRegisterRequestJoiningFormSetupModel.fromJson(json['joiningForm']) : null;
    if (json['subscriptionPackages'] != null) {
      subscriptionPackages = <RestaurantRegisterRequestSubscriptionPackageConfigModel>[];
      json['subscriptionPackages'].forEach((v) {
        subscriptionPackages!.add(RestaurantRegisterRequestSubscriptionPackageConfigModel.fromJson(v, locale));
      });
    } else {
      subscriptionPackages = [];
    }
    payment = json['payment'] != null ? PaymentListModel.fromJson(json['payment'], locale) : null;
    settings = json['settings'] != null ? BusinessSettingConfigModel.fromJson(json['settings']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    if (licenses != null) {
      data['licenses'] = licenses!.map((v) => v.toJson()).toList();
    }
    if (joiningForm != null) {
      data['joiningForm'] = joiningForm!.toJson();
    }
    if (subscriptionPackages != null) {
      data['subscriptionPackages'] = subscriptionPackages!.map((v) => v.toJson()).toList();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    if (settings != null) {
      data['settings'] = settings!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class RestaurantRegisterRequestCitiesModel {
  LocationCoordinates? location;
  String? name;
  List<CommanTranslations>? translations;
  String? id;
  final String locale;
  RestaurantRegisterRequestCitiesModel({this.location, this.name, this.translations, this.id, required this.locale});

  RestaurantRegisterRequestCitiesModel.fromJson(Map<String, dynamic> json, this.locale) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    name = json['name'];
    if (json['translations'] != null) {
      translations = <CommanTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CommanTranslations.fromJson(v));
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
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
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

class CommanTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CommanTranslations({this.name, this.code, this.nativeName, this.value});

  CommanTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantRegisterRequestLicenseModel {
  String? name;
  List<CommanTranslations>? translations;
  String? id;
  final String locale;
  RestaurantRegisterRequestLicenseModel({this.name, this.translations, this.id, required this.locale});

  RestaurantRegisterRequestLicenseModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <CommanTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CommanTranslations.fromJson(v));
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

class RestaurantRegisterRequestJoiningFormSetupModel {
  RestaurantRegisterRequestJoiningFormResultConfig? result;
  bool? success;

  RestaurantRegisterRequestJoiningFormSetupModel({this.result, this.success});

  RestaurantRegisterRequestJoiningFormSetupModel.fromJson(Map<String, dynamic> json) {
    result = json['result'] != null ? RestaurantRegisterRequestJoiningFormResultConfig.fromJson(json['result']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['result'] = result!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class RestaurantRegisterRequestJoiningFormResultConfig {
  List<RestaurantFormConfigModel>? restaurantForm;
  String? id;

  RestaurantRegisterRequestJoiningFormResultConfig({this.restaurantForm, this.id});

  RestaurantRegisterRequestJoiningFormResultConfig.fromJson(Map<String, dynamic> json) {
    if (json['restaurantForm'] != null) {
      restaurantForm = <RestaurantFormConfigModel>[];
      json['restaurantForm'].forEach((v) {
        restaurantForm!.add(RestaurantFormConfigModel.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurantForm != null) {
      data['restaurantForm'] = restaurantForm!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class RestaurantFormConfigModel {
  String? uuid;
  bool? isRequired;
  String? type;
  String? title;
  String? placeholder;
  List<JoiningFormCheckboxItemConfigModel>? items;

  RestaurantFormConfigModel({this.uuid, this.isRequired, this.type, this.title, this.placeholder, this.items});

  RestaurantFormConfigModel.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    if (json['isRequired'] != null && (json['isRequired'] == true || json['isRequired'] == 'true')) {
      isRequired = true;
    } else {
      isRequired = false;
    }
    type = json['type'];
    title = json['title'];
    placeholder = json['placeholder'];
    if (json['items'] != null) {
      items = <JoiningFormCheckboxItemConfigModel>[];
      json['items'].forEach((v) {
        items!.add(JoiningFormCheckboxItemConfigModel.fromJson(v));
      });
    } else {
      items = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['isRequired'] = isRequired;
    data['type'] = type;
    data['title'] = title;
    data['placeholder'] = placeholder;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class JoiningFormCheckboxItemConfigModel {
  String? name;

  JoiningFormCheckboxItemConfigModel({this.name});

  JoiningFormCheckboxItemConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}

class RestaurantRegisterRequestSubscriptionPackageConfigModel {
  String? name;
  double? price;
  double? discount;
  double? commission;
  double? offerPrice = 0.0;
  String? shortDescriptions;
  int? validity;
  bool? haveTrial;
  int? trialValidity;
  String? icon;
  bool? pos;
  bool? ownDriver;
  bool? promote;
  bool? customCategory;
  bool? multiOutlet;
  bool? preBooking;
  bool? tableOrder;
  int? orderLimit;
  int? productLimit;
  List<SubscriptionPackageTranslations>? translations;
  bool? status;
  String? slug;
  bool? tiffinSubscription;
  bool? ownWaiter;
  bool? ownKitchen;
  String? id;
  final String locale;
  RestaurantRegisterRequestSubscriptionPackageConfigModel({
    this.name,
    this.price,
    this.discount,
    this.commission,
    this.offerPrice,
    this.shortDescriptions,
    this.validity,
    this.haveTrial,
    this.trialValidity,
    this.icon,
    this.pos,
    this.ownDriver,
    this.promote,
    this.customCategory,
    this.multiOutlet,
    this.preBooking,
    this.tableOrder,
    this.orderLimit,
    this.productLimit,
    this.translations,
    this.status,
    this.slug,
    this.tiffinSubscription,
    this.ownWaiter,
    this.ownKitchen,
    this.id,
    required this.locale,
  });

  RestaurantRegisterRequestSubscriptionPackageConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0;
    }
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        String discountValue = (double.parse(price.toString()) - (double.parse(price.toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
        offerPrice = double.parse(discountValue);
      }
    } else {
      discount = 0;
      offerPrice = 0.0;
    }
    if (json['commission'] != null && json['commission'] != '') {
      commission = double.parse(json['commission'].toString());
    } else {
      commission = 0;
    }
    shortDescriptions = json['shortDescriptions'];
    if (json['validity'] != null && json['validity'] != '') {
      validity = int.parse(json['validity'].toString());
    } else {
      validity = 0;
    }
    haveTrial = json['haveTrial'];
    if (json['trialValidity'] != null && json['trialValidity'] != '') {
      trialValidity = int.parse(json['trialValidity'].toString());
    } else {
      trialValidity = 0;
    }
    icon = json['icon'];
    pos = json['pos'];
    ownDriver = json['ownDriver'];
    promote = json['promote'];
    customCategory = json['customCategory'];
    multiOutlet = json['multiOutlet'];
    preBooking = json['preBooking'];
    tableOrder = json['tableOrder'];
    if (json['orderLimit'] != null && json['orderLimit'] != '') {
      orderLimit = int.parse(json['orderLimit'].toString());
    } else {
      orderLimit = 0;
    }
    if (json['productLimit'] != null && json['productLimit'] != '') {
      productLimit = int.parse(json['productLimit'].toString());
    } else {
      productLimit = 0;
    }
    if (json['translations'] != null) {
      translations = <SubscriptionPackageTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(SubscriptionPackageTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            name = translations![localeIndex].title!;
          }
          if (translations![localeIndex].shortDescriptions!.isNotEmpty) {
            shortDescriptions = translations![localeIndex].shortDescriptions!;
          }
        }
      }
    } else {
      translations = [];
    }
    status = json['status'];
    slug = json['slug'];
    tiffinSubscription = json['tiffinSubscription'];
    ownWaiter = json['ownWaiter'];
    ownKitchen = json['ownKitchen'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['discount'] = discount;
    data['commission'] = commission;
    data['shortDescriptions'] = shortDescriptions;
    data['validity'] = validity;
    data['haveTrial'] = haveTrial;
    data['trialValidity'] = trialValidity;
    data['icon'] = icon;
    data['pos'] = pos;
    data['ownDriver'] = ownDriver;
    data['promote'] = promote;
    data['customCategory'] = customCategory;
    data['multiOutlet'] = multiOutlet;
    data['preBooking'] = preBooking;
    data['tableOrder'] = tableOrder;
    data['orderLimit'] = orderLimit;
    data['productLimit'] = productLimit;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
    data['tiffinSubscription'] = tiffinSubscription;
    data['ownWaiter'] = ownWaiter;
    data['ownKitchen'] = ownKitchen;
    data['id'] = id;
    return data;
  }
}

class SubscriptionPackageTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescriptions;

  SubscriptionPackageTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescriptions});

  SubscriptionPackageTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    shortDescriptions = json['shortDescriptions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['shortDescriptions'] = shortDescriptions;
    return data;
  }
}

class PaymentListModel {
  bool? success;
  List<PaymentConfigModel>? payments;
  PaymentConfigModel? primary;
  final String locale;

  PaymentListModel({this.success, this.payments, this.primary, required this.locale});

  PaymentListModel.fromJson(Map<String, dynamic> json, this.locale) {
    success = json['success'];
    if (json['payments'] != null) {
      payments = <PaymentConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(PaymentConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    primary = json['primary'] != null ? PaymentConfigModel.fromJson(json['primary'], locale) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
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

class BusinessSettingConfigModel {
  bool? commissionBasedSystem;
  bool? subscriptionBasedSystem;

  BusinessSettingConfigModel({this.commissionBasedSystem, this.subscriptionBasedSystem});

  BusinessSettingConfigModel.fromJson(Map<String, dynamic> json) {
    commissionBasedSystem = json['commissionBasedSystem'];
    subscriptionBasedSystem = json['subscriptionBasedSystem'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commissionBasedSystem'] = commissionBasedSystem;
    data['subscriptionBasedSystem'] = subscriptionBasedSystem;
    return data;
  }
}

