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

class AccountUpdateNotificationSettingRequestModel {
  bool? newsletters;
  bool? promoEmail;
  bool? promoNotification;
  bool? promoWhatsApp;
  bool? socialEmail;
  bool? socialNotification;
  bool? orderEmail;
  bool? orderNotification;
  bool? orderWhatsApp;
  bool? importantUpdate;

  AccountUpdateNotificationSettingRequestModel({
    this.newsletters,
    this.promoEmail,
    this.promoNotification,
    this.promoWhatsApp,
    this.socialEmail,
    this.socialNotification,
    this.orderEmail,
    this.orderNotification,
    this.orderWhatsApp,
    this.importantUpdate,
  });

  AccountUpdateNotificationSettingRequestModel.fromJson(Map<String, dynamic> json) {
    newsletters = json['newsletters'];
    promoEmail = json['promoEmail'];
    promoNotification = json['promoNotification'];
    promoWhatsApp = json['promoWhatsApp'];
    socialEmail = json['socialEmail'];
    socialNotification = json['socialNotification'];
    orderEmail = json['orderEmail'];
    orderNotification = json['orderNotification'];
    orderWhatsApp = json['orderWhatsApp'];
    importantUpdate = json['importantUpdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['newsletters'] = newsletters;
    data['promoEmail'] = promoEmail;
    data['promoNotification'] = promoNotification;
    data['promoWhatsApp'] = promoWhatsApp;
    data['socialEmail'] = socialEmail;
    data['socialNotification'] = socialNotification;
    data['orderEmail'] = orderEmail;
    data['orderNotification'] = orderNotification;
    data['orderWhatsApp'] = orderWhatsApp;
    data['importantUpdate'] = importantUpdate;
    return data;
  }
}

