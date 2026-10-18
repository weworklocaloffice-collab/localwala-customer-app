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

part of 'user_avatar_list_modal_bloc.dart';

enum UserAvatarListModalStatus { loading, success, failure, empty }

extension UserAvatarListModalStatusX on UserAvatarListModalStatus {
  bool get isLoading => this == UserAvatarListModalStatus.loading;
  bool get isSuccess => this == UserAvatarListModalStatus.success;
  bool get isFailure => this == UserAvatarListModalStatus.failure;
  bool get isEmpty => this == UserAvatarListModalStatus.empty;
}

final class UserAvatarListModalState {
  final UserAvatarListResponseModel model;
  final String selected;
  final UserAvatarListModalStatus status;
  final int statusCode;
  final String alertMessage;
  final String extraMessage;
  const UserAvatarListModalState({required this.model, this.selected = '', this.status = UserAvatarListModalStatus.loading, this.statusCode = 0, this.alertMessage = '', this.extraMessage = ''});

  UserAvatarListModalState copyWith({UserAvatarListResponseModel? model, String? selected, UserAvatarListModalStatus? status, int? statusCode, String? alertMessage, String? extraMessage}) {
    return UserAvatarListModalState(
      model: model ?? this.model,
      selected: selected ?? this.selected,
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      alertMessage: alertMessage ?? this.alertMessage,
      extraMessage: extraMessage ?? this.extraMessage,
    );
  }
}

