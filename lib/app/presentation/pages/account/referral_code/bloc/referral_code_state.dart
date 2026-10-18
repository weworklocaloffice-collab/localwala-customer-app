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

part of 'referral_code_bloc.dart';

enum ReferralCodeStatus { loading, success, failure, unAuthorized }

extension ReferralCodeStatusX on ReferralCodeStatus {
  bool get isLoading => this == ReferralCodeStatus.loading;
  bool get isSuccess => this == ReferralCodeStatus.success;
  bool get isFailure => this == ReferralCodeStatus.failure;
  bool get isUnAuthorizd => this == ReferralCodeStatus.unAuthorized;
}

final class ReferralCodeState {
  final String title;
  final String subTitle;
  final String referralCode;
  final ReferralCodeResponseModel model;
  final ReferralCodeStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const ReferralCodeState({this.title = '', this.subTitle = '', this.referralCode = '', required this.model, this.status = ReferralCodeStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  ReferralCodeState copyWith({String? title, String? subTitle, String? referralCode, ReferralCodeResponseModel? model, ReferralCodeStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return ReferralCodeState(
      title: title ?? this.title,
      subTitle: subTitle ?? this.subTitle,
      referralCode: referralCode ?? this.referralCode,
      model: model ?? this.model,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

