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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/styles/cache_network_widget/cache_network_widget_view.dart';
import 'package:user/app/presentation/styles/debug_trace.dart';

/// Renders the media layer of a promotional banner.
///
/// Image media reuses [CacheNetworkImageWidget] so disk caching and placeholder
/// behaviour stay identical to every other banner in the app.
///
/// Lottie media owns its [AnimationController] rather than letting `Lottie` create one.
/// The package exposes no `speed` parameter, and its internal controller is forced back
/// to the composition duration on every `didUpdateWidget`. Supplying our own controller
/// keeps the configured playback speed, and because the internal auto-play path is
/// bypassed once a controller is present, this widget drives playback itself.
class HomePromoBannerMedia extends StatefulWidget {
  final HomePromoBannerSpec spec;
  final double width;
  final double height;

  /// Identifies which surface this instance is painting ('top' / 'bottom'), so the
  /// trace can tell the two halves of a shared header apart.
  final String slot;
  final BoxFit fit;

  /// Controller to drive Lottie playback with instead of a private one.
  ///
  /// A header shared between the app bar and the banner builds TWO of these widgets, one
  /// per window. Each owning its own [AnimationController] meant the asset was fetched and
  /// decoded twice and each half started playing whenever its own `onLoaded` happened to
  /// fire - a few hundred milliseconds apart, permanently. The two halves then showed
  /// different frames of the same loop, which is the "the animation is loading twice"
  /// symptom. Handing both windows ONE controller makes the frame identical by
  /// construction instead of by luck.
  final AnimationController? externalController;

  /// Frame rate clamp applied to Lottie playback.
  static const FrameRate frameRate = FrameRate(30);

  static const double minSpeed = 0.1;
  static const double maxSpeed = 4.0;

  const HomePromoBannerMedia({
    super.key,
    required this.spec,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.slot = '',
    this.externalController,
  });

  @override
  State<HomePromoBannerMedia> createState() => _HomePromoBannerMediaState();
}

class _HomePromoBannerMediaState extends State<HomePromoBannerMedia> with SingleTickerProviderStateMixin {
  static const String _tag = kBannerMediaTrace;

  /// Trace tag for this instance, suffixed with the surface it belongs to.
  String get _trace => widget.slot.isEmpty ? _tag : '$_tag/${widget.slot}';

  final AuthRepository _authRepository = AuthRepository();

  late final AnimationController _ownController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  /// The controller actually in use: the one shared by both halves of a header when there
  /// is one, otherwise this widget's own.
  AnimationController get _lottieController =>
      widget.externalController ?? _ownController;
  String _mediaBaseUrl = '';
  Timer? _probe;

  /// Whether a composition has actually arrived. Playback is gated on this
  /// because the controller starts life with a placeholder one second duration,
  /// so running it before the load finishes just spins a controller with nothing
  /// behind it.
  bool _compositionReady = false;

  @override
  void initState() {
    super.initState();
    _traceSpec('initState');
    if (widget.spec.media == HomeHeaderBannerMedia.lottie) {
      _loadMediaBaseUrl();
    }
  }

  @override
  void didUpdateWidget(covariant HomePromoBannerMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    _traceSpec('didUpdateWidget');
    if (widget.spec.media != HomeHeaderBannerMedia.lottie) return;
    if (oldWidget.spec.mediaUrl != widget.spec.mediaUrl) {
      _compositionReady = false;
      // A shared controller belongs to the whole header, so this half must not rewind an
      // animation the other half is already showing. The new asset will be picked up by
      // `_onLottieLoaded`, which applies the same rule before it touches playback.
      if (widget.externalController == null) {
        _lottieController.stop();
        _lottieController.value = 0;
      }
      _loadMediaBaseUrl();
      return;
    }
    // Only the flags changed. Playback still belongs to the load callback, but a
    // newly configured flag has to take effect on the animation already running.
    //
    // Same hazard as the load path: on a shared header BOTH halves get this callback and
    // `_applyPlayback()` rewinds, so the second one would undo the first's start. Only the
    // child that already owns playback re-applies it.
    if (_compositionReady && (widget.externalController == null || !_lottieController.isAnimating)) {
      _applyPlayback();
    }
  }

  /// Samples this slot's playhead so the two slices can be compared directly.
  ///
  /// The whole point of the shared canvas is that both slices show the SAME moment of the
  /// animation. Each surface drives its own [AnimationController] from its own
  /// `onLoaded`, so they can start a fraction of a second apart and then stay that far
  /// out of phase forever. Nothing about the geometry would show that - the slices would
  /// tile perfectly and the moving artwork would still visibly jump at the split. Logging
  /// `top` and `bottom` values against one wall clock is what makes that visible.
  void _tracePlayhead() {
    if (!DebugTrace.enabled || widget.slot.isEmpty) return;
    final DateTime now = DateTime.now();
    if (_lastPlayheadSample != null &&
        now.difference(_lastPlayheadSample!).inMilliseconds < 1000) {
      return;
    }
    _lastPlayheadSample = now;
    DebugTrace.log(
      'HeaderMediaPlayhead',
      '${widget.slot.padRight(6)} value=${_lottieController.value.toStringAsFixed(4)} '
      'at=${now.millisecondsSinceEpoch % 100000}',
    );
  }

  @override
  void dispose() {
    _probe?.cancel();
    _lottieController.removeListener(_tracePlayhead);
    // Only ever dispose a controller this widget created. A shared one belongs to the
    // header that spans both surfaces and outlives either half of it.
    if (widget.externalController == null) _ownController.dispose();
    super.dispose();
  }

  DateTime? _lastPlayheadSample;

  /// Records the configuration this widget was handed, so a bad payload is
  /// visible instead of silently degrading to the poster image.
  void _traceSpec(String where) {
    if (!DebugTrace.enabled) return;
    final HomePromoBannerSpec spec = widget.spec;
    DebugTrace.log(
      _trace,
      '$where media=${spec.media.name} mediaUrl="${spec.mediaUrl}" image="${spec.image}" '
      'hasMedia=${spec.hasMedia} autoplay=${spec.lottieAutoPlay} loop=${spec.lottieLoop} '
      'speed=${spec.lottieSpeed} resolved="${_resolveUrl(spec.mediaUrl ?? '')}" baseUrl="$_mediaBaseUrl"',
    );
  }

  Future<void> _loadMediaBaseUrl() async {
    final String baseUrl = await _authRepository.getMediaUrl();
    DebugTrace.log(_tag, 'media base url resolved to "$baseUrl" (empty=${baseUrl.trim().isEmpty})');
    if (!mounted) return;
    setState(() => _mediaBaseUrl = baseUrl);
  }

  /// Applies the configured playback speed once the real composition duration is known.
  void _onLottieLoaded(LottieComposition composition) {
    if (DebugTrace.enabled) {
      DebugTrace.log(
        _trace,
        'composition loaded from "${_resolveUrl(widget.spec.mediaUrl ?? '')}" '
        'duration=${composition.duration} frames=${composition.durationFrames} '
        'frameRate=${composition.frameRate} layers=${composition.layers.length} bounds=${composition.bounds}',
      );
      for (final Object warning in composition.warnings) {
        DebugTrace.log(_tag, 'composition warning: $warning');
      }
      // A shared-media surface must never hold the composition while a poster stands in
      // for it, and must never quietly serve an empty frame - both read as a hard cut at
      // the seam, because only one half of the picture would be alive.
      DebugTrace.log(
        'HeaderMediaLottie',
        '${widget.slot.isEmpty ? 'solo' : widget.slot.padRight(6)} '
        'loaded bounds=${composition.bounds} at=${DateTime.now().millisecondsSinceEpoch % 100000}',
      );
    }
    if (!mounted) return;
    final double speed = _clampedSpeed();
    _compositionReady = true;

    // Playback belongs to whoever OWNS the controller, and on a shared header that is
    // decided by arrival order, not by either child knowing it is not first.
    //
    // `repeat()` rewinds to the start of the range. Two instances load the composition
    // independently, so without this guard the second one to arrive restarts the shared
    // animation from frame 0 - the header visibly jumps a moment after it appears, even
    // though both halves then report the same value and look perfectly aligned while
    // sampled. A per-child flag could not prevent that, because each child has its own
    // state and neither can see what the other has already done. The controller's own
    // `isAnimating` IS shared state, so it is the only thing that can decide this
    // correctly: the first instance to arrive starts playback, and every later one leaves
    // the running animation alone.
    final bool alreadyRunning = widget.externalController != null && _lottieController.isAnimating;
    if (alreadyRunning) {
      DebugTrace.log(
        _trace,
        'shared controller already animating - NOT restarting '
        '(value=${_lottieController.value.toStringAsFixed(4)})',
      );
      return;
    }

    _lottieController.duration = Duration(milliseconds: (composition.duration.inMilliseconds / speed).round());
    DebugTrace.log(_trace, 'controller duration set to ${_lottieController.duration} for speed $speed');
    _applyPlayback();
    _lottieController.removeListener(_tracePlayhead);
    _lottieController.addListener(_tracePlayhead);
    _tracePlayhead();
    _probePlayback('after onLoaded');
  }

  /// Samples the controller a few frames later.
  ///
  /// A controller that never advances means the animation is parked on frame 0,
  /// which is indistinguishable from "it is not playing" by eye. Sampling it
  /// turns that into a number in the console.
  void _probePlayback(String reason) {
    if (!DebugTrace.enabled) return;
    _probe?.cancel();
    final double before = _lottieController.value;
    _probe = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      final double after = _lottieController.value;
      DebugTrace.log(
        _trace,
        'probe[$reason] ${widget.slot.isEmpty ? '' : '(${widget.slot}) '}animating=${_lottieController.isAnimating} status=${_lottieController.status.name} '
        'value $before -> $after ${(after == before ? '*** NOT ADVANCING ***' : 'advancing')}',
      );
    });
  }

  void _applyPlayback() {
    if (!mounted || !_compositionReady) return;
    if (!widget.spec.lottieAutoPlay) {
      DebugTrace.log(_tag, 'autoplay disabled by config - parked on frame 0');
      _lottieController.stop();
      _lottieController.value = 0;
      return;
    }
    if (widget.spec.lottieLoop) {
      _lottieController.repeat();
    } else {
      _lottieController.forward(from: 0);
    }
    DebugTrace.log(_trace, 'playback started animating=${_lottieController.isAnimating} status=${_lottieController.status.name}');
  }

  double _clampedSpeed() {
    final double speed = widget.spec.lottieSpeed;
    if (!speed.isFinite) return 1.0;
    return speed.clamp(HomePromoBannerMedia.minSpeed, HomePromoBannerMedia.maxSpeed);
  }

  /// Resolves a stored media path against the media base URL.
  ///
  /// The base URL is stored with a trailing slash (`https://bucket.s3....com/`) and
  /// the API hands out paths with a leading slash (`/header-banner/lottie/x.json`).
  /// Joining those literally produced a double slash, which S3 treats as a
  /// *different object key* and answered with `403 Forbidden` - so the animation
  /// silently degraded to the poster on every banner. Both sides are normalised
  /// before joining rather than assuming either one is already correct.
  String _resolveUrl(String path) {
    final String trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    final String base = _mediaBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (base.isEmpty) return '';
    return '$base/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    final HomePromoBannerSpec spec = widget.spec;

    if (!spec.hasMedia) {
      DebugTrace.log(_tag, 'NO MEDIA at all - mediaUrl and image are both blank (media=${spec.media.name})');
      return SizedBox(width: widget.width, height: widget.height);
    }

    if (spec.media == HomeHeaderBannerMedia.lottie) {
      final String url = _resolveUrl(spec.mediaUrl ?? '');
      if (url.isEmpty) {
        DebugTrace.log(
          _trace,
          'no playable URL (raw="${spec.mediaUrl}" baseUrl="$_mediaBaseUrl") - rendering the static poster instead of Lottie',
        );
        return _buildImageFallback('unresolvable lottie url');
      }
      DebugTrace.log(_tag, 'requesting lottie from $url');
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Lottie.network(
          url,
          controller: _lottieController,
          fit: spec.lottieFit,
          alignment: spec.lottieAlignment,
          animate: false,
          repeat: false,
          frameRate: HomePromoBannerMedia.frameRate,
          onLoaded: _onLottieLoaded,
          onWarning: (String warning) => DebugTrace.log(_tag, 'lottie warning: $warning'),
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            DebugTrace.error(_tag, error, stackTrace, context: 'Lottie load failed for $url');
            // The composition never arrived, so the controller must not keep
            // running against the placeholder duration.
            _compositionReady = false;
            _lottieController.stop();
            return _buildImageFallback('lottie load error');
          },
        ),
      );
    }

    DebugTrace.log(_tag, 'media=${spec.media.name} (NOT lottie) - rendering the poster image "${spec.image}"');
    return _buildImageFallback('media is not lottie');
  }

  Widget _buildImageFallback([String? reason]) {
    final String? image = widget.spec.image;
    if (image == null || image.trim().isEmpty) {
      DebugTrace.log(_tag, 'poster fallback has no image either (reason=${reason ?? 'unspecified'}) - banner renders blank');
      return SizedBox(width: widget.width, height: widget.height);
    }
    DebugTrace.log(_tag, 'rendering poster "$image" (reason=${reason ?? 'unspecified'})');
    return CacheNetworkImageWidget(width: widget.width, height: widget.height, imageUrl: image, fit: widget.fit);
  }
}
