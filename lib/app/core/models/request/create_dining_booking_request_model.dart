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

class CreateDiningBookingRequestModel {
  String? user;
  String? payment;
  String? restaurant;
  String? coupon;
  String? bookingDate;
  String? bookingSlot;
  int? guest;
  String? userName;
  int? userCountryCode;
  String? userContact;
  String? userEmail;
  String? specialRequest;
  String? campaignId;

  CreateDiningBookingRequestModel({
    this.user,
    this.payment,
    this.restaurant,
    this.coupon,
    this.bookingDate,
    this.bookingSlot,
    this.guest,
    this.userName,
    this.userCountryCode,
    this.userContact,
    this.userEmail,
    this.specialRequest,
    this.campaignId,
  });

  CreateDiningBookingRequestModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    payment = json['payment'];
    restaurant = json['restaurant'];
    coupon = json['coupon'];
    bookingDate = json['bookingDate'];
    bookingSlot = json['bookingSlot'];
    guest = json['guest'];
    userName = json['userName'];
    userCountryCode = json['userCountryCode'];
    userContact = json['userContact'];
    userEmail = json['userEmail'];
    specialRequest = json['specialRequest'];
    campaignId = json['campaignId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['payment'] = payment;
    data['restaurant'] = restaurant;
    data['coupon'] = coupon;
    data['bookingDate'] = bookingDate;
    data['bookingSlot'] = bookingSlot;
    data['guest'] = guest;
    data['userName'] = userName;
    data['userCountryCode'] = userCountryCode;
    data['userContact'] = userContact;
    data['userEmail'] = userEmail;
    data['specialRequest'] = specialRequest;
    data['campaignId'] = campaignId;
    return data;
  }
}

