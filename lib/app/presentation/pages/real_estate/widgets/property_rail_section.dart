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

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_card.dart';

/// Reusable "rail" of property cards — a title row + a horizontal
/// scroller. This is the building block for every "popular /
/// recently added / premium / affordable" section on the real estate
/// home page, so the visual rhythm stays the same as the food module.
///
/// All data comes from props. Loading / error / empty are explicit
/// states; the parent owns the fetch. Each card opens the same
/// [PropertyDetailScreen].
class PropertyRailSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isLoading;
  final String? error;
  final List<PropertyModel> items;
  final VoidCallback? onSeeAll;
  final double cardHeight;
  final double cardWidth;

  const PropertyRailSection({
    super.key,
    required this.title,
    required this.items,
    this.subtitle,
    this.isLoading = false,
    this.error,
    this.onSeeAll,
    this.cardHeight = 240,
    this.cardWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(subtitle!,
                          style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(AppLocalizations.of(context)!.re_see_all),
                ),
            ],
          ),
        ),
        if (isLoading)
          _SkeletonRow(cardHeight: cardHeight, cardWidth: cardWidth)
        else if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          )
        else if (items.isEmpty)
          const SizedBox.shrink()
        else
          SizedBox(
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = items[i];
                return SizedBox(
                  width: cardWidth,
                  child: PropertyCard(
                    property: p,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(propertyId: p.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  const _SkeletonRow({required this.cardHeight, required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}
