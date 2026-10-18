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

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
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
    on<ReelCommentAdded>(_onCommentAdded);
    on<ReelReported>(_onReported);
  }

  List<ReelModel> _currentItems() {
    final state = this.state;
    return state is ReelsLoadSuccess ? state.items : <ReelModel>[];
  }

  List<ReelModel> _updatedItems(
    String reelId,
    ReelModel Function(ReelModel) update,
  ) {
    return _currentItems()
        .map((item) => item.id == reelId ? update(item) : item)
        .toList();
  }

  void _emitSuccess(
    Emitter<ReelsState> emit,
    List<ReelModel> items, {
    int page = 1,
    int totalPages = 1,
  }) {
    emit(ReelsLoadSuccess(items: items, page: page, totalPages: totalPages));
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
      if (previous.isEmpty) {
        emit(const ReelsLoadFailure('Could not load reels. Pull to retry.'));
      }
      return;
    }
    final page = ReelsFeedPage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    final items = event.page == 1 ? page.items : [...previous, ...page.items];
    _emitSuccess(emit, items, page: page.page, totalPages: page.totalPages);
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
  ) async {
    final response = await _repository.toggleLike(event.reelId);
    if (!response.success) return;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _emitSuccess(
      emit,
      _updatedItems(
        event.reelId,
        (item) => item.copyWith(
          liked: (data['liked'] as bool?) ?? !item.liked,
          likesCount: (data['likeCount'] as num?)?.toInt() ?? item.likesCount,
        ),
      ),
    );
  }

  FutureOr<void> _onSaveToggled(
    ReelSaveToggled event,
    Emitter<ReelsState> emit,
  ) async {
    final response = await _repository.toggleSave(event.reelId);
    if (!response.success) return;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _emitSuccess(
      emit,
      _updatedItems(
        event.reelId,
        (item) => item.copyWith(
          saved: (data['saved'] as bool?) ?? !item.saved,
          savesCount: (data['saveCount'] as num?)?.toInt() ?? item.savesCount,
        ),
      ),
    );
  }

  FutureOr<void> _onShared(ReelShared event, Emitter<ReelsState> emit) async {
    final response = await _repository.recordShare(event.reelId);
    if (!response.success) return;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _emitSuccess(
      emit,
      _updatedItems(
        event.reelId,
        (item) => item.copyWith(
          sharesCount:
              (data['shares'] as num?)?.toInt() ?? item.sharesCount + 1,
        ),
      ),
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

  FutureOr<void> _onCommentAdded(
    ReelCommentAdded event,
    Emitter<ReelsState> emit,
  ) async {
    final response = await _repository.addComment(event.reelId, event.content);
    if (!response.success) return;
    _emitSuccess(
      emit,
      _updatedItems(
        event.reelId,
        (item) => item.copyWith(commentsCount: item.commentsCount + 1),
      ),
    );
  }

  FutureOr<void> _onReported(
    ReelReported event,
    Emitter<ReelsState> emit,
  ) async {
    await _repository.reportReel(
      event.reelId,
      event.reason,
      details: event.details,
    );
  }
}
