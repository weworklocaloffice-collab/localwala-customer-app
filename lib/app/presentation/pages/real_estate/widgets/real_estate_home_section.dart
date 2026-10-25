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
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/property_search.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/categories_section.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/featured_property_card.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/subcategory_picker_sheet.dart';

/// Real Estate home section.
///
/// Mirrors the food module's home layout: featured carousel at the top
/// and a "Browse by category" grid below. The categories grid includes
/// subcategory chips that pop a bottom sheet for drilling into a
/// subcategory — only [CategoryGroups] (the grouped endpoint) carries
/// the subcategory information; the flat [PropertyCategory] list does
/// not.
///
/// All three API calls run in parallel on mount; individual sections
/// become visible as their data resolves, with skeletons in the
/// meantime. The section is safe to drop into any scrollable.
class RealEstateHomeSection extends StatefulWidget {
  const RealEstateHomeSection({super.key});

  @override
  State<RealEstateHomeSection> createState() => _RealEstateHomeSectionState();
}

class _RealEstateHomeSectionState extends State<RealEstateHomeSection> {
  final _repo = RealEstateRepository();

  bool _featuredLoading = true;
  List<PropertyModel> _featured = const [];
  String? _featuredError;

  bool _categoriesLoading = true;
  CategoryGroups? _groups;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    // Run in parallel — the two endpoints are independent. Errors are
    // scoped per section so one failure doesn't blank the whole block.
    await Future.wait([_loadFeatured(), _loadCategories()]);
  }

  Future<void> _loadFeatured() async {
    try {
      final list = await _repo.listFeatured();
      if (!mounted) return;
      setState(() {
        _featured = list;
        _featuredLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _featuredLoading = false;
        _featuredError = 'Could not load featured properties';
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final groups = await _repo.listGroupedCategories();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _categoriesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesLoading = false;
        _categoriesError = 'Could not load categories';
      });
    }
  }

  // ---------------- Subcategory bottom sheet ----------------

  void _openSubcategorySheet(String groupName, List<GroupedCategory> items) {
    SubcategoryPickerSheet.show(
      context,
      groupName: groupName,
      items: items,
      onSelect: (c) => _onCategoryTapped(c.key, c.name),
    );
  }

  void _onCategoryTapped(String key, String label) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PropertySearchScreen(initialCategory: key, initialLabel: label),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildFeaturedSection(), _buildCategoriesSection()],
    );
  }

  Widget _buildFeaturedSection() {
    if (_featuredLoading) {
      return _featuredSkeleton();
    }
    if (_featuredError != null) {
      // Non-fatal — the categories section still shows.
      return const SizedBox.shrink();
    }
    if (_featured.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.re_featured_title,
                style: theme.textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PropertySearchScreen(),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.re_see_all),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = _featured[i];
              return SizedBox(
                width: 280,
                child: FeaturedPropertyCard(
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

  Widget _featuredSkeleton() {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          return Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return CategoriesSection(
      isLoading: _categoriesLoading,
      error: _categoriesError,
      groups: _groups,
      onCategorySelected: _onCategoryTapped,
      onGroupHeaderTapped: _openSubcategorySheet,
    );
  }
}
