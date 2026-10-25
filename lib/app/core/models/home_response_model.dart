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

class HomeResponseModel {
  AppSettingInfoModel? appSettings;
  CityConfigModel? city;
  List<RestaurantsModel>? restaurants;
  List<RestaurantsModel>? newArrivals;
  List<RestaurantsModel>? popularRestaurant;
  List<Brands>? brands;
  List<FoodsModel>? mostReviewedFoods;
  List<FoodsModel>? popularFoods;
  List<FoodsModel>? trendingFoods;
  List<CuisineConfigModel>? cuisine;
  List<CategoriesConfigModel>? categories;
  List<BannersModel>? banners;

  /// Resolved silver app bar + promotional banner. `null` means no banner is
  /// active, so the header renders exactly as it does today.
  HeaderBannerModel? headerBanner;
  List<CampaignConfigModel>? restaurantCampaign;
  List<CampaignConfigModel>? foodCampaign;
  List<TiffinSubscriptionPackagesInfoModel>? tiffinSubscriptionPackages;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  String? findMode;
  bool? success;
  final String locale;

  HomeResponseModel({
    this.appSettings,
    this.city,
    this.restaurants,
    this.newArrivals,
    this.popularRestaurant,
    this.brands,
    this.mostReviewedFoods,
    this.popularFoods,
    this.trendingFoods,
    this.cuisine,
    this.categories,
    this.banners,
    this.headerBanner,
    this.restaurantCampaign,
    this.foodCampaign,
    this.tiffinSubscriptionPackages,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
    this.findMode,
    this.success,
    required this.locale,
  });

  HomeResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    appSettings = json['appSettings'] != null ? AppSettingInfoModel.fromJson(json['appSettings']) : null;
    city = json['city'] != null ? CityConfigModel.fromJson(json['city'], locale) : null;
    if (json['restaurants'] != null) {
      restaurants = <RestaurantsModel>[];
      json['restaurants'].forEach((v) {
        restaurants!.add(RestaurantsModel.fromJson(v, locale));
      });
    } else {
      restaurants = [];
    }
    if (json['newArrivals'] != null) {
      newArrivals = <RestaurantsModel>[];
      json['newArrivals'].forEach((v) {
        newArrivals!.add(RestaurantsModel.fromJson(v, locale));
      });
    } else {
      newArrivals = [];
    }
    if (json['popularRestaurant'] != null) {
      popularRestaurant = <RestaurantsModel>[];
      json['popularRestaurant'].forEach((v) {
        popularRestaurant!.add(RestaurantsModel.fromJson(v, locale));
      });
    } else {
      popularRestaurant = [];
    }
    if (json['brands'] != null) {
      brands = <Brands>[];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v, locale));
      });
    } else {
      brands = [];
    }
    if (json['mostReviewedFoods'] != null) {
      mostReviewedFoods = <FoodsModel>[];
      json['mostReviewedFoods'].forEach((v) {
        mostReviewedFoods!.add(FoodsModel.fromJson(v, locale));
      });
    } else {
      mostReviewedFoods = [];
    }
    if (json['popularFoods'] != null) {
      popularFoods = <FoodsModel>[];
      json['popularFoods'].forEach((v) {
        popularFoods!.add(FoodsModel.fromJson(v, locale));
      });
    } else {
      popularFoods = [];
    }
    if (json['trendingFoods'] != null) {
      trendingFoods = <FoodsModel>[];
      json['trendingFoods'].forEach((v) {
        trendingFoods!.add(FoodsModel.fromJson(v, locale));
      });
    } else {
      trendingFoods = [];
    }
    if (json['cuisine'] != null) {
      cuisine = <CuisineConfigModel>[];
      json['cuisine'].forEach((v) {
        cuisine!.add(CuisineConfigModel.fromJson(v, locale));
      });
    } else {
      cuisine = [];
    }
    if (json['categories'] != null) {
      categories = <CategoriesConfigModel>[];
      json['categories'].forEach((v) {
        categories!.add(CategoriesConfigModel.fromJson(v, locale));
      });
    } else {
      categories = [];
    }
    if (json['banners'] != null) {
      banners = <BannersModel>[];
      json['banners'].forEach((v) {
        banners!.add(BannersModel.fromJson(v, locale));
      });
    } else {
      banners = [];
    }
    if (json['headerBanner'] != null) {
      headerBanner = HeaderBannerModel.fromJson(json['headerBanner'], locale);
    }
    if (json['restaurantCampaign'] != null) {
      restaurantCampaign = <CampaignConfigModel>[];
      json['restaurantCampaign'].forEach((v) {
        restaurantCampaign!.add(CampaignConfigModel.fromJson(v, locale));
      });
    } else {
      restaurantCampaign = [];
    }
    if (json['foodCampaign'] != null) {
      foodCampaign = <CampaignConfigModel>[];
      json['foodCampaign'].forEach((v) {
        foodCampaign!.add(CampaignConfigModel.fromJson(v, locale));
      });
    } else {
      foodCampaign = [];
    }
    if (json['tiffinSubscriptionPackages'] != null) {
      tiffinSubscriptionPackages = <TiffinSubscriptionPackagesInfoModel>[];
      json['tiffinSubscriptionPackages'].forEach((v) {
        tiffinSubscriptionPackages!.add(TiffinSubscriptionPackagesInfoModel.fromJson(v, locale));
      });
    } else {
      tiffinSubscriptionPackages = [];
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
    findMode = json['findMode'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (appSettings != null) {
      data['appSettings'] = appSettings!.toJson();
    }
    if (city != null) {
      data['city'] = city!.toJson();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.map((v) => v.toJson()).toList();
    }
    if (newArrivals != null) {
      data['newArrivals'] = newArrivals!.map((v) => v.toJson()).toList();
    }
    if (popularRestaurant != null) {
      data['popularRestaurant'] = popularRestaurant!.map((v) => v.toJson()).toList();
    }
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    if (mostReviewedFoods != null) {
      data['mostReviewedFoods'] = mostReviewedFoods!.map((v) => v.toJson()).toList();
    }
    if (popularFoods != null) {
      data['popularFoods'] = popularFoods!.map((v) => v.toJson()).toList();
    }
    if (trendingFoods != null) {
      data['trendingFoods'] = trendingFoods!.map((v) => v.toJson()).toList();
    }
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (banners != null) {
      data['banners'] = banners!.map((v) => v.toJson()).toList();
    }
    if (headerBanner != null) {
      data['headerBanner'] = headerBanner!.toJson();
    }
    if (restaurantCampaign != null) {
      data['restaurantCampaign'] = restaurantCampaign!.map((v) => v.toJson()).toList();
    }
    if (foodCampaign != null) {
      data['foodCampaign'] = foodCampaign!.map((v) => v.toJson()).toList();
    }
    if (tiffinSubscriptionPackages != null) {
      data['tiffinSubscriptionPackages'] = tiffinSubscriptionPackages!.map((v) => v.toJson()).toList();
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

class AppSettingInfoModel {
  bool? showPopularFood;
  bool? showPopularRestaurant;
  bool? showNewRestaurant;
  bool? showMostReviewedFood;
  bool? showTiffinSubscriptionPackages;
  bool? showTodaysTrendingFood;
  String? id;

  AppSettingInfoModel({this.showPopularFood, this.showPopularRestaurant, this.showNewRestaurant, this.showMostReviewedFood, this.showTiffinSubscriptionPackages, this.showTodaysTrendingFood, this.id});

  AppSettingInfoModel.fromJson(Map<String, dynamic> json) {
    showPopularFood = json['showPopularFood'];
    showPopularRestaurant = json['showPopularRestaurant'];
    showNewRestaurant = json['showNewRestaurant'];
    showMostReviewedFood = json['showMostReviewedFood'];
    showTiffinSubscriptionPackages = json['showTiffinSubscriptionPackages'];
    showTodaysTrendingFood = json['showTodaysTrendingFood'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['showPopularFood'] = showPopularFood;
    data['showPopularRestaurant'] = showPopularRestaurant;
    data['showNewRestaurant'] = showNewRestaurant;
    data['showMostReviewedFood'] = showMostReviewedFood;
    data['showTiffinSubscriptionPackages'] = showTiffinSubscriptionPackages;
    data['showTodaysTrendingFood'] = showTodaysTrendingFood;
    data['id'] = id;
    return data;
  }
}

class CityConfigModel {
  LocationCoordinates? location;
  String? name;
  String? image;
  List<Translations>? translations;
  bool? status;
  String? slug;
  String? id;
  final String locale;
  CityConfigModel({this.location, this.name, this.image, this.translations, this.status, this.slug, this.id, required this.locale});

  CityConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    name = json['name'];
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

class RestaurantsModel {
  String? name;
  List<CuisineConfigModel>? cuisine;
  String? logo;
  String? cover;
  String? approxDeliveryTime;
  double? dishPriceForTwo;
  List<RestaurantTranslations>? translations;
  String? rating;
  bool? status;
  String? slug;
  List<Slots>? slots;
  bool? promote = false;
  String? distance;
  String? cuisineName;
  String? address;
  bool? isFavourite = false;
  bool? isHidden = false;
  String? id;
  final String locale;

  RestaurantsModel({
    this.name,
    this.cuisine,
    this.logo,
    this.cover,
    this.approxDeliveryTime,
    this.dishPriceForTwo,
    this.translations,
    this.rating,
    this.status,
    this.slug,
    this.slots,
    this.promote,
    this.distance,
    this.cuisineName,
    this.address,
    this.isFavourite,
    this.isHidden,
    this.id,
    required this.locale,
  });

  RestaurantsModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    if (json['cuisine'] != null) {
      cuisine = <CuisineConfigModel>[];
      List<String> names = <String>[];
      names.clear();
      json['cuisine'].forEach((v) {
        cuisine!.add(CuisineConfigModel.fromJson(v, locale));
        CuisineConfigModel cuisineData = CuisineConfigModel.fromJson(v, locale);
        if (locale.isNotEmpty && cuisineData.name!.isNotEmpty && cuisineData.translations!.isNotEmpty) {
          final int localeIndex = cuisineData.translations!.indexWhere((tLocale) => tLocale.code! == locale);
          if (localeIndex != -1) {
            if (cuisineData.translations![localeIndex].value!.isNotEmpty) {
              names.add(cuisineData.translations![localeIndex].value!);
            }
          } else {
            names.add(cuisineData.name!);
          }
        }
      });
      cuisineName = names.join(' • ');
    } else {
      cuisine = [];
      cuisineName = '';
    }
    logo = json['logo'];
    cover = json['cover'];
    approxDeliveryTime = json['approxDeliveryTime'];
    if (json['dishPriceForTwo'] != null && json['dishPriceForTwo'] != '') {
      dishPriceForTwo = double.parse(json['dishPriceForTwo'].toString());
    } else {
      dishPriceForTwo = 0.0;
    }

    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString()).toStringAsFixed(1);
    } else {
      rating = '0.0';
    }

    status = json['status'];
    slug = json['slug'];
    if (json['slots'] != null) {
      slots = <Slots>[];
      json['slots'].forEach((v) {
        slots!.add(Slots.fromJson(v));
      });
    } else {
      slots = [];
    }
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString()).toStringAsFixed(1);
    } else {
      distance = '0.0';
    }
    address = json['address'];
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
    if (json['promote'] != null && json['promote'] != '') {
      promote = json['promote'];
    } else {
      promote = false;
    }
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
    if (cuisine != null) {
      data['cuisine'] = cuisine!.map((v) => v.toJson()).toList();
    }
    data['logo'] = logo;
    data['cover'] = cover;
    data['approxDeliveryTime'] = approxDeliveryTime;
    data['dishPriceForTwo'] = dishPriceForTwo;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;

    data['status'] = status;
    data['slug'] = slug;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    data['promote'] = promote;
    data['distance'] = distance;
    data['cuisineName'] = cuisineName;
    data['address'] = address;
    data['isFavourite'] = isFavourite;
    data['isHidden'] = isHidden;
    data['id'] = id;
    return data;
  }
}

class CuisineConfigModel {
  String? name;
  String? image;
  List<Translations>? translations;
  bool? status;
  String? slug;
  final String locale;

  CuisineConfigModel({this.name, this.image, this.translations, this.status, this.slug, required this.locale});

  CuisineConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
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
    status = json['status'];
    slug = json['slug'];
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
    return data;
  }
}

class CategoriesConfigModel {
  String? name;
  String? image;
  List<Translations>? translations;
  bool? status;
  String? slug;
  final String locale;

  CategoriesConfigModel({this.name, this.image, this.translations, this.status, this.slug, required this.locale});

  CategoriesConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
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
    status = json['status'];
    slug = json['slug'];
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

class Slots {
  int? day;
  List<Times>? times;

  Slots({this.day, this.times});

  Slots.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    if (json['times'] != null) {
      times = <Times>[];
      json['times'].forEach((v) {
        times!.add(Times.fromJson(v));
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

class Times {
  String? start;
  String? end;

  Times({this.start, this.end});

  Times.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start'] = start;
    data['end'] = end;
    return data;
  }
}

class Brands {
  String? name;
  String? slug;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  String? id;
  final String locale;

  Brands({this.name, this.slug, this.logo, this.cover, this.translations, this.id, required this.locale});

  Brands.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    slug = json['slug'];
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
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['slug'] = slug;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    return data;
  }
}

class FoodsModel {
  String? name;
  String? shortDescription;
  String? image;
  String? restaurant;
  String? foodType;
  List<AddonConfigModel>? addons;
  String? startTime;
  String? endTime;
  double? price;
  String? discountType;
  double? discount;
  double? offerPrice = 0.0;
  List<VariationConfigModel>? variations;
  List<FoodTranslations>? translations;
  FoodRestaurantInfo? restaurants;
  bool? recommended;
  double? rating;
  String? totalRating;
  int? purchaseLimit;
  bool? isFavourite;
  int? quantity;
  String? cartEntity;
  String? status;
  bool? inStock;
  bool? taxationEnable;
  List<TaxationConfigModel>? foodtaxations;
  String? id;
  int? stockNumber;
  String? stockType;
  final String locale;

  FoodsModel({
    this.name,
    this.shortDescription,
    this.image,
    this.restaurant,
    this.foodType,
    this.addons,
    this.startTime,
    this.endTime,
    this.price,
    this.discountType,
    this.discount,
    this.offerPrice,
    this.variations,
    this.translations,
    this.restaurants,
    this.recommended,
    this.rating,
    this.totalRating,
    this.purchaseLimit,
    this.isFavourite = false,
    this.quantity,
    this.cartEntity,
    this.status,
    this.inStock,
    this.taxationEnable,
    this.foodtaxations,
    this.id,
    this.stockNumber,
    this.stockType,
    required this.locale,
  });

  FoodsModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    restaurant = json['restaurant'];
    foodType = json['foodType'];
    if (json['addons'] != null) {
      addons = <AddonConfigModel>[];
      json['addons'].forEach((v) {
        addons!.add(AddonConfigModel.fromJson(v, locale));
      });
    } else {
      addons = [];
    }
    startTime = json['startTime'];
    endTime = json['endTime'];
    taxationEnable = json['taxationEnable'];
    if (json['foodtaxations'] != null) {
      foodtaxations = <TaxationConfigModel>[];
      json['foodtaxations'].forEach((v) {
        foodtaxations!.add(TaxationConfigModel.fromJson(v, locale));
      });
    } else {
      foodtaxations = [];
    }
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
      if (json['taxationEnable'] != null && json['taxationEnable'] != '' && json['taxationEnable'] == true) {
        double taxPercentage = 0;
        if (json['foodtaxations'] != null) {
          json['foodtaxations'].forEach((v) {
            TaxationConfigModel taxation = TaxationConfigModel.fromJson(v, locale);
            taxPercentage = (taxPercentage + taxation.taxAmount!);
          });
        }
        if (taxPercentage > 0) {
          double basePrice = price!;
          String finalPriceString = (basePrice + (taxPercentage / 100) * basePrice).toStringAsFixed(2);
          double finalPrice = double.parse(finalPriceString);
          price = finalPrice;
        }
      }
    } else {
      price = 0.0;
    }
    discountType = json['discountType'];
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        if (json['discountType'] == '%') {
          String discountValue = (double.parse(price.toString()) - (double.parse(price.toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        } else {
          String discountValue = (double.parse(price.toString()) - double.parse(json['discount'].toString())).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        }
      }
    } else {
      discount = 0.0;
      offerPrice = 0.0;
    }
    if (json['variations'] != null) {
      variations = <VariationConfigModel>[];
      json['variations'].forEach((v) {
        variations!.add(VariationConfigModel.fromJson(v));
      });
    } else {
      variations = [];
    }
    restaurants = json['restaurants'] != null ? FoodRestaurantInfo.fromJson(json['restaurants'], locale) : null;

    recommended = json['recommended'];
    if (json['rating'] != null && json['rating'] != '') {
      rating = double.parse(json['rating'].toString());
    } else {
      rating = 0.0;
    }
    if (json['totalRating'] != null && json['totalRating'] != '') {
      int ratingCount = int.parse(json['totalRating'].toString());
      String formatNumber(num number) {
        if (number >= 1000000000) {
          return '${(number / 1000000000).toStringAsFixed(1)}B';
        } else if (number >= 1000000) {
          return '${(number / 1000000).toStringAsFixed(1)}M';
        } else if (number >= 1000) {
          return '${(number / 1000).toStringAsFixed(1)}K';
        } else {
          return number.toString();
        }
      }

      totalRating = formatNumber(ratingCount);
    } else {
      totalRating = '0';
    }
    if (json['purchaseLimit'] != null && json['purchaseLimit'] != '' && json['purchaseLimit'].toString() != '-1') {
      purchaseLimit = int.parse(json['purchaseLimit'].toString());
    } else if (json['purchaseLimit'].toString() == '-1') {
      purchaseLimit = 1000000000000000;
    } else {
      purchaseLimit = 5;
    }
    isFavourite = json['isFavourite'];
    if (json['quantity'] != null && json['quantity'] != '') {
      quantity = int.parse(json['quantity'].toString());
    } else {
      quantity = 0;
    }
    if (json['cartEntity'] != null && json['cartEntity'] != '') {
      cartEntity = json['cartEntity'];
    } else {
      cartEntity = 'single';
    }
    status = json['status'];
    inStock = json['inStock'];
    if (json['translations'] != null) {
      translations = <FoodTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(FoodTranslations.fromJson(v));
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
    if (json['stockNumber'] != null && json['stockNumber'] != '') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else {
      stockNumber = -1;
    }
    stockType = json['stockType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['restaurant'] = restaurant;
    data['foodType'] = foodType;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    if (foodtaxations != null) {
      data['foodtaxations'] = foodtaxations!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
    if (addons != null) {
      data['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    data['recommended'] = recommended;
    data['rating'] = rating;
    data['totalRating'] = totalRating;
    data['purchaseLimit'] = purchaseLimit;
    data['isFavourite'] = isFavourite;
    data['quantity'] = quantity;
    data['cartEntity'] = cartEntity;
    data['status'] = status;
    data['inStock'] = inStock;
    data['taxationEnable'] = taxationEnable;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    data['id'] = id;
    return data;
  }
}

class VariationConfigModel {
  bool? isRequired;
  String? title;
  String? type;
  int? min;
  int? max;
  List<VariationOptionConfigModel>? options;

  VariationConfigModel({this.isRequired, this.title, this.type, this.min, this.max, this.options});

  VariationConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['isRequired'].toString().toLowerCase() == 'true' || json['isRequired'] == true) {
      isRequired = true;
    } else {
      isRequired = false;
    }
    title = json['title'];
    type = json['type'];
    if (json['min'] != null && json['min'] != '') {
      min = int.parse(json['min'].toString());
    } else {
      min = 1;
    }
    if (json['max'] != null && json['max'] != '') {
      max = int.parse(json['max'].toString());
    } else {
      max = 1;
    }
    if (json['min'] == '0') {
      min = 1;
    }
    if (json['max'] == '0') {
      max = 1;
    }
    if (min == 1 && max == 1) {
      type = 'single';
    }
    if (json['options'] != null) {
      options = <VariationOptionConfigModel>[];
      json['options'].forEach((v) {
        options!.add(VariationOptionConfigModel.fromJson(v));
      });
    } else {
      options = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isRequired'] = isRequired;
    data['title'] = title;
    data['type'] = type;
    data['min'] = min;
    data['max'] = max;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VariationOptionConfigModel {
  String? name;
  double? price;
  int? stock;

  VariationOptionConfigModel({this.name, this.price, this.stock});

  VariationOptionConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    if (json['stock'] != null && json['stock'] != '' && json['stock'].toString() != '-1') {
      stock = int.parse(json['stock'].toString());
    } else if (json['stock'].toString() == '-1') {
      stock = 1000000000000000;
    } else {
      stock = 5;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['stock'] = stock;
    return data;
  }
}

class FoodTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  FoodTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  FoodTranslations.fromJson(Map<String, dynamic> json) {
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

class BannersModel {
  String? title;
  String? type;
  String? image;
  List<Translations>? translations;
  String? food;
  String? restaurant;
  String? external;
  BannerFoodModel? foods;
  BannerRestaurantModel? restaurants;
  String? id;
  final String locale;

  BannersModel({this.title, this.type, this.image, this.translations, this.food, this.restaurant, this.external, this.foods, this.restaurants, this.id, required this.locale});

  BannersModel.fromJson(Map<String, dynamic> json, this.locale) {
    title = json['title'];
    type = json['type'];
    image = json['image'];
    food = json['food'];
    restaurant = json['restaurant'];
    external = json['external'];
    foods = json['foods'] != null ? BannerFoodModel.fromJson(json['foods'], locale) : null;
    restaurants = json['restaurants'] != null ? BannerRestaurantModel.fromJson(json['restaurants'], locale) : null;
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].value!.isNotEmpty) {
            title = translations![localeIndex].value!;
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
    data['type'] = type;
    data['image'] = image;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['food'] = food;
    data['id'] = id;
    if (foods != null) {
      data['foods'] = foods!.toJson();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    return data;
  }
}

class BannerRestaurantModel {
  String? id;
  String? name;
  String? slug;
  List<RestaurantTranslations>? translations;
  final String locale;
  BannerRestaurantModel({this.id, this.name, this.slug, this.translations, required this.locale});

  BannerRestaurantModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerFoodModel {
  String? id;
  String? name;
  List<FoodTranslations>? translations;
  final String locale;
  BannerFoodModel({this.id, this.name, this.translations, required this.locale});

  BannerFoodModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    if (json['translations'] != null) {
      translations = <FoodTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(FoodTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Mirrors the customer payload produced by
/// `API/src/modules/header-banner/services/header.banner.resolver.service.js`.
///
/// Stored separately from [BannersModel] because it comes from its own backend
/// module, not the legacy banners collection. Every field is optional: the server
/// omits the whole object when no banner resolves, and `null` means "render the
/// default header exactly as today".
class HeaderBannerModel {
  String? id;
  String? campaignName;
  String? title;
  String? subtitle;
  List<Translations>? translations;
  List<Translations>? subtitleTranslations;

  String? media;
  String? mediaUrl;
  String? image;

  String? orientation;
  double? aspectRatio;
  String? heightMode;
  double? maxHeight;

  String? ctaText;
  String? ctaAction;
  String? ctaTarget;
  HeaderBannerCtaTarget? ctaTargetDetail;
  String? deepLink;
  bool? enableOverlayText;
  bool? showCta;

  /// CTA appearance. `null` on a colour means "follow the app theme".
  String? ctaPreset;
  String? ctaStyle;
  String? ctaBackgroundColor;
  String? ctaTextColor;
  double? ctaCornerRadius;
  double? ctaFontSize;
  double? ctaPaddingX;
  double? ctaPaddingY;
  bool? ctaFullWidth;
  bool? ctaShowArrow;

  /// CTA motion.
  String? ctaAnimation;
  double? ctaAnimationDuration;
  bool? ctaAnimationLoop;
  int? displayDuration;

  String? appBarBackgroundMode;
  String? appBarBackgroundColor;
  String? appBarGradientFrom;
  String? appBarGradientTo;
  List<String>? extractedColors;
  double? collapsedHeight;
  bool? showMediaInAppBar;
  bool? showLocation;
  bool? showLanguageSelector;
  bool? showNotificationIcon;

  bool? lottieAutoPlay;
  bool? lottieLoop;
  double? lottieSpeed;
  String? lottieFit;
  String? lottieAlignment;
  bool? parallaxEnabled;
  double? parallaxIntensity;

  /// Manual nudge of the banner media, as a fraction of the banner box.
  double? mediaOffsetX;
  double? mediaOffsetY;

  /// Nudge for the title/subtitle block. Same `-0.5 .. 0.5` fraction-of-banner units as
  /// the media nudge, but a separate pair so the two layers move independently.
  double? overlayOffsetX;
  double? overlayOffsetY;

  /// Nudge for the CTA button.
  double? ctaOffsetX;
  double? ctaOffsetY;

  /// Zoom applied to the banner media. `1` is the untouched render.
  double? mediaScale;

  String? scheduleType;
  DateTime? startDate;
  DateTime? endDate;
  int? priority;
  String? city;

  HeaderBannerModel({
    this.id,
    this.campaignName,
    this.title,
    this.subtitle,
    this.translations,
    this.subtitleTranslations,
    this.media,
    this.mediaUrl,
    this.image,
    this.orientation,
    this.aspectRatio,
    this.heightMode,
    this.maxHeight,
    this.ctaText,
    this.ctaAction,
    this.ctaTarget,
    this.ctaTargetDetail,
    this.deepLink,
    this.enableOverlayText,
    this.showCta,
    this.displayDuration,
    this.appBarBackgroundMode,
    this.appBarBackgroundColor,
    this.appBarGradientFrom,
    this.appBarGradientTo,
    this.extractedColors,
    this.collapsedHeight,
    this.showMediaInAppBar,
    this.showLocation,
    this.showLanguageSelector,
    this.showNotificationIcon,
    this.lottieAutoPlay,
    this.lottieLoop,
    this.lottieSpeed,
    this.lottieFit,
    this.lottieAlignment,
    this.parallaxEnabled,
    this.parallaxIntensity,
    this.scheduleType,
    this.startDate,
    this.endDate,
    this.priority,
    this.city,
  });

  HeaderBannerModel.fromJson(Map<String, dynamic> json, String locale) {
    id = _headerReadString(json['id']);
    campaignName = _headerReadString(json['campaignName']);
    translations = _headerReadTranslations(json['translations']);
    subtitleTranslations = _headerReadTranslations(json['subtitleTranslations']);
    title = _headerResolveTranslated(_headerReadString(json['title']), translations, locale);
    subtitle = _headerResolveTranslated(_headerReadString(json['subtitle']), subtitleTranslations, locale);

    media = _headerReadString(json['media']);
    mediaUrl = _headerReadString(json['mediaUrl']);
    image = _headerReadString(json['image']);

    orientation = _headerReadString(json['orientation']);
    aspectRatio = _headerReadDouble(json['aspectRatio']);
    heightMode = _headerReadString(json['heightMode']);
    maxHeight = _headerReadDouble(json['maxHeight']);

    ctaText = _headerReadString(json['ctaText']);
    ctaAction = _headerReadString(json['ctaAction']);
    ctaTarget = _headerReadString(json['ctaTarget']);
    if (json['ctaTargetDetail'] is Map<String, dynamic>) {
      ctaTargetDetail = HeaderBannerCtaTarget.fromJson(json['ctaTargetDetail'] as Map<String, dynamic>);
    }
    deepLink = _headerReadString(json['deepLink']);
    enableOverlayText = _headerReadBool(json['enableOverlayText']);
    showCta = _headerReadBool(json['showCta']);
    ctaPreset = _headerReadString(json['ctaPreset']);
    ctaStyle = _headerReadString(json['ctaStyle']);
    ctaBackgroundColor = _headerReadString(json['ctaBackgroundColor']);
    ctaTextColor = _headerReadString(json['ctaTextColor']);
    ctaCornerRadius = _headerReadDouble(json['ctaCornerRadius']);
    ctaFontSize = _headerReadDouble(json['ctaFontSize']);
    ctaPaddingX = _headerReadDouble(json['ctaPaddingX']);
    ctaPaddingY = _headerReadDouble(json['ctaPaddingY']);
    ctaFullWidth = _headerReadBool(json['ctaFullWidth']);
    ctaShowArrow = _headerReadBool(json['ctaShowArrow']);
    ctaAnimation = _headerReadString(json['ctaAnimation']);
    ctaAnimationDuration = _headerReadDouble(json['ctaAnimationDuration']);
    ctaAnimationLoop = _headerReadBool(json['ctaAnimationLoop']);
    displayDuration = _headerReadInt(json['displayDuration']);

    appBarBackgroundMode = _headerReadString(json['appBarBackgroundMode']);
    appBarBackgroundColor = _headerReadString(json['appBarBackgroundColor']);
    appBarGradientFrom = _headerReadString(json['appBarGradientFrom']);
    appBarGradientTo = _headerReadString(json['appBarGradientTo']);
    extractedColors = _headerReadStringList(json['extractedColors']);
    collapsedHeight = _headerReadDouble(json['collapsedHeight']);
    showMediaInAppBar = _headerReadBool(json['showMediaInAppBar']);
    showLocation = _headerReadBool(json['showLocation']);
    showLanguageSelector = _headerReadBool(json['showLanguageSelector']);
    showNotificationIcon = _headerReadBool(json['showNotificationIcon']);

    lottieAutoPlay = _headerReadBool(json['lottieAutoPlay']);
    lottieLoop = _headerReadBool(json['lottieLoop']);
    lottieSpeed = _headerReadDouble(json['lottieSpeed']);
    lottieFit = _headerReadString(json['lottieFit']);
    lottieAlignment = _headerReadString(json['lottieAlignment']);
    parallaxEnabled = json['parallaxEnabled'] == true;
    final num? rawIntensity = num.tryParse(json['parallaxIntensity']?.toString() ?? '');
    parallaxIntensity = (rawIntensity ?? 0.18).clamp(0.0, 0.5).toDouble();

    mediaOffsetX = _headerReadDouble(json['mediaOffsetX']);
    mediaOffsetY = _headerReadDouble(json['mediaOffsetY']);
    overlayOffsetX = _headerReadDouble(json['overlayOffsetX']);
    overlayOffsetY = _headerReadDouble(json['overlayOffsetY']);
    ctaOffsetX = _headerReadDouble(json['ctaOffsetX']);
    ctaOffsetY = _headerReadDouble(json['ctaOffsetY']);
    mediaScale = _headerReadDouble(json['mediaScale']);

    scheduleType = _headerReadString(json['scheduleType']);
    startDate = _headerReadDate(json['startDate']);
    endDate = _headerReadDate(json['endDate']);
    priority = _headerReadInt(json['priority']);
    city = _headerReadString(json['city']);
  }

  /// Resolves a translatable field against the active locale, falling back to the
  /// raw payload value so a banner without translations still renders.
  static String? _headerResolveTranslated(String? raw, List<Translations>? entries, String locale) {
    if (entries != null && entries.isNotEmpty && locale.isNotEmpty) {
      final int index = entries.indexWhere((Translations entry) => entry.code == locale);
      if (index != -1) {
        final String? value = entries[index].value;
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return raw;
  }

  static List<Translations>? _headerReadTranslations(dynamic value) {
    if (value is! List) return null;
    final List<Translations> entries = <Translations>[];
    for (final dynamic item in value) {
      if (item is Map<String, dynamic>) {
        entries.add(Translations.fromJson(item));
      }
    }
    return entries;
  }

  static List<String>? _headerReadStringList(dynamic value) {
    if (value is! List) return null;
    return value.map((dynamic entry) => entry?.toString() ?? '').where((String entry) => entry.isNotEmpty).toList();
  }

  static String? _headerReadString(dynamic value) {
    if (value == null) return null;
    final String result = value.toString();
    return result.isEmpty ? null : result;
  }

  static double? _headerReadDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static int? _headerReadInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _headerReadBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static DateTime? _headerReadDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'campaignName': campaignName,
      'title': title,
      'subtitle': subtitle,
      if (translations != null) 'translations': translations!.map((Translations entry) => entry.toJson()).toList(),
      if (subtitleTranslations != null) 'subtitleTranslations': subtitleTranslations!.map((Translations entry) => entry.toJson()).toList(),
      'media': media,
      'mediaUrl': mediaUrl,
      'image': image,
      'orientation': orientation,
      'aspectRatio': aspectRatio,
      'heightMode': heightMode,
      'maxHeight': maxHeight,
      'ctaText': ctaText,
      'ctaAction': ctaAction,
      'ctaTarget': ctaTarget,
      if (ctaTargetDetail != null) 'ctaTargetDetail': ctaTargetDetail!.toJson(),
      'deepLink': deepLink,
      'enableOverlayText': enableOverlayText,
      'showCta': showCta,
      'displayDuration': displayDuration,
      'appBarBackgroundMode': appBarBackgroundMode,
      'appBarBackgroundColor': appBarBackgroundColor,
      'appBarGradientFrom': appBarGradientFrom,
      'appBarGradientTo': appBarGradientTo,
      'extractedColors': extractedColors,
      'collapsedHeight': collapsedHeight,
      'showMediaInAppBar': showMediaInAppBar,
      'showLocation': showLocation,
      'showLanguageSelector': showLanguageSelector,
      'showNotificationIcon': showNotificationIcon,
      'lottieAutoPlay': lottieAutoPlay,
      'lottieLoop': lottieLoop,
      'lottieSpeed': lottieSpeed,
      'lottieFit': lottieFit,
      'lottieAlignment': lottieAlignment,
      'scheduleType': scheduleType,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'priority': priority,
      'city': city,
    };
  }
}

/// Navigation target resolved server side from a header banner's `ctaTarget`.
///
/// The client routes are argument based — `/restaurants_by_category` needs
/// `[name, slug, citySlug]` — so a bare ObjectId from the admin form is not
/// actionable on its own. Mirrors the `restaurants` / `foods` lookup the legacy
/// banners already return.
class HeaderBannerCtaTarget {
  String? type;
  String? id;
  String? name;
  String? slug;

  /// Parent kitchen, present only for a `food` target. The food modal resolves its own
  /// pricing from the restaurant, so an id alone is not enough to open it.
  String? restaurantId;

  HeaderBannerCtaTarget({this.type, this.id, this.name, this.slug, this.restaurantId});

  HeaderBannerCtaTarget.fromJson(Map<String, dynamic> json) {
    type = json['type']?.toString();
    id = json['id']?.toString();
    name = json['name']?.toString();
    slug = json['slug']?.toString();
    restaurantId = json['restaurantId']?.toString();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'type': type, 'id': id, 'name': name, 'slug': slug, 'restaurantId': restaurantId};
}

class CampaignConfigModel {
  String? title;
  String? shortDescription;
  String? image;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  List<CampaignTranslations>? translations;
  String? id;
  final String locale;

  CampaignConfigModel({this.title, this.shortDescription, this.image, this.startDate, this.endDate, this.startTime, this.endTime, this.translations, this.id, required this.locale});

  CampaignConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    title = json['title'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    if (json['translations'] != null) {
      translations = <CampaignTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(CampaignTranslations.fromJson(v));
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

class FoodRestaurantInfo {
  String? id;
  String? slug;
  String? name;
  String? logo;
  String? cover;
  List<RestaurantTranslations>? translations;
  final String locale;
  FoodRestaurantInfo({this.id, this.slug, this.name, this.logo, this.cover, this.translations, required this.locale});

  FoodRestaurantInfo.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    slug = json['slug'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddonConfigModel {
  String? name;
  List<Translations>? translations;
  String? id;
  double? price;
  bool? inStock;
  int? stockNumber;
  String? stockType;
  final String locale;

  AddonConfigModel({this.name, this.translations, this.id, this.price, this.inStock, this.stockNumber, this.stockType, required this.locale});

  AddonConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    id = json['id'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    if (json['inStock'] != null && json['inStock'] != '') {
      inStock = json['inStock'];
    } else {
      inStock = true;
    }
    if (json['stockNumber'] != null && json['stockNumber'] != '' && json['stockNumber'].toString() != '-1') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else if (json['stockNumber'].toString() == '-1') {
      stockNumber = 1000000000000000;
    } else {
      stockNumber = 5;
    }
    if (json['stockType'] != null && json['stockType'] != '') {
      stockType = json['stockType'];
    } else {
      stockType = 'unlimited';
    }
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['price'] = price;
    data['inStock'] = inStock;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    return data;
  }
}

class CampaignTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  CampaignTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  CampaignTranslations.fromJson(Map<String, dynamic> json) {
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

class TiffinSubscriptionPackagesInfoModel {
  String? name;
  String? shortDescription;
  String? image;
  List<String>? foods;
  String? interval;
  int? totalOrder;
  String? orderTo;
  String? available;
  String? discountType;
  List<SubscriptionPackagesTranslations>? translations;
  SubscriptionPackageRestaurantsInfoModel? restaurants;
  String? id;
  double? price;
  double? discount;
  double? offerPrice = 0.0;
  final String locale;

  TiffinSubscriptionPackagesInfoModel({
    this.name,
    this.shortDescription,
    this.image,
    this.foods,
    this.interval,
    this.totalOrder,
    this.orderTo,
    this.available,
    this.discountType,
    this.translations,
    this.restaurants,
    this.id,
    this.price,
    this.discount,
    this.offerPrice,
    required this.locale,
  });

  TiffinSubscriptionPackagesInfoModel.fromJson(Map<String, dynamic> json, this.locale) {
    name = json['name'];
    shortDescription = json['shortDescription'];
    image = json['image'];
    foods = json['foods'].cast<String>();
    interval = json['interval'];
    if (json['totalOrder'] != null && json['totalOrder'] != '') {
      totalOrder = int.parse(json['totalOrder'].toString());
    } else {
      totalOrder = 0;
    }
    orderTo = json['orderTo'];
    available = json['available'];
    discountType = json['discountType'];

    restaurants = json['restaurants'] != null ? SubscriptionPackageRestaurantsInfoModel.fromJson(json['restaurants'], locale) : null;
    id = json['id'];
    if (json['price'] != null && json['price'] != '') {
      price = double.parse(json['price'].toString());
    } else {
      price = 0.0;
    }
    discountType = json['discountType'];
    if (json['discount'] != null && json['discount'] != '') {
      discount = double.parse(json['discount'].toString());
      if (discount! > 0) {
        if (json['discountType'] == '%') {
          String discountValue = (double.parse(json['price'].toString()) - (double.parse(json['price'].toString()) * double.parse(json['discount'].toString()) / 100)).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        } else {
          String discountValue = (double.parse(json['price'].toString()) - double.parse(json['discount'].toString())).toStringAsFixed(2);
          offerPrice = double.parse(discountValue);
        }
      }
    } else {
      discount = 0.0;
      offerPrice = 0.0;
    }
    if (json['translations'] != null) {
      translations = <SubscriptionPackagesTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(SubscriptionPackagesTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['foods'] = foods;
    data['interval'] = interval;
    data['totalOrder'] = totalOrder;
    data['orderTo'] = orderTo;
    data['available'] = available;
    data['discountType'] = discountType;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    if (restaurants != null) {
      data['restaurants'] = restaurants!.toJson();
    }
    data['id'] = id;
    data['price'] = price;
    data['discountType'] = discountType;
    data['discount'] = discount;
    data['offerPrice'] = offerPrice;
    return data;
  }
}

class SubscriptionPackagesTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? shortDescription;

  SubscriptionPackagesTranslations({this.name, this.code, this.nativeName, this.title, this.shortDescription});

  SubscriptionPackagesTranslations.fromJson(Map<String, dynamic> json) {
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

class SubscriptionPackageRestaurantsInfoModel {
  String? id;
  String? name;
  String? logo;
  String? cover;
  List<SubscriptionPacakgeRestaurantTranslations>? translations;
  final String locale;
  SubscriptionPackageRestaurantsInfoModel({this.id, this.name, this.logo, this.cover, this.translations, required this.locale});

  SubscriptionPackageRestaurantsInfoModel.fromJson(Map<String, dynamic> json, this.locale) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    cover = json['cover'];
    if (json['translations'] != null) {
      translations = <SubscriptionPacakgeRestaurantTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(SubscriptionPacakgeRestaurantTranslations.fromJson(v));
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['logo'] = logo;
    data['cover'] = cover;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPacakgeRestaurantTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? address;

  SubscriptionPacakgeRestaurantTranslations({this.name, this.code, this.nativeName, this.title, this.address});

  SubscriptionPacakgeRestaurantTranslations.fromJson(Map<String, dynamic> json) {
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

class TaxationConfigModel {
  String? taxName;
  List<FoodTaxationTranslation>? translations;
  String? id;
  double? taxAmount;
  final String locale;
  TaxationConfigModel({this.taxName, this.translations, this.id, this.taxAmount, required this.locale});

  TaxationConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    taxName = json['taxName'];
    if (json['translations'] != null) {
      translations = <FoodTaxationTranslation>[];
      json['translations'].forEach((v) {
        translations!.add(FoodTaxationTranslation.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            taxName = translations![localeIndex].title!;
          }
        }
      }
    } else {
      translations = [];
    }
    id = json['id'];
    if (json['taxAmount'] != null && json['taxAmount'] != '') {
      taxAmount = double.parse(json['taxAmount'].toString());
    } else {
      taxAmount = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['taxName'] = taxName;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['taxAmount'] = taxAmount;
    return data;
  }
}

class FoodTaxationTranslation {
  String? name;
  String? code;
  String? nativeName;
  String? title;

  FoodTaxationTranslation({this.name, this.code, this.nativeName, this.title});

  FoodTaxationTranslation.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    return data;
  }
}
