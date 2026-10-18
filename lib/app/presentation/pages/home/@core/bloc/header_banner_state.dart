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

part of 'header_banner_bloc.dart';

enum HeaderBannerStatus { loading, ready, empty, failure }

extension HeaderBannerStatusX on HeaderBannerStatus {
  bool get isLoading => this == HeaderBannerStatus.loading;
  bool get isReady => this == HeaderBannerStatus.ready;
  bool get isEmpty => this == HeaderBannerStatus.empty;
  bool get isFailure => this == HeaderBannerStatus.failure;
}

final class HeaderBannerState {
  /// Resolved banners, ordered by priority. Empty means "render nothing".
  final List<HomePromoBannerSpec> specs;

  /// Resolved silver app bar configuration. `null` means "render exactly as today".
  final HomeAppBarTheme? headerTheme;

  final HeaderBannerStatus status;
  final String alertMessage;

  const HeaderBannerState({this.specs = const [], this.headerTheme, this.status = HeaderBannerStatus.loading, this.alertMessage = ''});

  bool get hasBanners => specs.isNotEmpty;

  bool get hasHeaderTheme => headerTheme != null && headerTheme!.hasDecoration;

  HeaderBannerState copyWith({List<HomePromoBannerSpec>? specs, HomeAppBarTheme? headerTheme, HeaderBannerStatus? status, String? alertMessage}) {
    return HeaderBannerState(specs: specs ?? this.specs, headerTheme: headerTheme ?? this.headerTheme, status: status ?? this.status, alertMessage: alertMessage ?? this.alertMessage);
  }
}
