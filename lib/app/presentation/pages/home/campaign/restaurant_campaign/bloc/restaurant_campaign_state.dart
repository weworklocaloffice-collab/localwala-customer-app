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

part of 'restaurant_campaign_bloc.dart';

enum RestaurantCampaignStatus { loading, success, failure, customError, favUpdate, hidden, unhidden }

extension RestaurantCampaignStatusX on RestaurantCampaignStatus {
  bool get isLoading => this == RestaurantCampaignStatus.loading;
  bool get isSuccess => this == RestaurantCampaignStatus.success;
  bool get isFailure => this == RestaurantCampaignStatus.failure;
  bool get isCustomError => this == RestaurantCampaignStatus.customError;
  bool get isFavUpdate => this == RestaurantCampaignStatus.favUpdate;
  bool get isHidden => this == RestaurantCampaignStatus.hidden;
  bool get isUnhidden => this == RestaurantCampaignStatus.unhidden;
}

final class RestaurantCampaignState {
  final RestaurantCampaignDetailModel campaign;
  final List<String> favIds;
  final String hideUnhideId;
  final bool isAuthorized;
  final RestaurantCampaignStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const RestaurantCampaignState({
    required this.campaign,
    this.favIds = const [],
    this.hideUnhideId = '',
    this.isAuthorized = false,
    this.status = RestaurantCampaignStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  RestaurantCampaignState copyWith({
    RestaurantCampaignDetailModel? campaign,
    List<String>? favIds,
    String? hideUnhideId,
    bool? isAuthorized,
    RestaurantCampaignStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return RestaurantCampaignState(
      campaign: campaign ?? this.campaign,
      favIds: favIds ?? this.favIds,
      hideUnhideId: hideUnhideId ?? this.hideUnhideId,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

