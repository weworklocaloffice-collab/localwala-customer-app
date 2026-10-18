/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Local Stores entry card — how a customer gets INTO the vertical.
///
/// Modelled on `RealEstateEntryCard`: a new vertical gets a card in the home column
/// rather than a new bottom tab, which is plan §14.1 Option B. Without this card the whole
/// stores feature is unreachable — its routes are registered, but nothing navigates to
/// them, so it would ship as dead code.
///
/// The subtitle is the number of outlets the SERVER returned, not a marketing phrase. A
/// failed or empty call says so rather than inventing a count.
///
/// Coordinates come from `LocationRepository`, where the app already keeps the position the
/// customer chose for delivery. This adds no geolocator dependency: the vertical reuses
/// the location the user already set rather than prompting for a second one.
class StoresEntryCard extends StatefulWidget {
  const StoresEntryCard({super.key, this.onTap, this.service, this.location});

  /// Override the destination, for a host that wants to push a pre-filtered storefront.
  final VoidCallback? onTap;

  /// Injectable for widget tests; omitted in the app.
  final StoresCustomerService? service;
  final LocationRepository? location;

  @override
  State<StoresEntryCard> createState() => _StoresEntryCardState();
}

class _StoresEntryCardState extends State<StoresEntryCard> {
  late final StoresCustomerService _stores;
  late final LocationRepository _location;

  bool _loading = true;
  bool _hasLocation = false;
  double? _lat;
  double? _lng;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _stores = widget.service ?? StoresCustomerService();
    _location = widget.location ?? LocationRepository();
    _load();
  }

  Future<void> _load() async {
    // `haveLocation` is checked FIRST because `userLatitude()` returns 0 — not null —
    // when unset, so a bare 0.0 is indistinguishable from a real position and would send
    // a nonsense point to `/nearby`.
    final bool has = await _location.haveLocation();
    if (!mounted) return;
    if (!has) {
      setState(() => _loading = false);
      return;
    }

    final double lat = await _location.userLatitude();
    final double lng = await _location.userLongitude();
    if (!mounted) return;
    setState(() {
      _hasLocation = true;
      _lat = lat;
      _lng = lng;
    });

    try {
      final response = await _stores.nearby(lat: lat, lng: lng);
      if (!mounted) return;
      if (!response.success) {
        setState(() => _loading = false);
        return;
      }
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final List? outlets = body['outlets'] as List?;
      if (!mounted) return;
      setState(() {
        _count = outlets?.length ?? 0;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onPressed() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    // `GET /nearby` requires both coordinates and 400s without them, so with no position
    // the storefront is pushed empty and shows its own "add an address" state rather than
    // firing a request known to fail.
    Navigator.of(context).pushNamed(
      AppRouter.storesHomeRoute,
      arguments: _hasLocation ? <dynamic>[_lat, _lng] : <dynamic>[],
    );
  }

  String _subtitle(AppLocalizations l10n) {
    if (_loading) return l10n.stores_entry_subtitle;
    if (!_hasLocation) return l10n.stores_set_location_prompt;
    return l10n.stores_near_you(_count);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: _onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.storefront, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.stores_entry_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onPrimaryContainer),
            IconButton(
              tooltip: l10n.stores_search_hint,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.storesSearchRoute);
              },
              icon: Icon(Icons.search, color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}