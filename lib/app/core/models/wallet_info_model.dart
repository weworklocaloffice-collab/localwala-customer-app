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

import 'package:intl/intl.dart';

class WalletInfoModel {
  List<WalletTransactionModel>? transaction;
  WalletUserInfoModel? info;
  int? page;
  int? limit;
  int? totalPages;
  int? totalResults;
  UserSettingsModel? userSettings;
  bool? success;
  final String locale;

  WalletInfoModel({this.transaction, this.info, this.page, this.limit, this.totalPages, this.totalResults, this.userSettings, this.success, required this.locale});

  WalletInfoModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['transaction'] != null) {
      transaction = <WalletTransactionModel>[];
      json['transaction'].forEach((v) {
        transaction!.add(WalletTransactionModel.fromJson(v, locale));
      });
    } else {
      transaction = [];
    }
    info = json['info'] != null ? WalletUserInfoModel.fromJson(json['info']) : null;
    page = json['page'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
    userSettings = json['userSettings'] != null ? UserSettingsModel.fromJson(json['userSettings']) : null;
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transaction != null) {
      data['transaction'] = transaction!.map((v) => v.toJson()).toList();
    }
    if (info != null) {
      data['info'] = info!.toJson();
    }
    data['page'] = page;
    data['limit'] = limit;
    data['totalPages'] = totalPages;
    data['totalResults'] = totalResults;
    if (userSettings != null) {
      data['userSettings'] = userSettings!.toJson();
    }
    data['success'] = success;
    return data;
  }
}

class WalletTransactionModel {
  String? type;
  bool? confirmed;
  bool? status;
  String? createdAt;
  String? uuid;
  String? id;
  double? amount;
  final String locale;

  WalletTransactionModel({this.type, this.confirmed, this.status, this.createdAt, this.uuid, this.id, this.amount, required this.locale});

  WalletTransactionModel.fromJson(Map<String, dynamic> json, this.locale) {
    type = json['type'];
    confirmed = json['confirmed'];
    status = json['status'];
    if (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['createdAt']);
      var inputDate = DateTime.parse(parseDate.toString());
      createdAt = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      createdAt = '-';
    }
    uuid = json['uuid'];
    id = json['id'];
    if (json['amount'] != null && json['amount'] != '') {
      amount = double.parse(json['amount'].toString());
    } else {
      amount = 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['confirmed'] = confirmed;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['uuid'] = uuid;
    data['id'] = id;
    data['amount'] = amount;
    return data;
  }
}

class WalletUserInfoModel {
  String? holderId;
  String? description;
  double? balance;
  int? decimalPlaces;
  bool? status;
  String? uuid;
  String? id;

  WalletUserInfoModel({this.holderId, this.description, this.balance, this.decimalPlaces, this.status, this.uuid, this.id});

  WalletUserInfoModel.fromJson(Map<String, dynamic> json) {
    holderId = json['holderId'];
    description = json['description'];
    if (json['balance'] != null && json['balance'] != '') {
      balance = double.parse(json['balance'].toString());
    } else {
      balance = 0;
    }
    if (json['decimalPlaces'] != null && json['decimalPlaces'] != '') {
      decimalPlaces = int.parse(json['decimalPlaces'].toString());
    } else {
      decimalPlaces = 2;
    }
    status = json['status'];
    uuid = json['uuid'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['holderId'] = holderId;
    data['description'] = description;
    data['balance'] = balance;
    data['decimalPlaces'] = decimalPlaces;
    data['status'] = status;
    data['uuid'] = uuid;
    data['id'] = id;
    return data;
  }
}

class UserSettingsModel {
  bool? canEarnBuyFromWallet;
  bool? refundToWallet;
  bool? canAddFundToWallet;
  bool? canEarnLoyaltyPointOnOrder;
  String? id;

  UserSettingsModel({this.canEarnBuyFromWallet, this.refundToWallet, this.canAddFundToWallet, this.canEarnLoyaltyPointOnOrder, this.id});

  UserSettingsModel.fromJson(Map<String, dynamic> json) {
    canEarnBuyFromWallet = json['canEarnBuyFromWallet'];
    refundToWallet = json['refundToWallet'];
    canAddFundToWallet = json['canAddFundToWallet'];
    canEarnLoyaltyPointOnOrder = json['canEarnLoyaltyPointOnOrder'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canEarnBuyFromWallet'] = canEarnBuyFromWallet;
    data['refundToWallet'] = refundToWallet;
    data['canAddFundToWallet'] = canAddFundToWallet;
    data['canEarnLoyaltyPointOnOrder'] = canEarnLoyaltyPointOnOrder;
    data['id'] = id;
    return data;
  }
}

