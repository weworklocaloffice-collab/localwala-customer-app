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

class DiningBookingInformationResponseModel {
  DiningRestaurantInfoConfigModel? details;
  List<SlotsConfigModel>? slots;
  DinnigSettingConfigModel? dinnigSetting;
  List<DiningBookingCouponConfigModel>? diningCoupons;
  List<int>? guestAvailability;
  bool? success;
  final String locale;
  DiningBookingInformationResponseModel({this.details, this.slots, this.dinnigSetting, this.diningCoupons, this.guestAvailability, this.success, required this.locale});

  DiningBookingInformationResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    details = json['details'] != null ? DiningRestaurantInfoConfigModel.fromJson(json['details'], locale) : null;
    if (json['slots'] != null) {
      slots = <SlotsConfigModel>[];
      json['slots'].forEach((v) {
        slots!.add(SlotsConfigModel.fromJson(v));
      });
    } else {
      slots = [];
    }
    dinnigSetting = json['dinnigSetting'] != null ? DinnigSettingConfigModel.fromJson(json['dinnigSetting']) : null;
    if (json['diningCoupons'] != null) {
      diningCoupons = <DiningBookingCouponConfigModel>[];
      json['diningCoupons'].forEach((v) {
        diningCoupons!.add(DiningBookingCouponConfigModel.fromJson(v, locale));
      });
    } else {
      diningCoupons = [];
    }
    guestAvailability = (json['guestAvailability'] as List?)?.cast<int>() ?? [];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (details != null) {
      data['details'] = details!.toJson();
    }
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    if (dinnigSetting != null) {
      data['dinnigSetting'] = dinnigSetting!.toJson();
    }
    if (diningCoupons != null) {
      data['diningCoupons'] = diningCoupons!.map((v) => v.toJson()).toList();
    }
    data['guestAvailability'] = guestAvailability;
    data['success'] = success;
    return data;
  }
}

class DiningRestaurantInfoConfigModel {
  String? name;
  String? address;
  String? logo;
  String? cover;
  LocationCoordinates? location;
  List<RestaurantTranslations>? translations;
  String? slug;
  String? id;
  double? dishPriceForTwo;
  bool? preBooking;
  RestaurantOwerInfoConfigModel? owerInfo;
  final String locale;
  DiningRestaurantInfoConfigModel({this.name, this.address, this.logo, this.cover, this.location, this.translations, this.slug, this.id, this.dishPriceForTwo, this.preBooking, this.owerInfo, required this.locale});

  DiningRestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    logo = json['logo'];
    cover = json['cover'];
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
    slug = json['slug'];
    id = json['id'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
    preBooking = json['preBooking'];
    owerInfo = json['owerInfo'] != null ? RestaurantOwerInfoConfigModel.fromJson(json['owerInfo']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['logo'] = logo;
    data['cover'] = cover;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['slug'] = slug;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['preBooking'] = preBooking;
    if (owerInfo != null) {
      data['owerInfo'] = owerInfo!.toJson();
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

class RestaurantOwerInfoConfigModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;
  String? countryCode;
  String? contactNumber;
  String? contactEmail;

  RestaurantOwerInfoConfigModel({this.id, this.firstName, this.lastName, this.image, this.countryCode, this.contactNumber, this.contactEmail});

  RestaurantOwerInfoConfigModel.fromJson(Map<String, dynamic> json) {
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

class SlotsConfigModel {
  int? day;
  List<DiningSlotTimeConfigModel>? times;

  SlotsConfigModel({this.day, this.times});

  SlotsConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['day'] != null && json['day'] != '') {
      day = int.parse(json['day'].toString());
    } else {
      day = 0;
    }
    if (json['times'] != null) {
      times = <DiningSlotTimeConfigModel>[];
      json['times'].forEach((v) {
        times!.add(DiningSlotTimeConfigModel.fromJson(v));
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

class DiningSlotTimeConfigModel {
  String? type;
  String? time;

  DiningSlotTimeConfigModel({this.type, this.time});

  DiningSlotTimeConfigModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['time'] = time;
    return data;
  }
}

class DinnigSettingConfigModel {
  bool? preBookingChargeRequired;
  bool? guestBooking;
  double? minBookingCharge;
  String? id;

  DinnigSettingConfigModel({this.preBookingChargeRequired, this.guestBooking, this.minBookingCharge, this.id});

  DinnigSettingConfigModel.fromJson(Map<String, dynamic> json) {
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

class DiningBookingCouponConfigModel {
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
  final String locale;
  DiningBookingCouponConfigModel({
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
    required this.locale,
  });

  DiningBookingCouponConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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

