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

/// A state that still has a usable feed in it.
///
/// Lifted out of [ReelsLoadSuccess] because a failed page load and a failed interaction
/// both have to leave the reels already on screen exactly where they were. Re-emitting
/// "success" for those cases would lie to the listener, and giving each its own copy of
/// items/page/totalPages is how the pagination window got reset by a like in the first
/// place.
sealed class ReelsFeed extends ReelsState {
  final List<ReelModel> items;
  final int page;
  final int totalPages;

  /// The API ended the feed because a signed-out visitor used up the guest
  /// allowance. Carried on every [ReelsFeed] so a like or a page retry cannot
  /// silently drop the sign-in card the feed is supposed to end on.
  final bool loginRequired;

  const ReelsFeed({
    required this.items,
    required this.page,
    required this.totalPages,
    this.loginRequired = false,
  });

  bool get hasMore => page < totalPages;
}

final class ReelsLoadSuccess extends ReelsFeed {
  const ReelsLoadSuccess({
    required super.items,
    required super.page,
    required super.totalPages,
    super.loginRequired,
  });
}

final class ReelsLoadFailure extends ReelsState {
  final String message;

  const ReelsLoadFailure(this.message);
}

/// The session is gone: the feed came back 401 and the Dio interceptor has already
/// thrown both tokens away.
///
/// Kept apart from [ReelsLoadFailure] because the two need different screens. A failed
/// load can be retried; a missing token cannot. Telling the user to pull to retry after
/// the refresh token was rejected gives them an action that is guaranteed to fail, so
/// the view has to offer a way back to login instead.
final class ReelsAuthRequired extends ReelsState {
  const ReelsAuthRequired();
}

/// A page beyond the first failed while the feed is already on screen.
///
/// Separate from [ReelsLoadFailure] on purpose. That state replaces the whole feed,
/// which is right for page 1 and catastrophic for page 2 - one dropped request mid-scroll
/// must not throw away every reel the user has already swiped past. This state carries
/// the feed forward unchanged and only says "that load finished, unsuccessfully", which
/// is the signal the view needs to re-arm its paging gate and say so.
final class ReelsFeedPageFailed extends ReelsFeed {
  const ReelsFeedPageFailed({
    required super.items,
    required super.page,
    required super.totalPages,
    super.loginRequired,
  });
}

/// An interaction (like, save, share, comment) was rolled back.
///
/// The optimistic write is undone and the feed is handed back untouched, so the UI can
/// show a message without having to reconcile anything itself. Before this the bloc
/// returned early on every failed call: the heart stayed where the tap had not yet
/// reached it, and nothing on screen said why.
final class ReelsActionFailed extends ReelsFeed {
  final String message;

  /// The interaction was rejected with 401, so the fix is logging in rather than
  /// retrying. The view turns this into a sign-in action on the message.
  final bool signInRequired;

  const ReelsActionFailed({
    required super.items,
    required super.page,
    required super.totalPages,
    super.loginRequired,
    required this.message,
    this.signInRequired = false,
  });
}
