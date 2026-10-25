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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Compact horizontal card for the featured carousel — narrower than
/// [PropertyCard] because it sits in a 220-px-tall rail.
///
/// Layout:
///   - Cover image (16:9-ish via Card aspect)
///   - Bottom-to-top transparent gradient for legibility
///   - Title + price in the lower-left corner, white text
///
/// Reusable: any place that wants a compact "show a single listing
/// with cover + key text" card can drop this in.
class FeaturedPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback? onTap;

  const FeaturedPropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cover = property.media.isNotEmpty ? property.media.first : null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (cover != null)
              CachedNetworkImage(
                imageUrl: cover,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: theme.dividerColor),
                errorWidget: (_, __, ___) => Container(
                  color: theme.dividerColor,
                  child: const Icon(Icons.apartment, size: 32),
                ),
              )
            else
              Container(
                color: theme.dividerColor,
                child: const Icon(Icons.apartment, size: 32),
              ),
            // Bottom gradient for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.propertyTitle(property),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.propertyPrice(property),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
