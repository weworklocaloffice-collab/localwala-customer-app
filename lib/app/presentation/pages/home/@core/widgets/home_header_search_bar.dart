/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Ac 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * This source code, including its associated assets, APIs, databases, business logic,
 * designs, and documentation, is proprietary and confidential to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale, mirroring,
 * reverse engineering, or use of this software, in whole or in part, without explicit
 * written authorization from the copyright holder, is strictly prohibited.
 */

import 'package:flutter/material.dart';
import 'package:user/app/presentation/styles/app_style.dart';
import 'package:user/app/presentation/styles/theme.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// The home header's search field.
///
/// It used to live in [AppBar.bottom], which made it the only part of the app bar that
/// changed size. Everything difficult about that header followed from it: the slot had to
/// be clamped so an `OverflowBox` could not resolve to `Infinity` at the end of a fold,
/// and the media canvas had to be re-measured every frame to take the same 55px off both
/// the app bar's slice and the banner's, or a hole opened along the seam. Sizing the app
/// bar itself is what keeps those in step - not arithmetic that has to remember to agree.
///
/// Here it sits on its own, below the promotional banner, on a clean surface rather than
/// floated over artwork.
class HomeHeaderSearchBar extends StatelessWidget {
  /// Height reserved for the field.
  static const double height = 55.0;

  const HomeHeaderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      // Full width: this sits in a `Column`, which defaults to
      // `CrossAxisAlignment.center` and lays non-flex children out with loose
      // constraints, so an unset width collapses the field to its label.
      width: double.infinity,
      height: height,
      child: Padding(
        // Vertical padding only. Padding on all four sides ate into the fixed 55px, so the
        // field itself was left with far less room than the row needed and the text sat
        // cramped. The outer box already reserves the height; this only insets the pill.
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeProvider.scaffoldPadding,
          vertical: 4,
        ),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context).pushNamed(AppRouter.searchRoute),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                // `outlineVariant`, not `surface`. The border used to be painted in the
                // very colour it sits on, so on a light theme it was all but invisible
                // and the field read as floating text with no field around it.
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Row(
                // Explicit: an unaligned `Row` centres its children at the top, which
                // pushed the icon and label out of line with each other.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  // `Expanded` so a long localised label ellipsises instead of
                  // overflowing the pill.
                  Expanded(
                    child: Text(
                      translate.home_search_bar,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: kAppLblMediumFontMediumGrey(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}