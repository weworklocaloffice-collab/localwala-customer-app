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

part of 'food_campaign_bloc.dart';

enum FoodCampaignStatus { loading, success, failure, customError, cartUpdate, cartError, favUpdate }

extension FoodCampaignStatusX on FoodCampaignStatus {
  bool get isLoading => this == FoodCampaignStatus.loading;
  bool get isSuccess => this == FoodCampaignStatus.success;
  bool get isFailure => this == FoodCampaignStatus.failure;
  bool get isCustomError => this == FoodCampaignStatus.customError;
  bool get isCartUpdate => this == FoodCampaignStatus.cartUpdate;
  bool get isCartError => this == FoodCampaignStatus.cartError;
  bool get isFavUpdate => this == FoodCampaignStatus.favUpdate;
}

final class FoodCampaignState {
  final FoodCampaignDetailModel campaign;
  final List<String> favIds;
  final String appLocale;
  final FoodCampaignStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const FoodCampaignState({required this.campaign, this.favIds = const [], this.appLocale = '', this.status = FoodCampaignStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  FoodCampaignState copyWith({FoodCampaignDetailModel? campaign, List<String>? favIds, String? appLocale, FoodCampaignStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return FoodCampaignState(
      campaign: campaign ?? this.campaign,
      favIds: favIds ?? this.favIds,
      appLocale: appLocale ?? this.appLocale,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

