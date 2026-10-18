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

class UserAvatarListResponseModel {
  List<UserAvatarConfigModel>? avatar;
  bool? success;

  UserAvatarListResponseModel({this.avatar, this.success});

  UserAvatarListResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['avatar'] != null) {
      avatar = <UserAvatarConfigModel>[];
      json['avatar'].forEach((v) {
        avatar!.add(UserAvatarConfigModel.fromJson(v));
      });
    } else {
      avatar = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (avatar != null) {
      data['avatar'] = avatar!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class UserAvatarConfigModel {
  String? avatar;
  bool? isDefault;
  bool? status;
  String? id;

  UserAvatarConfigModel({this.avatar, this.isDefault, this.status, this.id});

  UserAvatarConfigModel.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    isDefault = json['isDefault'];
    status = json['status'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['isDefault'] = isDefault;
    data['status'] = status;
    data['id'] = id;
    return data;
  }
}

