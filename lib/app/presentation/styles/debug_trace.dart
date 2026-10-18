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

import 'package:flutter/foundation.dart';

/// Temporary diagnostic tracing, added to chase down silent media failures.
///
/// Every call is compiled out of release builds unless the app is launched with
/// `--dart-define=LOCALWALA_TRACE=true`, so this is safe to leave in place while
/// chasing a bug and is a no-op for real users.
///
/// Output goes through [debugPrint] rather than `dart:developer` on purpose.
/// `developer.log` is silently swallowed by `flutter run` on a physical device,
/// which makes a trace that "is logging" look identical to one that never ran.
class DebugTrace {
  /// Set with `--dart-define=LOCALWALA_TRACE=true` to keep tracing in a profile build.
  static const bool _forced = bool.fromEnvironment('LOCALWALA_TRACE');

  static bool get enabled => kDebugMode || _forced;

  static void log(String tag, String message) {
    if (!enabled) return;
    debugPrint('>> [$tag] $message');
  }

  static void error(String tag, Object error, StackTrace? stackTrace, {String? context}) {
    if (!enabled) return;
    debugPrint('>> [$tag] !! ${context == null ? 'failed' : '$context: FAILED'}');
    debugPrint('>> [$tag] !! $error');
    if (stackTrace != null) {
      // Truncated: these come from the http/json layer and are enormous, and the
      // first frames are the ones that identify the failure.
      debugPrint('>> [$tag] !! ${stackTrace.toString().split('\n').take(12).join('\n')}');
    }
  }
}

/// Tracing tag for the header banner media pipeline (image + Lottie).
const String kBannerMediaTrace = 'BannerMedia';