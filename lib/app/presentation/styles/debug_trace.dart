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
/// Tracing stays ON by default so a bug this visual can actually be observed.
  /// Once the seam is fixed this should go back behind a dart-define.
class DebugTrace {
  /// Set with `--dart-define=LOCALWALA_TRACE=false` to silence tracing.
  static const bool _off = bool.fromEnvironment('LOCALWALA_TRACE');

  static bool get enabled => !_off;

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