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

class TiffinSubscriptionRefundReasonListModel {
  List<TiffinSubscriptionReasonsConfigModel>? reasons;
  final String locale;
  TiffinSubscriptionRefundReasonListModel({this.reasons, required this.locale});

  TiffinSubscriptionRefundReasonListModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['reasons'] != null) {
      reasons = <TiffinSubscriptionReasonsConfigModel>[];
      json['reasons'].forEach((v) {
        reasons!.add(TiffinSubscriptionReasonsConfigModel.fromJson(v, locale));
      });
    } else {
      reasons = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (reasons != null) {
      data['reasons'] = reasons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TiffinSubscriptionReasonsConfigModel {
  String? name;
  List<TiffinSubscriptionReasonsTranslations>? translations;
  bool? status;
  String? id;
  final String locale;
  TiffinSubscriptionReasonsConfigModel({this.name, this.translations, this.status, this.id, required this.locale});

  TiffinSubscriptionReasonsConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <TiffinSubscriptionReasonsTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(TiffinSubscriptionReasonsTranslations.fromJson(v));
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

class TiffinSubscriptionReasonsTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  TiffinSubscriptionReasonsTranslations({this.name, this.code, this.nativeName, this.value});

  TiffinSubscriptionReasonsTranslations.fromJson(Map<String, dynamic> json) {
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

