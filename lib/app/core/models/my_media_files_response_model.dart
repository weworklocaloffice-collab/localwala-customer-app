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

class MyMediaFilesResponseModel {
  List<MediaFileConfigModel>? results;
  bool? success;

  MyMediaFilesResponseModel({this.results, this.success});

  MyMediaFilesResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <MediaFileConfigModel>[];
      json['results'].forEach((v) {
        results!.add(MediaFileConfigModel.fromJson(v));
      });
    } else {
      results = [];
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    return data;
  }
}

class MediaFileConfigModel {
  String? path;
  String? uid;
  String? id;

  MediaFileConfigModel({this.path, this.uid, this.id});

  MediaFileConfigModel.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    uid = json['uid'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['uid'] = uid;
    data['id'] = id;
    return data;
  }
}

