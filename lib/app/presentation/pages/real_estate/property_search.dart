/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/location_repository.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/map_search.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_card.dart';

/// Real Estate search screen — category chips + filters + result grid.
/// Mirrors the food module's `dining_search_view.dart` layout so the
/// visual language is shared.
class PropertySearchScreen extends StatefulWidget {
  /// When set, the screen opens with this category selected and the chip
  /// row scrolled to it. The label is used as the AppBar title override
  /// when non-empty.
  final String? initialCategory;
  final String? initialLabel;

  /// When set, the screen opens with results pre-sorted. The home
  /// discovery rails pass this so tapping "See all" on a rail opens
  /// the same ordering.
  final String? initialSortBy;

  /// When set, the screen opens scoped to BUY or RENT. Price rails pass
  /// BUY so a monthly rent is never compared with a sale price.
  final String? initialTransactionType;

  const PropertySearchScreen({
    super.key,
    this.initialCategory,
    this.initialLabel,
    this.initialSortBy,
    this.initialTransactionType,
  });

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _repo = RealEstateRepository();
  final _locationRepo = LocationRepository();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const int _pageSize = 20;
  static const double _nearMeRadiusMeters = 5000;

  bool _loadingCategories = true;
  List<PropertyCategory> _categories = const [];
  String? _selectedCategory;
  String? _transactionType; // BUY | RENT
  String? _sortBy;

  bool _loadingResults = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _page = 1;
  int _requestId = 0;
  String _searchText = '';
  Timer? _searchDebounce;
  List<PropertyModel> _results = const [];
  String? _error;

  // Filter sheet state. Null means unfiltered.
  double? _minPrice;
  double? _maxPrice;
  int? _bedrooms;
  bool _verifiedOnly = false;
  bool _nearMe = false;
  double? _lng;
  double? _lat;

  Map<String?, String> _sortOptions(AppLocalizations translate) => {
    null: translate.re_sort_relevance,
    'views:desc': translate.re_sort_most_viewed,
    'enquiries:desc': translate.re_sort_most_enquired,
    'publishedAt:desc': translate.re_sort_newest,
    'price:desc': translate.re_sort_price_high,
    'price:asc': translate.re_sort_price_low,
  };

  int get _activeFilterCount {
    var n = 0;
    if (_minPrice != null) n++;
    if (_maxPrice != null) n++;
    if (_bedrooms != null) n++;
    if (_verifiedOnly) n++;
    if (_nearMe) n++;
    if (_sortBy != null) n++;
    return n;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
    if (widget.initialSortBy != null) {
      _sortBy = widget.initialSortBy;
    }
    if (widget.initialTransactionType != null) {
      _transactionType = widget.initialTransactionType;
    }
    _scrollController.addListener(_onScroll);
    _loadCategories();
    _search();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      _loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      final next = value.trim();
      if (next == _searchText) return;
      _searchText = next;
      _search();
    });
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    final next = value.trim();
    if (next == _searchText) return;
    _searchText = next;
    _search();
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchText = '';
    _search();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repo.listCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _error = 'Could not load categories';
      });
    }
  }

  Future<List<PropertyModel>> _fetchPage(int page) {
    return _repo.search(
      search: _searchText,
      transactionType: _transactionType,
      category: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      bedrooms: _bedrooms,
      verifiedOnly: _verifiedOnly,
      sortBy: _sortBy,
      lng: _nearMe ? _lng : null,
      lat: _nearMe ? _lat : null,
      radiusMeters: _nearMeRadiusMeters,
      page: page,
      limit: _pageSize,
    );
  }

  Future<void> _search() async {
    final requestId = ++_requestId;
    setState(() {
      _loadingResults = true;
      _loadingMore = false;
      _hasMore = true;
      _page = 1;
      _error = null;
    });
    try {
      final list = await _fetchPage(1);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _results = list;
        _loadingResults = false;
        _hasMore = list.length == _pageSize;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = 'Search failed';
        _loadingResults = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingResults || _loadingMore || !_hasMore) return;
    final requestId = _requestId;
    final nextPage = _page + 1;
    setState(() => _loadingMore = true);
    try {
      final list = await _fetchPage(nextPage);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _page = nextPage;
        _results = [..._results, ...list];
        _loadingMore = false;
        _hasMore = list.length == _pageSize;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _loadingMore = false);
    }
  }

  void _onSelectCategory(String? key) {
    setState(() => _selectedCategory = key);
    _search();
  }

  void _onSelectTransaction(String? value) {
    setState(() => _transactionType = value);
    _search();
  }

  /// Price, bedroom, verified and sort filters. Every control maps to a
  /// backend-accepted query key (`priceMin`/`priceMax` in rupees,
  /// `spec_bedrooms`, `verified`, `sortBy`) — unknown keys are rejected
  /// server-side, so the sheet only offers what the API takes.
  void _openFilters() {
    final translate = AppLocalizations.of(context)!;
    final sortOptions = _sortOptions(translate);
    final minCtrl = TextEditingController(
      text: _minPrice?.toStringAsFixed(0) ?? '',
    );
    final maxCtrl = TextEditingController(
      text: _maxPrice?.toStringAsFixed(0) ?? '',
    );
    int? bedrooms = _bedrooms;
    bool verifiedOnly = _verifiedOnly;
    bool nearMe = _nearMe;
    String? sortBy = _sortBy;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setSheet) => SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  translate.re_filter_price,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: translate.re_price_min_label,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: translate.re_price_max_label,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  translate.re_filter_bedrooms,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                DropdownButton<int?>(
                  value: bedrooms,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(translate.re_filter_any),
                    ),
                    const DropdownMenuItem(value: 1, child: Text('1')),
                    const DropdownMenuItem(value: 2, child: Text('2')),
                    const DropdownMenuItem(value: 3, child: Text('3')),
                    const DropdownMenuItem(value: 4, child: Text('4')),
                    const DropdownMenuItem(value: 5, child: Text('5')),
                  ],
                  onChanged: (int? v) => setSheet(() => bedrooms = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(translate.re_filter_verified),
                  value: verifiedOnly,
                  onChanged: (bool v) => setSheet(() => verifiedOnly = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(translate.re_filter_near_me),
                  value: nearMe,
                  onChanged: (bool v) => setSheet(() => nearMe = v),
                ),
                DropdownButton<String?>(
                  value: sortBy,
                  isExpanded: true,
                  items: [
                    for (final MapEntry<String?, String> e
                        in sortOptions.entries)
                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ],
                  onChanged: (String? v) => setSheet(() => sortBy = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _minPrice = null;
                            _maxPrice = null;
                            _bedrooms = null;
                            _verifiedOnly = false;
                            _nearMe = false;
                            _lng = null;
                            _lat = null;
                            _sortBy = widget.initialSortBy;
                          });
                          _search();
                        },
                        child: Text(translate.re_filter_clear_all),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          final double? min = double.tryParse(
                            minCtrl.text.trim(),
                          );
                          final double? max = double.tryParse(
                            maxCtrl.text.trim(),
                          );
                          double? lng;
                          double? lat;
                          if (nearMe) {
                            final hasLocation = await _locationRepo
                                .haveLocation();
                            if (!ctx.mounted) return;
                            if (!hasLocation) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    translate.re_near_me_no_location,
                                  ),
                                ),
                              );
                              return;
                            }
                            lng = await _locationRepo.userLongitude();
                            lat = await _locationRepo.userLatitude();
                            if (!ctx.mounted) return;
                          }
                          Navigator.of(ctx).pop();
                          setState(() {
                            _minPrice = min;
                            _maxPrice = max;
                            _bedrooms = bedrooms;
                            _verifiedOnly = verifiedOnly;
                            _nearMe = nearMe;
                            _lng = lng;
                            _lat = lat;
                            _sortBy = sortBy;
                          });
                          _search();
                        },
                        child: Text(translate.re_filter_apply),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialLabel ?? translate.re_search_title),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: translate.re_filter_price,
                icon: const Icon(Icons.tune_outlined),
                onPressed: _openFilters,
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: translate.re_map_view_tooltip,
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MapSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: translate.re_search_hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _searchController.text.isEmpty
                      ? null
                      : _clearSearch,
                ),
                isDense: true,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          // Transaction type toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(translate.re_search_buy),
                  selected: _transactionType == 'BUY',
                  onSelected: (s) => _onSelectTransaction(s ? 'BUY' : null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(translate.re_search_rent),
                  selected: _transactionType == 'RENT',
                  onSelected: (s) => _onSelectTransaction(s ? 'RENT' : null),
                ),
              ],
            ),
          ),
          // Category chips
          SizedBox(
            height: 48,
            child: _loadingCategories
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(translate.re_search_all),
                            selected: _selectedCategory == null,
                            onSelected: (_) => _onSelectCategory(null),
                          ),
                        );
                      }
                      final cat = _categories[i - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.name),
                          selected: _selectedCategory == cat.key,
                          onSelected: (s) =>
                              _onSelectCategory(s ? cat.key : null),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // Results
          Expanded(
            child: _loadingResults
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        translate.re_error_generic,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _results.isEmpty
                ? Center(child: Text(translate.re_no_results))
                : Stack(
                    children: [
                      GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 280,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _results.length,
                        itemBuilder: (context, i) {
                          final p = _results[i];
                          return PropertyCard(
                            property: p,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PropertyDetailScreen(propertyId: p.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (_loadingMore)
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
