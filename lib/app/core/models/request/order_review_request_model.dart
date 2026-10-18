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

import 'package:user/app/core/models/request/product_review_param_request_model.dart';

class OrderReviewRequestModel {
  String? user;
  String? orders;
  String? driver;
  String? restaurant;
  int? driverRate;
  int? restaurantRate;
  String? driverMessage;
  String? restaurantMessage;
  List<ProductReviewParamRequestModel>? product;
  String? images;
  String? shortReview;

  OrderReviewRequestModel({this.user, this.orders, this.driver, this.restaurant, this.driverRate, this.restaurantRate, this.driverMessage, this.restaurantMessage, this.product, this.images, this.shortReview});

  OrderReviewRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    orders = json['orders'];
    driver = json['driver'];
    restaurant = json['restaurant'];
    driverRate = json['driverRate'];
    restaurantRate = json['restaurantRate'];
    driverMessage = json['driverMessage'];
    restaurantMessage = json['restaurantMessage'];
    if (json['product'] != null) {
      product = <ProductReviewParamRequestModel>[];
      json['product'].forEach((v) {
        product!.add(ProductReviewParamRequestModel.fromJson(v));
      });
    } else {
      product = [];
    }
    images = json['images'];
    shortReview = json['shortReview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['orders'] = orders;
    data['driver'] = driver;
    data['restaurant'] = restaurant;
    data['driverRate'] = driverRate;
    data['restaurantRate'] = restaurantRate;
    data['driverMessage'] = driverMessage;
    data['restaurantMessage'] = restaurantMessage;
    if (product != null) {
      data['product'] = product!.map((v) => v.toJson()).toList();
    }
    data['images'] = images;
    data['shortReview'] = shortReview;
    return data;
  }
}

