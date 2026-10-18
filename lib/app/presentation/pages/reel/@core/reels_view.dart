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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user/app/core/models/reel_model.dart';
import 'package:user/app/core/repositories/reels_repository.dart';
import 'package:user/app/features/social/widgets/social_proof_row.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/presentation/pages/reel/@core/bloc/reels_bloc.dart';
import 'package:user/app/presentation/pages/reel/@core/comments_sheet.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

/// Default CTA routing, used whenever the host screen doesn't supply its own
/// `onCtaTap`: restaurants open by slug (the restaurant screen fetches by
/// slug, never by id), foods open in the single-food modal.
void handleReelCtaTap(BuildContext context, ReelModel reel) {
  final refId = (reel.target.refId ?? '').trim();
  if (refId.isEmpty) return;
  switch (reel.target.type) {
    case 'RESTAURANT':
      Navigator.of(context).pushNamed(
        AppRouter.restaurantRoute,
        arguments: [refId, reel.targetSummary.slug, reel.targetSummary.name],
      );
    case 'PRODUCT':
      Navigator.of(context).pushNamed(
        AppRouter.singleFoodFromBannerRoute,
        arguments: [refId, reel.targetSummary.name],
      );
    default:
      break;
  }
}

// TODO(l10n): move chrome strings below into app_*.arb.
class ReelsScreen extends StatelessWidget {
  /// Fired with the tapped reel so the host app can deep-link the CTA into
  /// its order/booking/property flow (label + target travel in the model).
  final void Function(ReelModel reel)? onCtaTap;

  const ReelsScreen({super.key, this.onCtaTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReelsBloc()..add(const ReelsFeedRequested()),
      child: _ReelsView(onCtaTap: onCtaTap),
    );
  }
}

class _ReelsView extends StatefulWidget {
  final void Function(ReelModel reel)? onCtaTap;

  const _ReelsView({this.onCtaTap});

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> {
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  bool _loadingMore = false;
  int _loadedPage = 1;
  // Preload next video controller
  VideoPlayerController? _nextVideoController;
  String? _nextVideoUrl;

  @override
  void dispose() {
    _currentPage.dispose();
    _pageController.dispose();
    _nextVideoController?.dispose();
    super.dispose();
  }

  void _preloadNextVideo(List<ReelModel> items, int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= items.length) return;
    final nextReel = items[nextIndex];
    final url = nextReel.videoUrl;
    if (url.isEmpty || url == _nextVideoUrl) return;
    _nextVideoUrl = url;
    _nextVideoController?.dispose();
    _nextVideoController = VideoPlayerController.networkUrl(Uri.parse(url));
    _nextVideoController!.initialize().catchError((_) {
      _nextVideoController?.dispose();
      _nextVideoController = null;
      _nextVideoUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ReelsBloc, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoadInProgress) {
            return _ReelsSkeleton();
          }
          if (state is ReelsLoadFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ReelsBloc>().add(
                      const ReelsFeedRefreshed(),
                    ),
                    child: Text(translate.try_again),
                  ),
                ],
              ),
            );
          }
          if (state is! ReelsLoadSuccess || state.items.isEmpty) {
            return Center(
              child: Text(
                translate.reels_empty,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (state.page != _loadedPage) {
            _loadedPage = state.page;
            _loadingMore = false;
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ReelsBloc>().add(const ReelsFeedRefreshed()),
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              onPageChanged: (index) {
                _currentPage.value = index;
                _preloadNextVideo(state.items, index);
                if (index >= state.items.length - 3 &&
                    state.hasMore &&
                    !_loadingMore) {
                  _loadingMore = true;
                  context.read<ReelsBloc>().add(
                    ReelsFeedRequested(page: state.page + 1),
                  );
                }
              },
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                final reel = state.items[index];
                final isNext = index == _currentPage.value + 1;
                return _ReelPage(
                  reel: reel,
                  index: index,
                  currentPage: _currentPage,
                  onCtaTap: widget.onCtaTap,
                  preloadedController: isNext ? _nextVideoController : null,
                  onPreloadedAdopted: () {
                    _nextVideoController = null;
                    _nextVideoUrl = null;
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReelPage extends StatefulWidget {
  final ReelModel reel;
  final int index;
  final ValueNotifier<int> currentPage;
  final void Function(ReelModel reel)? onCtaTap;
  final VideoPlayerController? preloadedController;

  /// Fired once this page takes ownership of [preloadedController]. The parent
  /// must drop its reference at that moment, otherwise both would believe they
  /// own the same player and one of them would dispose it mid-playback.
  final VoidCallback? onPreloadedAdopted;

  const _ReelPage({
    required this.reel,
    required this.index,
    required this.currentPage,
    this.onCtaTap,
    this.preloadedController,
    this.onPreloadedAdopted,
  });

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _playing = false;
  int _watchedMs = 0;
  DateTime? _playStartedAt;
  bool _viewReported = false;
  bool _showHeart = false;
  bool _captionExpanded = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartOpacityAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.currentPage.addListener(_onPageChanged);
    _initPlayer();
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.elasticOut),
    );
    _heartOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.currentPage.removeListener(_onPageChanged);
    _pauseAndReport(force: true);
    _controller?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  /// Backgrounding the app leaves the platform player alive, so without this
  /// the reel keeps talking over whatever the user switched to — music, a
  /// call, another app. Tearing the player down is the only reliable stop.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller == null) {
        // stopVideo() tore the player down while we were away; rebuild it.
        _initPlayer();
      } else if (widget.currentPage.value == widget.index) {
        // Fresh viewing session, same as tapping to replay.
        _watchedMs = 0;
        _viewReported = false;
        _startPlaying();
      }
      return;
    }
    _debugTracePlayer('lifecycle:$state');
    stopVideo();
  }

  Future<void> _initPlayer() async {
    if (widget.reel.videoUrl.isEmpty) return;

    // Use preloaded controller if available (for next video)
    VideoPlayerController controller;
    final adopted = widget.preloadedController;
    if (adopted != null && adopted.value.isInitialized) {
      controller = adopted;
      // Ownership transfers here — release the parent before we ever use it.
      widget.onPreloadedAdopted?.call();
      if (kDebugMode) {
        debugPrint('[reels] adopted preloaded ctrl reel=${widget.reel.id}');
      }
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
      );
      try {
        await controller.initialize();
      } catch (_) {
        return;
      }
    }

    if (!mounted) {
      controller.dispose();
      return;
    }
    controller.setLooping(true);
    _controller = controller;
    setState(() {});
    if (widget.currentPage.value == widget.index) _startPlaying();
  }

  void _onPageChanged() {
    if (widget.currentPage.value == widget.index) {
      _startPlaying();
    } else {
      _pauseAndReport();
    }
  }

  void _startPlaying() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _playing) {
      return;
    }
    controller.play();
    _playing = true;
    _playStartedAt = DateTime.now();
    if (mounted) setState(() {});
  }

  /// Banks the elapsed time for the current viewing session. Safe to call
  /// twice — the second call is a no-op once `_playStartedAt` is cleared.
  void _closeWatchSession() {
    if (_playStartedAt != null) {
      _watchedMs += DateTime.now().difference(_playStartedAt!).inMilliseconds;
      _playStartedAt = null;
    }
  }

  /// DEBUG ONLY — remove once the navigation-audio regression is confirmed fixed.
  /// Prints the real player state at the moment we tear down, because the
  /// `_playing` flag alone has already lied once. Drop this whole method
  /// together with its two call sites.
  void _debugTracePlayer(String site) {
    if (!kDebugMode) return;
    final c = _controller;
    debugPrint(
      '[reels] $site '
      'reel=${widget.reel.id} idx=${widget.index} mounted=$mounted '
      'flag=$_playing ctrl=${c != null} '
      'init=${c?.value.isInitialized} playing=${c?.value.isPlaying} '
      'pos=${c?.value.position.inMilliseconds} vol=${c?.value.volume}',
    );
  }

  /// Pauses playback and files the view event.
  ///
  /// `force` pauses even when [_playing] has drifted from the real platform
  /// player state. The drift is real: a controller handed over by the
  /// preloader can be playing while our flag says otherwise, and the old
  /// early-return skipped `pause()` in exactly that case.
  void _pauseAndReport({bool force = false}) {
    final controller = _controller;
    if (controller == null) return;
    _debugTracePlayer('pause(force=$force)');
    if (_playing || force) {
      controller.pause();
      _playing = false;
      _closeWatchSession();
      if (!_viewReported && mounted) {
        _viewReported = true;
        final durationMs = controller.value.duration.inMilliseconds;
        final positionMs = controller.value.position.inMilliseconds;
        final completed = durationMs > 0 && positionMs / durationMs >= 0.9;
        context.read<ReelsBloc>().add(
          ReelViewed(widget.reel.id, watchedMs: _watchedMs, completed: completed),
        );
      }
    }
    if (mounted) setState(() {});
  }

  /// Runs immediately before this reel navigates away.
  ///
  /// Disposing — not merely pausing — is what actually stops the audio.
  /// A `pause()` can be skipped or race the platform player; tearing the
  /// player down cannot be ignored. The controller is now fully owned here,
  /// so the preloader must not also hold it (see onPreloadedAdopted).
  void stopVideo() {
    _pauseAndReport(force: true);
    _debugTracePlayer('stopVideo:dispose');
    _controller?.dispose();
    _controller = null;
  }

  /// Opens whatever this reel points at.
  ///
  /// The target card and the CTA button are the same intent, so they share one
  /// implementation. They previously carried separate routing logic that had
  /// drifted apart: the card re-implemented its own RESTAURANT-only guard, so
  /// product targets tapped into nothing while the button worked.
  void _openTarget() {
    stopVideo();
    if (widget.onCtaTap != null) {
      widget.onCtaTap!.call(widget.reel);
      return;
    }
    handleReelCtaTap(context, widget.reel);
  }

  void _togglePlay() {
    if (_playing) {
      _pauseAndReport();
    } else {
      // Fresh viewing session: its own watch-time row on the next pause.
      _watchedMs = 0;
      _viewReported = false;
      _startPlaying();
    }
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    controller.setVolume(controller.value.volume > 0 ? 0 : 1);
    if (mounted) setState(() {});
  }

  void _showLikeAnimation() {
    _heartAnimationController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showHeart = false);
    });
    setState(() => _showHeart = true);
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final controller = _controller;
    final bloc = context.read<ReelsBloc>();

    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: () {
        if (!reel.liked) {
          bloc.add(ReelLikeToggled(reel.id));
          _showLikeAnimation();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else if (reel.thumbnail != null && reel.thumbnail!.isNotEmpty)
            Image.network(reel.thumbnail!, fit: BoxFit.cover)
          else
            Container(color: Colors.grey.shade900),
          if (!_playing)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
          // Video progress bar
          if (controller != null && controller.value.isInitialized && _playing)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _VideoProgressBar(controller: controller),
            ),
          // Heart animation on double-tap like
          if (_showHeart)
            Center(
              child: AnimatedBuilder(
                animation: _heartAnimationController,
                builder: (_, __) => Transform.scale(
                  scale: _heartScaleAnimation.value,
                  child: Opacity(
                    opacity: _heartOpacityAnimation.value,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                      size: 100,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            right: 76,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reel.caption != null && reel.caption!.isNotEmpty) ...[
                  _ExpandableCaption(
                    text: reel.caption!,
                    expanded: _captionExpanded,
                    onTap: () => setState(() => _captionExpanded = !_captionExpanded),
                  ),
                ],
                // Hashtag chips
                if (reel.hashtags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _HashtagChips(
                    hashtags: reel.hashtags,
                    onTap: (tag) {
                      // TODO: Navigate to hashtag search/filter
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('#$tag - Search coming soon'),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 6),
                SocialProofRow(
                  proof: reel.socialProof,
                  textStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                // Comment preview (top 2 comments)
                if (reel.commentsCount > 0) ...[
                  const SizedBox(height: 8),
                  _CommentPreview(
                    reelId: reel.id,
                    commentsCount: reel.commentsCount,
                    onTap: () => showReelCommentsSheet(
                      context,
                      reelId: reel.id,
                      bloc: bloc,
                    ),
                  ),
                ],
                // Restaurant card (shows when targetSummary has data)
                if (reel.targetSummary.name.isNotEmpty &&
                    reel.targetSummary.image.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _openTarget,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              reel.targetSummary.image,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 56,
                                height: 56,
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.restaurant,
                                    color: Colors.white54, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reel.targetSummary.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // Rating row
                                if (reel.target.type == 'RESTAURANT' &&
                                    (reel.targetSummary.rating != null &&
                                        (reel.targetSummary.rating! > 0) ||
                                        reel.targetSummary.reviewCount != null &&
                                        (reel.targetSummary.reviewCount! > 0) ||
                                        reel.targetSummary.isOpen != null ||
                                        reel.targetSummary.distanceKm != null))
                                  Row(
                                    children: [
                                      if (reel.targetSummary.rating != null &&
                                          reel.targetSummary.rating! > 0) ...[
                                        const Icon(Icons.star, color: Colors.amber, size: 13),
                                        const SizedBox(width: 3),
                                        Text(
                                          reel.targetSummary.rating!.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (reel.targetSummary.reviewCount != null &&
                                            reel.targetSummary.reviewCount! > 0) ...[
                                          const SizedBox(width: 3),
                                          Text(
                                            '(${reel.targetSummary.reviewCount})',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(width: 10),
                                      ],
                                      if (reel.targetSummary.isOpen != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: reel.targetSummary.isOpen!
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: reel.targetSummary.isOpen!
                                                  ? Colors.green
                                                  : Colors.red,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            reel.targetSummary.isOpen!
                                                ? 'Open now'
                                                : 'Closed',
                                            style: TextStyle(
                                              color: reel.targetSummary.isOpen!
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      else if (reel.targetSummary.distanceKm != null)
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.white70, size: 11),
                                            const SizedBox(width: 3),
                                            Text(
                                              '${reel.targetSummary.distanceKm!.toStringAsFixed(1)} km',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                // Cuisine tags
                                if (reel.target.type == 'RESTAURANT' &&
                                    reel.targetSummary.cuisines != null &&
                                    reel.targetSummary.cuisines!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Wrap(
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: (reel.targetSummary.cuisines! as List)
                                          .take(3)
                                          .map((c) => Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  c.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 9,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                // Price tier
                                if (reel.target.type == 'RESTAURANT' &&
                                    reel.targetSummary.priceTier != null &&
                                    reel.targetSummary.priceTier! > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '₹' * reel.targetSummary.priceTier!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                if (reel.target.type == 'RESTAURANT' &&
                                    reel.targetSummary.rating == null &&
                                    reel.targetSummary.reviewCount == null &&
                                    reel.targetSummary.isOpen == null &&
                                    reel.targetSummary.distanceKm == null &&
                                    (reel.targetSummary.cuisines == null ||
                                        reel.targetSummary.cuisines!.isEmpty) &&
                                    reel.targetSummary.priceTier == null)
                                  const Text(
                                    'Restaurant',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (reel.cta.label.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _openTarget,
                    child: Text(reel.cta.label),
                  ),
                ],
              ],
            ),
          ),
          Positioned(right: 8, bottom: 24, child: _ActionRail(reel: reel, controller: _controller, onToggleMute: _toggleMute)),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  final ReelModel reel;
  final VideoPlayerController? controller;
  final VoidCallback? onToggleMute;

  const _ActionRail({required this.reel, this.controller, this.onToggleMute});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReelsBloc>();
    final isMuted = controller?.value.volume == 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailButton(
          icon: reel.liked ? Icons.favorite : Icons.favorite_border,
          color: reel.liked ? Colors.redAccent : Colors.white,
          label: '${reel.likesCount}',
          onTap: () => bloc.add(ReelLikeToggled(reel.id)),
        ),
        _RailButton(
          icon: Icons.comment_outlined,
          label: '${reel.commentsCount}',
          onTap: () =>
              showReelCommentsSheet(context, reelId: reel.id, bloc: bloc),
        ),
        _RailButton(
          icon: reel.saved ? Icons.bookmark : Icons.bookmark_border,
          label: '${reel.savesCount}',
          onTap: () => bloc.add(ReelSaveToggled(reel.id)),
        ),
        _RailButton(
          icon: Icons.share_outlined,
          label: '${reel.sharesCount}',
          onTap: () {
            bloc.add(ReelShared(reel.id));
            _showShareSheet(context, reel);
          },
        ),
        if (onToggleMute != null)
          _RailButton(
            icon: isMuted ? Icons.volume_off : Icons.volume_up,
            label: isMuted ? 'Muted' : null,
            onTap: onToggleMute!,
          ),
        _RailButton(
          icon: Icons.more_vert,
          onTap: () => _showReportMenu(context, bloc, reel.id),
        ),
      ],
    );
  }

  Future<void> _showReportMenu(
    BuildContext context,
    ReelsBloc bloc,
    String reelId,
  ) async {
    const reasons = [
      'SPAM',
      'INAPPROPRIATE',
      'MISLEADING',
      'COPYRIGHT',
      'OTHER',
    ];
    final translate = AppLocalizations.of(context)!;
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(translate.report_reel_title),
        children: [
          for (final reason in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(reason),
              child: Text(reason),
            ),
        ],
      ),
    );
    if (selected != null) bloc.add(ReelReported(reelId, selected));
  }

  Future<void> _showShareSheet(BuildContext context, ReelModel reel) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share reel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Only genuinely distinct actions. Per-app buttons are deliberately
            // absent: share_plus cannot target a specific app, so they would all
            // open the same system sheet.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShareOption(
                  icon: Icons.link,
                  label: 'Copy link',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: reel.videoUrl));
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Link copied'),
                        backgroundColor: Colors.black87,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 56),
                _ShareOption(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    SharePlus.instance.share(
                      ShareParams(
                        text: reel.caption?.isNotEmpty == true
                            ? '${reel.caption}\n${reel.videoUrl}'
                            : reel.videoUrl,
                        subject: reel.targetSummary.name,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            if (label != null)
              Text(
                label!,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReelsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade900,
      highlightColor: Colors.grey.shade800,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 3,
        itemBuilder: (_, __) => _SkeletonReelPage(),
      ),
    );
  }
}

class _SkeletonReelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video placeholder
          Container(color: Colors.grey.shade900),
          // Play button placeholder
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom content placeholders
          Positioned(
            left: 12,
            right: 76,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Caption lines
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white10,
                ),
                SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 16,
                  color: Colors.white10,
                ),
                SizedBox(height: 16),
                // Social proof
                Container(
                  width: 120,
                  height: 14,
                  color: Colors.white10,
                ),
                SizedBox(height: 16),
                // Restaurant card
                Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(height: 16),
                // CTA button
                Container(
                  width: 140,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          // Action rail placeholders
          Positioned(
            right: 8,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < 4) ...[
                      SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 11,
                        color: Colors.white10,
                      ),
                    ],
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoProgressBar({required this.controller});

  @override
  State<_VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<_VideoProgressBar> {
  Timer? _timer;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _position = widget.controller.value.position;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted && widget.controller.value.isInitialized) {
        setState(() => _position = widget.controller.value.position);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration;
    final progress = duration.inMilliseconds > 0
        ? _position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      height: 2,
      color: Colors.white.withOpacity(0.3),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

class _ExpandableCaption extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onTap;

  const _ExpandableCaption({
    required this.text,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: text,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
        );
        final tp = TextPainter(
          text: span,
          maxLines: expanded ? null : 2,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);
        final needsExpand = tp.didExceedMaxLines;

        return GestureDetector(
          onTap: needsExpand ? onTap : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                maxLines: expanded ? null : 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (needsExpand) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    expanded ? 'Show less' : 'Show more',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HashtagChips extends StatelessWidget {
  final List<String> hashtags;
  final void Function(String)? onTap;

  const _HashtagChips({required this.hashtags, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: hashtags.take(8).map((tag) {
        return GestureDetector(
          onTap: () => onTap?.call(tag),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              '#$tag',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Top-2 comments pulled from the same endpoint the comments sheet uses, so the
/// inline preview and the sheet can never disagree. Silently renders nothing on
/// failure — a missing preview must never block the feed.
class _CommentPreview extends StatefulWidget {
  final String reelId;
  final int commentsCount;
  final VoidCallback onTap;

  const _CommentPreview({
    required this.reelId,
    required this.commentsCount,
    required this.onTap,
  });

  @override
  State<_CommentPreview> createState() => _CommentPreviewState();
}

class _CommentPreviewState extends State<_CommentPreview> {
  final ReelsRepository _repository = ReelsRepository();
  List<({String name, String text})> _previews = const [];
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    if (widget.commentsCount > 0) _load();
  }

  @override
  void didUpdateWidget(covariant _CommentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Counts are patched by the bloc on add; re-fetch when it moves so the
    // newest comment appears without a manual refresh.
    if (widget.commentsCount != oldWidget.commentsCount) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_requested) return;
    _requested = true;
    try {
      final response = await _repository.getComments(widget.reelId, limit: 2);
      if (!mounted || !response.success) return;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;
      final raw = (decoded['results'] as List?) ?? const [];
      final next = <({String name, String text})>[];
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) continue;
        final text = (entry['text'] as String?)?.trim() ?? '';
        if (text.isEmpty) continue;
        next.add((name: _authorName(entry['userId']), text: text));
        if (next.length == 2) break;
      }
      if (mounted) setState(() => _previews = next);
    } catch (_) {
      // Preview is best-effort; leave the rail comment button as the fallback.
    }
  }

  String _authorName(dynamic user) {
    if (user is Map<String, dynamic>) {
      final full = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
          .trim();
      if (full.isNotEmpty) return full;
    }
    return 'Localwala user';
  }

  @override
  Widget build(BuildContext context) {
    if (_previews.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Text(
          'View all ${widget.commentsCount} comments',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final comment in _previews)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${comment.name}  ${comment.text}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          Text(
            'View all ${widget.commentsCount} comments',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}