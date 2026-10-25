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

import 'package:flutter/material.dart';
import 'package:user/app/core/models/home_response_model.dart';
import 'package:user/app/presentation/styles/theme.dart';

/// How the silver app bar derives its background.
enum HomeHeaderBackgroundMode {
  /// Take the colour extracted from the banner media.
  auto,

  /// Use an explicitly configured colour.
  manual,

  /// Use an explicitly configured two stop gradient.
  gradient,
}

/// Media kind rendered inside the promotional banner slot.
///
/// The app bar itself never renders media - colour only.
enum HomeHeaderBannerMedia {
  image,
  lottie;

  /// Resolves the media kind from an API `type` string.
  ///
  /// `video` is accepted for forward compatibility and resolves to [image] so the
  /// configured poster frame is displayed. A dedicated video surface is deferred.
  static HomeHeaderBannerMedia fromType(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'lottie' || 'animation' => HomeHeaderBannerMedia.lottie,
      _ => HomeHeaderBannerMedia.image,
    };
  }
}

/// Configuration for the silver app bar (a.k.a. "Silver App Bar" in the design boards).
///
/// A `null` [HomeAppBarTheme] means "no configuration supplied" and the app bar must
/// render exactly as it does today. That is the regression guarantee for this feature.
@immutable
class HomeAppBarTheme {
  /// How the background colour is resolved.
  final HomeHeaderBackgroundMode backgroundMode;

  /// Solid background colour. Used for [HomeHeaderBackgroundMode.manual] and as the
  /// base colour for [HomeHeaderBackgroundMode.auto].
  final Color? backgroundColor;

  /// Gradient start colour.
  final Color? gradientFrom;

  /// Gradient end colour.
  final Color? gradientTo;

  /// Palette extracted from the banner image, surfaced for previewing in admin.
  final List<Color> extractedPalette;

  /// Collapsed height of the app bar, in logical pixels.
  final double collapsedHeight;

  /// Whether the location row (pin + title + subtitle) is shown.
  final bool showLocation;

  /// Whether the language selector action is shown.
  final bool showLanguageSelector;

  /// Whether the notification bell (and its badge) is shown.
  final bool showNotificationIcon;

  const HomeAppBarTheme({
    this.backgroundMode = HomeHeaderBackgroundMode.auto,
    this.backgroundColor,
    this.gradientFrom,
    this.gradientTo,
    this.extractedPalette = const [],
    this.collapsedHeight = ThemeProvider.homeHeaderCollapsedHeight,
    this.showLocation = true,
    this.showLanguageSelector = true,
    this.showNotificationIcon = true,
  });

  /// Builds a theme from the values published by the API banner configuration.
  ///
  /// Every field is optional, so a partially populated or absent payload degrades to
  /// the defaults rather than throwing.
  factory HomeAppBarTheme.fromJson(Map<String, dynamic> json) {
    return HomeAppBarTheme(
      backgroundMode: HomeHeaderBackgroundMode.values.firstWhere((mode) => mode.name == json['appBarBackgroundMode']?.toString().trim().toLowerCase(), orElse: () => HomeHeaderBackgroundMode.auto),
      backgroundColor: parseHexColor(json['appBarBackgroundColor']?.toString()),
      gradientFrom: parseHexColor(json['appBarGradientFrom']?.toString()),
      gradientTo: parseHexColor(json['appBarGradientTo']?.toString()),
      extractedPalette: parseHexPalette(json['extractedColors']),
      collapsedHeight: _readCollapsedHeight(json['collapsedHeight']),
      showLocation: _readFlag(json['showLocation'], fallback: true),
      showLanguageSelector: _readFlag(json['showLanguageSelector'], fallback: true),
      showNotificationIcon: _readFlag(json['showNotificationIcon'], fallback: true),
    );
  }

  /// Whether a gradient can actually be painted.
  bool get isGradient => backgroundMode == HomeHeaderBackgroundMode.gradient && gradientFrom != null && gradientTo != null;

  /// Height of the search bar the app bar renders beneath its toolbar row.
  ///
  /// Declared here rather than on the app bar widget so the gradient geometry below
  /// can be computed from the theme alone, with no import back to the widget.
  static const double searchBarHeight = 55.0;

  /// Painted height of the app bar region, toolbar row plus search bar.
  double get appBarHeight => collapsedHeight;

  /// Where the app bar's slice of the gradient ends, as a fraction of the surface.
  ///
  /// [bannerHeight] should be the height the banner actually paints. The default is
  /// only a fallback for a caller that cannot know it; windowing against the real
  /// height is what keeps the two slices in proportion, so the app bar's ramp is
  /// not steeper than the banner's.
  double appBarGradientEnd({double? bannerHeight}) {
    final double banner = (bannerHeight != null && bannerHeight > 0) ? bannerHeight : HomePromoBannerSpec.defaultHeight;
    return appBarHeight / (appBarHeight + banner);
  }

  /// [decoration] restricted to the slice of the header surface between
  /// [startFraction] and [endFraction].
  ///
  /// A vertical gradient distributes its stops over whatever box it is painted in.
  /// Painting the same gradient into the app bar and the banner therefore restarted
  /// it at their boundary: the app bar ran to its dark stop, then the banner began
  /// light again. Windowing makes the two slices add up to one sweep - both
  /// boundaries resolve to the same colour, so the join is invisible.
  ///
  /// The slice is built by sampling the parent gradient at each end rather than by
  /// re-using its colours with a shifted `stops` list, which would only be valid
  /// for a two colour gradient.
  ///
  /// Returns the plain [decoration] for a solid colour, since a solid has no stops
  /// to window, and `null` when there is nothing configured.
  Decoration? windowedDecoration(double startFraction, double endFraction) {
    if (!hasDecoration) return null;
    if (!isGradient) return decoration;

    final LinearGradient gradient = linearGradient;
    final double start = startFraction.clamp(0.0, 1.0);
    final double end = endFraction.clamp(start, 1.0);

    /// Resolves the gradient's colour at absolute position [t] (0..1).
    Color sample(double t) {
      final List<double> stops =
          gradient.stops ??
          List<double>.generate(
            gradient.colors.length,
            (int i) => gradient.colors.length == 1 ? 0.0 : i / (gradient.colors.length - 1),
          );

      if (t <= stops.first) return gradient.colors.first;
      if (t >= stops.last) return gradient.colors.last;

      for (int i = 0; i < stops.length - 1; i++) {
        if (t >= stops[i] && t <= stops[i + 1]) {
          final double localT = (t - stops[i]) / (stops[i + 1] - stops[i]);
          return Color.lerp(gradient.colors[i], gradient.colors[i + 1], localT) ?? gradient.colors[i];
        }
      }

      return gradient.colors.last;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[sample(start), sample(end)],
      ),
    );
  }

  /// Whether a solid colour can actually be painted.
  bool get isSolid => backgroundColor != null;

  /// Whether this theme paints anything at all. When `false` the app bar keeps the
  /// ambient [AppBarTheme] and renders unchanged.
  bool get hasDecoration => isGradient || isSolid;

  /// The gradient used when [isGradient] is `true`.
  LinearGradient get linearGradient {
    return LinearGradient(colors: [gradientFrom ?? ThemeProvider.homeHeaderGradientFrom, gradientTo ?? ThemeProvider.homeHeaderGradientTo], begin: Alignment.topCenter, end: Alignment.bottomCenter);
  }

  /// Background decoration for the app bar, or `null` when nothing should change.
  Decoration? get decoration {
    if (!hasDecoration) return null;
    if (isGradient) return BoxDecoration(gradient: linearGradient);
    return BoxDecoration(color: backgroundColor);
  }

  /// Parses `#RGB`, `#RRGGBB` and `#AARRGGBB` (with or without the leading `#`).
  ///
  /// Returns `null` for anything unparseable so a malformed payload can never paint a
  /// transparent or black app bar.
  static Color? parseHexColor(String? value) {
    if (value == null) return null;
    var hex = value.trim();
    if (hex.isEmpty) return null;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.startsWith('0x') || hex.startsWith('0X')) hex = hex.substring(2);
    if (hex.length == 3) {
      hex = hex.split('').map((char) => '$char$char').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final int? parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  /// Parses a list of hex colours, skipping unparseable entries.
  static List<Color> parseHexPalette(dynamic value) {
    if (value is! List) return const [];
    final List<Color> colors = <Color>[];
    for (final dynamic entry in value) {
      final Color? color = parseHexColor(entry?.toString());
      if (color != null) colors.add(color);
    }
    return colors;
  }

  static double _readCollapsedHeight(dynamic value) {
    if (value is num && value > 0) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value.trim());
      if (parsed != null && parsed > 0) return parsed;
    }
    return ThemeProvider.homeHeaderCollapsedHeight;
  }

  static bool _readFlag(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  @override
  bool operator ==(Object other) {
    return other is HomeAppBarTheme &&
        other.backgroundMode == backgroundMode &&
        other.backgroundColor == backgroundColor &&
        other.gradientFrom == gradientFrom &&
        other.gradientTo == gradientTo &&
        other.collapsedHeight == collapsedHeight &&
        other.showLocation == showLocation &&
        other.showLanguageSelector == showLanguageSelector &&
        other.showNotificationIcon == showNotificationIcon;
  }

  @override
  int get hashCode => Object.hash(backgroundMode, backgroundColor, gradientFrom, gradientTo, collapsedHeight, showLocation, showLanguageSelector, showNotificationIcon);
}

/// Immutable description of the promotional banner rendered between the app bar and
/// the home content.
///
/// This is the only widget allowed to render banner image / Lottie media.
/// How an effect behaves when left switched on.
enum HomeCtaAnimation {
  none,
  pulse,
  heartbeat,
  wiggle,
  shake,
  glow,
  shimmer,
  arrowSlide,
  borderRunner,
  bounce,
  fadeIn,
  slideUp,
  zoomIn,
  flipIn,
  pressDown,
  rainbow,
  goldenShine;

  static HomeCtaAnimation parse(String? value) {
    final String effect = value?.trim().toLowerCase() ?? '';
    return HomeCtaAnimation.values.firstWhere(
      (HomeCtaAnimation animation) => animation.name.toLowerCase() == effect,
      orElse: () => HomeCtaAnimation.none,
    );
  }

  /// One-shot on appear. Repeating these reads as a glitch rather than an effect, so the
  /// client ignores `ctaAnimationLoop` for them and the panel does not offer the toggle.
  bool get isEntrance =>
      this == HomeCtaAnimation.bounce ||
      this == HomeCtaAnimation.fadeIn ||
      this == HomeCtaAnimation.slideUp ||
      this == HomeCtaAnimation.zoomIn ||
      this == HomeCtaAnimation.flipIn;

  /// Driven by touch rather than a ticker, so `duration` does not apply to it.
  bool get isInteraction => this == HomeCtaAnimation.pressDown;

  /// Repeats cleanly and is the only family where "Loop forever" means anything.
  bool get isLoopable =>
      !isEntrance && !isInteraction && this != HomeCtaAnimation.none;
}

/// How the banner's media is divided between the app bar and the banner slot.
class HeaderMediaLayout {
  /// Height the app bar paints, i.e. the admin's `collapsedHeight`.
  final double appBarHeight;

  /// Height the banner slot paints.
  final double bannerHeight;

  /// Width both surfaces share.
  final double width;

  /// Extra canvas rendered above and below the visible region, as a fraction of
  /// [canvasHeight], so the artwork can be panned for parallax without ever running out of
  /// media at an edge.
  final double parallaxFactor;

  const HeaderMediaLayout({
    required this.appBarHeight,
    required this.bannerHeight,
    required this.width,
    this.parallaxFactor = 0.18,
  });

  /// Height of the visible region: exactly the sum of the two windows.
  ///
  /// Deliberately unchanged by parallax. This is the span the two surfaces must always
  /// cover between them, and keeping it a property of the layout rather than of wherever
  /// the artwork happens to be panned to is what keeps them contiguous.
  double get canvasHeight => appBarHeight + bannerHeight;

  /// Bleed available above and below the visible region.
  double get overscan => canvasHeight * parallaxFactor;

  /// Height actually rendered, including the bleed.
  double get paintedCanvasHeight => canvasHeight + overscan * 2;

  /// Fraction of [canvasHeight] at which the app bar's window ends.
  ///
  /// Mirrors `previewGradientSplit` in the admin preview, so the gradient seam and the
  /// media seam land on exactly the same line.
  double get appBarFraction =>
      canvasHeight <= 0 ? 1 : (appBarHeight / canvasHeight).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      other is HeaderMediaLayout &&
      other.appBarHeight == appBarHeight &&
      other.bannerHeight == bannerHeight &&
      other.width == width &&
      other.parallaxFactor == parallaxFactor;

  @override
  int get hashCode => Object.hash(appBarHeight, bannerHeight, width, parallaxFactor);
}

/// Fill treatment of the CTA button.
enum HomeCtaStyle {
  solid,
  outline,
  ghost;

  static HomeCtaStyle parse(String? value) => HomeCtaStyle.values.firstWhere(
    (HomeCtaStyle style) => style.name == value?.trim().toLowerCase(),
    orElse: () => HomeCtaStyle.solid,
  );
}

@immutable
class HomePromoBannerSpec {
  /// Minimum fixed height accepted by the admin slider.
  static const double minHeight = 130.0;

  /// Maximum fixed height accepted by the admin slider.
  static const double maxHeight = 210.0;

  /// Default fixed height from the design boards.
  static const double defaultHeight = 170.0;

  /// Smallest zoom the admin preview will store. `1` is the untouched render.
  static const double minMediaScale = 1.0;

  /// Largest zoom the admin preview will store.
  static const double maxMediaScale = 3.0;

  /// 16:9 as used by horizontal banners.
  static const double horizontalAspectRatio = 16 / 9;

  /// 3:4 as used by vertical banners.
  static const double verticalAspectRatio = 3 / 4;

  /// Lower bound on fixed height.
  static const double minWidth = 1.0;

  // CTA appearance defaults. These mirror the API model's defaults and the `default`
  // preset in the admin, so a record saved before these fields existed renders exactly as
  // it did before they were added.
  static const double defaultCtaCornerRadius = 6;
  static const double defaultCtaFontSize = 12;
  static const double defaultCtaPaddingX = 14;
  static const double defaultCtaPaddingY = 9;
  static const double defaultCtaAnimationDuration = 1200;

  final String? id;
  final HomeHeaderBannerMedia media;
  final bool isVertical;
  final double? aspectRatio;
  final bool useFixedHeight;
  final double height;
  final String? mediaUrl;
  final String? image;
  final String? title;
  final String? subtitle;
  final String? ctaText;
  final String? ctaAction;
  final String? ctaTarget;
  final HeaderBannerCtaTarget? ctaTargetDetail;
  final String? deepLink;
  final bool enableOverlayText;

  /// Whether the CTA button is shown. Separate from `enableOverlayText` so the button
  /// can be turned off without also hiding the title and subtitle.
  final bool showCta;

  // CTA appearance. A null colour means "follow the app theme", which is how the button
  // looked before any of this was configurable.
  final HomeCtaStyle ctaStyle;
  final String? ctaBackgroundColor;
  final String? ctaTextColor;
  final double ctaCornerRadius;
  final double ctaFontSize;
  final double ctaPaddingX;
  final double ctaPaddingY;
  final bool ctaFullWidth;
  final bool ctaShowArrow;

  // CTA motion. Defaults to no motion and no loop - the button is above the fold on
  // every app open, so animation is opt-in.
  final HomeCtaAnimation ctaAnimation;
  final double ctaAnimationDuration;
  final bool ctaAnimationLoop;

  /// Paint the same media in the app bar as well as the banner slot.
  ///
  /// Off by default. When on, a Lottie banner mounts a second composition alongside the
  /// one in the slot - both are visible at once, so both tick - which is the deliberate
  /// cost of showing the same animation in both surfaces.
  final bool showMediaInAppBar;

  /// Whether the header media drifts more slowly than the surface as the page scrolls.
  ///
  /// Off by default. When on, [parallaxIntensity] sets how much of the header's own height
  /// the artwork may lag by, which keeps the effect proportionate on every screen size
  /// instead of being a fixed pixel distance that behaves differently on a phone and a
  /// tablet.
  final bool parallaxEnabled;
  final double parallaxIntensity;

  final int priority;
  final int displayDuration;
  final bool isActive;

  final bool lottieAutoPlay;
  final bool lottieLoop;
  final double lottieSpeed;
  final BoxFit lottieFit;
  final Alignment lottieAlignment;

  /// Manual nudge of the banner media, as a fraction of the banner box.
  ///
  /// Set by dragging the banner in the admin preview and stored as a fraction
  /// rather than pixels so the same value holds on every screen size. `(0, 0)`
  /// means no nudge, which leaves fit and alignment to decide the placement.
  final Offset mediaOffset;

  /// Nudge of the title/subtitle block. Same fraction-of-banner units as [mediaOffset],
  /// but a separate pair: cropping the artwork must not drag the copy with it.
  final Offset overlayOffset;

  /// Nudge of the CTA button. Independent of both [mediaOffset] and [overlayOffset].
  final Offset ctaOffset;

  /// Zoom applied to the media layer, on top of fit, alignment and the nudge.
  ///
  /// `1` is the untouched render. Anything higher crops into the artwork the way a
  /// design tool's scale handle does, which is how an operator decides what part of
  /// a wide image a 16:9 slot actually shows. Unitless, so it means the same thing
  /// on a phone and on a tablet.
  final double mediaScale;

  const HomePromoBannerSpec({
    this.id,
    this.media = HomeHeaderBannerMedia.image,
    this.isVertical = false,
    this.aspectRatio,
    this.useFixedHeight = false,
    this.height = defaultHeight,
    this.mediaUrl,
    this.image,
    this.title,
    this.subtitle,
    this.ctaText,
    this.ctaAction,
    this.ctaTarget,
    this.ctaTargetDetail,
    this.deepLink,
    this.enableOverlayText = true,
    this.showCta = true,
    this.ctaStyle = HomeCtaStyle.solid,
    this.ctaBackgroundColor,
    this.ctaTextColor,
    this.ctaCornerRadius = defaultCtaCornerRadius,
    this.ctaFontSize = defaultCtaFontSize,
    this.ctaPaddingX = defaultCtaPaddingX,
    this.ctaPaddingY = defaultCtaPaddingY,
    this.ctaFullWidth = false,
    this.ctaShowArrow = true,
    this.ctaAnimation = HomeCtaAnimation.none,
    this.ctaAnimationDuration = defaultCtaAnimationDuration,
    this.ctaAnimationLoop = false,
    this.showMediaInAppBar = false,
    this.parallaxEnabled = false,
    this.parallaxIntensity = 0.18,
    this.priority = 999,
    this.displayDuration = 5,
    this.isActive = true,
    this.lottieAutoPlay = true,
    this.lottieLoop = true,
    this.lottieSpeed = 1.0,
    this.lottieFit = BoxFit.cover,
    this.lottieAlignment = Alignment.center,
    this.mediaOffset = Offset.zero,
    this.overlayOffset = Offset.zero,
    this.ctaOffset = Offset.zero,
    this.mediaScale = 1.0,
  });

  /// Whether any renderable media is present.
  bool get hasMedia => _isFilled(mediaUrl) || _isFilled(image);

  /// Whether the banner content block should be painted.
  ///
  /// Only the title and subtitle. The CTA button is deliberately NOT folded in here:
  /// it has its own switch, so turning the content off must not take the button with it.
  bool get hasOverlayText => enableOverlayText && (_isFilled(title) || _isFilled(subtitle));

  /// Whether the CTA should be painted. Independent of [hasOverlayText].
  bool get hasCta => showCta && _isFilled(ctaText);

  /// Aspect ratio, falling back to the orientation default.
  double get resolvedAspectRatio {
    if (aspectRatio != null && aspectRatio! > 0) return aspectRatio!;
    return isVertical ? verticalAspectRatio : horizontalAspectRatio;
  }

  /// The height to paint.
  ///
  /// [availableWidth] is only consulted in responsive mode.
  double resolveHeight(double availableWidth) {
    if (useFixedHeight) return height.clamp(minHeight, maxHeight);
    if (availableWidth < minWidth) return defaultHeight;
    return availableWidth / resolvedAspectRatio;
  }

  /// Whether the banner should navigate anywhere when tapped.
  bool get hasTapTarget => hasCta || _isFilled(deepLink) || _isFilled(ctaTarget);

  static bool _isFilled(String? value) => value != null && value.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    return other is HomePromoBannerSpec &&
        other.id == id &&
        other.media == media &&
        other.isVertical == isVertical &&
        other.aspectRatio == aspectRatio &&
        other.useFixedHeight == useFixedHeight &&
        other.height == height &&
        other.mediaUrl == mediaUrl &&
        other.image == image &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.ctaText == ctaText &&
        other.ctaAction == ctaAction &&
        other.ctaTarget == ctaTarget &&
        other.ctaTargetDetail == ctaTargetDetail &&
        other.deepLink == deepLink &&
        other.enableOverlayText == enableOverlayText &&
        other.showCta == showCta &&
        other.ctaStyle == ctaStyle &&
        other.ctaBackgroundColor == ctaBackgroundColor &&
        other.ctaTextColor == ctaTextColor &&
        other.ctaCornerRadius == ctaCornerRadius &&
        other.ctaFontSize == ctaFontSize &&
        other.ctaPaddingX == ctaPaddingX &&
        other.ctaPaddingY == ctaPaddingY &&
        other.ctaFullWidth == ctaFullWidth &&
        other.ctaShowArrow == ctaShowArrow &&
        other.ctaAnimation == ctaAnimation &&
        other.ctaAnimationDuration == ctaAnimationDuration &&
        other.ctaAnimationLoop == ctaAnimationLoop &&
        other.showMediaInAppBar == showMediaInAppBar &&
        other.priority == priority &&
        other.displayDuration == displayDuration &&
        other.isActive == isActive &&
        other.lottieAutoPlay == lottieAutoPlay &&
        other.lottieLoop == lottieLoop &&
        other.lottieSpeed == lottieSpeed &&
        other.lottieFit == lottieFit &&
        other.lottieAlignment == lottieAlignment &&
        other.mediaOffset == mediaOffset &&
        other.overlayOffset == overlayOffset &&
        other.ctaOffset == ctaOffset &&
        other.mediaScale == mediaScale;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    id,
    media,
    isVertical,
    aspectRatio,
    useFixedHeight,
    height,
    mediaUrl,
    image,
    title,
    subtitle,
    ctaText,
    ctaAction,
    ctaTarget,
    ctaTargetDetail,
    deepLink,
    enableOverlayText,
    showCta,
    ctaStyle,
    ctaBackgroundColor,
    ctaTextColor,
    ctaCornerRadius,
    ctaFontSize,
    ctaPaddingX,
    ctaPaddingY,
    ctaFullWidth,
    ctaShowArrow,
    ctaAnimation,
    ctaAnimationDuration,
    ctaAnimationLoop,
    showMediaInAppBar,
    priority,
    displayDuration,
    isActive,
    lottieAutoPlay,
    lottieLoop,
    lottieSpeed,
    lottieFit,
    lottieAlignment,
    mediaOffset,
    overlayOffset,
    ctaOffset,
    mediaScale,
  ]);
}
