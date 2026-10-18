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

import 'package:user/app/core/models/dining_booking_list_response_model.dart';

class DiningBookingSearchResponseModel {
  List<DiningBookingDetailConfigModel>? bookings;
  int? totalResults;
  bool? success;
  final String locale;
  DiningBookingSearchResponseModel({this.bookings, this.totalResults, this.success, required this.locale});

  DiningBookingSearchResponseModel.fromJson(Map<String, dynamic> json, this.locale) {
    if (json['bookings'] != null) {
      bookings = <DiningBookingDetailConfigModel>[];
      json['bookings'].forEach((v) {
        bookings!.add(DiningBookingDetailConfigModel.fromJson(v, locale));
      });
    } else {
      bookings = [];
    }
    if (json['totalResults'] != null && json['totalResults'] != '') {
      totalResults = int.parse(json['totalResults'].toString());
    } else {
      totalResults = 0;
    }
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bookings != null) {
      data['bookings'] = bookings!.map((v) => v.toJson()).toList();
    }
    data['totalResults'] = totalResults;
    data['success'] = success;
    return data;
  }
}

