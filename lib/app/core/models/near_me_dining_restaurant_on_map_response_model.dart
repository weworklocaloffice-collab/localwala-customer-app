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

class NearMeDiningRestaurantsOnMapResponseModel {
  NearMeDiningRestaurantOnMapCityConfigModel? city;
  List<NearMeDiningOnMapRestaurantInfoConfigModel>? dinings;
  String? findMode;
  bool? success;
  final String locale;
  NearMeDiningRestaurantsOnMapResponseModel({this.city, this.findMode, this.success, required this.locale});

  NearMeDiningRestaurantsOnMapResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    city = json['city'] != null ? NearMeDiningRestaurantOnMapCityConfigModel.fromJson(json['city'], locale) : null;
    if (json['dinings'] != null) {
      dinings = <NearMeDiningOnMapRestaurantInfoConfigModel>[];
      json['dinings'].forEach((v) {
        dinings!.add(NearMeDiningOnMapRestaurantInfoConfigModel.fromJson(v, locale));
      });
    } else {
      dinings = [];
    }
    findMode = json['findMode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (dinings != null) {
      data['dinings'] = dinings!.map((v) => v.toJson()).toList();
    }
    data['findMode'] = findMode;
    data['success'] = success;
    return data;
  }
}

class NearMeDiningRestaurantOnMapCityConfigModel {
  LocationCoordinates? location;
  String? name;
  String? image;
  List<NearMeDiningRestaurantOnMapTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  NearMeDiningRestaurantOnMapCityConfigModel({this.location, this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  NearMeDiningRestaurantOnMapCityConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <NearMeDiningRestaurantOnMapTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(NearMeDiningRestaurantOnMapTranslations.fromJson(v));
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
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
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

class NearMeDiningRestaurantOnMapTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  NearMeDiningRestaurantOnMapTranslations({this.name, this.code, this.nativeName, this.value});

  NearMeDiningRestaurantOnMapTranslations.fromJson(Map<String, dynamic> json) {
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

class NearMeDiningOnMapRestaurantInfoConfigModel {
  String? name;
  String? address;
  List<NearMeDiningRestaurantOnMapCuisineConfigModel>? cuisine;
  String? cuisineName;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<NearMeDiningRestaurantOnMapRestaurantTranslations>? translations;
  LocationCoordinates? location;
  String? rating;
  bool? status;
  String? slug;
  String? distance;
  String? id;
  double? dishPriceForTwo;
  bool? promote;
  final String locale;
  NearMeDiningOnMapRestaurantInfoConfigModel({
    this.name,
    this.address,
    this.cuisine,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.translations,
    this.rating,
    this.status,
    this.slug,
    this.distance,
    this.location,
    this.id,
    this.dishPriceForTwo,
    this.promote,
    this.cuisineName,
    required this.locale,
  });

  NearMeDiningOnMapRestaurantInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    if (json['cuisine'] != null) {
      cuisine = <NearMeDiningRestaurantOnMapCuisineConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(NearMeDiningRestaurantOnMapCuisineConfigModel.fromJson(v, locale));
        NearMeDiningRestaurantOnMapCuisineConfigModel cuisineData = NearMeDiningRestaurantOnMapCuisineConfigModel.fromJson(v, locale);
        names.add(cuisineData.name!);
      });
      cuisineName = names.join(' • ');
    } else {
      cuisine = [];
      cuisineName = '';
    }

    logo = json['logo'];
    cover = json['cover'];
    approxDeliveryTime = json['approxDeliveryTime'];
    if (json['translations'] != null) {
      translations = <NearMeDiningRestaurantOnMapRestaurantTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(NearMeDiningRestaurantOnMapRestaurantTranslations.fromJson(v));
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
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString()).toStringAsFixed(1);
    } else {
      rating = '0.0';
    }
    status = json['status'];
    slug = json['slug'];
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString()).toStringAsFixed(1);
    } else {
      distance = '0.0';
    }
    id = json['id'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }
    if (json['promote'] != null && json['promote'] != '') {
      promote = json['promote'];
    } else {
      promote = false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    data['logo'] = logo;
    data['cover'] = cover;
    data['approxDeliveryTime'] = approxDeliveryTime;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['status'] = status;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['slug'] = slug;
    data['distance'] = distance;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['promote'] = promote;
    return data;
  }
}

class NearMeDiningRestaurantOnMapCuisineConfigModel {
  String? name;
  String? image;
  List<NearMeDiningRestaurantOnMapCuisineTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  NearMeDiningRestaurantOnMapCuisineConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  NearMeDiningRestaurantOnMapCuisineConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <NearMeDiningRestaurantOnMapCuisineTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(NearMeDiningRestaurantOnMapCuisineTranslations.fromJson(v));
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
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class NearMeDiningRestaurantOnMapRestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  NearMeDiningRestaurantOnMapRestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  NearMeDiningRestaurantOnMapRestaurantTranslations.fromJson(Map<String, dynamic> json) {
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

class NearMeDiningRestaurantOnMapCuisineTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  NearMeDiningRestaurantOnMapCuisineTranslations({this.name, this.code, this.nativeName, this.value});

  NearMeDiningRestaurantOnMapCuisineTranslations.fromJson(Map<String, dynamic> json) {
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

