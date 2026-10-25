/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Â© 2026 WeWorkLocal.
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

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/models/reel_model.dart';
import 'package:user/app/core/repositories/reels_repository.dart';

part 'reels_event.dart';
part 'reels_state.dart';

/// Customer reels feed. Server-confirmed toggles (no optimistic rollback
/// bookkeeping): each interaction awaits the API and applies its counts.
class ReelsBloc extends Bloc<ReelsEvent, ReelsState> {
  final ReelsRepository _repository = ReelsRepository();

  ReelsBloc() : super(ReelsInitial()) {
    on<ReelsFeedRequested>(_onFeedRequested);
    on<ReelsFeedRefreshed>(_onFeedRefreshed);
    on<ReelLikeToggled>(_onLikeToggled);
    on<ReelSaveToggled>(_onSaveToggled);
    on<ReelShared>(_onShared);
    on<ReelViewed>(_onViewed);
    on<ReelCommentPosted>(_onCommentPosted);
    on<ReelReported>(_onReported);
  }

  List<ReelModel> _currentItems() {
    final state = this.state;
    return state is ReelsFeed ? state.items : <ReelModel>[];
  }

  /// Reels with an interaction call still in flight.
  ///
  /// Guarded per reel, not globally: a slow like on one card must not block liking the
  /// next one.
  final Set<String> _inFlight = <String>{};

  /// Page metadata of the loaded feed, or null when nothing is loaded.
  ///
  /// Every interaction below re-emits the list it was handed rather than refetching it,
  /// so it has to carry the pagination window across with it. Without that, applying a
  /// like reset the state to `page: 1, totalPages: 1` - `hasMore` went false, the loader
  /// row left `itemCount`, and one tap on the heart permanently ended infinite scroll
  /// until the user pulled to refresh.
  ({int page, int totalPages})? _currentPaging() {
    final state = this.state;
    if (state is! ReelsFeed) return null;
    return (page: state.page, totalPages: state.totalPages);
  }

  /// Whether the feed on screen is already ending in a sign-in prompt, so that a
  /// failure emission does not drop it.
  bool _currentLoginRequired() {
    final state = this.state;
    return state is ReelsFeed && state.loginRequired;
  }

  List<ReelModel> _updatedItems(
    String reelId,
    ReelModel Function(ReelModel) update,
  ) {
    final state = this.state;
    // Bail out rather than emitting an empty feed. A like arriving while the first
    // page is still loading would otherwise replace the whole feed with
    // `ReelsLoadSuccess([], 1, 1)`, which the view renders as "No reels yet".
    if (state is! ReelsFeed) return const <ReelModel>[];
    return state.items
        .map((item) => item.id == reelId ? update(item) : item)
        .toList();
  }

  /// Re-emits the current feed with one item replaced.
  ///
  /// A no-op when there is nothing loaded to amend, so a late-arriving response can
  /// never clear a feed it did not contribute to.
  void _emitAmended(
    Emitter<ReelsState> emit,
    String reelId,
    ReelModel Function(ReelModel) update,
  ) {
    final state = this.state;
    if (state is! ReelsFeed) return;
    emit(
      ReelsLoadSuccess(
        items: _updatedItems(reelId, update),
        page: state.page,
        totalPages: state.totalPages,
        loginRequired: state.loginRequired,
      ),
    );
  }

  /// Runs an interaction optimistically: paint the change now, reconcile with the server
  /// on the way back, and undo it if the call did not land.
  ///
  /// Without this the heart, the bookmark and the counter all sat frozen for the length
  /// of a round trip, which on a phone reads as a dropped tap. Without the rollback it
  /// would instead leave a lie on screen when the call failed - and every failure used
  /// to be silent, so the user had no way to tell a slow network from a broken button.
  Future<void> _optimistic(
    Emitter<ReelsState> emit,
    String reelId,
    ReelModel Function(ReelModel) optimisticUpdate,
    ReelModel Function(ReelModel, Map<String, dynamic> data) reconcile,
    Future<DioApiResponse> Function() call,
    String failureMessage,
  ) async {
    // The server toggle is read-then-write, so two overlapping taps on the same reel
    // could resolve in either order and leave the icon disagreeing with the count.
    if (_inFlight.contains(reelId)) return;
    _inFlight.add(reelId);

    // Snapshot for the rollback: the whole item, not just the field being toggled.
    final state = this.state;
    final original = state is ReelsFeed
        ? state.items.where((item) => item.id == reelId).firstOrNull
        : null;
    if (original == null) {
      _inFlight.remove(reelId);
      return;
    }

    _emitAmended(emit, reelId, optimisticUpdate);

    try {
      final response = await call();
      final data = response.success ? _decodeMap(response.body) : null;
      if (data == null) {
        // 401 means no token: a guest tapping a heart, not a broken call. The
        // rollback is the same, but the view offers a way into login instead of
        // "try again", which could never work.
        _rollback(
          emit,
          original,
          failureMessage,
          signInRequired: response.statusCode == 401,
        );
        return;
      }
      _emitAmended(emit, reelId, (item) => reconcile(item, data));
    } finally {
      _inFlight.remove(reelId);
    }
  }

  /// Puts the pre-tap item back and tells the view why, in one emission.
  void _rollback(
    Emitter<ReelsState> emit,
    ReelModel original,
    String message, {
    bool signInRequired = false,
  }) {
    final state = this.state;
    if (state is! ReelsFeed) return;
    emit(
      ReelsActionFailed(
        items: state.items
            .map((item) => item.id == original.id ? original : item)
            .toList(),
        page: state.page,
        totalPages: state.totalPages,
        loginRequired: state.loginRequired,
        message: message,
        signInRequired: signInRequired,
      ),
    );
  }

  /// Safely reads a JSON object body.
  ///
  /// `DioApiResponse.body` is `jsonEncode(raw.data)`, so a 204 or an empty payload
  /// round-trips as the string `'null'` / `'""'`. The direct
  /// `jsonDecode(response.body) as Map<String, dynamic>` these calls used instead threw
  /// a TypeError on exactly that, taking down every like, save, share and comment in
  /// one go - and a throw inside an event handler is swallowed by bloc, so it presented
  /// as the tap doing nothing at all.
  Map<String, dynamic>? _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  void _emitSuccess(
    Emitter<ReelsState> emit,
    List<ReelModel> items, {
    int page = 1,
    int totalPages = 1,
    bool loginRequired = false,
  }) {
    emit(
      ReelsLoadSuccess(
        items: items,
        page: page,
        totalPages: totalPages,
        loginRequired: loginRequired,
      ),
    );
  }

  FutureOr<void> _onFeedRequested(
    ReelsFeedRequested event,
    Emitter<ReelsState> emit,
  ) async {
    final previous = _currentItems();
    if (event.page == 1 && previous.isEmpty) emit(ReelsLoadInProgress());
    final response = await _repository.getFeed(
      page: event.page,
      limit: event.limit,
    );
    if (!response.success) {
      if (response.statusCode == 401) {
        emit(const ReelsAuthRequired());
        return;
      }
      if (previous.isEmpty) {
        emit(const ReelsLoadFailure('Could not load reels. Pull to retry.'));
        return;
      }
      // The feed is already on screen, so it stays. But something has to be emitted,
      // because the view latches its paging gate when a request starts and only clears
      // it on a state change. Silently returning here left that gate shut: one dropped
      // request mid-scroll meant no further page could ever be requested and the loader
      // row spun forever.
      final paging = _currentPaging() ?? (page: 1, totalPages: 1);
      emit(
        ReelsFeedPageFailed(
          items: previous,
          page: paging.page,
          totalPages: paging.totalPages,
          loginRequired: _currentLoginRequired(),
        ),
      );
      return;
    }
    final page = ReelsFeedPage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    final items = event.page == 1 ? page.items : [...previous, ...page.items];
    _emitSuccess(
      emit,
      items,
      page: page.page,
      totalPages: page.totalPages,
      loginRequired: page.loginRequired,
    );
  }

  FutureOr<void> _onFeedRefreshed(
    ReelsFeedRefreshed event,
    Emitter<ReelsState> emit,
  ) async {
    add(const ReelsFeedRequested(page: 1));
  }

  FutureOr<void> _onLikeToggled(
    ReelLikeToggled event,
    Emitter<ReelsState> emit,
  ) {
    return _optimistic(
      emit,
      event.reelId,
      (item) => item.copyWith(
        liked: !item.liked,
        likesCount: item.likesCount + (item.liked ? -1 : 1),
      ),
      (item, data) => item.copyWith(
        liked: (data['liked'] as bool?) ?? item.liked,
        likesCount: (data['likeCount'] as num?)?.toInt() ?? item.likesCount,
      ),
      () => _repository.toggleLike(event.reelId),
      'Could not update the like. Try again.',
    );
  }

  FutureOr<void> _onSaveToggled(
    ReelSaveToggled event,
    Emitter<ReelsState> emit,
  ) {
    return _optimistic(
      emit,
      event.reelId,
      (item) => item.copyWith(
        saved: !item.saved,
        savesCount: item.savesCount + (item.saved ? -1 : 1),
      ),
      (item, data) => item.copyWith(
        saved: (data['saved'] as bool?) ?? item.saved,
        savesCount: (data['saveCount'] as num?)?.toInt() ?? item.savesCount,
      ),
      () => _repository.toggleSave(event.reelId),
      'Could not update the save. Try again.',
    );
  }

  FutureOr<void> _onShared(ReelShared event, Emitter<ReelsState> emit) {
    return _optimistic(
      emit,
      event.reelId,
      (item) => item.copyWith(sharesCount: item.sharesCount + 1),
      (item, data) => item.copyWith(
        sharesCount: (data['shares'] as num?)?.toInt() ?? item.sharesCount,
      ),
      () => _repository.recordShare(event.reelId),
      'Could not share this reel. Try again.',
    );
  }

  FutureOr<void> _onViewed(ReelViewed event, Emitter<ReelsState> emit) async {
    // Fire-and-forget analytics: no state change on success or failure.
    await _repository.recordView(
      event.reelId,
      watchedMs: event.watchedMs,
      completed: event.completed,
    );
  }

  void _onCommentPosted(ReelCommentPosted event, Emitter<ReelsState> emit) {
    // The sheet posts the comment itself (so a failure can keep the draft), and it
    // owns the retry UI. All that is left here is the counter on the feed.
    _emitAmended(
      emit,
      event.reelId,
      (item) => item.copyWith(commentsCount: item.commentsCount + 1),
    );
  }

  FutureOr<void> _onReported(
    ReelReported event,
    Emitter<ReelsState> emit,
  ) async {
    final response = await _repository.reportReel(
      event.reelId,
      event.reason,
      details: event.details,
    );
    // Silently discarded before. Reporting is the one action a user takes *for* the
    // platform's benefit and never sees an outcome for, so a failure left them believing
    // it went through. 409 is the deliberate duplicate - still worth acknowledging.
    if (response.success) {
      event.onReported?.call();
      return;
    }
    final state = this.state;
    if (state is! ReelsFeed) return;
    emit(
      ReelsActionFailed(
        items: state.items,
        page: state.page,
        totalPages: state.totalPages,
        message: 'Could not submit the report.',
      ),
    );
  }
}
