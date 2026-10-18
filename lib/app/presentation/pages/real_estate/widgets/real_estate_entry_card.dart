/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 *
 * This source code is proprietary to WeWorkLocal.
 */

import 'package:flutter/material.dart';

import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Real Estate "entry row" widget — renders a single tappable card
/// labelled "Properties" alongside the food categories. Mirrors the
/// food module's `categories_grid` visual style. Tapping it opens the
/// real estate search screen (router: reSearchRoute).
///
/// **Wiring** (plan §14.1 entry point, pending business-owner decision):
///   • Option A — embed as an extra tab (would require moving tabs from
///     6 to 7, currently capped at 6 by the plan).
///   • Option B — vertical picker on the welcome/home screen (current
///     safe default; this widget fits either).
///   • The widget itself is route-agnostic; only the place that pushes
///     the route changes between options. Use `onTap` override if you
///     want a custom entry.
class RealEstateEntryCard extends StatefulWidget {
  final VoidCallback? onTap;

  const RealEstateEntryCard({super.key, this.onTap});

  @override
  State<RealEstateEntryCard> createState() => _RealEstateEntryCardState();
}

class _RealEstateEntryCardState extends State<RealEstateEntryCard> {
  final _repo = RealEstateRepository();
  int _count = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final cats = await _repo.listCategories();
      if (!mounted) return;
      setState(() {
        _count = cats.fold<int>(0, (sum, c) => sum + c.count);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onPressed() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    Navigator.of(context).pushNamed(AppRouter.reSearchRoute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: Icon(Icons.apartment, color: theme.colorScheme.onPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.re_search_title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _loading
                        ? 'Browse — Buy or Rent'
                        : '$_count listings • Buy or Rent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onPrimaryContainer),
            IconButton(
              icon: Icon(Icons.favorite, color: theme.colorScheme.onPrimaryContainer),
              tooltip: AppLocalizations.of(context)!.re_saved_tooltip,
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.reSavedPropertiesRoute),
            ),
          ],
        ),
      ),
    );
  }
}
