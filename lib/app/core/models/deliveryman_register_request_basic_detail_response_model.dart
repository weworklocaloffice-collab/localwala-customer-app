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

class DeliverymanRegisterRequestBasicDetailModel {
  List<DeliverymanRegisterRequestCitiesModel>? cities;
  List<DeliverymanRegisterRequestVehicleModel>? vehicles;
  DeliverymanJoiningFormSetupModel? joiningForm;
  bool? success;
  final String locale;
  DeliverymanRegisterRequestBasicDetailModel({this.cities, this.vehicles, this.joiningForm, this.success, required this.locale});

  DeliverymanRegisterRequestBasicDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['cities'] != null) {
      cities = <DeliverymanRegisterRequestCitiesModel>[];
      json['cities'].forEach((v) {
        cities!.add(DeliverymanRegisterRequestCitiesModel.fromJson(v, locale));
      });
    } else {
      cities = [];
    }
    if (json['vehicles'] != null) {
      vehicles = <DeliverymanRegisterRequestVehicleModel>[];
      json['vehicles'].forEach((v) {
        vehicles!.add(DeliverymanRegisterRequestVehicleModel.fromJson(v, locale));
      });
    } else {
      vehicles = [];
    }
    joiningForm = json['joiningForm'] != null ? DeliverymanJoiningFormSetupModel.fromJson(json['joiningForm']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    if (vehicles != null) {
      data['vehicles'] = vehicles!.map((v) => v.toJson()).toList();
    }
    if (joiningForm != null) {
      data['joiningForm'] = joiningForm!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class DeliverymanRegisterRequestCitiesModel {
  LocationCoordinates? location;
  String? name;
  List<CommanTranslations>? translations;
  String? id;
  final String locale;
  DeliverymanRegisterRequestCitiesModel({this.location, this.name, this.translations, this.id, required this.locale});

  DeliverymanRegisterRequestCitiesModel.fromJson(Map<String, dynamic> json, this.locale) {
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

class DeliverymanRegisterRequestVehicleModel {
  String? name;
  List<CommanTranslations>? translations;
  String? id;
  final String locale;
  DeliverymanRegisterRequestVehicleModel({this.name, this.translations, this.id, required this.locale});

  DeliverymanRegisterRequestVehicleModel.fromJson(Map<String, dynamic> json, this.locale) {
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

class DeliverymanJoiningFormSetupModel {
  JoiningFormResultConfig? result;
  bool? success;

  DeliverymanJoiningFormSetupModel({this.result, this.success});

  DeliverymanJoiningFormSetupModel.fromJson(Map<String, dynamic> json) {
    result = json['result'] != null ? JoiningFormResultConfig.fromJson(json['result']) : null;
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

class JoiningFormResultConfig {
  List<DeliverymanFormConfigModel>? deliverymanForm;
  String? id;

  JoiningFormResultConfig({this.deliverymanForm, this.id});

  JoiningFormResultConfig.fromJson(Map<String, dynamic> json) {
    if (json['deliverymanForm'] != null) {
      deliverymanForm = <DeliverymanFormConfigModel>[];
      json['deliverymanForm'].forEach((v) {
        deliverymanForm!.add(DeliverymanFormConfigModel.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (deliverymanForm != null) {
      data['deliverymanForm'] = deliverymanForm!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class DeliverymanFormConfigModel {
  String? uuid;
  bool? isRequired;
  String? type;
  String? title;
  String? placeholder;
  List<JoiningFormCheckboxItemConfigModel>? items;

  DeliverymanFormConfigModel({this.uuid, this.isRequired, this.type, this.title, this.placeholder, this.items});

  DeliverymanFormConfigModel.fromJson(Map<String, dynamic> json) {
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

