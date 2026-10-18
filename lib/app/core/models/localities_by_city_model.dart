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

class RegisterRequestLocalitiesModel {
  List<LocalitiesFromCityModel>? localities;
  bool? success;
  final String locale;

  RegisterRequestLocalitiesModel({this.localities, this.success, required this.locale});

  RegisterRequestLocalitiesModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['localities'] != null) {
      localities = <LocalitiesFromCityModel>[];
      json['localities'].forEach((v) {
        localities!.add(LocalitiesFromCityModel.fromJson(v, locale));
      });
    } else {
      localities = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (localities != null) {
      data['localities'] = localities!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class LocalitiesFromCityModel {
  LocationCoordinates? location;
  String? name;
  List<CommanTranslations>? translations;
  String? id;
  final String locale;
  LocalitiesFromCityModel({this.location, this.name, this.translations, this.id, required this.locale});

  LocalitiesFromCityModel.fromJson(Map<String, dynamic> json, this.locale) {
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

