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
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

part of 'reels_bloc.dart';

sealed class ReelsState {
  const ReelsState();
}

final class ReelsInitial extends ReelsState {}

final class ReelsLoadInProgress extends ReelsState {}

final class ReelsLoadSuccess extends ReelsState {
  final List<ReelModel> items;
  final int page;
  final int totalPages;

  const ReelsLoadSuccess({
    required this.items,
    required this.page,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

final class ReelsLoadFailure extends ReelsState {
  final String message;

  const ReelsLoadFailure(this.message);
}
