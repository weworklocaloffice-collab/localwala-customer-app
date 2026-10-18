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

class DiningResponseModel {
  DiningCityInfoConfigModel? city;
  List<DiningRestaurantsInfoConfigModel>? dinings;
  List<DiningRestaurantsInfoConfigModel>? newArrivals;
  List<DiningRestaurantsInfoConfigModel>? popularDining;
  List<DiningCategoriesConfigModel>? categories;
  List<DiningCampaignConfigModel>? diningCampaign;
  DiningAppSettingsConfigModel? appSettings;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  String? findMode;
  bool? success;
  final String locale;
  DiningResponseModel({
    this.city,
    this.dinings,
    this.newArrivals,
    this.popularDining,
    this.categories,
    this.diningCampaign,
    this.appSettings,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
    this.findMode,
    this.success,
    required this.locale,
  });

  DiningResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    city = json['city'] != null ? DiningCityInfoConfigModel.fromJson(json['city'], locale) : null;
    if (json['dinings'] != null) {
      dinings = <DiningRestaurantsInfoConfigModel>[];
      json['dinings'].forEach((v) {
        dinings!.add(DiningRestaurantsInfoConfigModel.fromJson(v, locale));
      });
    } else {
      dinings = [];
    }
    if (json['newArrivals'] != null) {
      newArrivals = <DiningRestaurantsInfoConfigModel>[];
      json['newArrivals'].forEach((v) {
        newArrivals!.add(DiningRestaurantsInfoConfigModel.fromJson(v, locale));
      });
    } else {
      newArrivals = [];
    }
    if (json['popularDining'] != null) {
      popularDining = <DiningRestaurantsInfoConfigModel>[];
      json['popularDining'].forEach((v) {
        popularDining!.add(DiningRestaurantsInfoConfigModel.fromJson(v, locale));
      });
    } else {
      popularDining = [];
    }
    if (json['categories'] != null) {
      categories = <DiningCategoriesConfigModel>[];
      json['categories'].forEach((v) {
        categories!.add(DiningCategoriesConfigModel.fromJson(v, locale));
      });
    } else {
      categories = [];
    }
    if (json['diningCampaign'] != null) {
      diningCampaign = <DiningCampaignConfigModel>[];
      json['diningCampaign'].forEach((v) {
        diningCampaign!.add(DiningCampaignConfigModel.fromJson(v, locale));
      });
    } else {
      diningCampaign = [];
    }
    appSettings = json['appSettings'] != null ? DiningAppSettingsConfigModel.fromJson(json['appSettings']) : null;
    if (json['page'] != null && json['page'] != '') {
      page = int.parse(json['page'].toString());
    } else {
      page = 0;
    }
    if (json['limit'] != null && json['limit'] != '') {
      limit = int.parse(json['limit'].toString());
    } else {
      limit = 0;
    }
    if (json['totalPages'] != null && json['totalPages'] != '') {
      totalPages = int.parse(json['totalPages'].toString());
    } else {
      totalPages = 0;
    }
    if (json['totalResults'] != null && json['totalResults'] != '') {
      totalResults = int.parse(json['totalResults'].toString());
    } else {
      totalResults = 0;
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
    if (newArrivals != null) {
      data['newArrivals'] = newArrivals!.map((v) => v.toJson()).toList();
    }
    if (popularDining != null) {
      data['popularDining'] = popularDining!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (diningCampaign != null) {
      data['diningCampaign'] = diningCampaign!.map((v) => v.toJson()).toList();
    }
    if (appSettings != null) {
      data['appSettings'] = appSettings!.toJson();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    data['findMode'] = findMode;
    data['success'] = success;
    return data;
  }
}

class DiningCityInfoConfigModel {
  LocationCoordinates? location;
  String? name;
  String? image;
  List<DiningCityTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningCityInfoConfigModel({this.location, this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningCityInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <DiningCityTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCityTranslations.fromJson(v));
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

class DiningCityTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  DiningCityTranslations({this.name, this.code, this.nativeName, this.value});

  DiningCityTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningRestaurantsInfoConfigModel {
  String? name;
  String? address;
  List<RestaurantCuisineConfigModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  List<RestaurantTranslations>? translations;
  String? rating;
  bool? status;
  String? slug;
  String? distance;
  String? cuisineName;
  bool? isFavourite = false;
  bool? isHidden = false;
  String? id;
  double? dishPriceForTwo;
  bool? promote = false;
  final String locale;
  DiningRestaurantsInfoConfigModel({
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
    this.isFavourite,
    this.isHidden,
    this.id,
    this.dishPriceForTwo,
    this.promote,
    this.cuisineName,
    required this.locale,
  });

  DiningRestaurantsInfoConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    address = json['address'];
    if (json['cuisine'] != null) {
      cuisine = <RestaurantCuisineConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(RestaurantCuisineConfigModel.fromJson(v, locale));
        RestaurantCuisineConfigModel cuisineData = RestaurantCuisineConfigModel.fromJson(v, locale);
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
    if (json['isFavourite'] != null && json['isFavourite'] != '') {
      isFavourite = json['isFavourite'];
    } else {
      isFavourite = false;
    }
    if (json['isHidden'] != null && json['isHidden'] != '') {
      isHidden = json['isHidden'];
    } else {
      isHidden = false;
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
    data['slug'] = slug;
    data['distance'] = distance;
    data['isFavourite'] = isFavourite;
    data['isHidden'] = isHidden;
    data['id'] = id;
    data['dishPriceForTwo'] = dishPriceForTwo;
    data['promote'] = promote;
    return data;
  }
}

class RestaurantCuisineConfigModel {
  String? name;
  String? image;
  List<CuisineTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  RestaurantCuisineConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  RestaurantCuisineConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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

class DiningCategoriesConfigModel {
  String? name;
  String? image;
  List<CategoryTranslations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  DiningCategoriesConfigModel({this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  DiningCategoriesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    image = json['image'];
    if (json['translations'] != null) {
      translations = <CategoryTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CategoryTranslations.fromJson(v));
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

class CategoryTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? value;

  CategoryTranslations({this.name, this.code, this.nativeName, this.value});

  CategoryTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningCampaignConfigModel {
  String? title;
  String? shortDescription;
  String? image;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  List<DiningCampaignTranslations>? translations;
  String? id;
  final String locale;
  DiningCampaignConfigModel({this.title, this.shortDescription, this.image, this.startDate, this.endDate, this.startTime, this.endTime, this.translations, this.id, required this.locale});

  DiningCampaignConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    title = json['title'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    if (json['translations'] != null) {
      translations = <DiningCampaignTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(DiningCampaignTranslations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            title = translations![localeIndex].title!;
          }
          if (translations![localeIndex].shortDescription!.isNotEmpty) {
            shortDescription = translations![localeIndex].shortDescription!;
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
    data['title'] = title;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class DiningCampaignTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  DiningCampaignTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  DiningCampaignTranslations.fromJson(Map<String, dynamic> json) {
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

class DiningAppSettingsConfigModel {
  bool? showNewDiningRestaurant;
  bool? showPopularDiningRestaurant;
  String? id;

  DiningAppSettingsConfigModel({this.showNewDiningRestaurant, this.showPopularDiningRestaurant, this.id});

  DiningAppSettingsConfigModel.fromJson(Map<String, dynamic> json) {
    showNewDiningRestaurant = json['showNewDiningRestaurant'];
    showPopularDiningRestaurant = json['showPopularDiningRestaurant'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['showNewDiningRestaurant'] = showNewDiningRestaurant;
    data['showPopularDiningRestaurant'] = showPopularDiningRestaurant;
    data['id'] = id;
    return data;
  }
}

