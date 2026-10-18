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

sealed class HeaderBannerEvent {}

/// Fired once when the header is first needed.
final class HeaderBannerInitialEvent extends HeaderBannerEvent {}

/// Fired whenever a fresh home response arrives, including on pull-to-refresh.
///
/// [headerBanner] is `null` when the server resolved no banner, which is the
/// signal to render the default header.
final class HeaderBannerUpdatedEvent extends HeaderBannerEvent {
  final HeaderBannerModel? headerBanner;

  HeaderBannerUpdatedEvent({required this.headerBanner});
}
