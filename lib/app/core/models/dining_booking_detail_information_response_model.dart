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

class DiningBookingDetailInformationResponseModel {
  DiningBookingDetailInfoConfigModel? details;
  RestaurantSettingConfigModel? restaurantSettings;
  List<RepayPaymentConfigModel>? payments;
  RepayPaymentConfigModel? primary;
  BusinessSettingConfigModel? businessSettings;
  bool? success;
  final String locale;
  DiningBookingDetailInformationResponseModel({this.details, this.restaurantSettings, this.payments, this.primary, this.businessSettings, this.success, required this.locale});

  DiningBookingDetailInformationResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? DiningBookingDetailInfoConfigModel.fromJson(json['details'], locale) : null;
    restaurantSettings = json['restaurantSettings'] != null ? RestaurantSettingConfigModel.fromJson(json['restaurantSettings']) : null;
    if (json['payments'] != null) {
      payments = <RepayPaymentConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(RepayPaymentConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    primary = json['primary'] != null ? RepayPaymentConfigModel.fromJson(json['primary'], locale) : null;
    businessSettings = json['businessSettings'] != null ? BusinessSettingConfigModel.fromJson(json['businessSettings']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (restaurantSettings != null) {
      data['restaurantSettings'] = restaurantSettings!.toJson();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
    if (businessSettings != null) {
      data['businessSettings'] = businessSettings!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class DiningBookingDetailInfoConfigModel {
  RestaurantInfoConfigModel? restaurant;
  String? bookingDate;
  String? bookingSlot;
  int? guest;
  String? userName;
  String? userCountryCode;
  String? userContact;
  String? userEmail;
  String? specialRequest;
  String? status;
  String? createdAt;
  DiningCouponInfoConfigModel? diningcoupons;
  String? id;
  PaymentInfoConfigModel? paymentInfo;
  TransactionConfigModel? transaction;
  double? preBookingCharge;
  double? couponCoverCharge;
  double? grandTotal;
  double? timeDifferenceOfOrderInMinutes;
  final String locale;
  DiningBookingDetailInfoConfigModel({
    this.restaurant,
    this.bookingDate,
    this.bookingSlot,
    this.guest,
    this.userName,
    this.userCountryCode,
    this.userContact,
    this.userEmail,
    this.specialRequest,
    this.status,
    this.createdAt,
    this.diningcoupons,
    this.id,
    this.paymentInfo,
    this.transaction,
    this.preBookingCharge,
    this.couponCoverCharge,
    this.grandTotal,
    this.timeDifferenceOfOrderInMinutes,
    required this.locale,
  });

  DiningBookingDetailInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? RestaurantInfoConfigModel.fromJson(json['restaurant'], locale) : null;
    if (json['bookingDate'] != null && json['bookingDate'] != '') {
      DateTime dateTime = DateTime.parse(json['bookingDate']);
      String formattedDate = DateFormat('dd MMM yyyy', locale).format(dateTime);
      bookingDate = formattedDate;
    } else {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat('dd MMM yyyy', locale).format(dateTime);
      bookingDate = formattedDate;
    }
    bookingSlot = json['bookingSlot'];
    if (json['guest'] != null && json['guest'] != '') {
      guest = int.parse(json['guest'].toString());
    } else {
      guest = 1;
    }
    userName = json['userName'];
    userCountryCode = json['userCountryCode'].toString();
    userContact = json['userContact'];
    userEmail = json['userEmail'];
    specialRequest = json['specialRequest'] != null && json['specialRequest'] != '' ? json['specialRequest'] : '';
    status = json['status'];
    createdAt = json['createdAt'];
    diningcoupons = json['diningcoupons'] != null ? DiningCouponInfoConfigModel.fromJson(json['diningcoupons'], locale) : null;
    id = json['id'];
    paymentInfo = json['paymentInfo'] != null ? PaymentInfoConfigModel.fromJson(json['paymentInfo'], locale) : null;
    transaction = json['transaction'] != null ? TransactionConfigModel.fromJson(json['transaction'], locale) : null;
    if (json['preBookingCharge'] != null && json['preBookingCharge'] != '') {
      preBookingCharge = double.parse(json['preBookingCharge'].toString());
    } else {
      preBookingCharge = 0.0;
    }
    if (json['couponCoverCharge'] != null && json['couponCoverCharge'] != '') {
      couponCoverCharge = double.parse(json['couponCoverCharge'].toString());
    } else {
      couponCoverCharge = 0.0;
    }
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0.0;
    }
    if (json['timeDifferenceOfOrderInMinutes'] != null && json['timeDifferenceOfOrderInMinutes'] != '') {
      timeDifferenceOfOrderInMinutes = double.parse(json['timeDifferenceOfOrderInMinutes'].toString());
    } else {
      timeDifferenceOfOrderInMinutes = 50;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    data['bookingDate'] = bookingDate;
    data['bookingSlot'] = bookingSlot;
    data['guest'] = guest;
    data['userName'] = userName;
    data['userCountryCode'] = userCountryCode;
    data['userContact'] = userContact;
    data['userEmail'] = userEmail;
    data['specialRequest'] = specialRequest;
    data['status'] = status;
    data['createdAt'] = createdAt;
    if (diningcoupons != null) {
      data['diningcoupons'] = diningcoupons!.toJson();
    }
    data['id'] = id;
    if (paymentInfo != null) {
      data['paymentInfo'] = paymentInfo!.toJson();
    }
    if (transaction != null) {
      data['transaction'] = transaction!.toJson();
    }
    data['preBookingCharge'] = preBookingCharge;
    data['couponCoverCharge'] = couponCoverCharge;
    data['grandTotal'] = grandTotal;
    data['timeDifferenceOfOrderInMinutes'] = timeDifferenceOfOrderInMinutes;
    return data;
  }
}

class RestaurantSettingConfigModel {
  bool? canInitiateChat;
  bool? canInitiateCall;
  String? id;

  RestaurantSettingConfigModel({this.canInitiateChat, this.canInitiateCall, this.id});

  RestaurantSettingConfigModel.fromJson(Map<String, dynamic> json) {
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

class RestaurantInfoConfigModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  String? slug;
  String? address;
  LocationCoordinates? location;
  List<RestaurantTranslations>? translations;
  final String locale;
  RestaurantInfoConfigModel({this.id, this.name, this.logo, this.cover, this.slug, this.address, this.location, this.translations, required this.locale});

  RestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    slug = json['slug'];
    address = json['address'];
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
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
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
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

class BusinessSettingConfigModel {
  bool? refundRequest;
  String? id;

  BusinessSettingConfigModel({this.refundRequest, this.id});

  BusinessSettingConfigModel.fromJson(Map<String, dynamic> json) {
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

class DiningCouponInfoConfigModel {
  String? name;
  String? discountType;
  bool? preBookingChargeRequired;
  List<CouponTranslations>? translations;
  String? id;
  double? minDiscount;
  double? maxDiscount;
  double? preBookingChargeAmount;
  final String locale;
  DiningCouponInfoConfigModel({this.name, this.discountType, this.preBookingChargeRequired, this.translations, this.id, this.minDiscount, this.maxDiscount, this.preBookingChargeAmount, required this.locale});

  DiningCouponInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    discountType = json['discountType'];
    preBookingChargeRequired = json['preBookingChargeRequired'];
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
    if (json['minDiscount'] != null && json['minDiscount'] != '') {
      minDiscount = double.parse(json['minDiscount'].toString());
    } else {
      minDiscount = 0.0;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['discountType'] = discountType;
    data['preBookingChargeRequired'] = preBookingChargeRequired;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['minDiscount'] = minDiscount;
    data['maxDiscount'] = maxDiscount;
    data['preBookingChargeAmount'] = preBookingChargeAmount;
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

class TransactionConfigModel {
  String? id;
  String? status;
  String? createdAt;
  final String locale;
  TransactionConfigModel({this.id, this.status, this.createdAt, required this.locale});

  TransactionConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    status = json['status'];
    if (json['createdAt'] != null && json['createdAt'] != '') {
      DateTime dateTime = DateTime.parse(json['createdAt']);
      String formattedDate = DateFormat('dd MMM yyyy hh:mm a', locale).format(dateTime);
      createdAt = formattedDate;
    } else {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat('dd MMM yyyy hh:mm a', locale).format(dateTime);
      createdAt = formattedDate;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['createdAt'] = createdAt;
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

class RestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;
  String? shortDescription;

  RestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address, this.shortDescription});

  RestaurantTranslations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    address = json['address'];
    shortDescription = json['shortDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['address'] = address;
    data['shortDescription'] = shortDescription;
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

