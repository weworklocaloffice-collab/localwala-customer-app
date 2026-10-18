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

import 'package:bloc/bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:user/app/core/models/home_response_model.dart';
import 'package:user/app/presentation/pages/home/@core/widgets/home_promo_banner_model.dart';
import 'package:user/app/presentation/styles/debug_trace.dart';
import 'package:user/app/presentation/styles/theme.dart';

part 'header_banner_event.dart';
part 'header_banner_state.dart';

/// Resolves which promotional banner - if any - owns the home header.
///
/// The bloc consumes the single `headerBanner` the server already resolved for the
/// customer, so pull-to-refresh refetches the header configuration in the same round
/// trip as the home feed. City scope, schedule window, status and priority are all
/// applied server side.
///
/// When no banner resolves the bloc reports an empty result and the app bar keeps
/// rendering exactly as it does today.
class HeaderBannerBloc extends Bloc<HeaderBannerEvent, HeaderBannerState> {
  HeaderBannerBloc() : super(const HeaderBannerState()) {
    on<HeaderBannerInitialEvent>(_onHeaderBannerInitialEvent);
    on<HeaderBannerUpdatedEvent>(_onHeaderBannerUpdatedEvent);
  }

  void _onHeaderBannerInitialEvent(HeaderBannerInitialEvent event, Emitter<HeaderBannerState> emit) {
    emit(state.copyWith(status: HeaderBannerStatus.ready));
  }

  void _onHeaderBannerUpdatedEvent(HeaderBannerUpdatedEvent event, Emitter<HeaderBannerState> emit) {
    try {
      final HeaderBannerModel? banner = event.headerBanner;

      if (banner == null) {
        emit(const HeaderBannerState(status: HeaderBannerStatus.empty));
        return;
      }

      final HomePromoBannerSpec spec = _toSpec(banner);

      if (!spec.isActive || !spec.hasMedia) {
        emit(const HeaderBannerState(status: HeaderBannerStatus.empty));
        return;
      }

      emit(HeaderBannerState(status: HeaderBannerStatus.ready, specs: <HomePromoBannerSpec>[spec], headerTheme: _toAppBarTheme(banner)));
    } catch (error, stackTrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: 'HeaderBannerBloc.updated');
      }
      // Fall back to today's header rather than surfacing an error to the customer.
      emit(const HeaderBannerState(status: HeaderBannerStatus.empty));
    }
  }

  /// Maps the server payload onto the banner view model.
  HomePromoBannerSpec _toSpec(HeaderBannerModel banner) {
    DebugTrace.log(
      kBannerMediaTrace,
      'API payload media="${banner.media}" mediaUrl="${banner.mediaUrl}" image="${banner.image}" '
      'lottieAutoPlay=${banner.lottieAutoPlay} lottieLoop=${banner.lottieLoop} lottieSpeed=${banner.lottieSpeed} '
      'lottieFit=${banner.lottieFit} lottieAlignment=${banner.lottieAlignment}',
    );
    return HomePromoBannerSpec(
      id: banner.id,
      media: HomeHeaderBannerMedia.fromType(banner.media),
      isVertical: banner.orientation?.trim().toLowerCase() == 'vertical',
      aspectRatio: banner.aspectRatio,
      useFixedHeight: banner.heightMode?.trim().toLowerCase() == 'fixed',
      height: banner.maxHeight ?? HomePromoBannerSpec.defaultHeight,
      mediaUrl: banner.mediaUrl,
      image: banner.image,
      title: banner.title,
      subtitle: banner.subtitle,
      ctaText: banner.ctaText,
      ctaAction: banner.ctaAction,
      ctaTarget: banner.ctaTarget,
      ctaTargetDetail: banner.ctaTargetDetail,
      deepLink: banner.deepLink,
      enableOverlayText: banner.enableOverlayText ?? true,
      showCta: banner.showCta ?? true,
      ctaStyle: _readCtaStyle(banner.ctaStyle),
      ctaBackgroundColor: _readHex(banner.ctaBackgroundColor),
      ctaTextColor: _readHex(banner.ctaTextColor),
      ctaCornerRadius: _readCtaNumber(
        banner.ctaCornerRadius,
        HomePromoBannerSpec.defaultCtaCornerRadius,
        0,
        999,
      ),
      ctaFontSize: _readCtaNumber(
        banner.ctaFontSize,
        HomePromoBannerSpec.defaultCtaFontSize,
        10,
        24,
      ),
      ctaPaddingX: _readCtaNumber(
        banner.ctaPaddingX,
        HomePromoBannerSpec.defaultCtaPaddingX,
        0,
        40,
      ),
      ctaPaddingY: _readCtaNumber(
        banner.ctaPaddingY,
        HomePromoBannerSpec.defaultCtaPaddingY,
        0,
        40,
      ),
      ctaFullWidth: banner.ctaFullWidth ?? false,
      ctaShowArrow: banner.ctaShowArrow ?? true,
      ctaAnimation: _readCtaAnimation(banner.ctaAnimation),
      ctaAnimationDuration: _readCtaNumber(
        banner.ctaAnimationDuration,
        HomePromoBannerSpec.defaultCtaAnimationDuration,
        200,
        5000,
      ),
      ctaAnimationLoop: banner.ctaAnimationLoop ?? false,
      priority: banner.priority ?? 999,
      displayDuration: banner.displayDuration ?? 5,
      isActive: true,
      lottieAutoPlay: banner.lottieAutoPlay ?? true,
      lottieLoop: banner.lottieLoop ?? true,
      lottieSpeed: banner.lottieSpeed ?? 1.0,
      lottieFit: _readFit(banner.lottieFit),
      lottieAlignment: _readAlignment(banner.lottieAlignment),
      mediaOffset: _readOffset(banner.mediaOffsetX, banner.mediaOffsetY),
      overlayOffset: _readOffset(banner.overlayOffsetX, banner.overlayOffsetY),
      ctaOffset: _readOffset(banner.ctaOffsetX, banner.ctaOffsetY),
      mediaScale: _readScale(banner.mediaScale),
    );
  }

  /// Reads the admin's zoom, clamped to the range the admin stores.
  ///
  /// A payload outside the clamp means an older or hand-edited record, so it is
  /// pulled back to a legal zoom rather than trusted - and anything below `1` would
  /// shrink the artwork out of its frame, which is never what a saved banner wants.
  static double _readScale(double? value) {
    if (value == null || !value.isFinite) return 1.0;
    return value.clamp(HomePromoBannerSpec.minMediaScale, HomePromoBannerSpec.maxMediaScale);
  }

  /// Reads the admin's drag placement, clamped to the range the admin stores.
  ///
  /// A payload outside the clamp means an older or hand-edited record, so it is
  /// pulled back to a legal nudge rather than trusted, and `(0, 0)` means "no
  /// nudge" so fit and alignment keep deciding the placement.
  static Offset _readOffset(double? x, double? y) {
    const double limit = 0.5;
    double clamp(double? value) {
      if (value == null || !value.isFinite) return 0;
      return value.clamp(-limit, limit);
    }

    return Offset(clamp(x), clamp(y));
  }

  /// Reads a numeric CTA setting, clamped to the range the admin stores.
  ///
  /// Same defensive posture as [_readOffset]: a payload outside the range means an older
  /// or hand-edited record, so it is pulled back to a legal value rather than trusted.
  static double _readCtaNumber(double? value, double fallback, double min, double max) {
    if (value == null || !value.isFinite) return fallback;
    return value.clamp(min, max);
  }

  /// Unknown fill styles fall back to `solid` - the rendering the app used before the
  /// field existed, so a bad value degrades to today's button rather than to nothing.
  static HomeCtaStyle _readCtaStyle(String? value) => HomeCtaStyle.parse(value);

  static HomeCtaAnimation _readCtaAnimation(String? value) =>
      HomeCtaAnimation.parse(value);

  /// Accepts `#RGB` and `#RRGGBB`; anything else reads as "no override".
  static String? _readHex(String? value) {
    if (value == null) return null;
    String hex = value.trim().toUpperCase().replaceAll('#', '');
    if (hex.length == 3) {
      hex = hex.split('').map((String c) => '$c$c').join();
    }
    if (hex.length != 6 || !RegExp(r'^[0-9A-F]{6}$').hasMatch(hex)) return null;
    return '#$hex';
  }

  /// Builds the app bar configuration from the resolved banner.
  ///
  /// In [HomeHeaderBackgroundMode.auto] the colour is taken from the configured colour
  /// or the extracted palette. When neither is available no colour is applied, which
  /// leaves the ambient app bar untouched.
  HomeAppBarTheme? _toAppBarTheme(HeaderBannerModel banner) {
    final HomeHeaderBackgroundMode mode = HomeHeaderBackgroundMode.values.firstWhere(
      (HomeHeaderBackgroundMode value) => value.name == banner.appBarBackgroundMode?.trim().toLowerCase(),
      orElse: () => HomeHeaderBackgroundMode.auto,
    );

    Color? autoColor;
    if (mode == HomeHeaderBackgroundMode.auto) {
      autoColor = HomeAppBarTheme.parseHexColor(banner.appBarBackgroundColor) ?? HomeAppBarTheme.parseHexPalette(banner.extractedColors).firstOrNull;
    }

    final HomeAppBarTheme theme = HomeAppBarTheme(
      backgroundMode: mode,
      backgroundColor: mode == HomeHeaderBackgroundMode.manual ? HomeAppBarTheme.parseHexColor(banner.appBarBackgroundColor) : autoColor,
      gradientFrom: HomeAppBarTheme.parseHexColor(banner.appBarGradientFrom),
      gradientTo: HomeAppBarTheme.parseHexColor(banner.appBarGradientTo),
      extractedPalette: HomeAppBarTheme.parseHexPalette(banner.extractedColors),
      collapsedHeight: banner.collapsedHeight ?? ThemeProvider.homeHeaderCollapsedHeight,
      showLocation: banner.showLocation ?? true,
      showLanguageSelector: banner.showLanguageSelector ?? true,
      showNotificationIcon: banner.showNotificationIcon ?? true,
    );
    _traceTheme(banner, theme);
    return theme;
  }

  /// Reports why the app bar and the banner band do or do not agree.
  ///
  /// `decoration` is what both actually paint. When it is null the app bar falls
  /// back to the ambient Material theme while the band falls back to
  /// [ThemeProvider.homeHeaderBackgroundColor], so the two diverge. This prints
  /// the raw payload alongside the resolved result so a mismatch can be read
  /// straight off the log instead of inferred.
  void _traceTheme(HeaderBannerModel banner, HomeAppBarTheme theme) {
    if (!DebugTrace.enabled) return;
    DebugTrace.log(
      kBannerMediaTrace,
      'appbar RAW mode="${banner.appBarBackgroundMode}" colour="${banner.appBarBackgroundColor}" '
      'gradientFrom="${banner.appBarGradientFrom}" gradientTo="${banner.appBarGradientTo}" '
      'palette=${banner.extractedColors}',
    );
    DebugTrace.log(
      kBannerMediaTrace,
      'appbar RESOLVED mode=${theme.backgroundMode.name} isGradient=${theme.isGradient} '
      'isSolid=${theme.isSolid} hasDecoration=${theme.hasDecoration} '
      'decoration=${theme.decoration == null ? 'NULL -> app bar paints the ambient Material theme, banner paints #FFE6D3, THEY DIFFER' : theme.decoration.toString()}',
    );
  }

  static BoxFit _readFit(String? value) {
    return BoxFit.values.firstWhere((BoxFit fit) => fit.name == value?.trim().toLowerCase(), orElse: () => BoxFit.cover);
  }

  static Alignment _readAlignment(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'topleft' => Alignment.topLeft,
      'topcenter' => Alignment.topCenter,
      'topright' => Alignment.topRight,
      'centerleft' => Alignment.centerLeft,
      'centerright' => Alignment.centerRight,
      'bottomleft' => Alignment.bottomLeft,
      'bottomcenter' => Alignment.bottomCenter,
      'bottomright' => Alignment.bottomRight,
      _ => Alignment.center,
    };
  }
}
