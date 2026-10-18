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

class MySupportChatListResponseModel {
  List<SupportChatListModel>? chats;
  bool? success;
  final String locale;

  MySupportChatListResponseModel({this.chats, this.success, required this.locale});

  MySupportChatListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['chats'] != null) {
      chats = <SupportChatListModel>[];
      json['chats'].forEach((v) {
        chats!.add(SupportChatListModel.fromJson(v, locale));
      });
    } else {
      chats = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chats != null) {
      data['chats'] = chats!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class SupportChatListModel {
  String? orders;
  String? booking;
  String? purchaseSubscription;
  String? complaints;
  String? reportIssue;
  String? supportType;
  String? lastMessage;
  String? lastMessageType;
  String? updatedAt;
  List<SupportTeamConfigModel>? team;
  String? status;
  String? id;
  final String locale;
  SupportChatListModel({
    this.orders,
    this.booking,
    this.purchaseSubscription,
    this.complaints,
    this.reportIssue,
    this.supportType,
    this.lastMessage,
    this.lastMessageType,
    this.updatedAt,
    this.team,
    this.status,
    this.id,
    required this.locale,
  });

  SupportChatListModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['orders'] != null && json['orders'] != '') {
      orders = json['orders'];
    } else {
      orders = '';
    }
    if (json['booking'] != null && json['booking'] != '') {
      booking = json['booking'];
    } else {
      booking = '';
    }
    if (json['purchaseSubscription'] != null && json['purchaseSubscription'] != '') {
      purchaseSubscription = json['purchaseSubscription'];
    } else {
      purchaseSubscription = '';
    }
    if (json['complaints'] != null && json['complaints'] != '') {
      complaints = json['complaints'];
    } else {
      complaints = '';
    }
    if (json['reportIssue'] != null && json['reportIssue'] != '') {
      reportIssue = json['reportIssue'];
    } else {
      reportIssue = '';
    }
    supportType = json['supportType'];
    lastMessage = json['lastMessage'];
    lastMessageType = json['lastMessageType'];
    if (json['updatedAt'] != null && json['updatedAt'] != '') {
      DateTime date = DateTime.parse(json['updatedAt']);
      updatedAt = DateFormat('d MMMM yyyy', locale).format(date);
    } else {
      updatedAt = '15 July 1997';
    }
    if (json['team'] != null) {
      team = <SupportTeamConfigModel>[];
      json['team'].forEach((v) {
        team!.add(SupportTeamConfigModel.fromJson(v));
      });
    } else {
      team = [];
    }
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders;
    data['booking'] = booking;
    data['purchaseSubscription'] = purchaseSubscription;
    data['complaints'] = complaints;
    data['reportIssue'] = reportIssue;
    data['supportType'] = supportType;
    data['lastMessage'] = lastMessage;
    data['lastMessageType'] = lastMessageType;
    data['updatedAt'] = updatedAt;
    if (team != null) {
      data['team'] = team!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['status'] = status;
    return data;
  }
}

class SupportTeamConfigModel {
  String? firstName;
  String? lastName;
  String? image;
  String? id;

  SupportTeamConfigModel({this.firstName, this.lastName, this.image, this.id});

  SupportTeamConfigModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    data['id'] = id;
    return data;
  }
}

