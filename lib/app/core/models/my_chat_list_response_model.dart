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

class MyChatListResponseModel {
  List<ChatConfigModel>? chats;
  bool? success;
  final String locale;
  MyChatListResponseModel({this.chats, this.success, required this.locale});

  MyChatListResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['chats'] != null) {
      chats = <ChatConfigModel>[];
      json['chats'].forEach((v) {
        chats!.add(ChatConfigModel.fromJson(v, locale));
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

class ChatConfigModel {
  String? senderId;
  String? receiverId;
  UserInfoConfigModel? senderInfo;
  UserInfoConfigModel? receiverInfo;
  String? id;
  String? lastMessage;
  String? lastMessageType;
  String? updatedAt;
  final String locale;

  ChatConfigModel({this.senderId, this.receiverId, this.senderInfo, this.receiverInfo, this.id, this.lastMessage, this.lastMessageType, this.updatedAt, required this.locale});

  ChatConfigModel.fromJson(Map<String, dynamic> json, this.locale) {
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    senderInfo = json['senderInfo'] != null ? UserInfoConfigModel.fromJson(json['senderInfo']) : null;
    receiverInfo = json['receiverInfo'] != null ? UserInfoConfigModel.fromJson(json['receiverInfo']) : null;
    id = json['id'];
    lastMessage = json['lastMessage'];
    lastMessageType = json['lastMessageType'];
    if (json['updatedAt'] != null && json['updatedAt'] != '') {
      DateTime date = DateTime.parse(json['updatedAt']);
      updatedAt = DateFormat('d MMMM yyyy', locale).format(date);
    } else {
      updatedAt = '15 July 1997';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    if (senderInfo != null) {
      data['senderInfo'] = senderInfo!.toJson();
    }
    if (receiverInfo != null) {
      data['receiverInfo'] = receiverInfo!.toJson();
    }
    data['id'] = id;
    data['lastMessage'] = lastMessage;
    data['lastMessageType'] = lastMessageType;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class UserInfoConfigModel {
  String? id;
  String? firstName;
  String? lastName;
  String? image;

  UserInfoConfigModel({this.id, this.firstName, this.lastName, this.image});

  UserInfoConfigModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['image'] = image;
    return data;
  }
}

