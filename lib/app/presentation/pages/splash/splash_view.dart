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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:user/app/core/config/assets_url.dart';
import 'package:user/app/presentation/pages/location/@core/location_view.dart';
import 'package:user/app/presentation/pages/splash/bloc/splash_bloc.dart';
import 'package:user/app/presentation/pages/tabs/tabs_view.dart';
import 'package:user/app/presentation/styles/app_localization/app_localization_bloc.dart';
import 'package:user/app/presentation/styles/force_update_dialog.dart';
import 'package:user/app/router/app_route_config.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashView();
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  static const String _splashAnimation = 'assets/jsons/splash.json';

  // The animation uses near-white wordmark and pale-blue streaks, so it needs a
  // constant dark backdrop in both themes; keep the native launch screens in sync.
  static const Color _splashBackground = Color(0xFF0B0F1E);

  // The 16:9 composition already spans full screen width; scaling up makes it
  // taller and crops the side streaks off-screen. Tune to taste (1.0 = max no-crop).
  static const double _splashAnimationScale = 1.3;

  // Exit choreography: once the pin settles, the whole splash zooms into it and
  // fades while the destination fades/scales in beneath — a continuous reveal
  // instead of a hard cut. The destination route is pushed at the zoom midpoint
  // so both motions overlap.
  static const Duration _exitDuration = Duration(milliseconds: 420);
  static const double _exitHandoff = 0.45;

  late final AnimationController _animationController;
  late final AnimationController _exitController;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitFade;
  Timer? _safetyTimer;
  SplashState? _pendingState;
  bool _animationFinished = false;
  bool _navigated = false;
  bool _exitStarted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _animationController.addStatusListener(_onAnimationStatus);
    _exitController = AnimationController(vsync: this, duration: _exitDuration);
    _exitScale = Tween<double>(begin: 1, end: 1.4)
        .animate(CurvedAnimation(parent: _exitController, curve: const Interval(0, 0.85, curve: Curves.easeOutCubic)));
    _exitFade = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _exitController, curve: const Interval(0.15, 0.9, curve: Curves.easeOut)));
    _exitController.addListener(_onExitTick);
    // The animation is the minimum display time; never let a broken asset trap the user here.
    _safetyTimer = Timer(const Duration(seconds: 10), () {
      _animationFinished = true;
      _maybeNavigate();
    });
    context.read<SplashBloc>().add(SplashInitialEvent());
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _animationController.removeStatusListener(_onAnimationStatus);
    _animationController.dispose();
    _exitController.removeListener(_onExitTick);
    _exitController.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _safetyTimer?.cancel();
    _animationFinished = true;
    _maybeNavigate();
  }

  void _handleState(SplashState state) {
    if (_navigated) return;
    if (state.status.isAppLocale) {
      context.read<AppLocalizationBloc>().add(ChangeAppLocalizationEvent(defaultLanguage: state.appLocale));
    } else if (state.status.isForceUpdate) {
      ForceUpdateDialogService.showUpdateDialog(context, state.newUpdateVersion, state.versionUpdateUrl);
    } else if (state.status.isFailure || state.status.isMaintenance || state.status.isConnectionError) {
      // Error destinations cut straight through — no ceremony into a failure screen.
      _navigate(state);
    } else {
      // Happy-path destinations wait until the animation has played out.
      _pendingState = state;
      _maybeNavigate();
    }
  }

  void _maybeNavigate() {
    if (_navigated || !_animationFinished || _pendingState == null || !mounted) return;
    if (_pendingState!.status.isHome || _pendingState!.status.isLocation) {
      _startExitZoom();
    } else {
      _navigate(_pendingState!);
    }
  }

  void _startExitZoom() {
    if (_exitStarted) return;
    _exitStarted = true;
    _exitController.forward();
  }

  void _onExitTick() {
    if (_navigated || _pendingState == null) return;
    if (_exitController.value >= _exitHandoff) {
      _navigate(_pendingState!);
    }
  }

  void _navigate(SplashState state) {
    _navigated = true;
    if (state.status.isIntro) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.welcomeRoute, (Route<dynamic> route) => false);
    } else if (state.status.isUnAuthorized) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.loginRoute, (Route<dynamic> route) => false);
    } else if (state.status.isHome) {
      Navigator.of(context).pushAndRemoveUntil(
        _revealRoute(AppBottomTabScreen(tabIndex: 0)),
        (Route<dynamic> route) => false,
      );
    } else if (state.status.isLocation) {
      Navigator.of(context).pushAndRemoveUntil(
        _revealRoute(const LocationScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (state.status.isFailure) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.serverErrorRoute, (Route<dynamic> route) => false);
    } else if (state.status.isMaintenance) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.maintenanceRoute, (Route<dynamic> route) => false, arguments: [state.businessEmail, state.businessMobile]);
    } else if (state.status.isConnectionError) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.internetConnectionRoute, (Route<dynamic> route) => false);
    }
  }

  /// Entrance that overlaps the splash's exit zoom: the page fades in while
  /// settling from a slight scale-down, so it reads as materializing beneath.
  PageRouteBuilder<void> _revealRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final Animation<double> curved = animation.drive(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  void _skipAnimation() {
    if (_animationFinished || _animationController.duration == null) return;
    _animationController.animateTo(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashBloc, SplashState>(
      listener: (context, state) => _handleState(state),
      builder: (context, state) {
        return FadeTransition(
          opacity: _exitFade,
          child: ScaleTransition(
            scale: _exitScale,
            child: Scaffold(
              backgroundColor: _splashBackground,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _skipAnimation,
                  child: Center(
                    child: Transform.scale(
                      scale: _splashAnimationScale,
                      child: Lottie.asset(
                        _splashAnimation,
                        controller: _animationController,
                        repeat: false,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        onLoaded: (composition) {
                          if (!mounted) return;
                          _animationController
                            ..duration = composition.duration
                            ..forward();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Splash lottie failed to load: $error');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _animationFinished = true;
                            _maybeNavigate();
                          });
                          return Image.asset(AssetsUrl.imageURL.splashIcon, height: 70, width: 70, fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
