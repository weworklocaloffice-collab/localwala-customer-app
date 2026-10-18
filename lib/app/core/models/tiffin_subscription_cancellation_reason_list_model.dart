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

class TiffinSubscriptionCancellationReasonListModel {
  List<TiffinSubscriptionCancellationReasonModel>? reasons;
  final String locale;
  TiffinSubscriptionCancellationReasonListModel({this.reasons, required this.locale});

  TiffinSubscriptionCancellationReasonListModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['reasons'] != null) {
      reasons = <TiffinSubscriptionCancellationReasonModel>[];
      json['reasons'].forEach((v) {
        reasons!.add(TiffinSubscriptionCancellationReasonModel.fromJson(v, locale));
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

class TiffinSubscriptionCancellationReasonModel {
  String? name;
  List<TiffinSubscriptionCancellationReasonTranslations>? translations;
  String? id;
  final String locale;
  TiffinSubscriptionCancellationReasonModel({this.name, this.translations, this.id, required this.locale});

  TiffinSubscriptionCancellationReasonModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['translations'] != null) {
      translations = <TiffinSubscriptionCancellationReasonTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(TiffinSubscriptionCancellationReasonTranslations.fromJson(v));
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

class TiffinSubscriptionCancellationReasonTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  TiffinSubscriptionCancellationReasonTranslations({this.name, this.code, this.nativeName, this.value});

  TiffinSubscriptionCancellationReasonTranslations.fromJson(Map<String, dynamic> json) {
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

