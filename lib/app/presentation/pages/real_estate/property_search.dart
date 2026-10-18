/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
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

  const PropertySearchScreen({
    super.key,
    this.initialCategory,
    this.initialLabel,
    this.initialSortBy,
  });

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _repo = RealEstateRepository();

  bool _loadingCategories = true;
  List<PropertyCategory> _categories = const [];
  String? _selectedCategory;
  String? _transactionType; // BUY | RENT
  String? _city;
  String? _sortBy;

  bool _loadingResults = false;
  List<PropertyModel> _results = const [];
  String? _error;

  // Filter sheet state. Null means unfiltered.
  double? _minPrice;
  double? _maxPrice;
  int? _bedrooms;
  bool _verifiedOnly = false;

  static const Map<String?, String> sortOptions = {
    null: 'Relevance',
    'views:desc': 'Most viewed',
    'enquiries:desc': 'Most enquired',
    'publishedAt:desc': 'Newest',
    'price:desc': 'Price: high to low',
    'price:asc': 'Price: low to high',
  };

  int get _activeFilterCount {
    var n = 0;
    if (_minPrice != null) n++;
    if (_maxPrice != null) n++;
    if (_bedrooms != null) n++;
    if (_verifiedOnly) n++;
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
    _loadCategories();
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

  Future<void> _search() async {
    setState(() {
      _loadingResults = true;
      _error = null;
    });
    try {
      final list = await _repo.search(
        city: _city,
        transactionType: _transactionType,
        category: _selectedCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        bedrooms: _bedrooms,
        verifiedOnly: _verifiedOnly,
        sortBy: _sortBy,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _results = list;
        _loadingResults = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Search failed';
        _loadingResults = false;
      });
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
    final minCtrl = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
    int? bedrooms = _bedrooms;
    bool verifiedOnly = _verifiedOnly;
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
                Text(translate.re_filter_price, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min (₹)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max (₹)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(translate.re_filter_bedrooms, style: Theme.of(ctx).textTheme.titleMedium),
                DropdownButton<int?>(
                  value: bedrooms,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Any')),
                    DropdownMenuItem(value: 1, child: Text('1')),
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                    DropdownMenuItem(value: 5, child: Text('5')),
                  ],
                  onChanged: (int? v) => setSheet(() => bedrooms = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Verified only'),
                  value: verifiedOnly,
                  onChanged: (bool v) => setSheet(() => verifiedOnly = v),
                ),
                DropdownButton<String?>(
                  value: sortBy,
                  isExpanded: true,
                  items: [
                    for (final MapEntry<String?, String> e in sortOptions.entries)
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
                            _sortBy = widget.initialSortBy;
                          });
                          _search();
                        },
                        child: const Text('Clear all'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final double? min = double.tryParse(minCtrl.text.trim());
                          final double? max = double.tryParse(maxCtrl.text.trim());
                          Navigator.of(ctx).pop();
                          setState(() {
                            _minPrice = min;
                            _maxPrice = max;
                            _bedrooms = bedrooms;
                            _verifiedOnly = verifiedOnly;
                            _sortBy = sortBy;
                          });
                          _search();
                        },
                        child: const Text('Apply'),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                          onSelected: (s) => _onSelectCategory(s ? cat.key : null),
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
                          child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                        ),
                      )
                    : _results.isEmpty
                        ? Center(child: Text(translate.re_no_results))
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                                      builder: (_) => PropertyDetailScreen(propertyId: p.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
