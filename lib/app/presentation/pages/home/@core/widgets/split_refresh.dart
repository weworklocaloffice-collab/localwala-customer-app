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

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Pull to refresh that splits the page open instead of overlaying it.
///
/// A stock [RefreshIndicator] pins its spinner to the top edge of the scroll
/// view, so the spinner rides on top of the first row of content while the drag
/// gap opens behind it. Here the page is translated down by the drag distance
/// as one block, the strip that opens between the app bar and the first child
/// is the only thing painted, and the spinner is centred inside that strip, so
/// the page reads as splitting open under the app bar.
///
/// The gap is derived from scroll overscroll rather than a gesture recogniser,
/// so nothing competes with the scroll view for the pointer and normal
/// scrolling is untouched.
class SplitRefresh extends StatefulWidget {
  const SplitRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshExtent = 76.0,
    this.indicatorSize = 26.0,
    this.triggerRatio = 0.7,
    this.dragResistance = 0.55,
  });

  /// The scrollable page. It is translated as a single block, never re-laid out.
  final Widget child;

  /// Runs once the drag passes the trigger point. The split stays open for as
  /// long as the returned future is pending.
  final Future<void> Function() onRefresh;

  /// Height of the fully open split. The spinner is centred inside it.
  final double refreshExtent;

  /// Diameter of the progress indicator drawn inside the split.
  final double indicatorSize;

  /// Fraction of [refreshExtent] the drag must cover before refresh arms.
  final double triggerRatio;

  /// 1 drags one to one, 0 never opens the split.
  final double dragResistance;

  @override
  State<SplitRefresh> createState() => _SplitRefreshState();
}

class _SplitRefreshState extends State<SplitRefresh> with SingleTickerProviderStateMixin {
  late final AnimationController _settle = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

  /// Pull read back from negative pixels. Bouncing platforms (iOS, macOS)
  /// report it that way, so it is an absolute distance off the metrics.
  double _pixelPull = 0;

  /// Pull accumulated from overscroll notifications. Clamping platforms
  /// (Android, desktop) report it that way instead, so it has to be summed.
  double _notificationPull = 0;

  /// Furthest the split opened during the current drag. Kept separately from
  /// the live gap because the platform springs the scroll position back to the
  /// edge on release, which would otherwise erase the reach before the trigger
  /// is judged.
  double _reach = 0;

  double _settleFrom = 0;
  double _settleTo = 0;
  bool _settling = false;
  bool _refreshing = false;

  double get _trigger => widget.refreshExtent * widget.triggerRatio;

  double get _rawPull => math.max(_pixelPull, _notificationPull);

  double get _gap => _refreshing ? widget.refreshExtent : _damp(_rawPull);

  /// Resistance opens the split progressively, then hard limits growth so a
  /// long flick cannot push the page off screen.
  double _damp(double raw) {
    final double linear = raw * widget.dragResistance;
    if (linear <= widget.refreshExtent) return linear;
    return widget.refreshExtent + (linear - widget.refreshExtent) * 0.18;
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _resetPull() {
    _pixelPull = 0;
    _notificationPull = 0;
    _reach = 0;
  }

  /// Opens the split to the current pull distance, remembering the reach.
  void _openSplit() {
    if (_settling) _settle.stop();
    _settling = false;
    _reach = math.max(_reach, _rawPull);
    setState(() {});
  }

  /// Springs the split from where it currently sits to [target].
  ///
  /// [from] is passed in rather than sampled from [_gap] because the callers
  /// clear the pull state first, and [_gap] is derived from it.
  void _animateSplitTo(double from, double target) {
    _settle.stop();
    _settleFrom = from;
    _settleTo = target;
    _settling = true;
    _settle
      ..reset()
      ..forward();
  }

  /// Judges the finished drag, then either refreshes or springs the split shut.
  Future<void> _finishDrag() async {
    if (_refreshing) return;
    // Compared after damping, so the release point is exactly where the spinner
    // inside the split reads full.
    if (_damp(_reach) < _trigger) {
      final double from = _gap;
      _resetPull();
      _animateSplitTo(from, 0);
      return;
    }
    setState(() {
      _refreshing = true;
      _resetPull();
    });
    try {
      await widget.onRefresh();
    } catch (_) {
      // A failed refresh must still close the split, never leave it stuck open.
    }
    if (!mounted) return;
    // Sampled while still refreshing, so the close starts from the open split
    // instead of snapping it shut.
    final double from = _gap;
    _animateSplitTo(from, 0);
    setState(() => _refreshing = false);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // The campaign carousel and the food carousels are nested scrollables and
    // report their own overscroll.
    if (notification.depth != 0) return false;
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    if (_refreshing) return false;

    if (notification is ScrollStartNotification) {
      _settle.stop();
      _settling = false;
      // A fresh gesture always starts from a closed split, so a half finished
      // settle from the previous pull cannot bleed into this one.
      _resetPull();
      setState(() {});
      return false;
    }

    // Only a finger driven overscroll opens the split. Ballistic and spring
    // driven updates are ignored, otherwise the spring back to the edge would
    // collapse the split the moment the customer lifts their thumb.
    if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
      if (metrics.extentBefore <= 0 && metrics.pixels < 0) {
        _pixelPull = -metrics.pixels;
        _openSplit();
      }
      return false;
    }

    // Clamping platforms (Android, desktop) hold the scroll position on the
    // edge and report the pull as summed overscroll instead of negative pixels.
    if (notification is OverscrollNotification &&
        notification.dragDetails != null &&
        metrics.extentBefore <= 0 &&
        notification.overscroll < 0) {
      if (_settling) _settle.stop();
      _settling = false;
      _notificationPull += -notification.overscroll;
      _openSplit();
      return false;
    }

    if (notification is ScrollEndNotification && _reach > 0) {
      _finishDrag();
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ScrollBehavior behavior = ScrollConfiguration.of(context).copyWith(
      // The platform indicator paints over the first row of content, which is
      // the exact thing this widget replaces. It does not gate the scroll
      // position itself, so the overscroll signals below still arrive.
      overscroll: false,
    );
    return ScrollConfiguration(
      behavior: behavior,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: AnimatedBuilder(
          animation: _settle,
          builder: (BuildContext context, Widget? child) {
            final double gap = _settling ? lerpDouble(_settleFrom, _settleTo, Curves.easeOutCubic.transform(_settle.value))! : _gap;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: <Widget>[
                Transform.translate(offset: Offset(0, gap), child: child),
                Positioned.fill(
                  child: _SplitIndicator(gap: gap, trigger: _trigger, size: widget.indicatorSize, spinning: _refreshing),
                ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// The spinner that lives inside the opened split.
class _SplitIndicator extends StatelessWidget {
  const _SplitIndicator({required this.gap, required this.trigger, required this.size, required this.spinning});

  final double gap;
  final double trigger;
  final double size;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    if (gap <= 0) return const SizedBox.shrink();
    final double progress = (gap / trigger).clamp(0.0, 1.0);
    final Color accent = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: Opacity(
        opacity: progress,
        child: Align(
          alignment: Alignment.topCenter,
          child: Transform.scale(
            scale: 0.7 + (0.3 * progress),
            child: Padding(
              padding: EdgeInsets.only(top: math.max(0, (gap - size) / 2)),
              child: SizedBox.square(
                dimension: size,
                child: CircularProgressIndicator(
                  value: spinning ? null : progress,
                  strokeWidth: 2.4,
                  strokeCap: StrokeCap.round,
                  color: accent,
                  backgroundColor: accent.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}