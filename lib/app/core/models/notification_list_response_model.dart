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

import 'package:timeago/timeago.dart' as timeago;

class NotificationListResponseModel {
  List<NotificationModel>? results;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  final String locale;
  NotificationListResponseModel({this.results, this.page, this.limit, this.totalPages, this.totalResults, required this.locale});

  NotificationListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['results'] != null) {
      results = <NotificationModel>[];
      json['results'].forEach((v) {
        results!.add(NotificationModel.fromJson(v, locale));
      });
    } else {
      results = [];
    }
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    return data;
  }
}

class NotificationModel {
  String? title;
  String? content;
  String? createdAt;
  List<Translations>? translations;
  bool? status;
  String? id;
  final String locale;
  NotificationModel({this.title, this.content, this.createdAt, this.translations, this.status, this.id, required this.locale});

  NotificationModel.fromJson(Map<String, dynamic> json, this.locale) {
    title = json['title'];
    content = json['content'];
    String username = '';
    bool userHelper = false;
    if (json['userHelper'] != null && json['userHelper'] != '' && json['userHelper'].toString() == 'true') {
      userHelper = true;
      username = json['username'] != null && json['username'] != '' ? json['username'] : '';
    }
    String restaurantName = '';
    bool restaurantHelper = false;
    if (json['restaurantHelper'] != null && json['restaurantHelper'] != '' && json['restaurantHelper'].toString() == 'true') {
      restaurantHelper = true;
      RestaurantOrPackageDetailModel? details = json['restaurantName'] != null ? RestaurantOrPackageDetailModel.fromJson(json['restaurantName'], locale) : null;
      if (details != null && details.name!.isNotEmpty) {
        restaurantName = details.name!;
      }
    }
    String time = '';
    bool timeHelper = false;
    if (json['timeHelper'] != null && json['timeHelper'] != '' && json['timeHelper'].toString() == 'true') {
      timeHelper = true;
      time = json['time'] != null && json['time'] != '' ? json['time'] : '';
    }
    String driverName = '';
    bool driverHelper = false;
    if (json['driverHelper'] != null && json['driverHelper'] != '' && json['driverHelper'].toString() == 'true') {
      driverHelper = true;
      driverName = json['driverName'] != null && json['driverName'] != '' ? json['driverName'] : '';
    }
    String reason = '';
    bool reasonHelper = false;
    if (json['reasonHelper'] != null && json['reasonHelper'] != '' && json['reasonHelper'].toString() == 'true') {
      reasonHelper = true;
      reason = json['reason'] != null && json['reason'] != '' ? json['reason'] : '';
    }
    String amount = '';
    bool amountHelper = false;
    if (json['amountHelper'] != null && json['amountHelper'] != '' && json['amountHelper'].toString() == 'true') {
      amountHelper = true;
      amount = json['amount'] != null && json['amount'] != '' ? json['amount'] : '';
    }
    String packageName = '';
    bool packageHelper = false;
    if (json['packageHelper'] != null && json['packageHelper'] != '' && json['packageHelper'].toString() == 'true') {
      packageHelper = true;
      RestaurantOrPackageDetailModel? details = json['packageName'] != null ? RestaurantOrPackageDetailModel.fromJson(json['packageName'], locale) : null;
      if (details != null && details.name!.isNotEmpty) {
        packageName = details.name!;
      }
    }
    String kind = '';
    bool kindHelper = false;
    if (json['kindHelper'] != null && json['kindHelper'] != '' && json['kindHelper'].toString() == 'true') {
      kindHelper = true;
      kind = json['kind'] != null && json['kind'] != '' ? json['kind'] : '';
    }
    String order = '';
    bool orderHelper = false;
    if (json['orderHelper'] != null && json['orderHelper'] != '' && json['orderHelper'].toString() == 'true') {
      orderHelper = true;
      order = json['order'] != null && json['order'] != '' ? json['order'] : '';
    }
    if (json['translations'] != null) {
      translations = <Translations>[];
      json['translations'].forEach((v) {
        translations!.add(Translations.fromJson(v));
      });
      if (locale.isNotEmpty && translations!.isNotEmpty) {
        final int localeIndex = translations!.indexWhere((tLocale) => tLocale.code! == locale);
        if (localeIndex != -1) {
          if (translations![localeIndex].title!.isNotEmpty) {
            title = translations![localeIndex].title!;
          }
          if (translations![localeIndex].description!.isNotEmpty) {
            content = translations![localeIndex].description!;
          }
        }
      }
    } else {
      translations = [];
    }

    if (userHelper) {
      title = title!.replaceAll('{{user}}', username);
      content = content!.replaceAll('{{user}}', username);
    }

    if (restaurantHelper) {
      title = title!.replaceAll('{{restaurant}}', restaurantName);
      content = content!.replaceAll('{{restaurant}}', restaurantName);
    }

    if (timeHelper) {
      title = title!.replaceAll('{{time}}', time);
      content = content!.replaceAll('{{time}}', time);
    }

    if (driverHelper) {
      title = title!.replaceAll('{{driver}}', driverName);
      content = content!.replaceAll('{{driver}}', driverName);
    }

    if (reasonHelper) {
      title = title!.replaceAll('{{reason}}', reason);
      content = content!.replaceAll('{{reason}}', reason);
    }

    if (amountHelper) {
      title = title!.replaceAll('{{amount}}', amount);
      content = content!.replaceAll('{{amount}}', amount);
    }

    if (packageHelper) {
      title = title!.replaceAll('{{packageName}}', packageName);
      content = content!.replaceAll('{{packageName}}', packageName);
    }

    if (kindHelper) {
      title = title!.replaceAll('{{kind}}', kind);
      content = content!.replaceAll('{{kind}}', kind);
    }

    if (orderHelper) {
      title = title!.replaceAll('{{order}}', order);
      content = content!.replaceAll('{{order}}', order);
    }

    if (json['createdAt'] != null && json['createdAt'] != '') {
      String apiDate = json['createdAt'];
      DateTime parsedDate = DateTime.parse(apiDate);
      String timeAgoEn = timeago.format(parsedDate, locale: locale);
      createdAt = timeAgoEn;
    } else {
      createdAt = 'just now';
    }
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['content'] = content;
    data['createdAt'] = createdAt;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

class Translations {
  String? name;
  String? code;
  String? nativeName;
  String? title;
  String? description;

  Translations({this.name, this.code, this.nativeName, this.title, this.description});

  Translations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    code = json['code'];
    nativeName = json['nativeName'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['nativeName'] = nativeName;
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

class RestaurantOrPackageDetailModel {
  String? name;
  List<RestaurantOrPackageTranslations>? translations;
  final String locale;
  RestaurantOrPackageDetailModel({this.name, this.translations, required this.locale});

  RestaurantOrPackageDetailModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['name'] != null && json['name'] != '') {
      name = json['name'];
    } else {
      name = '';
    }
    if (json['translations'] != null) {
      translations = <RestaurantOrPackageTranslations>[];
      json['translations'].forEach((v) {
        translations!.add(RestaurantOrPackageTranslations.fromJson(v));
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
    data['name'] = name;
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RestaurantOrPackageTranslations {
  String? name;
  String? code;
  String? nativeName;
  String? title;

  RestaurantOrPackageTranslations({this.name, this.code, this.nativeName, this.title});

  RestaurantOrPackageTranslations.fromJson(Map<String, dynamic> json) {
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

