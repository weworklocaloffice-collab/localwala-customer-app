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

class ChatSocketIncomingMessageModel {
  String? senderId;
  String? message;
  String? randomId;
  // Canonical server id from persist-then-emit. Absent on older servers and on
  // pre-auth echoes, so every consumer must fall back to `randomId`.
  String? messageId;
  String? messageType;
  String? currentDate;
  String? role;
  String? senderFirstName;
  String? senderLastName;
  String? senderCover;

  ChatSocketIncomingMessageModel({this.senderId, this.message, this.randomId, this.messageId, this.messageType, this.currentDate, this.role, this.senderFirstName, this.senderLastName, this.senderCover});

  ChatSocketIncomingMessageModel.fromJson(Map<String, dynamic> json) {
    senderId = json['senderId'];
    message = json['message'];
    randomId = json['randomId'];
    messageId = json['messageId'];
    messageType = json['messageType'];
    currentDate = json['currentDate'];
    role = json['role']?.toString();
    senderFirstName = json['senderFirstName']?.toString();
    senderLastName = json['senderLastName']?.toString();
    senderCover = json['senderCover']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['message'] = message;
    data['randomId'] = randomId;
    data['messageId'] = messageId;
    data['messageType'] = messageType;
    data['currentDate'] = currentDate;
    data['role'] = role;
    data['senderFirstName'] = senderFirstName;
    data['senderLastName'] = senderLastName;
    data['senderCover'] = senderCover;
    return data;
  }
}

