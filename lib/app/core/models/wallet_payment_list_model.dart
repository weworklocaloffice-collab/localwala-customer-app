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

class WalletAddMoneyBasicDetailModel {
  bool? success;
  List<PaymentConfigModel>? payments;
  PaymentConfigModel? primary;
  List<BonusConfigModel>? bonus;
  final String locale;
  WalletAddMoneyBasicDetailModel({this.success, this.payments, this.primary, this.bonus, required this.locale});

  WalletAddMoneyBasicDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    if (json['bonus'] != null) {
      bonus = <BonusConfigModel>[];
      json['bonus'].forEach((v) {
        bonus!.add(BonusConfigModel.fromJson(v, locale));
      });
    } else {
      bonus = [];
    }
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
    if (bonus != null) {
      data['bonus'] = bonus!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentConfigModel {
  String? name;
  String? slug;
  String? image;
  List<Translations>? translations;
  bool? isDefault;
  String? id;
  final String locale;
  PaymentConfigModel({this.name, this.slug, this.image, this.translations, this.isDefault, this.id, required this.locale});

  PaymentConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    slug = json['slug'];
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

class BonusConfigModel {
  String? name;
  String? shortDescription;
  String? image;
  String? start;
  String? expires;
  String? bonusType;
  double? bonusAmount;
  double? minWalletAmount;
  double? maxBonusAmount;
  List<BonusTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  BonusConfigModel({
    this.name,
    this.shortDescription,
    this.image,
    this.start,
    this.expires,
    this.bonusType,
    this.bonusAmount,
    this.minWalletAmount,
    this.maxBonusAmount,
    this.translations,
    this.status,
    this.id,
    required this.locale,
  });

  BonusConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    if (json['start'] != null && json['start'] != '') {
      String dateString = json['start'];
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat("d MMM, y", locale).format(dateTime);
      start = formattedDate;
    } else {
      start = '15 July, 2025';
    }
    if (json['expires'] != null && json['expires'] != '') {
      String dateString = json['expires'];
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat("d MMM, y", locale).format(dateTime);
      expires = formattedDate;
    } else {
      expires = '15 July, 2025';
    }
    bonusType = json['bonusType'];
    if (json['bonusAmount'] != null && json['bonusAmount'] != '') {
      bonusAmount = double.parse(json['bonusAmount'].toString());
    } else {
      bonusAmount = 0;
    }
    if (json['minWalletAmount'] != null && json['minWalletAmount'] != '') {
      minWalletAmount = double.parse(json['minWalletAmount'].toString());
    } else {
      minWalletAmount = 0;
    }
    if (json['maxBonusAmount'] != null && json['maxBonusAmount'] != '') {
      maxBonusAmount = double.parse(json['maxBonusAmount'].toString());
    } else {
      maxBonusAmount = 0;
    }
    if (json['translations'] != null) {
      translations = <BonusTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(BonusTranslations.fromJson(v));
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
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['start'] = start;
    data['expires'] = expires;
    data['bonusType'] = bonusType;
    data['bonusAmount'] = bonusAmount;
    data['minWalletAmount'] = minWalletAmount;
    data['maxBonusAmount'] = maxBonusAmount;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class BonusTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  BonusTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  BonusTranslations.fromJson(Map<String, dynamic> json) {
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

