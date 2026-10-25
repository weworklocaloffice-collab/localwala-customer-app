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

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:user/app/core/models/reel_model.dart';
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

  /// Whether the reels tab is the one on screen. `TabBarView` keeps every tab alive,
  /// so without this the reel keeps playing audio after the user swipes to another
  /// tab - the player is never rebuilt, and the page index inside reels never changes
  /// either, so nothing else in this widget notices.
  final bool isActive;

  const ReelsScreen({super.key, this.onCtaTap, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReelsBloc()..add(const ReelsFeedRequested()),
      child: _ReelsView(onCtaTap: onCtaTap, isActive: isActive),
    );
  }
}

class _ReelsView extends StatefulWidget {
  final void Function(ReelModel reel)? onCtaTap;
  final bool isActive;

  const _ReelsView({this.onCtaTap, this.isActive = true});

  @override
  State<_ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<_ReelsView> {
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final PageController _pageController = PageController();
  bool _loadingMore = false;
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
      body: BlocConsumer<ReelsBloc, ReelsState>(
        listenWhen: (previous, current) =>
            current is ReelsFeedPageFailed ||
            current is ReelsActionFailed ||
            current is ReelsLoadSuccess,
        listener: (context, state) {
          // The paging gate is set when the next page is requested and cleared when a
          // state lands. Doing it in a listener rather than in `build` keeps a widget
          // field from being mutated mid-render, and covers the failure path, which
          // deliberately leaves `page` unchanged.
          _loadingMore = false;
          final message = switch (state) {
            ReelsFeedPageFailed() => 'Could not load more reels.',
            // Rollback of an optimistic like/save/share, or a failed comment or report.
            // Previously these returned silently and the user was left tapping a
            // button that looked broken with nothing to explain it.
            ReelsActionFailed(:final message) => message,
            _ => null,
          };
          if (message == null) return;
          // A guest tapping a heart has nothing to retry - they need a token. The
          // server message would read as a broken button, so it is replaced with the
          // sign-in prompt and given the action that actually resolves it.
          final signInRequired =
              state is ReelsActionFailed && state.signInRequired;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  signInRequired
                      ? translate.reels_sign_in_to_continue
                      : message,
                ),
                action: signInRequired
                    ? SnackBarAction(
                        label: translate.sign_in_sign_up,
                        onPressed: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil(
                              AppRouter.loginRoute,
                              (Route<dynamic> route) => false,
                            ),
                      )
                    : null,
              ),
            );
        },
        builder: (context, state) {
          if (state is ReelsLoadInProgress) {
            return _ReelsSkeleton();
          }
          if (state is ReelsAuthRequired) {
            return _ReelsSessionExpired(onSignIn: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.loginRoute,
                (Route<dynamic> route) => false,
              );
            });
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
          // Both of these carry a usable feed: a failed page load keeps what was already
          // loaded, and a rolled-back interaction hands back the pre-tap feed.
          if (state is ReelsFeed) {
            if (state.items.isEmpty) {
              return Center(
                child: Text(
                  translate.reels_empty,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }
            return _feed(context, state);
          }
          return Center(
            child: Text(
              translate.reels_empty,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  /// The scrolling feed, shared by every [ReelsFeed] subclass.
  Widget _feed(BuildContext context, ReelsFeed state) {
    final items = state.items;
    final hasMore = state.hasMore;
    final loginRequired = state.loginRequired;
    final page = state.page;
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ReelsBloc>().add(const ReelsFeedRefreshed()),
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount:
            items.length + (hasMore ? 1 : 0) + (loginRequired ? 1 : 0),
        onPageChanged: (index) {
          _currentPage.value = index;
          _preloadNextVideo(items, index);
          if (index >= items.length - 3 && hasMore && !_loadingMore) {
            _loadingMore = true;
            context.read<ReelsBloc>().add(ReelsFeedRequested(page: page + 1));
          }
        },
        itemBuilder: (context, index) {
          final signInIndex = items.length + (hasMore ? 1 : 0);
          if (loginRequired && index == signInIndex) {
            return _ReelsSignInCard(
              onSignIn: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.loginRoute,
                (Route<dynamic> route) => false,
              ),
            );
          }
          if (index >= items.length) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final reel = items[index];
          final isNext = index == _currentPage.value + 1;
          return _ReelPage(
            reel: reel,
            index: index,
            currentPage: _currentPage,
            isActive: widget.isActive,
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
  }
}

class _ReelPage extends StatefulWidget {
  final ReelModel reel;
  final int index;
  final ValueNotifier<int> currentPage;
  final bool isActive;
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
    this.isActive = true,
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
  bool _loading = false;
  bool _loadFailed = false;
  bool _buffering = false;
  bool _initializing = false;
  /// Video pixels, as reported by the decoder. Starts at zero and is only known
  /// once the first frame is decoded on Android - see the build method.
  Size _videoSize = Size.zero;
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

  /// The reels tab is not a route, so nothing above this page rebuilds when the user
  /// switches tabs - `TabBarView` just keeps both children mounted. [isActive] is the
  /// only signal for that, and acting on it here is what stops the audio.
  @override
  void didUpdateWidget(covariant _ReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive == widget.isActive) return;
    if (!widget.isActive) {
      _pauseAndReport();
    } else if (widget.currentPage.value == widget.index) {
      _startPlaying();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.currentPage.removeListener(_onPageChanged);
    _pauseAndReport(force: true);
    _releaseController();
    _heartAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `ModalRoute.of` subscribes to the route's own status, and that status notifies on
    // both push and pop - so this is the one signal on this page that fires when a
    // target opens and closes again. Nothing else does: the page index does not change,
    // and `didChangeAppLifecycleState` only reports the app being backgrounded. Without
    // it the reel came back from a restaurant page sitting frozen with no autoplay.
    final route = ModalRoute.of(context);
    if (!(route?.isCurrent ?? true)) return;
    // Deferred: resuming calls setState, and this runs mid-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.isActive) return;
      if (widget.currentPage.value != widget.index) return;
      if (_controller == null && !_loadFailed) {
        _initPlayer();
        return;
      }
      _startPlaying();
    });
  }

  /// Backgrounding the app leaves the platform player alive, so without this
  /// the reel keeps talking over whatever the user switched to â€” music, a
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
    // `didChangeDependencies` can call back in before the first attempt settles.
    if (_initializing) return;
    _initializing = true;

    // Use preloaded controller if available (for next video)
    VideoPlayerController controller;
    final adopted = widget.preloadedController;
    if (adopted != null && adopted.value.isInitialized) {
      controller = adopted;
      // Ownership transfers here â€” release the parent before we ever use it.
      widget.onPreloadedAdopted?.call();
      if (kDebugMode) {
        debugPrint('[reels] adopted preloaded ctrl reel=${widget.reel.id}');
      }
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.reel.videoUrl),
      );
      if (mounted) {
        setState(() {
          _loading = true;
          _loadFailed = false;
        });
      }
      try {
        await controller.initialize();
      } catch (_) {
        // This used to `return` and leave the controller alive: the platform
        // player was never disposed, the page sat on a frozen thumbnail with a
        // play icon that did nothing, and nothing retried. Tear it down and
        // show an explicit retry instead.
        controller.dispose();
        _initializing = false;
        if (mounted) {
          setState(() {
            _loading = false;
            _buffering = false;
            _videoSize = Size.zero;
            _loadFailed = true;
          });
        }
        return;
      }
    }

    if (!mounted) {
      controller.dispose();
      _initializing = false;
      return;
    }
    if (kDebugMode) {
      // Logcat tells us whether the decoder actually reported pixels. `Size.zero`
      // here means Android answered "ready" before it knew the video size, which
      // is the audio-without-picture case.
      debugPrint(
        '[reels] initialized reel=${widget.reel.id} '
        'size=${controller.value.size} '
        'duration=${controller.value.duration}',
      );
    }
    controller.setLooping(true);
    controller.addListener(_onPlayerTick);
    _controller = controller;
    _initializing = false;
    setState(() {
      _loading = false;
      _loadFailed = false;
      _buffering = controller.value.isBuffering;
      _videoSize = controller.value.size;
    });
    if (widget.isActive && widget.currentPage.value == widget.index) {
      _startPlaying();
    }
  }

  /// Drives the buffering spinner and the video's layout size. The controller
  /// notifies on every position update, so only rebuild when one of the two
  /// values that affect the UI actually moves.
  ///
  /// The size half is not cosmetic: Android reports `isInitialized` before it
  /// reports the video size, so the first build can see `isInitialized == true`
  /// with `size == Size.zero`. Without a fallback the player was laid out at 0x0
  /// and the reel played its audio over a blank screen.
  void _onPlayerTick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final value = controller.value;
    if (value.isBuffering == _buffering && value.size == _videoSize) return;
    setState(() {
      _buffering = value.isBuffering;
      if (value.size != _videoSize) {
        if (kDebugMode) {
          debugPrint(
            '[reels] video size $_videoSize -> ${value.size} '
            'reel=${widget.reel.id}',
          );
        }
        _videoSize = value.size;
      }
    });
  }

  void _releaseController() {
    final controller = _controller;
    if (controller == null) return;
    controller.removeListener(_onPlayerTick);
    controller.dispose();
    _controller = null;
    _buffering = false;
    _videoSize = Size.zero;
  }

  void _retryVideo() {
    if (_initializing) return;
    setState(() {
      _loadFailed = false;
      _loading = true;
    });
    _initPlayer();
  }

  void _onPageChanged() {
    if (widget.isActive && widget.currentPage.value == widget.index) {
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
  /// twice â€” the second call is a no-op once `_playStartedAt` is cleared.
  void _closeWatchSession() {
    if (_playStartedAt != null) {
      _watchedMs += DateTime.now().difference(_playStartedAt!).inMilliseconds;
      _playStartedAt = null;
    }
  }

  /// DEBUG ONLY â€” remove once the navigation-audio regression is confirmed fixed.
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
      // Pages that only passed through the viewport still get built and disposed
      // (PageView keeps neighbours alive), and `force` made those report a view with
      // watchedMs 0 - inflation with no viewing behind it. No play time, no view.
      if (!_viewReported && mounted && _watchedMs > 0) {
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
  /// Disposing â€” not merely pausing â€” is what actually stops the audio.
  /// A `pause()` can be skipped or race the platform player; tearing the
  /// player down cannot be ignored. The controller is now fully owned here,
  /// so the preloader must not also hold it (see onPreloadedAdopted).
  void stopVideo() {
    _pauseAndReport(force: true);
    _debugTracePlayer('stopVideo:dispose');
    _releaseController();
  }

  /// Opens whatever this reel points at.
  ///
  /// The target card and the CTA button are the same intent, so they share one
  /// implementation. They previously carried separate routing logic that had
  /// drifted apart: the card re-implemented its own RESTAURANT-only guard, so
  /// product targets tapped into nothing while the button worked.
  void _openTarget() {
    // Pause, but keep the controller. `stopVideo()` disposed it, and nothing rebuilt it
    // on the way back: the page index never changed so no listener fired, and
    // `didChangeAppLifecycleState` only reacts to the app being backgrounded, not to a
    // route being popped. The reel came back permanently dead - thumbnail, no playback,
    // and `_togglePlay` a no-op because `_startPlaying` early-returns on a null
    // controller. Holding the decoder costs a little memory for the few seconds the
    // user is off in a restaurant page, and buys back a reel that still works.
    _pauseAndReport();
    if (widget.onCtaTap != null) {
      widget.onCtaTap!.call(widget.reel);
      return;
    }
    handleReelCtaTap(context, widget.reel);
  }

  void _togglePlay() {
    if (_loadFailed) {
      _retryVideo();
      return;
    }
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
            // Layout must never be 0x0. Android reports `isInitialized` before it
            // reports the video size, and FittedBox with a zero-sized child paints
            // nothing - the reel played audio while the picture stayed invisible.
            // The surface the decoder draws into is sized from this box, so the
            // fallback is a real 9:16 resolution (matching the 720p transcode)
            // rather than a tiny 9x16 box.
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoSize.width > 0 ? _videoSize.width : 720,
                height: _videoSize.height > 0 ? _videoSize.height : 1280,
                child: VideoPlayer(controller),
              ),
            )
          else if (reel.thumbnail != null && reel.thumbnail!.isNotEmpty)
            Image.network(reel.thumbnail!, fit: BoxFit.cover)
          else
            Container(color: Colors.grey.shade900),
          if (!_playing && !_loading && !_loadFailed)
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 64),
            ),
          // Buffering / first-load spinner. `_buffering` is fed by the player
          // listener; without it a stalled network read looked like a still frame.
          if ((_loading || _buffering) && !_loadFailed)
            const Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          // A failed load is now explicit instead of a frozen thumbnail with a
          // dead play button.
          if (_loadFailed)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_off,
                        color: Colors.white70, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.reels_video_unavailable,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: _retryVideo,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      child: Text(AppLocalizations.of(context)!.re_retry),
                    ),
                  ],
                ),
              ),
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
                // A single link, directly under the caption. This used to fetch the
                // top two comments and print their text here, which put comment bodies
                // immediately above the restaurant card - the reel looked like it had
                // comments attached to the restaurant. It also cost one extra request
                // per reel while scrolling.
                if (reel.commentsCount > 0) ...[
                  const SizedBox(height: 4),
                  _ViewAllComments(
                    count: reel.commentsCount,
                    onTap: () => showReelCommentsSheet(
                      context,
                      reelId: reel.id,
                      bloc: bloc,
                    ),
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
                                      'â‚¹' * reel.targetSummary.priceTier!,
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
          onTap: () => _showShareSheet(context, reel, bloc),
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
    if (selected == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    bloc.add(
      ReelReported(
        reelId,
        selected,
        onReported: () => messenger.showSnackBar(
          SnackBar(content: Text(translate.report_saved)),
        ),
      ),
    );
  }

  Future<void> _showShareSheet(
    BuildContext context,
    ReelModel reel,
    ReelsBloc bloc,
  ) async {
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
                    // Counted only once the link is actually on the clipboard. The
                    // counter used to move on the button press, so merely opening
                    // and dismissing this sheet inflated it.
                    bloc.add(ReelShared(reel.id));
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
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final result = await SharePlus.instance.share(
                      ShareParams(
                        text: reel.caption?.isNotEmpty == true
                            ? '${reel.caption}\n${reel.videoUrl}'
                            : reel.videoUrl,
                        subject: reel.targetSummary.name,
                      ),
                    );
                    if (result.status == ShareResultStatus.success) {
                      bloc.add(ReelShared(reel.id));
                    }
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

/// Shown when the feed answered 401 and the auth interceptor has already cleared the
/// tokens. "Pull to retry" was the old copy here, but by this point there is nothing to
/// retry with: every further request will be rejected too, so the only useful action is
/// getting back to the login screen.
class _ReelsSessionExpired extends StatelessWidget {
  final VoidCallback onSignIn;

  const _ReelsSessionExpired({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white70, size: 44),
            const SizedBox(height: 16),
            Text(
              translate.session_expired,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSignIn,
              child: Text(translate.sign_in_sign_up),
            ),
          ],
        ),
      ),
    );
  }
}

/// The end of a guest's feed.
///
/// The API stops serving reels once a signed-out visitor has used up the allowance
/// the admin configured, and flags that page. Without this card the feed just ran
/// out, which read as a bug rather than an invitation.
class _ReelsSignInCard extends StatelessWidget {
  final VoidCallback onSignIn;

  const _ReelsSignInCard({required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white70, size: 44),
            const SizedBox(height: 16),
            Text(
              translate.reels_sign_in_to_continue,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onSignIn,
              child: Text(translate.sign_in_sign_up),
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
/// Single "View all N comments" link, shown directly under the caption.
///
/// Replaces the old top-2 preview, which fetched the comment list for every reel
/// that scrolled past and printed the comment bodies immediately above the
/// restaurant card. That made the reel look like it carried comments about the
/// restaurant, and it cost one request per reel. The action rail still shows the
/// count, so this is a link, not a preview.
class _ViewAllComments extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ViewAllComments({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        AppLocalizations.of(context)!.reels_view_all_comments(count),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
