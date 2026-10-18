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

part of 'dining_campaign_bloc.dart';

enum DiningCampaignStatus { loading, success, failure, customError, favUpdate, hidden, unhidden }

extension DiningCampaignStatusX on DiningCampaignStatus {
  bool get isLoading => this == DiningCampaignStatus.loading;
  bool get isSuccess => this == DiningCampaignStatus.success;
  bool get isFailure => this == DiningCampaignStatus.failure;
  bool get isCustomError => this == DiningCampaignStatus.customError;
  bool get isFavUpdate => this == DiningCampaignStatus.favUpdate;
  bool get isHidden => this == DiningCampaignStatus.hidden;
  bool get isUnhidden => this == DiningCampaignStatus.unhidden;
}

final class DiningCampaignState {
  final DiningCampaignDetailResponseModel model;
  final List<String> favIds;
  final String hideUnhideId;
  final bool isAuthorized;
  final DiningCampaignStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const DiningCampaignState({
    required this.model,
    this.favIds = const [],
    this.hideUnhideId = '',
    this.isAuthorized = false,
    this.status = DiningCampaignStatus.loading,
    this.statusCode = 0,
    this.alertMessage = '',
    this.extraMessage = '',
  });

  DiningCampaignState copyWith({
    DiningCampaignDetailResponseModel? model,
    List<String>? favIds,
    String? hideUnhideId,
    bool? isAuthorized,
    DiningCampaignStatus? status,
    int? statusCode,
    String? alertMessage,
    String? extraMessage,
  }) {
    return DiningCampaignState(
      model: model ?? this.model,
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

