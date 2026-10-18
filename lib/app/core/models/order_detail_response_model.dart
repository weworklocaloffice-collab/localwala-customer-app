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

class OrderDetailResponseModel {
  OrderDetailConfigModel? details;
  String? findMode;
  DriverSettingsConfigModel? driverSettings;
  OrderSettingsConfigModel? orderSettings;
  RestaurantSettings? restaurantSettings;
  RestaurantUserInfoModel? restUserInfo;
  RestaurantLicenseModel? restaurantLicense;
  BusinessSettingsModel? businessSettings;
  List<RepayPaymentConfigModel>? payments;
  RepayPaymentConfigModel? primary;
  int? driverOrderCount;
  bool? success;
  final String locale;
  OrderDetailResponseModel({
    this.details,
    this.findMode,
    this.driverSettings,
    this.orderSettings,
    this.restaurantSettings,
    this.restUserInfo,
    this.restaurantLicense,
    this.businessSettings,
    this.driverOrderCount,
    this.payments,
    this.primary,
    this.success,
    required this.locale,
  });

  OrderDetailResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? OrderDetailConfigModel.fromJson(json['details'], locale) : null;
    findMode = json['findMode'];
    driverSettings = json['driverSettings'] != null ? DriverSettingsConfigModel.fromJson(json['driverSettings']) : null;
    orderSettings = json['orderSettings'] != null ? OrderSettingsConfigModel.fromJson(json['orderSettings']) : null;
    restaurantSettings = json['restaurantSettings'] != null ? RestaurantSettings.fromJson(json['restaurantSettings']) : null;
    restUserInfo = json['restUserInfo'] != null ? RestaurantUserInfoModel.fromJson(json['restUserInfo']) : null;
    restaurantLicense = json['restaurantLicense'] != null ? RestaurantLicenseModel.fromJson(json['restaurantLicense'], locale) : null;
    businessSettings = json['businessSettings'] != null ? BusinessSettingsModel.fromJson(json['businessSettings']) : null;
    if (json['driverOrderCount'] != null && json['driverOrderCount'] != '') {
      driverOrderCount = int.parse(json['driverOrderCount'].toString());
    } else {
      driverOrderCount = 0;
    }
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
    if (details != null) {
      data['details'] = details!.toJson();
    }
    data['findMode'] = findMode;
    if (driverSettings != null) {
      data['driverSettings'] = driverSettings!.toJson();
    }
    if (orderSettings != null) {
      data['orderSettings'] = orderSettings!.toJson();
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
    if (businessSettings != null) {
      data['businessSettings'] = businessSettings!.toJson();
    }
    data['driverOrderCount'] = driverOrderCount;
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

class OrderDetailConfigModel {
  String? user;
  RestaurantConfigModel? restaurant;
  String? receiverName;
  int? countryCode;
  String? receiverContact;
  String? driverOrderPin;
  String? customerOrderPin;
  String? status;
  String? id;
  int? orderNo;
  DeliveryAddressRawConfigModel? deliveryAddressRaw;
  List<FoodInCartModel>? cartItem;
  double? grandTotal;
  double? realTotal;
  double? itemTotal;
  double? itemDiscount;
  double? couponDiscountCharge;
  double? deliveryCharge;
  double? foodServiceCharge;
  double? serviceCharge;
  double? packageCharge;
  double? packageChargeTax;
  double? walletAmount;
  double? deliveryTip;
  double? extraCharge;
  String? cookingInstruction;
  PaymentInfoConfigModel? paymentInfo;
  DeliveryInstructionInfoConfigModel? deliveryInstructionInfo;
  DriverInfoModel? driverInfo;
  String? orderTo;
  String? createdAt;
  String? scheduleDate;
  String? orderAt;
  bool? instantOrder;
  bool? scheduleOrder;
  bool? subscriptionOrder;
  String? scheduleTime;
  double? timeDifferenceOfOrderInMinutes;
  bool? isFavouriteOrder = false;
  bool? ratingSaved = false;
  final String locale;
  OrderDetailConfigModel({
    this.user,
    this.restaurant,
    this.receiverName,
    this.countryCode,
    this.receiverContact,
    this.driverOrderPin,
    this.customerOrderPin,
    this.status,
    this.id,
    this.orderNo,
    this.deliveryAddressRaw,
    this.cartItem,
    this.grandTotal,
    this.realTotal,
    this.itemTotal,
    this.itemDiscount,
    this.couponDiscountCharge,
    this.deliveryCharge,
    this.foodServiceCharge,
    this.serviceCharge,
    this.packageCharge,
    this.packageChargeTax,
    this.walletAmount,
    this.deliveryTip,
    this.extraCharge,
    this.cookingInstruction,
    this.paymentInfo,
    this.deliveryInstructionInfo,
    this.driverInfo,
    this.orderTo,
    this.createdAt,
    this.scheduleDate,
    this.orderAt,
    this.instantOrder,
    this.scheduleOrder,
    this.subscriptionOrder,
    this.scheduleTime,
    this.timeDifferenceOfOrderInMinutes,
    this.isFavouriteOrder,
    this.ratingSaved,
    required this.locale,
  });

  OrderDetailConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['user'] != null && json['user'] != '') {
      user = json['user'];
    } else {
      user = '';
    }
    restaurant = json['restaurant'] != null ? RestaurantConfigModel.fromJson(json['restaurant'], locale) : null;
    receiverName = json['receiverName'];
    if (json['countryCode'] != null && json['countryCode'] != '') {
      countryCode = int.parse(json['countryCode'].toString());
    } else {
      countryCode = 91;
    }
    receiverContact = json['receiverContact'];
    driverOrderPin = json['driverOrderPin'];
    customerOrderPin = json['customerOrderPin'];
    status = json['status'];
    id = json['id'];
    if (json['orderNo'] != null && json['orderNo'] != '') {
      orderNo = int.parse(json['orderNo'].toString());
    } else {
      orderNo = 0;
    }
    deliveryAddressRaw = json['deliveryAddressRaw'] != null ? DeliveryAddressRawConfigModel.fromJson(json['deliveryAddressRaw']) : null;
    if (json['cartItem'] != null) {
      cartItem = <FoodInCartModel>[];
      json['cartItem'].forEach((v) {
        cartItem!.add(FoodInCartModel.fromJson(v, locale));
      });
    } else {
      cartItem = [];
    }
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0.0;
    }
    if (json['realTotal'] != null && json['realTotal'] != '') {
      realTotal = double.parse(json['realTotal'].toString());
    } else {
      realTotal = 0.0;
    }
    if (json['itemTotal'] != null && json['itemTotal'] != '') {
      itemTotal = double.parse(json['itemTotal'].toString());
    } else {
      itemTotal = 0.0;
    }
    if (json['itemDiscount'] != null && json['itemDiscount'] != '') {
      itemDiscount = double.parse(json['itemDiscount'].toString());
    } else {
      itemDiscount = 0.0;
    }
    if (json['couponDiscountCharge'] != null && json['couponDiscountCharge'] != '') {
      couponDiscountCharge = double.parse(json['couponDiscountCharge'].toString());
    } else {
      couponDiscountCharge = 0.0;
    }
    if (json['deliveryCharge'] != null && json['deliveryCharge'] != '') {
      deliveryCharge = double.parse(json['deliveryCharge'].toString());
    } else {
      deliveryCharge = 0.0;
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
    if (json['walletAmount'] != null && json['walletAmount'] != '') {
      walletAmount = double.parse(json['walletAmount'].toString());
    } else {
      walletAmount = 0.0;
    }
    if (json['deliveryTip'] != null && json['deliveryTip'] != '') {
      deliveryTip = double.parse(json['deliveryTip'].toString());
    } else {
      deliveryTip = 0.0;
    }
    if (json['extraCharge'] != null && json['extraCharge'] != '') {
      extraCharge = double.parse(json['extraCharge'].toString());
    } else {
      extraCharge = 0.0;
    }
    cookingInstruction = json['cookingInstruction'];
    paymentInfo = json['paymentInfo'] != null ? PaymentInfoConfigModel.fromJson(json['paymentInfo'], locale) : null;
    deliveryInstructionInfo = json['deliveryInstructionInfo'] != null ? DeliveryInstructionInfoConfigModel.fromJson(json['deliveryInstructionInfo'], locale) : null;
    driverInfo = json['driverInfo'] != null ? DriverInfoModel.fromJson(json['driverInfo']) : null;
    orderTo = json['orderTo'];
    if (json['createdAt'] != null && json['createdAt'] != '') {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['createdAt']);
      var inputDate = DateTime.parse(parseDate.toString());
      createdAt = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      createdAt = '-';
    }
    if (json['scheduleDate'] != null && json['scheduleDate'] != '') {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['scheduleDate']);
      var inputDate = DateTime.parse(parseDate.toString());
      scheduleDate = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      scheduleDate = '-';
    }
    if (json['orderAt'] != null && json['orderAt'] != '') {
      DateTime parsedTime = DateFormat("h:mm a").parse(json['orderAt'].toString().toUpperCase());
      String formattedTime = DateFormat.jm(locale).format(parsedTime);
      orderAt = formattedTime;
    } else {
      orderAt = '02:00 PM';
    }
    instantOrder = json['instantOrder'];
    scheduleOrder = json['scheduleOrder'];
    subscriptionOrder = json['subscriptionOrder'];
    if (json['scheduleTime'] != null && json['scheduleTime'] != '') {
      DateTime parsedTime = DateFormat("h:mm a").parse(json['scheduleTime'].toString().toUpperCase());
      String formattedTime = DateFormat.jm(locale).format(parsedTime);
      scheduleTime = formattedTime;
    } else {
      scheduleTime = '';
    }
    if (json['timeDifferenceOfOrderInMinutes'] != null && json['timeDifferenceOfOrderInMinutes'] != '') {
      timeDifferenceOfOrderInMinutes = double.parse(json['timeDifferenceOfOrderInMinutes'].toString());
    } else {
      timeDifferenceOfOrderInMinutes = 50;
    }
    if (json['isFavouriteOrder'] != null && json['isFavouriteOrder'] != '') {
      isFavouriteOrder = json['isFavouriteOrder'];
    } else {
      isFavouriteOrder = false;
    }
    if (json['ratingSaved'] != null && json['ratingSaved'] != '') {
      ratingSaved = json['ratingSaved'];
    } else {
      ratingSaved = false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['driverOrderPin'] = driverOrderPin;
    data['customerOrderPin'] = customerOrderPin;
    data['status'] = status;
    data['id'] = id;
    data['orderNo'] = orderNo;
    if (deliveryAddressRaw != null) {
      data['deliveryAddressRaw'] = deliveryAddressRaw!.toJson();
    }
    if (cartItem != null) {
      data['cartItem'] = cartItem!.map((v) => v.toJson()).toList();
    }
    data['grandTotal'] = grandTotal;
    data['realTotal'] = realTotal;
    data['itemTotal'] = itemTotal;
    data['itemDiscount'] = itemDiscount;
    data['couponDiscountCharge'] = couponDiscountCharge;
    data['deliveryCharge'] = deliveryCharge;
    data['foodServiceCharge'] = foodServiceCharge;
    data['serviceCharge'] = serviceCharge;
    data['packageCharge'] = packageCharge;
    data['packageChargeTax'] = packageChargeTax;
    data['walletAmount'] = walletAmount;
    data['deliveryTip'] = deliveryTip;
    data['extraCharge'] = extraCharge;
    data['cookingInstruction'] = cookingInstruction;
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    if (deliveryInstructionInfo != null) {
      data['deliveryInstructionInfo'] = deliveryInstructionInfo!.toJson();
    }
    if (driverInfo != null) {
      data['driverInfo'] = driverInfo!.toJson();
    }
    data['orderTo'] = orderTo;
    data['createdAt'] = createdAt;
    data['scheduleDate'] = scheduleDate;
    data['orderAt'] = orderAt;
    data['instantOrder'] = instantOrder;
    data['scheduleOrder'] = scheduleOrder;
    data['subscriptionOrder'] = subscriptionOrder;
    data['scheduleTime'] = scheduleTime;
    data['timeDifferenceOfOrderInMinutes'] = timeDifferenceOfOrderInMinutes;
    data['isFavouriteOrder'] = isFavouriteOrder;
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

class RestaurantInfo {
  String? id;
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantInfo({this.id, this.name, this.logo, this.cover, this.translations, required this.locale});

  RestaurantInfo.fromJson(Map<String, dynamic> json, this.locale) {
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

class DriverSettingsConfigModel {
  bool? deliveryProof;
  bool? canInitiateChat;
  bool? canInitiateCall;
  bool? pickupProof;
  String? id;

  DriverSettingsConfigModel({this.deliveryProof, this.canInitiateChat, this.canInitiateCall, this.pickupProof, this.id});

  DriverSettingsConfigModel.fromJson(Map<String, dynamic> json) {
    deliveryProof = json['deliveryProof'];
    canInitiateChat = json['canInitiateChat'];
    canInitiateCall = json['canInitiateCall'];
    pickupProof = json['pickupProof'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deliveryProof'] = deliveryProof;
    data['canInitiateChat'] = canInitiateChat;
    data['canInitiateCall'] = canInitiateCall;
    data['pickupProof'] = pickupProof;
    data['id'] = id;
    return data;
  }
}

class OrderSettingsConfigModel {
  bool? deliveryVerification;
  bool? driverCanCancelOrder;
  String? orderConfirmationModel;
  String? id;

  OrderSettingsConfigModel({this.deliveryVerification, this.driverCanCancelOrder, this.orderConfirmationModel, this.id});

  OrderSettingsConfigModel.fromJson(Map<String, dynamic> json) {
    deliveryVerification = json['deliveryVerification'];
    driverCanCancelOrder = json['driverCanCancelOrder'];
    orderConfirmationModel = json['orderConfirmationModel'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deliveryVerification'] = deliveryVerification;
    data['driverCanCancelOrder'] = driverCanCancelOrder;
    data['orderConfirmationModel'] = orderConfirmationModel;
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

class DriverInfoModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;
  String? role;
  LocationConfigModel? location;

  DriverInfoModel({this.id, this.firstName, this.lastName, this.image, this.role, this.location});

  DriverInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
    role = json['role'];
    location = json['location'] != null ? LocationConfigModel.fromJson(json['location']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    data['role'] = role;
    if (location != null) {
      data['location'] = location!.toJson();
    }
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

class BusinessSettingsModel {
  String? findMode;
  int? deliveryArea;
  bool? refundRequest;
  String? id;

  BusinessSettingsModel({this.findMode, this.deliveryArea, this.refundRequest, this.id});

  BusinessSettingsModel.fromJson(Map<String, dynamic> json) {
    findMode = json['findMode'];
    deliveryArea = json['deliveryArea'];
    refundRequest = json['refundRequest'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['findMode'] = findMode;
    data['deliveryArea'] = deliveryArea;
    data['refundRequest'] = refundRequest;
    data['id'] = id;
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

