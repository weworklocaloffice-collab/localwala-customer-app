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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_media.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';

/// A single promotional banner.
///
/// This widget is the only place banner media is painted. The silver app bar above it
/// always renders colour only.
///
/// [backgroundTheme] is the same [HomeAppBarTheme] the app bar renders from, so the
/// band and the app bar sit on one continuous surface. When it carries no decoration
/// - `auto` mode with no configured colour and no extracted palette - the banner
/// falls back to the ambient home header colour rather than painting nothing.
class HomePromoBanner extends StatelessWidget {
  final HomePromoBannerSpec spec;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final HomeAppBarTheme? backgroundTheme;

  const HomePromoBanner({
    super.key,
    required this.spec,
    required this.width,
    required this.height,
    this.onTap,
    this.backgroundTheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool vertical = spec.isVertical;
    // The banner paints the slice of the header sweep below the app bar, so the
    // gradient runs continuously from the app bar into the band rather than
    // restarting here.
    final HomeAppBarTheme? theme = backgroundTheme;
    // Windowed against this banner's real height so the slice the app bar ends on
    // and the slice the banner starts on meet at exactly the same colour.
    final Decoration decoration =
        theme?.windowedDecoration(theme.appBarGradientEnd(bannerHeight: height), 1) ??
        const BoxDecoration(color: ThemeProvider.homeHeaderBackgroundColor);
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: spec.hasTapTarget && onTap != null ? onTap : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Zoom wraps the nudge rather than sitting beside it, so the composition is
              // plain "scale about the centre, then shift": dragging the zoom rail
              // crops symmetrically, and the nudge picks which part stays in frame.
              Transform.scale(
                scale: spec.mediaScale,
                child: FractionalTranslation(
                  translation: spec.mediaOffset,
                  child: HomePromoBannerMedia(spec: spec, width: width, height: height),
                ),
              ),
              if (spec.hasOverlayText) ...[
                // FractionalTranslation keeps the nudge proportional to the banner, so a
                // placement chosen in the admin preview holds on every screen size.
                FractionalTranslation(
                  translation: spec.overlayOffset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x66000000),
                          Color(0xB3000000),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        vertical ? 20 : 14,
                        vertical ? 20 : 12,
                        vertical ? 20 : 14,
                        vertical ? 20 : 14,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isFilled(spec.title))
                            Text(
                              spec.title!.trim(),
                              maxLines: vertical ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: kAppLblSemiBoldFontLarge(context).copyWith(
                                color: Colors.white,
                                fontSize: vertical ? 22 : 18,
                                height: 1.15,
                              ),
                            ),
                          if (_isFilled(spec.subtitle)) ...[
                            kAppSpacerVertical(height: 6),
                            Text(
                              spec.subtitle!.trim(),
                              maxLines: vertical ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: kAppLblSmallFontMedium(
                                context,
                                color: 'white',
                              ).copyWith(color: Colors.white, height: 1.3),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              // The CTA is its own layer, a sibling of the content block rather than a
              // child of it. Nesting it inside `hasOverlayText` meant switching off
              // "Show Banner Content" silently took the button with it, which is the
              // opposite of what the two independent switches promise. It carries its own
              // solid background, so it needs no scrim to stay legible on bright media.
              if (spec.hasCta)
                FractionalTranslation(
                  translation: spec.ctaOffset,
                  child: Padding(
                    padding: EdgeInsets.all(vertical ? 20 : 14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: _CtaButton(spec: spec),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isFilled(String? value) =>
      value != null && value.trim().isNotEmpty;
}

/// Rounded call-to-action button painted over banner media.
///
/// Appearance comes entirely from [spec]: fill treatment, colours, radius, padding and
/// width are all operator-configurable, and a null colour falls back to the app theme so a
/// banner saved before these settings existed renders exactly as it did before them.
///
/// Stateful only for the two cases that genuinely need a repeating ticker - `bounce`, and
/// any effect with [HomePromoBannerSpec.ctaAnimationLoop] set. Everything else is an
/// implicit animation, which needs no controller and disposes itself.
class _CtaButton extends StatefulWidget {
  final HomePromoBannerSpec spec;

  const _CtaButton({required this.spec});

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> with SingleTickerProviderStateMixin {
  /// Always present. Created stopped in [initState] and started only once
  /// `didChangeDependencies` has confirmed motion is allowed.
  late final AnimationController _loop;

  HomePromoBannerSpec get _spec => widget.spec;

  /// Whether this effect has to run on a repeating ticker rather than fire once.
  bool get _needsLoop =>
      _spec.ctaAnimationLoop && _spec.ctaAnimation != HomeCtaAnimation.none;

  /// Honour the OS "reduce motion" setting.
  ///
  /// The first use of this flag in the app; an indefinitely repeating animation is exactly
  /// the case it exists for, and a looping button is otherwise an accessibility problem
  /// rather than a matter of taste.
  ///
  /// Reads an inherited widget, so it must only be called from `didChangeDependencies`,
  /// `didUpdateWidget` or `build` - never from `initState`.
  bool get _motionAllowed =>
      !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

  /// Half the configured duration, so a repeat is one move plus an equal pause rather
  /// than a cycle that is entirely movement (which reads as a flicker).
  Duration get _cycleDuration => Duration(
    milliseconds: _spec.ctaAnimationDuration.round() ~/ 2,
  );

  @override
  void initState() {
    super.initState();
    // The controller is created unconditionally and kept stopped until
    // `didChangeDependencies` decides whether motion is allowed. Constructing it here is
    // legal - `vsync: this` is the documented use of a TickerProvider from initState -
    // and keeping this hook free of inherited-widget reads is the whole point: reading
    // MediaQuery from initState threw "dependOnInheritedWidgetOfExactType ... before
    // initState completed" and took the home page's banner with it.
    _loop = AnimationController(vsync: this, duration: _cycleDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First safe point at which MediaQuery can be read.
    _syncLoop();
  }

  @override
  void didUpdateWidget(covariant _CtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The spec is replaced on every carousel tick, so the loop has to be re-evaluated
    // rather than only decided once.
    if (oldWidget.spec.ctaAnimation != _spec.ctaAnimation ||
        oldWidget.spec.ctaAnimationLoop != _spec.ctaAnimationLoop ||
        oldWidget.spec.ctaAnimationDuration != _spec.ctaAnimationDuration) {
      _loop.duration = _cycleDuration;
      _syncLoop();
    }
  }

  /// Starts or stops the ticker to match the current effect.
  ///
  /// Uses `stop()` + a value reset rather than disposing and rebuilding, so a carousel
  /// tick that swaps the spec does not churn a new controller every frame.
  void _syncLoop() {
    if (_needsLoop && _motionAllowed) {
      _loop.duration = _cycleDuration;
      if (!_loop.isAnimating) _loop.repeat();
      return;
    }

    _loop.stop();
    _loop.value = 0;
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  static Color? _hexToColor(String? raw) {
    if (raw == null) return null;
    String hex = raw.trim().toUpperCase().replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((String c) => '$c$c').join();
    }
    if (hex.length != 6) return null;
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  /// Resolved CTA background, falling back to the app's primary colour when the operator
  /// has not chosen one.
  Color _backgroundColor(Color fallback) => _hexToColor(_spec.ctaBackgroundColor) ?? fallback;

  /// Resolved CTA text colour, defaulting to white.
  Color _textColor(Color fallback) => _hexToColor(_spec.ctaTextColor) ?? fallback;

  /// Fill, border and colours for the configured [HomeCtaStyle].
  BoxDecoration _decoration(Color fallbackBackground, Color fallbackText) {
    final Color background = _backgroundColor(fallbackBackground);
    final Color text = _textColor(fallbackText);

    switch (_spec.ctaStyle) {
      case HomeCtaStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_spec.ctaCornerRadius),
          border: Border.all(color: text),
        );
      case HomeCtaStyle.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_spec.ctaCornerRadius),
        );
      case HomeCtaStyle.solid:
        return BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(_spec.ctaCornerRadius),
        );
    }
  }

  // --------------------------------------------------------------------- effects

  /// Wraps the finished button in the transform for the current effect.
  ///
  /// Paint effects and `arrowSlide` have already been applied by [_buildButton], so they
  /// fall through untouched here.
  Widget _applyTransform(double t, Widget button) {
    switch (_spec.ctaAnimation) {
      case HomeCtaAnimation.none:
        return button;
      case HomeCtaAnimation.pulse:
        return ctaPulse(t, button);
      case HomeCtaAnimation.heartbeat:
        return ctaHeartbeat(t, button);
      case HomeCtaAnimation.wiggle:
        return ctaWiggle(t, button);
      case HomeCtaAnimation.shake:
        return ctaShake(t, button);
      case HomeCtaAnimation.bounce:
        return ctaBounce(t, button);
      case HomeCtaAnimation.zoomIn:
        return ctaZoomIn(t, button);
      case HomeCtaAnimation.fadeIn:
        return ctaFadeIn(t, button);
      case HomeCtaAnimation.slideUp:
        return ctaSlideUp(t, button);
      case HomeCtaAnimation.flipIn:
        return ctaFlipIn(t, button);
      case HomeCtaAnimation.pressDown:
      case HomeCtaAnimation.arrowSlide:
      case HomeCtaAnimation.glow:
      case HomeCtaAnimation.shimmer:
      case HomeCtaAnimation.goldenShine:
      case HomeCtaAnimation.rainbow:
      case HomeCtaAnimation.borderRunner:
        return button;
    }
  }

  /// Builds the button for one frame of its effect.
  ///
  /// Takes the animation value rather than reading the controller itself so the repeating
  /// path and the one-shot entrance path share a single layout implementation.
  Widget _buildButton(BuildContext context, double t) {
    final Color fallbackBackground = Theme.of(context).primaryColor;
    final Color fallbackText = Colors.white;
    final Color background = _backgroundColor(fallbackBackground);
    final Color text = _textColor(fallbackText);
    final double radius = _spec.ctaCornerRadius;

    BoxDecoration decoration = _decoration(fallbackBackground, fallbackText);

    // Effects that change the paint rather than the geometry.
    if (_motionAllowed) {
      switch (_spec.ctaAnimation) {
        case HomeCtaAnimation.glow:
          decoration = decoration.copyWith(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: background.withValues(alpha: 0.16 + (0.4 * ctaSmooth(t))),
                blurRadius: 10 + (20 * ctaSmooth(t)),
                spreadRadius: 1 + (3 * ctaSmooth(t)),
              ),
            ],
          );
          break;
        case HomeCtaAnimation.goldenShine:
          decoration = decoration.copyWith(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFFD4A72C).withValues(alpha: 0.45),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          );
          break;
        default:
          break;
      }
    }

    final Color iconColor = text;
    final double iconSize = _spec.ctaFontSize + 2;
    final bool arrowMoves = _motionAllowed && _spec.ctaAnimation == HomeCtaAnimation.arrowSlide;

    Widget arrow = Icon(Icons.arrow_forward_rounded, size: iconSize, color: iconColor);
    if (arrowMoves) {
      // Nudges right and settles back, so the label does not move with it.
      arrow = Transform.translate(
        offset: Offset(3 * ctaSmooth(t), 0),
        child: arrow,
      );
    }

    Widget button = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _spec.ctaPaddingX,
        vertical: _spec.ctaPaddingY,
      ),
      decoration: decoration,
      width: _spec.ctaFullWidth ? double.infinity : null,
      child: Row(
        mainAxisSize: _spec.ctaFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: _spec.ctaFullWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text(
              _spec.ctaText!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: kAppLblSmallFontBold(
                context,
                color: 'white',
              ).copyWith(color: text, fontSize: _spec.ctaFontSize),
            ),
          ),
          if (_spec.ctaShowArrow) ...<Widget>[
            kAppSpacerHorizontal(width: 6),
            arrow,
          ],
        ],
      ),
    );

    // Mask effects wrap the painted button, not the whole box, so a glow's shadow is not
    // clipped away by the mask's own bounds.
    if (_motionAllowed) {
      switch (_spec.ctaAnimation) {
        case HomeCtaAnimation.shimmer:
          button = CtaShimmerMask(t: t, child: button);
          break;
        case HomeCtaAnimation.goldenShine:
          button = CtaShimmerMask(t: t, colors: kCtaGold, child: button);
          break;
        case HomeCtaAnimation.rainbow:
        case HomeCtaAnimation.borderRunner:
          button = CustomPaint(
            painter: CtaBorderPainter(
              progress: t,
              highlight: _spec.ctaAnimation == HomeCtaAnimation.rainbow
                  ? kCtaRainbow[1]
                  : text,
              base: _spec.ctaAnimation == HomeCtaAnimation.rainbow
                  ? kCtaRainbow[0]
                  : background,
              radius: radius,
              spectrum: _spec.ctaAnimation == HomeCtaAnimation.rainbow
                  ? kCtaRainbow
                  : null,
            ),
            child: button,
          );
          break;
        default:
          break;
      }
    }

    return _applyTransform(t, button);
  }

  /// `pressDown` reacts to touch rather than a timer, so it gets its own gesture path.
  Widget _buildPressDown(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: Transform.scale(
        scale: _pressed ? 0.94 : 1,
        child: _buildButton(context, 0),
      ),
    );
  }

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final HomeCtaAnimation effect = _spec.ctaAnimation;

    if (!_motionAllowed || effect == HomeCtaAnimation.none) {
      return _buildButton(context, 0);
    }

    if (effect == HomeCtaAnimation.pressDown) return _buildPressDown(context);

    // One-shot entrances play once through an implicit tween and then stop; the repeating
    // path is only ever taken by the loopable family, where `ctaAnimationLoop` is on.
    if (effect.isEntrance) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: _spec.ctaAnimationDuration.round()),
        curve: effect == HomeCtaAnimation.bounce
            ? Curves.easeOutBack
            : Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? _) =>
            _buildButton(context, value),
      );
    }

    return AnimatedBuilder(
      animation: _loop,
      builder: (BuildContext context, Widget? _) => _buildButton(context, _loop.value),
    );
  }
}

// ===========================================================================
// CTA effect library
//
// Each effect is a pure function of one number in [0,1) plus the button, so the same
// definition serves both the repeating path (driven by the controller) and the one-shot
// entrance path (driven by a tween). Effects that need the button's own colour - glow,
// and the animated borders - instead report what to paint; see [_CtaButtonState].
// ===========================================================================

/// 0 -> 1 -> 0 across a cycle, peaking just past halfway.
double ctaWave(double t) => (t < 0.5 ? t * 2 : (1 - t) * 2);

/// As [ctaWave] but eased, for motion that should settle rather than snap.
double ctaSmooth(double t) => math.sin(ctaWave(t) * math.pi);

/// Traces a bright segment around the button's rounded outline.
///
/// `BoxDecoration` cannot animate a stroke, so the runner and both festive borders paint
/// themselves. A `TileMode.repeated` gradient whose `transform` shifts each frame is what
/// moves the highlight around the perimeter without rebuilding the path.
class CtaBorderPainter extends CustomPainter {
  final double progress;
  final Color highlight;
  final Color? base;
  final double radius;
  final double strokeWidth;
  final List<Color>? spectrum;

  const CtaBorderPainter({
    required this.progress,
    required this.highlight,
    required this.radius,
    this.base,
    this.strokeWidth = 2,
    this.spectrum,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rounded = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    // Travel one width plus one height so the highlight clears an edge before it returns.
    final double shift = (progress % 1.0) * (size.width + size.height);

    final List<Color> colors = spectrum ??
        <Color>[base ?? highlight, highlight, base ?? highlight];

    canvas.drawRRect(
      rounded,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          colors: colors,
          stops: const <double>[0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          tileMode: TileMode.repeated,
        ).createShader(
          Rect.fromLTWH(-shift, 0, size.width, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(CtaBorderPainter old) =>
      old.progress != progress ||
      old.highlight != highlight ||
      old.base != base ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      !identical(old.spectrum, spectrum);
}

/// A diagonal light streak travelling across the button's fill.
class CtaShimmerMask extends StatelessWidget {
  final double t;
  final Widget child;
  final List<Color> colors;

  const CtaShimmerMask({
    super.key,
    required this.t,
    required this.child,
    this.colors = const <Color>[
      Color(0x00FFFFFF),
      Color(0x99FFFFFF),
      Color(0x00FFFFFF),
    ],
  });

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcATop,
    shaderCallback: (Rect bounds) => LinearGradient(
      colors: colors,
      stops: const <double>[0.0, 0.5, 1.0],
      begin: Alignment(-1.4 + (t * 2.4), 0),
      end: Alignment(0.4 + (t * 2.4), 0),
    ).createShader(bounds),
    child: child,
  );
}

const List<Color> kCtaRainbow = <Color>[
  Color(0xFFFF4D4D),
  Color(0xFFFFC93C),
  Color(0xFF4DFF88),
  Color(0xFF4DD2FF),
  Color(0xFFB84DFF),
  Color(0xFFFF4D4D),
];

const List<Color> kCtaGold = <Color>[
  Color(0xFF8A6A1F),
  Color(0xFFFFE9A8),
  Color(0xFFD4A72C),
  Color(0xFFFFF6D8),
  Color(0xFF8A6A1F),
];

// ---------------------------------------------------------------------------
// Transform effects. Every one takes the button and returns it transformed.
// ---------------------------------------------------------------------------

Widget ctaPulse(double t, Widget c) =>
    Transform.scale(scale: 1 + (0.06 * ctaSmooth(t)), child: c);

/// Two thumps per cycle instead of one swell - that is what reads as a heartbeat.
Widget ctaHeartbeat(double t, Widget c) {
  final double w = ctaWave(t);
  final double thump = w < 0.16
      ? (w / 0.16)
      : (w < 0.32 ? 1 - ((w - 0.16) / 0.16) : (w < 0.5 ? (w - 0.32) / 0.18 : 0));
  return Transform.scale(scale: 1 + (0.08 * thump), child: c);
}

Widget ctaWiggle(double t, Widget c) => Transform.rotate(
  angle: 0.05 * math.sin(ctaSmooth(t) * 2 * math.pi),
  child: c,
);

/// Damped sine: a firm first swing that settles before the cycle ends.
Widget ctaShake(double t, Widget c) {
  final double w = ctaSmooth(t);
  return Transform.translate(
    offset: Offset(4 * (1 - w) * math.sin(w * 8 * math.pi), 0),
    child: c,
  );
}

/// Fast rise, slow fall, flat along the bottom - a bounce rather than a ping.
Widget ctaBounce(double t, Widget c) {
  final double lift =
      t < 0.35 ? (t / 0.35) : (t < 0.65 ? 1 - ((t - 0.35) / 0.3) : 0);
  return Transform.translate(offset: Offset(0, -9 * lift), child: c);
}

Widget ctaZoomIn(double t, Widget c) =>
    Transform.scale(scale: 0.72 + (0.28 * t), child: c);

Widget ctaFadeIn(double t, Widget c) => Opacity(opacity: t, child: c);

Widget ctaSlideUp(double t, Widget c) => FractionalTranslation(
  translation: Offset(0, 0.2 * (1 - t)),
  child: Opacity(opacity: t, child: c),
);

/// Rotation about the Y axis. The tiny perspective entry is what makes it read as a
/// three-dimensional flip rather than a squashed horizontal scale.
Widget ctaFlipIn(double t, Widget c) {
  final double angle = (1 - t) * math.pi;
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(angle),
    child: Opacity(opacity: t < 0.5 ? t * 2 : 1, child: c),
  );
}

/// Rotating set of promotional banners with page indicator dots.
///
/// Rotation is opt in per banner through `displayDuration` and pauses while the widget
/// is off stage.
class HomePromoBannerCarousel extends StatefulWidget {
  final List<HomePromoBannerSpec> specs;
  final double availableWidth;
  final void Function(HomePromoBannerSpec spec)? onTap;

  /// Shared with the app bar so the band continues the app bar surface.
  final HomeAppBarTheme? backgroundTheme;

  const HomePromoBannerCarousel({
    super.key,
    required this.specs,
    required this.availableWidth,
    this.onTap,
    this.backgroundTheme,
  });

  @override
  State<HomePromoBannerCarousel> createState() =>
      _HomePromoBannerCarouselState();
}

class _HomePromoBannerCarouselState extends State<HomePromoBannerCarousel> {
  late final PageController _pageController = PageController(
    viewportFraction: 1.0,
  );
  Timer? _rotationTimer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void didUpdateWidget(covariant HomePromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.specs.length != widget.specs.length) {
      _index = 0;
      _startRotation();
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (!mounted || widget.specs.length <= 1) return;
    final int seconds =
        widget.specs[_index.clamp(0, widget.specs.length - 1)].displayDuration;
    if (seconds <= 0) return;
    _rotationTimer = Timer.periodic(
      Duration(seconds: seconds),
      (Timer timer) => _rotate(),
    );
  }

  void _rotate() {
    if (!mounted || !_pageController.hasClients || widget.specs.length <= 1)
      return;
    final int next = (_index + 1) % widget.specs.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<HomePromoBannerSpec> specs = widget.specs;
    if (specs.isEmpty) return const SizedBox.shrink();

    final HomePromoBannerSpec active = specs[_index.clamp(0, specs.length - 1)];
    final double height = active.resolveHeight(widget.availableWidth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: specs.length,
            onPageChanged: (int index) {
              setState(() => _index = index);
              _startRotation();
            },
            itemBuilder: (BuildContext context, int index) {
              final HomePromoBannerSpec spec = specs[index];
              return HomePromoBanner(
                spec: spec,
                width: widget.availableWidth,
                height: spec.resolveHeight(widget.availableWidth),
                onTap: widget.onTap == null ? null : () => widget.onTap!(spec),
                backgroundTheme: widget.backgroundTheme,
              );
            },
          ),
        ),
        if (specs.length > 1) ...[
          kAppSpacerVertical(height: 8),
          Center(
            child: _PageDots(count: specs.length, index: _index),
          ),
        ],
      ],
    );
  }
}

/// Page indicator dots shown when more than one banner is active.
class _PageDots extends StatelessWidget {
  final int count;
  final int index;

  const _PageDots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    final Color active = ThemeProvider.primaryColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(count, (int i) {
        final bool selected = i == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 14 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected ? active : active.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// The banner slot that lives between the silver app bar and the home content.
class HomePromoBannerSlot extends StatelessWidget {
  final List<HomePromoBannerSpec> specs;
  final void Function(HomePromoBannerSpec spec)? onTap;

  /// The app bar's own theme, so the banner paints the same surface the app bar
  /// paints instead of a second, independent colour.
  final HomeAppBarTheme? backgroundTheme;

  const HomePromoBannerSlot({super.key, required this.specs, this.onTap, this.backgroundTheme});

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) return const SizedBox.shrink();
    // Full bleed, matching the header board: the band meets both screen edges and sits
    // flush under the app bar. Any inset here shows the page background as a white gap.
    return HomePromoBannerCarousel(
      specs: specs,
      availableWidth: MediaQuery.of(context).size.width,
      onTap: onTap,
      backgroundTheme: backgroundTheme,
    );
  }
}
