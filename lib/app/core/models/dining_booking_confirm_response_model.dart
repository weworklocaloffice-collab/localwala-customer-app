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

class DiningBookingConfirmResponseModel {
  RestaurantInfoConfigModel? restaurant;
  List<NoticesConfigModel>? notices;
  DiningBookingCouponConfirmationInfoConfig? coupon;
  UserInfoConfig? user;
  DinnigSettingInfoConfig? dinnigSetting;
  List<PaymentsConfigModel>? payments;
  PaymentsConfigModel? primary;
  bool? success;
  final String locale;
  DiningBookingConfirmResponseModel({this.restaurant, this.notices, this.coupon, this.user, this.dinnigSetting, this.payments, this.primary, this.success, required this.locale});

  DiningBookingConfirmResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    restaurant = json['restaurant'] != null ? RestaurantInfoConfigModel.fromJson(json['restaurant'], locale) : null;
    if (json['notices'] != null) {
      notices = <NoticesConfigModel>[];
      json['notices'].forEach((v) {
        notices!.add(NoticesConfigModel.fromJson(v, locale));
      });
    } else {
      notices = [];
    }
    coupon = json['coupon'] != null ? DiningBookingCouponConfirmationInfoConfig.fromJson(json['coupon'], locale) : null;
    user = json['user'] != null ? UserInfoConfig.fromJson(json['user']) : null;
    dinnigSetting = json['dinnigSetting'] != null ? DinnigSettingInfoConfig.fromJson(json['dinnigSetting']) : null;
    if (json['payments'] != null) {
      payments = <PaymentsConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(PaymentsConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    primary = json['primary'] != null ? PaymentsConfigModel.fromJson(json['primary'], locale) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (notices != null) {
      data['notices'] = notices!.map((v) => v.toJson()).toList();
    }
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (dinnigSetting != null) {
      data['dinnigSetting'] = dinnigSetting!.toJson();
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

class RestaurantInfoConfigModel {
  String? name;
  String? address;
  List<RestaurantTranslations>? translations;
  String? id;
  final String locale;
  RestaurantInfoConfigModel({this.name, this.address, this.translations, this.id, required this.locale});

  RestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
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
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
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

class NoticesConfigModel {
  String? name;
  List<NoticeTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  NoticesConfigModel({this.name, this.translations, this.status, this.id, required this.locale});

  NoticesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
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

class DiningBookingCouponConfirmationInfoConfig {
  String? name;
  String? code;
  String? discountType;
  double? maxDiscount;
  double? minDiscount;
  bool? preBookingChargeRequired;
  double? preBookingChargeAmount;
  List<DiningBookingCouponConfirmationTranslations>? translations;
  String? id;
  final String locale;
  DiningBookingCouponConfirmationInfoConfig({
    this.name,
    this.code,
    this.discountType,
    this.minDiscount,
    this.maxDiscount,
    this.preBookingChargeRequired,
    this.preBookingChargeAmount,
    this.translations,
    this.id,
    required this.locale,
  });

  DiningBookingCouponConfirmationInfoConfig.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    code = json['code'];
    discountType = json['discountType'];
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
    preBookingChargeRequired = json['preBookingChargeRequired'];
    if (json['translations'] != null) {
      translations = <DiningBookingCouponConfirmationTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningBookingCouponConfirmationTranslations.fromJson(v));
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
    data['code'] = code;
    data['discountType'] = discountType;
    data['minDiscount'] = minDiscount;
    data['maxDiscount'] = maxDiscount;
    data['preBookingChargeRequired'] = preBookingChargeRequired;
    data['preBookingChargeAmount'] = preBookingChargeAmount;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class DiningBookingCouponConfirmationTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningBookingCouponConfirmationTranslations({this.name, this.code, this.nativeName, this.value});

  DiningBookingCouponConfirmationTranslations.fromJson(Map<String, dynamic> json) {
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

class UserInfoConfig {
  String? firstName;
  String? lastName;
  String? countryCode;
  String? mobile;
  String? email;
  String? id;

  UserInfoConfig({this.firstName, this.lastName, this.countryCode, this.mobile, this.email, this.id});

  UserInfoConfig.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    countryCode = json['countryCode'].toString();
    mobile = json['mobile'];
    email = json['email'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['countryCode'] = countryCode;
    data['mobile'] = mobile;
    data['email'] = email;
    data['id'] = id;
    return data;
  }
}

class DinnigSettingInfoConfig {
  bool? preBookingChargeRequired;
  bool? guestBooking;
  double? minBookingCharge;
  String? id;

  DinnigSettingInfoConfig({this.preBookingChargeRequired, this.guestBooking, this.minBookingCharge, this.id});

  DinnigSettingInfoConfig.fromJson(Map<String, dynamic> json) {
    preBookingChargeRequired = json['preBookingChargeRequired'];
    guestBooking = json['guestBooking'];
    if (json['minBookingCharge'] != null && json['minBookingCharge'] != '') {
      minBookingCharge = double.parse(json['minBookingCharge'].toString());
    } else {
      minBookingCharge = 0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['preBookingChargeRequired'] = preBookingChargeRequired;
    data['guestBooking'] = guestBooking;
    data['minBookingCharge'] = minBookingCharge;
    data['id'] = id;
    return data;
  }
}

class PaymentsConfigModel {
  String? name;
  String? slug;
  String? image;
  List<PaymentTranslations>? translations;
  bool? isDefault;
  String? id;
  final String locale;
  PaymentsConfigModel({this.name, this.slug, this.image, this.translations, this.isDefault, this.id, required this.locale});

  PaymentsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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

