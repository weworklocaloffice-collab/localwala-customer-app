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

class OrderSettingsModel {
  OrdersConfigModel? orders;
  BusinessConfigModel? business;
  CustomerConfig? customer;
  PaymentConfigModel? primary;
  List<PaymentConfigModel>? payments;
  WalletConfigModel? wallet;
  RestaurantConfigModel? restaurant;
  List<InstructionConfigModel>? instruction;
  DeliveryAddressConfigModel? address;
  PackagingConfigModel? packaging;
  List<GratitudesConfigModel>? gratitudes;
  FoodInCartConfigModel? foods;
  final String locale;
  OrderSettingsModel({this.orders, this.business, this.customer, this.primary, this.payments, this.wallet, this.restaurant, this.instruction, this.address, this.packaging, this.gratitudes, this.foods, required this.locale});

  OrderSettingsModel.fromJson(Map<String, dynamic> json, this.locale) {
    orders = json['orders'] != null ? OrdersConfigModel.fromJson(json['orders']) : null;
    business = json['business'] != null ? BusinessConfigModel.fromJson(json['business']) : null;
    customer = json['customer'] != null ? CustomerConfig.fromJson(json['customer']) : null;
    primary = json['primary'] != null ? PaymentConfigModel.fromJson(json['primary'], locale) : null;
    if (json['payments'] != null) {
      payments = <PaymentConfigModel>[];
      json['payments'].forEach((v) {
        payments!.add(PaymentConfigModel.fromJson(v, locale));
      });
    } else {
      payments = [];
    }
    wallet = json['wallet'] != null ? WalletConfigModel.fromJson(json['wallet']) : null;
    restaurant = json['restaurant'] != null ? RestaurantConfigModel.fromJson(json['restaurant']) : null;
    if (json['instruction'] != null) {
      instruction = <InstructionConfigModel>[];
      json['instruction'].forEach((v) {
        instruction!.add(InstructionConfigModel.fromJson(v, locale));
      });
    } else {
      instruction = [];
    }
    address = json['address'] != null ? DeliveryAddressConfigModel.fromJson(json['address']) : null;
    packaging = json['packaging'] != null ? PackagingConfigModel.fromJson(json['packaging']) : null;
    if (json['gratitudes'] != null) {
      gratitudes = <GratitudesConfigModel>[];
      json['gratitudes'].forEach((v) {
        gratitudes!.add(GratitudesConfigModel.fromJson(v));
      });
    } else {
      gratitudes = [];
    }
    foods = json['foods'] != null ? FoodInCartConfigModel.fromJson(json['foods'], locale) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (orders != null) {
      data['orders'] = orders!.toJson();
    }
    if (business != null) {
      data['business'] = business!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
    if (payments != null) {
      data['payments'] = payments!.map((v) => v.toJson()).toList();
    }
    if (wallet != null) {
      data['wallet'] = wallet!.toJson();
    }
    if (restaurant != null) {
      data['restaurant'] = restaurant!.toJson();
    }
    if (instruction != null) {
      data['instruction'] = instruction!.map((v) => v.toJson()).toList();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (packaging != null) {
      data['packaging'] = packaging!.toJson();
    }
    if (gratitudes != null) {
      data['gratitudes'] = gratitudes!.map((v) => v.toJson()).toList();
    }
    if (foods != null) {
      data['foods'] = foods!.toJson();
    }
    return data;
  }
}

class OrdersConfigModel {
  bool? homeDelivery;
  bool? takeaway;
  bool? scheduleDelivery;
  TimeIntervalForScheduleDelivery? timeIntervalForScheduleDelivery;
  bool? instantOrder;
  bool? customerOrderDate;
  int? customerCanOrderWithinDays;
  String? id;

  OrdersConfigModel({this.homeDelivery, this.takeaway, this.scheduleDelivery, this.timeIntervalForScheduleDelivery, this.instantOrder, this.customerOrderDate, this.customerCanOrderWithinDays, this.id});

  OrdersConfigModel.fromJson(Map<String, dynamic> json) {
    homeDelivery = json['homeDelivery'];
    takeaway = json['takeaway'];
    scheduleDelivery = json['scheduleDelivery'];
    timeIntervalForScheduleDelivery = json['timeIntervalForScheduleDelivery'] != null ? TimeIntervalForScheduleDelivery.fromJson(json['timeIntervalForScheduleDelivery']) : null;
    instantOrder = json['instantOrder'];
    customerOrderDate = json['customerOrderDate'];
    if (json['customerCanOrderWithinDays'] != null && json['customerCanOrderWithinDays'] != '') {
      customerCanOrderWithinDays = int.parse(json['customerCanOrderWithinDays'].toString());
    } else {
      customerCanOrderWithinDays = 0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['homeDelivery'] = homeDelivery;
    data['takeaway'] = takeaway;
    data['scheduleDelivery'] = scheduleDelivery;
    if (timeIntervalForScheduleDelivery != null) {
      data['timeIntervalForScheduleDelivery'] = timeIntervalForScheduleDelivery!.toJson();
    }
    data['instantOrder'] = instantOrder;
    data['customerOrderDate'] = customerOrderDate;
    data['customerCanOrderWithinDays'] = customerCanOrderWithinDays;
    data['id'] = id;
    return data;
  }
}

class TimeIntervalForScheduleDelivery {
  int? value;
  String? type;

  TimeIntervalForScheduleDelivery({this.value, this.type});

  TimeIntervalForScheduleDelivery.fromJson(Map<String, dynamic> json) {
    if (json['value'] != null && json['value'] != '') {
      value = int.parse(json['value'].toString());
    } else {
      value = 0;
    }
    if (json['type'] != null && json['type'] != '') {
      type = json['type'];
    } else {
      type = 'min';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['type'] = type;
    return data;
  }
}

class BusinessConfigModel {
  bool? haveFreeDeliveryInTotal;
  double? freeDelivery;
  bool? haveFreeDeliveryInDistance;
  double? freeDeliveryInDistance;
  bool? includeTaxOnFood;
  bool? additionalServiceCharge;
  String? additionalServiceName;
  double? additionalServiceAmount;
  bool? partialPayment;
  String? partialAmountPayment;
  String? findMode;
  double? deliveryArea;
  double? foodTaxAmount;
  String? foodTaxName;
  String? foodTaxType;
  double? deliveryChargeAmount;
  String? deliveryChargeMethod;
  String? id;

  BusinessConfigModel({
    this.haveFreeDeliveryInTotal,
    this.freeDelivery,
    this.haveFreeDeliveryInDistance,
    this.freeDeliveryInDistance,
    this.includeTaxOnFood,
    this.additionalServiceCharge,
    this.additionalServiceName,
    this.additionalServiceAmount,
    this.partialPayment,
    this.partialAmountPayment,
    this.findMode,
    this.deliveryArea,
    this.foodTaxAmount,
    this.foodTaxName,
    this.foodTaxType,
    this.deliveryChargeAmount,
    this.deliveryChargeMethod,
    this.id,
  });

  BusinessConfigModel.fromJson(Map<String, dynamic> json) {
    haveFreeDeliveryInTotal = json['haveFreeDeliveryInTotal'];
    if (json['freeDelivery'] != null && json['freeDelivery'] != '') {
      freeDelivery = double.parse(json['freeDelivery'].toString());
    } else {
      freeDelivery = 0.0;
    }
    haveFreeDeliveryInDistance = json['haveFreeDeliveryInDistance'];
    if (json['freeDeliveryInDistance'] != null && json['freeDeliveryInDistance'] != '') {
      freeDeliveryInDistance = double.parse(json['freeDeliveryInDistance'].toString());
    } else {
      freeDeliveryInDistance = 0.0;
    }
    includeTaxOnFood = json['includeTaxOnFood'];
    additionalServiceCharge = json['additionalServiceCharge'];
    additionalServiceName = json['additionalServiceName'];
    if (json['additionalServiceAmount'] != null && json['additionalServiceAmount'] != '') {
      additionalServiceAmount = double.parse(json['additionalServiceAmount'].toString());
    } else {
      additionalServiceAmount = 0.0;
    }
    partialPayment = json['partialPayment'];
    partialAmountPayment = json['partialAmountPayment'];
    findMode = json['findMode'];
    if (json['deliveryArea'] != null && json['deliveryArea'] != '') {
      deliveryArea = double.parse(json['deliveryArea'].toString());
    } else {
      deliveryArea = 0.0;
    }
    if (json['foodTaxAmount'] != null && json['foodTaxAmount'] != '') {
      foodTaxAmount = double.parse(json['foodTaxAmount'].toString());
    } else {
      foodTaxAmount = 0.0;
    }
    foodTaxName = json['foodTaxName'];
    foodTaxType = json['foodTaxType'];
    if (json['deliveryChargeAmount'] != null && json['deliveryChargeAmount'] != '') {
      deliveryChargeAmount = double.parse(json['deliveryChargeAmount'].toString());
    } else {
      deliveryChargeAmount = 0.0;
    }
    deliveryChargeMethod = json['deliveryChargeMethod'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['haveFreeDeliveryInTotal'] = haveFreeDeliveryInTotal;
    data['freeDelivery'] = freeDelivery;
    data['haveFreeDeliveryInDistance'] = haveFreeDeliveryInDistance;
    data['freeDeliveryInDistance'] = freeDeliveryInDistance;
    data['includeTaxOnFood'] = includeTaxOnFood;
    data['additionalServiceCharge'] = additionalServiceCharge;
    data['additionalServiceName'] = additionalServiceName;
    data['additionalServiceAmount'] = additionalServiceAmount;
    data['partialPayment'] = partialPayment;
    data['partialAmountPayment'] = partialAmountPayment;
    data['findMode'] = findMode;
    data['deliveryArea'] = deliveryArea;
    data['foodTaxAmount'] = foodTaxAmount;
    data['foodTaxName'] = foodTaxName;
    data['foodTaxType'] = foodTaxType;
    data['deliveryChargeAmount'] = deliveryChargeAmount;
    data['deliveryChargeMethod'] = deliveryChargeMethod;
    data['id'] = id;
    return data;
  }
}

class CustomerConfig {
  bool? canEarnBuyFromWallet;
  bool? canEarnLoyaltyPointOnOrder;
  double? loyaltyMinOrderTotal;
  double? loyaltyPointValue;
  String? id;

  CustomerConfig({this.canEarnBuyFromWallet, this.canEarnLoyaltyPointOnOrder, this.loyaltyMinOrderTotal, this.loyaltyPointValue, this.id});

  CustomerConfig.fromJson(Map<String, dynamic> json) {
    canEarnBuyFromWallet = json['canEarnBuyFromWallet'];
    canEarnLoyaltyPointOnOrder = json['canEarnLoyaltyPointOnOrder'];
    if (json['loyaltyMinOrderTotal'] != null && json['loyaltyMinOrderTotal'] != '') {
      loyaltyMinOrderTotal = double.parse(json['loyaltyMinOrderTotal'].toString());
    } else {
      loyaltyMinOrderTotal = 0.0;
    }
    if (json['loyaltyPointValue'] != null && json['loyaltyPointValue'] != '') {
      loyaltyPointValue = double.parse(json['loyaltyPointValue'].toString());
    } else {
      loyaltyPointValue = 0.0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canEarnBuyFromWallet'] = canEarnBuyFromWallet;
    data['canEarnLoyaltyPointOnOrder'] = canEarnLoyaltyPointOnOrder;
    data['loyaltyMinOrderTotal'] = loyaltyMinOrderTotal;
    data['loyaltyPointValue'] = loyaltyPointValue;
    data['id'] = id;
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

class WalletConfigModel {
  double? balance;
  String? id;

  WalletConfigModel({this.balance, this.id});

  WalletConfigModel.fromJson(Map<String, dynamic> json) {
    if (json['balance'] != null && json['balance'] != '') {
      balance = double.parse(json['balance'].toString());
    } else {
      balance = 0.0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['balance'] = balance;
    data['id'] = id;
    return data;
  }
}

class RestaurantConfigModel {
  String? name;
  double? distance;
  String? approxDeliveryTime;
  List<SlotsConfigModel>? slots;
  String? id;
  bool? takeAway;
  double? minOrderAmount;
  bool? acceptHomeDelivery;
  bool? acceptScheduleDelivery;

  RestaurantConfigModel({this.name, this.slots, this.approxDeliveryTime, this.distance, this.id, this.takeAway, this.minOrderAmount, this.acceptHomeDelivery, this.acceptScheduleDelivery});

  RestaurantConfigModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['distance'] != null && json['distance'] != '') {
      distance = double.parse(json['distance'].toString());
    } else {
      distance = 0.0;
    }
    if (json['slots'] != null) {
      slots = <SlotsConfigModel>[];
      json['slots'].forEach((v) {
        slots!.add(SlotsConfigModel.fromJson(v));
      });
    } else {
      slots = [];
    }
    approxDeliveryTime = json['approxDeliveryTime'];
    id = json['id'];
    takeAway = json['takeAway'];
    if (json['minOrderAmount'] != null && json['minOrderAmount'] != '') {
      minOrderAmount = double.parse(json['minOrderAmount'].toString());
    } else {
      minOrderAmount = 0.0;
    }
    acceptHomeDelivery = json['acceptHomeDelivery'];
    acceptScheduleDelivery = json['acceptScheduleDelivery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['distance'] = distance;
    data['approxDeliveryTime'] = approxDeliveryTime;
    if (slots != null) {
      data['slots'] = slots!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['takeAway'] = takeAway;
    data['minOrderAmount'] = minOrderAmount;
    data['acceptHomeDelivery'] = acceptHomeDelivery;
    data['acceptScheduleDelivery'] = acceptScheduleDelivery;
    return data;
  }
}

class InstructionConfigModel {
  String? name;
  String? image;
  List<Translations>? translations;
  bool? status;
  String? id;
  final String locale;
  InstructionConfigModel({this.name, this.image, this.translations, this.status, this.id, required this.locale});

  InstructionConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    data['id'] = id;
    return data;
  }
}

class DeliveryAddressConfigModel {
  LocationCoordinates? location;
  int? title;
  String? receiverName;
  int? countryCode;
  String? receiverContact;
  String? flatHouse;
  String? locality;
  String? landmark;
  String? id;

  DeliveryAddressConfigModel({this.location, this.title, this.receiverName, this.countryCode, this.receiverContact, this.flatHouse, this.locality, this.landmark, this.id});

  DeliveryAddressConfigModel.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? LocationCoordinates.fromJson(json['location']) : null;
    title = json['title'];
    receiverName = json['receiverName'];
    countryCode = json['countryCode'];
    receiverContact = json['receiverContact'];
    flatHouse = json['flatHouse'];
    locality = json['locality'];
    landmark = json['landmark'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['title'] = title;
    data['receiverName'] = receiverName;
    data['countryCode'] = countryCode;
    data['receiverContact'] = receiverContact;
    data['flatHouse'] = flatHouse;
    data['locality'] = locality;
    data['landmark'] = landmark;
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

class PackagingConfigModel {
  bool? havePackagingCharges;
  bool? includePackagesChargesInTax;
  double? packagingCharges;
  double? packagingChargesTax;
  String? id;

  PackagingConfigModel({this.havePackagingCharges, this.includePackagesChargesInTax, this.packagingCharges, this.packagingChargesTax, this.id});

  PackagingConfigModel.fromJson(Map<String, dynamic> json) {
    havePackagingCharges = json['havePackagingCharges'];
    includePackagesChargesInTax = json['includePackagesChargesInTax'];
    if (json['packagingCharges'] != null && json['packagingCharges'] != '') {
      packagingCharges = double.parse(json['packagingCharges'].toString());
    } else {
      packagingCharges = 0.0;
    }
    if (json['packagingChargesTax'] != null && json['packagingChargesTax'] != '') {
      packagingChargesTax = double.parse(json['packagingChargesTax'].toString());
    } else {
      packagingChargesTax = 0.0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['havePackagingCharges'] = havePackagingCharges;
    data['includePackagesChargesInTax'] = includePackagesChargesInTax;
    data['packagingCharges'] = packagingCharges;
    data['packagingChargesTax'] = packagingChargesTax;
    data['id'] = id;
    return data;
  }
}

class GratitudesConfigModel {
  double? price;
  bool? mostTipped;
  bool? status;
  String? id;

  GratitudesConfigModel({this.price, this.mostTipped, this.status, this.id});

  GratitudesConfigModel.fromJson(Map<String, dynamic> json) {
    price = double.parse(json['price'].toString());
    mostTipped = json['mostTipped'];
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    data['mostTipped'] = mostTipped;
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class SlotsConfigModel {
  int? day;
  List<TimesConfigModel>? times;

  SlotsConfigModel({this.day, this.times});

  SlotsConfigModel.fromJson(Map<String, dynamic> json) {
    day = int.parse(json['day'].toString());
    if (json['times'] != null) {
      times = <TimesConfigModel>[];
      json['times'].forEach((v) {
        times!.add(TimesConfigModel.fromJson(v));
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

class TimesConfigModel {
  String? start;
  String? end;

  TimesConfigModel({this.start, this.end});

  TimesConfigModel.fromJson(Map<String, dynamic> json) {
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

class FoodInCartConfigModel {
  List<InCartItemConfigModel>? inCartItems;
  List<FoodInfoInCartConfigModel>? foodInfoInCart;
  bool? success;
  final String locale;
  FoodInCartConfigModel({this.inCartItems, this.foodInfoInCart, this.success, required this.locale});

  FoodInCartConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['inCartItems'] != null) {
      inCartItems = <InCartItemConfigModel>[];
      json['inCartItems'].forEach((v) {
        inCartItems!.add(InCartItemConfigModel.fromJson(v));
      });
    }
    if (json['foodInfoInCart'] != null) {
      foodInfoInCart = <FoodInfoInCartConfigModel>[];
      json['foodInfoInCart'].forEach((v) {
        foodInfoInCart!.add(FoodInfoInCartConfigModel.fromJson(v, locale));
      });
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (inCartItems != null) {
      data['inCartItems'] = inCartItems!.map((v) => v.toJson()).toList();
    }
    if (foodInfoInCart != null) {
      data['foodInfoInCart'] = foodInfoInCart!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class InCartItemConfigModel {
  String? trackingId;
  String? user;
  String? uuid;
  List<String>? addons;
  String? food;
  String? restaurant;
  int? quantity;
  List<InCartItemVariationConfigModel>? variations;
  double? itemTotal;
  double? grandTotal;
  String? id;

  InCartItemConfigModel({this.trackingId, this.user, this.uuid, this.addons, this.food, this.restaurant, this.quantity, this.variations, this.itemTotal, this.grandTotal, this.id});

  InCartItemConfigModel.fromJson(Map<String, dynamic> json) {
    trackingId = json['trackingId'];
    user = json['user'];
    uuid = json['uuid'];
    addons = json['addons'].cast<String>();
    food = json['food'];
    restaurant = json['restaurant'];
    if (json['quantity'] != null && json['quantity'] != '') {
      quantity = int.parse(json['quantity'].toString());
    } else {
      quantity = 1;
    }
    if (json['variations'] != null) {
      variations = <InCartItemVariationConfigModel>[];
      json['variations'].forEach((v) {
        variations!.add(InCartItemVariationConfigModel.fromJson(v));
      });
    }
    if (json['itemTotal'] != null && json['itemTotal'] != '') {
      itemTotal = double.parse(json['itemTotal'].toString());
    } else {
      itemTotal = 0;
    }
    if (json['grandTotal'] != null && json['grandTotal'] != '') {
      grandTotal = double.parse(json['grandTotal'].toString());
    } else {
      grandTotal = 0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trackingId'] = trackingId;
    data['user'] = user;
    data['uuid'] = uuid;
    data['addons'] = addons;
    data['food'] = food;
    data['restaurant'] = restaurant;
    data['quantity'] = quantity;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
    data['itemTotal'] = itemTotal;
    data['grandTotal'] = grandTotal;
    data['id'] = id;
    return data;
  }
}

class InCartItemVariationConfigModel {
  String? variation;
  List<String>? selected;

  InCartItemVariationConfigModel({this.variation, this.selected});

  InCartItemVariationConfigModel.fromJson(Map<String, dynamic> json) {
    variation = json['variation'];
    selected = json['selected'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variation'] = variation;
    data['selected'] = selected;
    return data;
  }
}

class FoodInfoInCartConfigModel {
  String? name;
  String? shortDescription;
  String? image;
  String? restaurant;
  String? foodType;
  List<AddonConfigModel>? addons;
  String? startTime;
  String? endTime;
  String? discountType;
  int? purchaseLimit;
  List<FoodTranslations>? translations;
  bool? inStock;
  String? status;
  bool? taxationEnable;
  int? stockNumber;
  String? stockType;
  List<TaxationConfigModel>? foodtaxations;
  String? id;
  double? price;
  double? discount;
  double? offerPrice = 0.0;
  List<VariationConfigModel>? variations;
  final String locale;
  FoodInfoInCartConfigModel({
    this.name,
    this.shortDescription,
    this.image,
    this.restaurant,
    this.foodType,
    this.addons,
    this.startTime,
    this.endTime,
    this.discountType,
    this.purchaseLimit,
    this.translations,
    this.inStock,
    this.status,
    this.taxationEnable,
    this.stockNumber,
    this.stockType,
    this.foodtaxations,
    this.id,
    this.price,
    this.discount,
    this.variations,
    required this.locale,
  });

  FoodInfoInCartConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
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
    discountType = json['discountType'];
    if (json['purchaseLimit'] != null && json['purchaseLimit'] != '' && json['purchaseLimit'].toString() != '-1') {
      purchaseLimit = int.parse(json['purchaseLimit'].toString());
    } else if (json['purchaseLimit'].toString() == '-1') {
      purchaseLimit = 1000000000000000;
    } else {
      purchaseLimit = 5;
    }
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
    inStock = json['inStock'];
    status = json['status'];
    taxationEnable = json['taxationEnable'];
    if (json['stockNumber'] != null && json['stockNumber'] != '') {
      stockNumber = int.parse(json['stockNumber'].toString());
    } else {
      stockNumber = -1;
    }
    stockType = json['stockType'];
    if (json['foodtaxations'] != null) {
      foodtaxations = <TaxationConfigModel>[];
      json['foodtaxations'].forEach((v) {
        foodtaxations!.add(TaxationConfigModel.fromJson(v, locale));
      });
    } else {
      foodtaxations = [];
    }
    id = json['id'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['shortDescription'] = shortDescription;
    data['image'] = image;
    data['restaurant'] = restaurant;
    data['foodType'] = foodType;
    if (addons != null) {
      data['addons'] = addons!.map((v) => v.toJson()).toList();
    }
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['discountType'] = discountType;
    data['purchaseLimit'] = purchaseLimit;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['inStock'] = inStock;
    data['status'] = status;
    data['taxationEnable'] = taxationEnable;
    data['stockNumber'] = stockNumber;
    data['stockType'] = stockType;
    if (foodtaxations != null) {
      data['foodtaxations'] = foodtaxations!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['price'] = price;
    data['discount'] = discount;
    if (variations != null) {
      data['variations'] = variations!.map((v) => v.toJson()).toList();
    }
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

