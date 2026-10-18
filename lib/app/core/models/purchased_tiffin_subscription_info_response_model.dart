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
import 'package:user/app/core/models/food_in_cart_model.dart';
import 'package:user/app/services/titlecase_string.dart';

class PurchasedTiffinSubscriptionPackageInfoResponseModel {
  BusinessSettingsConfigModel? businessSettings;
  PurchasedSubscriptionDetailConfigModel? details;
  OrderSettingsConfigModel? orderSettings;
  RestaurantSettings? restaurantSettings;
  RestaurantUserInfoModel? restUserInfo;
  RestaurantLicenseModel? restaurantLicense;
  List<RepayPaymentConfigModel>? payments;
  RepayPaymentConfigModel? primary;
  bool? success;
  final String locale;
  PurchasedTiffinSubscriptionPackageInfoResponseModel({
    this.businessSettings,
    this.details,
    this.orderSettings,
    this.restaurantSettings,
    this.restUserInfo,
    this.restaurantLicense,
    this.payments,
    this.primary,
    this.success,
    required this.locale,
  });

  PurchasedTiffinSubscriptionPackageInfoResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    businessSettings = json['businessSettings'] != null ? BusinessSettingsConfigModel.fromJson(json['businessSettings']) : null;
    details = json['details'] != null ? PurchasedSubscriptionDetailConfigModel.fromJson(json['details'], locale) : null;
    orderSettings = json['orderSettings'] != null ? OrderSettingsConfigModel.fromJson(json['orderSettings']) : null;
    restaurantSettings = json['restaurantSettings'] != null ? RestaurantSettings.fromJson(json['restaurantSettings']) : null;
    restUserInfo = json['restUserInfo'] != null ? RestaurantUserInfoModel.fromJson(json['restUserInfo']) : null;
    restaurantLicense = json['restaurantLicense'] != null ? RestaurantLicenseModel.fromJson(json['restaurantLicense'], locale) : null;
    if (json['payments'] != null) {
      payments = <RepayPaymentConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(RepayPaymentConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    primary = json['primary'] != null ? RepayPaymentConfigModel.fromJson(json['primary'], locale) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (businessSettings != null) {
      data['businessSettings'] = businessSettings!.toJson();
    }
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (restaurantSettings != null) {
      data['restaurantSettings'] = restaurantSettings!.toJson();
    }
    if (restUserInfo != null) {
      data['restUserInfo'] = restUserInfo!.toJson();
    }
    if (restaurantLicense != null) {
      data['restaurantLicense'] = restaurantLicense!.toJson();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class BusinessSettingsConfigModel {
  bool? refundRequest;
  String? id;

  BusinessSettingsConfigModel({this.refundRequest, this.id});

  BusinessSettingsConfigModel.fromJson(Map<String, dynamic> json) {
    refundRequest = json['refundRequest'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refundRequest'] = refundRequest;
    data['id'] = id;
    return data;
  }
}

class PurchasedSubscriptionDetailConfigModel {
  RestaurantConfigModel? restaurant;
  String? slot;
  String? orderAt;
  String? orderTo;
  String? cookingInstruction;
  String? receiverName;
  int? countryCode;
  String? receiverContact;
  int? totalOrder;
  String? startDate;
  List<String>? offDays;
  String? offDayName;
  List<String>? ordersDates;
  List<String>? requestedOffDates;
  String? status;
  String? id;
  List<FoodInCartModel>? cartItem;
  DeliveryAddressRawConfigModel? deliveryAddress;
  double? itemTotal;
  double? foodServiceCharge;
  double? serviceCharge;
  double? packageCharge;
  double? packageChargeTax;
  double? extraCharge;
  double? grandTotal;
  double? timeDifferenceOfOrderInMinutes;
  PackageDetailModel? package;
  PaymentInfoConfigModel? paymentInfo;
  DeliveryInstructionInfoConfigModel? deliveryInstructionInfo;
  final String locale;
  PurchasedSubscriptionDetailConfigModel({
    this.restaurant,
    this.slot,
    this.orderAt,
    this.orderTo,
    this.cookingInstruction,
    this.receiverName,
    this.countryCode,
    this.receiverContact,
    this.totalOrder,
    this.startDate,
    this.offDays,
    this.offDayName,
    this.ordersDates,
    this.requestedOffDates,
    this.status,
    this.id,
    this.cartItem,
    this.deliveryAddress,
    this.itemTotal,
    this.foodServiceCharge,
    this.serviceCharge,
    this.packageCharge,
    this.packageChargeTax,
    this.extraCharge,
    this.grandTotal,
    this.timeDifferenceOfOrderInMinutes,
    this.package,
    this.paymentInfo,
    this.deliveryInstructionInfo,
    required this.locale,
  });

  PurchasedSubscriptionDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? RestaurantConfigModel.fromJson(json['restaurant'], locale) : null;
    slot = json['slot'];
    orderAt = json['orderAt'];
    orderTo = json['orderTo'];
    cookingInstruction = json['cookingInstruction'];
    receiverName = json['receiverName'];
    if (json['countryCode'] != null && json['countryCode'] != '') {
      countryCode = int.parse(json['countryCode'].toString());
    } else {
      countryCode = 91;
    }
    receiverContact = json['receiverContact'];
    if (json['totalOrder'] != null && json['totalOrder'] != '') {
      totalOrder = int.parse(json['totalOrder'].toString());
    } else {
      totalOrder = 0;
    }
    if (json['startDate'] != null && json['startDate'] != '') {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['startDate']);
      var inputDate = DateTime.parse(parseDate.toString());
      startDate = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      startDate = '-';
    }
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
    ordersDates = json['ordersDates'].cast<String>();
    requestedOffDates = json['requestedOffDates'].cast<String>();
    status = json['status'];
    id = json['id'];
    if (json['cartItem'] != null) {
      cartItem = <FoodInCartModel>[];
      json['cartItem'].forEach((v) {
        cartItem!.add(FoodInCartModel.fromJson(v, locale));
      });
    } else {
      cartItem = [];
    }
    deliveryAddress = json['deliveryAddress'] != null ? DeliveryAddressRawConfigModel.fromJson(json['deliveryAddress']) : null;
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0.0;
    }
    if (json['itemTotal'] != null && json['itemTotal'] != '') {
      itemTotal = double.parse(json['itemTotal'].toString());
    } else {
      itemTotal = 0.0;
    }
    if (json['foodServiceCharge'] != null && json['foodServiceCharge'] != '') {
      foodServiceCharge = double.parse(json['foodServiceCharge'].toString());
    } else {
      foodServiceCharge = 0.0;
    }
    if (json['serviceCharge'] != null && json['serviceCharge'] != '') {
      serviceCharge = double.parse(json['serviceCharge'].toString());
    } else {
      serviceCharge = 0.0;
    }
    if (json['packageCharge'] != null && json['packageCharge'] != '') {
      packageCharge = double.parse(json['packageCharge'].toString());
    } else {
      packageCharge = 0.0;
    }
    if (json['packageChargeTax'] != null && json['packageChargeTax'] != '') {
      packageChargeTax = double.parse(json['packageChargeTax'].toString());
    } else {
      packageChargeTax = 0.0;
    }
    if (json['extraCharge'] != null && json['extraCharge'] != '') {
      extraCharge = double.parse(json['extraCharge'].toString());
    } else {
      extraCharge = 0.0;
    }
    if (json['timeDifferenceOfOrderInMinutes'] != null && json['timeDifferenceOfOrderInMinutes'] != '') {
      timeDifferenceOfOrderInMinutes = double.parse(json['timeDifferenceOfOrderInMinutes'].toString());
    } else {
      timeDifferenceOfOrderInMinutes = 50;
    }
    package = json['package'] != null ? PackageDetailModel.fromJson(json['package'], locale) : null;
    paymentInfo = json['paymentInfo'] != null ? PaymentInfoConfigModel.fromJson(json['paymentInfo'], locale) : null;
    deliveryInstructionInfo = json['deliveryInstructionInfo'] != null ? DeliveryInstructionInfoConfigModel.fromJson(json['deliveryInstructionInfo'], locale) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['slot'] = slot;
    data['orderAt'] = orderAt;
    data['orderTo'] = orderTo;
    data['cookingInstruction'] = cookingInstruction;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['totalOrder'] = totalOrder;
    data['startDate'] = startDate;
    data['offDays'] = offDays;
    data['ordersDates'] = ordersDates;
    data['requestedOffDates'] = requestedOffDates;
    data['status'] = status;
    data['id'] = id;
    if (cartItem != null) {
      data['cartItem'] = cartItem!.map((v) => v.toJson()).toList();
    }
    if (deliveryAddress != null) {
      data['deliveryAddress'] = deliveryAddress!.toJson();
    }
    data['itemTotal'] = itemTotal;
    data['foodServiceCharge'] = foodServiceCharge;
    data['serviceCharge'] = serviceCharge;
    data['packageCharge'] = packageCharge;
    data['packageChargeTax'] = packageChargeTax;
    data['extraCharge'] = extraCharge;
    data['grandTotal'] = grandTotal;
    data['timeDifferenceOfOrderInMinutes'] = timeDifferenceOfOrderInMinutes;
    if (package != null) {
      data['package'] = package!.toJson();
    }
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    if (deliveryInstructionInfo != null) {
      data['deliveryInstructionInfo'] = deliveryInstructionInfo!.toJson();
    }
    return data;
  }
}

class PackageDetailModel {
  String? id;
  String? name;
  String? shortDescription;
  String? image;
  List<PackageDetailTranslationsModel>? translations;
  final String locale;
  PackageDetailModel({this.id, this.name, this.shortDescription, this.image, this.translations, required this.locale});

  PackageDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <PackageDetailTranslationsModel>[];
      json['translations'].forEach((v) {
        translations!.add(PackageDetailTranslationsModel.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PackageDetailTranslationsModel {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  PackageDetailTranslationsModel({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  PackageDetailTranslationsModel.fromJson(Map<String, dynamic> json) {
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

class RestaurantConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  String? license;
  String? licenseId;
  LocationConfigModel? location;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.license, this.licenseId, this.location, this.translations, required this.locale});

  RestaurantConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    slug = json['slug'];
    address = json['address'];
    license = json['license'];
    licenseId = json['licenseId'];
    location = json['location'] != null ? LocationConfigModel.fromJson(json['location']) : null;
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
    data['logo'] = logo;
    data['cover'] = cover;
    data['slug'] = slug;
    data['address'] = address;
    data['license'] = license;
    data['licenseId'] = licenseId;
    if (location != null) {
      data['location'] = location!.toJson();
    }
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

class LocationConfigModel {
  String? type;
  List<double>? coordinates;

  LocationConfigModel({this.type, this.coordinates});

  LocationConfigModel.fromJson(Map<String, dynamic> json) {
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

class DeliveryAddressRawConfigModel {
  LocationConfigModel? location;
  int? title;
  String? receiverName;
  int? countryCode;
  String? receiverContact;
  String? flatHouse;
  String? locality;
  String? landmark;
  String? id;

  DeliveryAddressRawConfigModel({this.location, this.title, this.receiverName, this.countryCode, this.receiverContact, this.flatHouse, this.locality, this.landmark, this.id});

  DeliveryAddressRawConfigModel.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? LocationConfigModel.fromJson(json['location']) : null;
    if (json['title'] != null && json['title'] != '') {
      title = int.parse(json['title'].toString());
    } else {
      title = 0;
    }
    receiverName = json['receiverName'];
    if (json['countryCode'] != null && json['countryCode'] != '') {
      countryCode = int.parse(json['countryCode'].toString());
    } else {
      countryCode = 0;
    }
    receiverContact = json['receiverContact'];
    flatHouse = json['flatHouse'];
    locality = json['locality'];
    landmark = json['landmark'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['title'] = title;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['flatHouse'] = flatHouse;
    data['locality'] = locality;
    data['landmark'] = landmark;
    data['id'] = id;
    return data;
  }
}

class PaymentInfoConfigModel {
  String? id;
  String? slug;
  String? name;
  String? paymentWay;
  List<PaymentTranslations>? translations;
  final String locale;
  PaymentInfoConfigModel({this.id, this.slug, this.name, this.paymentWay, this.translations, required this.locale});

  PaymentInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    paymentWay = json['paymentWay'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['name'] = name;
    data['paymentWay'] = paymentWay;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
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

class DeliveryInstructionInfoConfigModel {
  String? id;
  String? name;
  String? image;
  List<DeliveryInstructionTranslations>? translations;
  final String locale;
  DeliveryInstructionInfoConfigModel({this.id, this.name, this.image, this.translations, required this.locale});

  DeliveryInstructionInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DeliveryInstructionTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DeliveryInstructionTranslations.fromJson(v));
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
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryInstructionTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DeliveryInstructionTranslations({this.name, this.code, this.nativeName, this.value});

  DeliveryInstructionTranslations.fromJson(Map<String, dynamic> json) {
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

class OrderSettingsConfigModel {
  bool? userCanCancelTiffinSubscriptionPackage;
  String? id;

  OrderSettingsConfigModel({this.userCanCancelTiffinSubscriptionPackage, this.id});

  OrderSettingsConfigModel.fromJson(Map<String, dynamic> json) {
    userCanCancelTiffinSubscriptionPackage = json['userCanCancelTiffinSubscriptionPackage'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userCanCancelTiffinSubscriptionPackage'] = userCanCancelTiffinSubscriptionPackage;
    data['id'] = id;
    return data;
  }
}

class RestaurantSettings {
  bool? canInitiateChat;
  bool? canInitiateCall;
  String? id;

  RestaurantSettings({this.canInitiateChat, this.canInitiateCall, this.id});

  RestaurantSettings.fromJson(Map<String, dynamic> json) {
    canInitiateChat = json['canInitiateChat'];
    canInitiateCall = json['canInitiateCall'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canInitiateChat'] = canInitiateChat;
    data['canInitiateCall'] = canInitiateCall;
    data['id'] = id;
    return data;
  }
}

class RestaurantUserInfoModel {
  String? firstName;
  String? lastName;
  String? role;
  String? image;
  int? countryCode;
  String? mobile;
  String? id;

  RestaurantUserInfoModel({this.firstName, this.lastName, this.role, this.image, this.countryCode, this.mobile, this.id});

  RestaurantUserInfoModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    role = json['role'];
    image = json['image'];
    countryCode = json['countryCode'];
    mobile = json['mobile'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['role'] = role;
    data['image'] = image;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['id'] = id;
    return data;
  }
}

class RestaurantLicenseModel {
  String? image;
  String? name;
  String? website;
  List<RestaurantLicenseTranslations>? translations;
  String? id;
  final String locale;
  RestaurantLicenseModel({this.image, this.name, this.website, this.translations, this.id, required this.locale});

  RestaurantLicenseModel.fromJson(Map<String, dynamic> json, this.locale) {
    image = json['image'];
    name = json['name'];
    website = json['website'];
    if (json['translations'] != null) {
      translations = <RestaurantLicenseTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantLicenseTranslations.fromJson(v));
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
    data['image'] = image;
    data['name'] = name;
    data['website'] = website;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class RestaurantLicenseTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  RestaurantLicenseTranslations({this.name, this.code, this.nativeName, this.value});

  RestaurantLicenseTranslations.fromJson(Map<String, dynamic> json) {
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

class RepayPaymentConfigModel {
  String? name;
  String? slug;
  String? image;
  List<RepayPaymentTranslations>? translations;
  bool? isDefault;
  String? id;
  final String locale;
  RepayPaymentConfigModel({this.name, this.slug, this.image, this.translations, this.isDefault, this.id, required this.locale});

  RepayPaymentConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <RepayPaymentTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RepayPaymentTranslations.fromJson(v));
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

class RepayPaymentTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  RepayPaymentTranslations({this.name, this.code, this.nativeName, this.value});

  RepayPaymentTranslations.fromJson(Map<String, dynamic> json) {
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

