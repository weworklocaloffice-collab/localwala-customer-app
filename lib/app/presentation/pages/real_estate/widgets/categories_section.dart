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

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/subcategory_picker_sheet.dart';

/// "Browse by category" section of the real estate home.
///
/// Renders three states:
///   1. **Loading** — two skeleton group rows.
///   2. **Error** — a single error line.
///   3. **Loaded** — singleton groups are flattened into one 4-up grid;
///      multi-category groups get a tappable header plus a 4-up grid, with
///      the header opening a [SubcategoryPickerSheet] for the full list.
///
/// Data flows in via props (no own fetch); the parent owns the API call
/// and re-uses it for the featured carousel. Both share the same
/// lifetime so the section never reloads when it does not need to.
class CategoriesSection extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final CategoryGroups? groups;
  final void Function(String key, String label) onCategorySelected;
  final void Function(String groupName, List<GroupedCategory> items)
  onGroupHeaderTapped;

  const CategoriesSection({
    super.key,
    required this.isLoading,
    required this.error,
    required this.groups,
    required this.onCategorySelected,
    required this.onGroupHeaderTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    final singleCategories = <GroupedCategory>[];
    final multiGroups = <MapEntry<String, List<GroupedCategory>>>[];
    if (groups != null) {
      for (final groupName in groups!.groupNames) {
        final items = groups!.byGroup[groupName] ?? const [];
        if (items.isEmpty) continue;
        if (items.length == 1) {
          singleCategories.add(items.single);
        } else {
          multiGroups.add(MapEntry(groupName, items));
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate.re_browse_by_category,
                style: theme.textTheme.titleMedium,
              ),
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          )
        else if (isLoading)
          const _CategoriesSkeleton()
        else if (singleCategories.isEmpty && multiGroups.isEmpty)
          const SizedBox.shrink()
        else ...[
          if (singleCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _CategoryGrid(
                items: singleCategories,
                onCategorySelected: onCategorySelected,
              ),
            ),
          ...multiGroups.map((entry) {
            final label = _groupLabel(translate, entry.key);
            return _GroupSection(
              groupName: label,
              items: entry.value,
              onCategorySelected: onCategorySelected,
              onHeaderTapped: () => onGroupHeaderTapped(label, entry.value),
            );
          }),
        ],
      ],
    );
  }
}

/// One group inside [CategoriesSection] — a tappable header + a 4-up
/// grid of subcategory tiles. Up to 4 tiles are shown inline; if the
/// group has more, a "+N more" hint appears next to the header and
/// tapping the header opens the full picker sheet.
class _GroupSection extends StatelessWidget {
  final String groupName;
  final List<GroupedCategory> items;
  final void Function(String key, String label) onCategorySelected;
  final VoidCallback onHeaderTapped;

  const _GroupSection({
    required this.groupName,
    required this.items,
    required this.onCategorySelected,
    required this.onHeaderTapped,
  });

  static const int _inlineLimit = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showMore = items.length > _inlineLimit;
    final visible = items.take(_inlineLimit).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onHeaderTapped,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(groupName, style: theme.textTheme.titleSmall),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18),
                  if (showMore) ...[
                    const Spacer(),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.re_more_count(items.length - _inlineLimit),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _CategoryGrid(items: visible, onCategorySelected: onCategorySelected),
        ],
      ),
    );
  }
}

/// 4-up grid used both for flattened singleton groups and inside a
/// multi-category group section.
class _CategoryGrid extends StatelessWidget {
  final List<GroupedCategory> items;
  final void Function(String key, String label) onCategorySelected;

  const _CategoryGrid({required this.items, required this.onCategorySelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return InkWell(
          onTap: () => onCategorySelected(c.key, c.name),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  _iconFor(c.key),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                c.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Placeholder rendered while the grouped-categories call is in flight.
/// Two rows of four 60-px tiles each — matches the eventual layout
/// so the screen does not jump when the data lands.
class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(2, (g) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: Theme.of(context).dividerColor,
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Turns the backend's uppercase group keys into display labels.
/// Unknown groups are title-cased rather than shown as raw keys.
String _groupLabel(AppLocalizations translate, String groupName) {
  switch (groupName.toUpperCase()) {
    case 'APARTMENT':
      return translate.re_group_apartment;
    case 'HOUSE':
      return translate.re_group_house;
    case 'VILLA':
      return translate.re_group_villa;
    case 'PLOT':
      return translate.re_group_plot;
    case 'COMMERCIAL':
      return translate.re_group_commercial;
    default:
      return _humanizeKey(groupName);
  }
}

String _humanizeKey(String key) {
  return key
      .split(RegExp(r'[_\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

/// Backend category keys map to these icons. Anything missing falls
/// back to a generic apartment icon.
IconData _iconFor(String key) {
  switch (key) {
    case 'APARTMENT':
      return Icons.apartment;
    case 'INDEPENDENT_HOUSE':
      return Icons.home;
    case 'VILLA':
      return Icons.villa;
    case 'PLOT':
      return Icons.landscape;
    case 'COMMERCIAL_OFFICE':
      return Icons.business;
    case 'COMMERCIAL_SHOP':
      return Icons.storefront;
    case 'COMMERCIAL_SHOWROOM':
      return Icons.store;
    case 'COMMERCIAL_WAREHOUSE':
      return Icons.warehouse;
    case 'COMMERCIAL_LAND':
      return Icons.terrain;
    default:
      return Icons.apartment;
  }
}
