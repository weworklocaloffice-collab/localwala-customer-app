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

class LoyaltyPointsResponseModel {
  List<ActivePoints>? activePoints;
  UserSettings? userSettings;
  double? totalPoints;
  double? canEarnInWallet;
  bool? success;
  final String locale;
  LoyaltyPointsResponseModel({this.activePoints, this.userSettings, this.totalPoints, this.canEarnInWallet, this.success, required this.locale});

  LoyaltyPointsResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['activePoints'] != null) {
      activePoints = <ActivePoints>[];
      json['activePoints'].forEach((v) {
        activePoints!.add(ActivePoints.fromJson(v, locale));
      });
    } else {
      activePoints = [];
    }
    userSettings = json['userSettings'] != null ? UserSettings.fromJson(json['userSettings']) : null;
    if (json['totalPoints'] != null && json['totalPoints'] != '') {
      totalPoints = double.parse(json['totalPoints'].toString());
    } else {
      totalPoints = 0.0;
    }
    if (json['canEarnInWallet'] != null && json['canEarnInWallet'] != '') {
      canEarnInWallet = double.parse(json['canEarnInWallet'].toString());
    } else {
      canEarnInWallet = 0.0;
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (activePoints != null) {
      data['activePoints'] = activePoints!.map((v) => v.toJson()).toList();
    }
    if (userSettings != null) {
      data['userSettings'] = userSettings!.toJson();
    }
    data['totalPoints'] = totalPoints;
    data['canEarnInWallet'] = canEarnInWallet;
    data['success'] = success;
    return data;
  }
}

class ActivePoints {
  String? orderId;
  String? coupon;
  String? redeemFrom;
  bool? redeemedToWallet;
  String? createdAt;
  String? id;
  double? loyaltyPointValue;
  final String locale;
  ActivePoints({this.orderId, this.coupon, this.redeemFrom, this.redeemedToWallet, this.createdAt, this.id, this.loyaltyPointValue, required this.locale});

  ActivePoints.fromJson(Map<String, dynamic> json, this.locale) {
    orderId = json['orderId'];
    coupon = json['coupon'];
    redeemFrom = json['redeemFrom'];
    redeemedToWallet = json['redeemedToWallet'];
    if (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty) {
      DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(json['createdAt']);
      var inputDate = DateTime.parse(parseDate.toString());
      createdAt = DateFormat.yMMMd(locale).format(inputDate);
    } else {
      createdAt = '-';
    }
    id = json['id'];
    if (json['loyaltyPointValue'] != null && json['loyaltyPointValue'] != '') {
      loyaltyPointValue = double.parse(json['loyaltyPointValue'].toString());
    } else {
      loyaltyPointValue = 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderId'] = orderId;
    data['coupon'] = coupon;
    data['redeemFrom'] = redeemFrom;
    data['redeemedToWallet'] = redeemedToWallet;
    data['createdAt'] = createdAt;
    data['id'] = id;
    data['loyaltyPointValue'] = loyaltyPointValue;
    return data;
  }
}

class UserSettings {
  bool? canEarnLoyaltyPointOnOrder;
  double? loyaltyMinOrderTotal;
  double? loyaltyPointValue;
  double? minLoyaltyPointToRedeem;
  double? priceOfOneLoyaltyPoint;
  String? id;

  UserSettings({this.canEarnLoyaltyPointOnOrder, this.loyaltyMinOrderTotal, this.loyaltyPointValue, this.minLoyaltyPointToRedeem, this.priceOfOneLoyaltyPoint, this.id});

  UserSettings.fromJson(Map<String, dynamic> json) {
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
    if (json['minLoyaltyPointToRedeem'] != null && json['minLoyaltyPointToRedeem'] != '') {
      minLoyaltyPointToRedeem = double.parse(json['minLoyaltyPointToRedeem'].toString());
    } else {
      minLoyaltyPointToRedeem = 0.0;
    }
    if (json['priceOfOneLoyaltyPoint'] != null && json['priceOfOneLoyaltyPoint'] != '') {
      priceOfOneLoyaltyPoint = double.parse(json['priceOfOneLoyaltyPoint'].toString());
    } else {
      priceOfOneLoyaltyPoint = 0.0;
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canEarnLoyaltyPointOnOrder'] = canEarnLoyaltyPointOnOrder;
    data['loyaltyMinOrderTotal'] = loyaltyMinOrderTotal;
    data['loyaltyPointValue'] = loyaltyPointValue;
    data['minLoyaltyPointToRedeem'] = minLoyaltyPointToRedeem;
    data['priceOfOneLoyaltyPoint'] = priceOfOneLoyaltyPoint;
    data['id'] = id;
    return data;
  }
}

