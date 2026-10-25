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
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/presentation/pages/real_estate/property_search.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_rail_section.dart';

/// Real Estate "discovery" section — multiple rails of properties
/// ordered differently, mirroring the food module's home layout.
///
/// Sections, in order:
///   1. **Popular properties**      — `sortBy=views:desc`
///   2. **Recently added**          — `sortBy=publishedAt:desc`
///   3. **Most enquired**           — `sortBy=enquiries:desc`
///   4. **Premium listings**        — `sortBy=price:desc`
///   5. **Affordable homes**        — `sortBy=price:asc`
///
/// Each rail is independent: its load failure does not block the
/// others, and each has its own skeleton + error state. The parent
/// mounts the section once; the section manages the load lifecycle.
class RealEstateDiscoverySection extends StatefulWidget {
  const RealEstateDiscoverySection({super.key});

  @override
  State<RealEstateDiscoverySection> createState() =>
      _RealEstateDiscoverySectionState();
}

class _RealEstateDiscoverySectionState
    extends State<RealEstateDiscoverySection> {
  final _repo = RealEstateRepository();

  // Per-section state. Loading defaults to true; `error` is non-null
  // when the load failed. `items` is empty until the call returns.
  bool _popularLoading = true;
  String? _popularError;
  List<PropertyModel> _popular = const [];

  bool _recentLoading = true;
  String? _recentError;
  List<PropertyModel> _recent = const [];

  bool _enquiredLoading = true;
  String? _enquiredError;
  List<PropertyModel> _enquired = const [];

  bool _premiumLoading = true;
  String? _premiumError;
  List<PropertyModel> _premium = const [];

  bool _affordableLoading = true;
  String? _affordableError;
  List<PropertyModel> _affordable = const [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    // Run in parallel — each rail is an independent search query.
    // A single failure does not blank the others.
    await Future.wait([
      _loadPopular(),
      _loadRecent(),
      _loadEnquired(),
      _loadPremium(),
      _loadAffordable(),
    ]);
  }

  Future<void> _loadPopular() => _loadSection(
    loader: () => _repo.listMostViewed(limit: 10),
    onLoaded: (l) => _popular = l,
    setLoading: (v) => _popularLoading = v,
    setError: (e) => _popularError = e,
  );

  Future<void> _loadRecent() => _loadSection(
    loader: () => _repo.listRecentlyPublished(limit: 10),
    onLoaded: (l) => _recent = l,
    setLoading: (v) => _recentLoading = v,
    setError: (e) => _recentError = e,
  );

  Future<void> _loadEnquired() => _loadSection(
    loader: () => _repo.listMostEnquired(limit: 10),
    onLoaded: (l) => _enquired = l,
    setLoading: (v) => _enquiredLoading = v,
    setError: (e) => _enquiredError = e,
  );

  Future<void> _loadPremium() => _loadSection(
    loader: () => _repo.listPremium(limit: 10),
    onLoaded: (l) => _premium = l,
    setLoading: (v) => _premiumLoading = v,
    setError: (e) => _premiumError = e,
  );

  Future<void> _loadAffordable() => _loadSection(
    loader: () => _repo.listAffordable(limit: 10),
    onLoaded: (l) => _affordable = l,
    setLoading: (v) => _affordableLoading = v,
    setError: (e) => _affordableError = e,
  );

  Future<void> _loadSection({
    required Future<List<PropertyModel>> Function() loader,
    required void Function(List<PropertyModel>) onLoaded,
    required void Function(bool) setLoading,
    required void Function(String?) setError,
  }) async {
    try {
      final list = await loader();
      if (!mounted) return;
      setState(() {
        onLoaded(list);
        setLoading(false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        setError(AppLocalizations.of(context)!.re_error_generic);
        setLoading(false);
      });
    }
  }

  void _openSearchWithSort({
    String? title,
    required String sortBy,
    String? transactionType,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PropertySearchScreen(
          initialSortBy: sortBy,
          initialLabel: title,
          initialTransactionType: transactionType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PropertyRailSection(
          title: translate.re_popular_title,
          subtitle: translate.re_popular_subtitle,
          isLoading: _popularLoading,
          error: _popularError,
          items: _popular,
          onSeeAll: () => _openSearchWithSort(
            title: translate.re_popular_title,
            sortBy: 'views:desc',
          ),
        ),
        PropertyRailSection(
          title: translate.re_recent_added_title,
          subtitle: translate.re_recent_added_subtitle,
          isLoading: _recentLoading,
          error: _recentError,
          items: _recent,
          onSeeAll: () => _openSearchWithSort(
            title: translate.re_recent,
            sortBy: 'publishedAt:desc',
          ),
        ),
        PropertyRailSection(
          title: translate.re_most_enquired_title,
          subtitle: translate.re_most_enquired_subtitle,
          isLoading: _enquiredLoading,
          error: _enquiredError,
          items: _enquired,
          onSeeAll: () => _openSearchWithSort(
            title: translate.re_most_enquired_title,
            sortBy: 'enquiries:desc',
          ),
        ),
        PropertyRailSection(
          title: translate.re_premium_title,
          subtitle: translate.re_premium_subtitle,
          isLoading: _premiumLoading,
          error: _premiumError,
          items: _premium,
          onSeeAll: () => _openSearchWithSort(
            title: translate.re_premium_title,
            sortBy: 'price:desc',
            transactionType: 'BUY',
          ),
        ),
        PropertyRailSection(
          title: translate.re_affordable_title,
          subtitle: translate.re_affordable_subtitle,
          isLoading: _affordableLoading,
          error: _affordableError,
          items: _affordable,
          onSeeAll: () => _openSearchWithSort(
            title: translate.re_affordable_title,
            sortBy: 'price:asc',
            transactionType: 'BUY',
          ),
        ),
      ],
    );
  }
}
