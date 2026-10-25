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

sealed class ReelsEvent {
  const ReelsEvent();
}

final class ReelsFeedRequested extends ReelsEvent {
  final int page;
  final int limit;

  const ReelsFeedRequested({this.page = 1, this.limit = 10});
}

final class ReelsFeedRefreshed extends ReelsEvent {
  const ReelsFeedRefreshed();
}

final class ReelLikeToggled extends ReelsEvent {
  final String reelId;

  const ReelLikeToggled(this.reelId);
}

final class ReelSaveToggled extends ReelsEvent {
  final String reelId;

  const ReelSaveToggled(this.reelId);
}

final class ReelShared extends ReelsEvent {
  final String reelId;

  const ReelShared(this.reelId);
}

final class ReelViewed extends ReelsEvent {
  final String reelId;
  final int watchedMs;
  final bool completed;

  const ReelViewed(this.reelId, {this.watchedMs = 0, this.completed = false});
}

/// Fired after the comments sheet has already posted the comment.
///
/// The sheet posts it directly so it can keep the draft on failure; the bloc only
/// owns the feed's comment counter, so this carries no content and must never be
/// re-sent to the API.
final class ReelCommentPosted extends ReelsEvent {
  final String reelId;

  const ReelCommentPosted(this.reelId);
}

/// One of SPAM, INAPPROPRIATE, MISLEADING, COPYRIGHT, OTHER.
final class ReelReported extends ReelsEvent {
  final String reelId;
  final String reason;
  final String? details;

  /// Called once the API answers. Only the success path needs it - failures are
  /// already surfaced through [ReelsActionFailed], and reporting was the one action
  /// that gave no confirmation when it worked.
  final void Function()? onReported;

  const ReelReported(
    this.reelId,
    this.reason, {
    this.details,
    this.onReported,
  });
}
