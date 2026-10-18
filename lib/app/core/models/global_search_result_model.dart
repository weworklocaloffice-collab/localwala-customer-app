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

class GlobalSearchResultModel {
  List<CategoriesResultModel>? categories;
  List<CuisineResultModel>? cuisines;
  List<RestaurantResultModel>? restaurants;
  List<BrandsResultModel>? brands;
  bool? success;
  final String locale;
  GlobalSearchResultModel({this.categories, this.cuisines, this.restaurants, this.brands, this.success, required this.locale});

  GlobalSearchResultModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['categories'] != null) {
      categories = <CategoriesResultModel>[];
      json['categories'].forEach((v) {
        categories!.add(CategoriesResultModel.fromJson(v, locale));
      });
    } else {
      categories = [];
    }
    if (json['cuisines'] != null) {
      cuisines = <CuisineResultModel>[];
      json['cuisines'].forEach((v) {
        cuisines!.add(CuisineResultModel.fromJson(v, locale));
      });
    } else {
      cuisines = [];
    }
    if (json['restaurants'] != null) {
      restaurants = <RestaurantResultModel>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(RestaurantResultModel.fromJson(v, locale));
      });
    } else {
      restaurants = [];
    }
    if (json['brands'] != null) {
      brands = <BrandsResultModel>[];
      json['brands'].forEach((v) {
        brands!.add(BrandsResultModel.fromJson(v, locale));
      });
    } else {
      brands = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (cuisines != null) {
      data['cuisines'] = cuisines!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class CategoriesResultModel {
  String? name;
  String? image;
  List<CategoriesTranslations>? translations;
  String? slug;
  String? id;
  final String locale;
  CategoriesResultModel({this.name, this.image, this.translations, this.slug, this.id, required this.locale});

  CategoriesResultModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <CategoriesTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CategoriesTranslations.fromJson(v));
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
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class CategoriesTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CategoriesTranslations({this.name, this.code, this.nativeName, this.value});

  CategoriesTranslations.fromJson(Map<String, dynamic> json) {
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

class CuisineResultModel {
  String? name;
  String? image;
  List<CuisineTranslations>? translations;
  String? slug;
  String? id;
  final String locale;
  CuisineResultModel({this.name, this.image, this.translations, this.slug, this.id, required this.locale});

  CuisineResultModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <CuisineTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CuisineTranslations.fromJson(v));
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
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class CuisineTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CuisineTranslations({this.name, this.code, this.nativeName, this.value});

  CuisineTranslations.fromJson(Map<String, dynamic> json) {
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

class RestaurantResultModel {
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  bool? status;
  String? slug;
  double? distance;
  String? id;
  final String locale;
  RestaurantResultModel({this.name, this.logo, this.cover, this.translations, this.status, this.slug, this.distance, this.id, required this.locale});

  RestaurantResultModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    status = json['status'];
    slug = json['slug'];
    distance = json['distance'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['slug'] = slug;
    data['distance'] = distance;
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

class BrandsResultModel {
  String? name;
  String? logo;
  String? cover;
  List<BrandsTranslations>? translations;
  String? slug;
  String? id;
  final String locale;
  BrandsResultModel({this.name, this.logo, this.cover, this.translations, this.slug, this.id, required this.locale});

  BrandsResultModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    if (json['translations'] != null) {
      translations = <BrandsTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(BrandsTranslations.fromJson(v));
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
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}

class BrandsTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  BrandsTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  BrandsTranslations.fromJson(Map<String, dynamic> json) {
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

