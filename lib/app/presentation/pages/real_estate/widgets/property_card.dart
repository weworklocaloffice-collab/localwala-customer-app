/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Compact property card used in search results, home feed and similar
/// lists. Mirrors the food module's restaurant card so the visual
/// language is consistent across verticals.
class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  /// Optional long-press handler. Used by the saved-properties screen
  /// to expose "unsave" via long-press, since there is no extra
  /// trailing icon to host a delete button.
  final VoidCallback? onLongPress;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    final cover = property.media.isNotEmpty ? property.media.first : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: cover != null
                  ? CachedNetworkImage(
                      imageUrl: cover,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: theme.dividerColor),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.dividerColor,
                        child: const Icon(Icons.apartment, size: 32),
                      ),
                    )
                  : Container(
                      color: theme.dividerColor,
                      child: const Icon(Icons.apartment, size: 32),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (property.verified) ...[
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          translate.propertyTitle(property),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    translate.propertyPrice(property),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (property.area != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        translate.re_area_sqft(
                          property.area!.toStringAsFixed(0),
                        ),
                        if (property.bedrooms != null)
                          translate.re_bhk(property.bedrooms!),
                        if (property.bathrooms != null)
                          translate.re_bath(property.bathrooms!),
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (property.locality != null || property.city != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [property.locality, property.city]
                                .where(
                                  (e) => e != null && e.toString().isNotEmpty,
                                )
                                .join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
