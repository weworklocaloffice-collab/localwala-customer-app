/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/dairy/dairy_money_view.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Faceted dairy storefront.
///
/// Category → sub-category drill-down from the tree endpoint, free-text
/// search, and a filter sheet (brand, fat level, milk type, price band) — all
/// served by `GET /catalog/products/search`, which returns products with their
/// in-stock SKUs attached so each result expands to its pack sizes directly.
class DairyHomeView extends StatefulWidget {
  const DairyHomeView({super.key});

  @override
  State<DairyHomeView> createState() => _DairyHomeViewState();
}

class _DairyHomeViewState extends State<DairyHomeView> {
  final DairyCustomerService _service = DairyCustomerService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<dynamic> _categories = const <dynamic>[];
  List<dynamic> _brands = const <dynamic>[];

  String? _categoryId;
  String? _subCategoryId;
  String? _brandId;
  String? _fatLevel;
  String? _milkType;
  double? _minPrice;
  double? _maxPrice;

  /// Attribute options are not served as facet counts by the API; they are
  /// accumulated from every result seen this session, so they only ever offer
  /// values that exist on real products.
  final Set<String> _seenFatLevels = <String>{};
  final Set<String> _seenMilkTypes = <String>{};

  bool _loading = true;
  String? _error;
  List<dynamic> _results = const <dynamic>[];
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final tree = await _service.categoryTree();
    final brands = await _service.brandList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (tree.success) {
        final Map<String, dynamic> decoded = asMap(jsonDecode(tree.body));
        _categories = decodeList(decoded['categories']);
      }
      if (brands.success) {
        final Map<String, dynamic> decoded = asMap(jsonDecode(brands.body));
        _brands = decodeList(decoded['brands']);
      }
    });
    await _query();
  }

  Future<void> _query() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await _service.searchProducts(
      category: _categoryId,
      subCategory: _subCategoryId,
      brand: _brandId,
      fatLevel: _fatLevel,
      milkType: _milkType,
      search: _searchController.text.trim(),
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) {
        final Map<String, dynamic> decoded = asMap(jsonDecode(r.body));
        _results = decodeList(decoded['products']);
        _total = int.tryParse(decoded['totalResults']?.toString() ?? '0') ?? 0;
        // Harvest attribute vocabulary for the filter sheet.
        for (final dynamic p in _results) {
          final Map<String, dynamic> attrs = asMap(asMap(p)['attributes']);
          final String fat = attrs['fatLevel']?.toString() ?? '';
          final String milk = attrs['milkType']?.toString() ?? '';
          if (fat.isNotEmpty) _seenFatLevels.add(fat);
          if (milk.isNotEmpty) _seenMilkTypes.add(milk);
        }
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_products;
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _query);
  }

  void _setCategory(String? id) {
    setState(() {
      _categoryId = id;
      _subCategoryId = null; // sub chips are re-derived per category
    });
    _query();
  }

  int get _activeFilterCount => <dynamic>[
        _brandId,
        _fatLevel,
        _milkType,
        _minPrice,
        _maxPrice,
      ].where((dynamic e) => e != null).length;

  Future<void> _openFilterSheet() async {
    final TextEditingController minCtrl = TextEditingController(
      text: _minPrice?.toStringAsFixed(0) ?? '',
    );
    final TextEditingController maxCtrl = TextEditingController(
      text: _maxPrice?.toStringAsFixed(0) ?? '',
    );
    String? sheetBrand = _brandId;
    String? sheetFat = _fatLevel;
    String? sheetMilk = _milkType;

    final bool? applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) => StatefulBuilder(
        builder: (BuildContext sheetContext, void Function(void Function()) setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AppLocalizations.of(sheetContext)!.dairy_filters, style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (_brands.isNotEmpty) ...<Widget>[
                  Text(AppLocalizations.of(sheetContext)!.dairy_brand),
                  DropdownButtonFormField<String>(
                    initialValue: sheetBrand,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(value: null, child: Text(AppLocalizations.of(sheetContext)!.dairy_any)),
                      ..._brands.map((dynamic b) {
                        final Map<String, dynamic> m = asMap(b);
                        return DropdownMenuItem<String>(
                          value: m['_id']?.toString() ?? '',
                          child: Text(m['name']?.toString() ?? ''),
                        );
                      }),
                    ],
                    onChanged: (String? v) => setSheetState(() => sheetBrand = (v == null || v.isEmpty) ? null : v),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_seenFatLevels.isNotEmpty) ...<Widget>[
                  Text(AppLocalizations.of(sheetContext)!.dairy_fat_level),
                  Wrap(
                    spacing: 6,
                    children: _seenFatLevels.map((String f) {
                      return ChoiceChip(
                        label: Text(f.replaceAll('_', ' ')),
                        selected: sheetFat == f,
                        onSelected: (bool on) => setSheetState(() => sheetFat = on ? f : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_seenMilkTypes.isNotEmpty) ...<Widget>[
                  Text(AppLocalizations.of(sheetContext)!.dairy_milk_type),
                  Wrap(
                    spacing: 6,
                    children: _seenMilkTypes.map((String t) {
                      return ChoiceChip(
                        label: Text(t.replaceAll('_', ' ')),
                        selected: sheetMilk == t,
                        onSelected: (bool on) => setSheetState(() => sheetMilk = on ? t : null),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(AppLocalizations.of(sheetContext)!.dairy_price_per_pack),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: AppLocalizations.of(sheetContext)!.dairy_min, border: const OutlineInputBorder()),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(AppLocalizations.of(sheetContext)!.dairy_to)),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: AppLocalizations.of(sheetContext)!.dairy_max, border: const OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: Text(AppLocalizations.of(sheetContext)!.dairy_clear_all),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: Text(AppLocalizations.of(sheetContext)!.dairy_apply),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (applied == null) return; // dismissed — keep previous filters
    setState(() {
      if (!applied) {
        _brandId = null;
        _fatLevel = null;
        _milkType = null;
        _minPrice = null;
        _maxPrice = null;
      } else {
        _brandId = (sheetBrand == null || sheetBrand!.isEmpty) ? null : sheetBrand;
        _fatLevel = sheetFat;
        _milkType = sheetMilk;
        final double? min = double.tryParse(minCtrl.text.trim());
        final double? max = double.tryParse(maxCtrl.text.trim());
        _minPrice = (min != null && min > 0) ? min : null;
        _maxPrice = (max != null && max > 0) ? max : null;
      }
    });
    _query();
  }

  List<dynamic> get _subCategories {
    if (_categoryId == null) return const <dynamic>[];
    for (final dynamic c in _categories) {
      final Map<String, dynamic> m = asMap(c);
      if (m['_id']?.toString() == _categoryId) {
        return decodeList(m['subCategories']);
      }
    }
    return const <dynamic>[];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.dairy_title),
        actions: <Widget>[
          IconButton(
            tooltip: t.dairy_orders,
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.dairyOrdersRoute),
          ),
          IconButton(
            tooltip: t.dairy_subscriptions,
            icon: const Icon(Icons.autorenew),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.dairySubscriptionsRoute),
          ),
          IconButton(
            tooltip: t.dairy_wallet_deposits,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (BuildContext context) => const DairyCustomerMoneyView()),
            ),
          ),
          IconButton(
            tooltip: t.dairy_support,
            icon: const Icon(Icons.support_agent),
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.dairySupportRoute),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: t.dairy_search_hint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: <Widget>[
                    IconButton(
                      tooltip: t.dairy_filters,
                      icon: const Icon(Icons.tune),
                      onPressed: _openFilterSheet,
                    ),
                    if (_activeFilterCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            '$_activeFilterCount',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: ChoiceChip(
                    label: Text(t.dairy_all),
                    selected: _categoryId == null,
                    onSelected: (_) => _setCategory(null),
                  ),
                ),
                ..._categories.map((dynamic c) {
                  final Map<String, dynamic> m = asMap(c);
                  final String id = m['_id']?.toString() ?? '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ChoiceChip(
                      label: Text(m['name']?.toString() ?? ''),
                      selected: _categoryId == id,
                      onSelected: (_) => _setCategory(id.isEmpty ? null : id),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_subCategories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: ChoiceChip(
                      label: Text(t.dairy_all),
                      selected: _subCategoryId == null,
                      onSelected: (_) {
                        setState(() => _subCategoryId = null);
                        _query();
                      },
                    ),
                  ),
                  ..._subCategories.map((dynamic s) {
                    final Map<String, dynamic> m = asMap(s);
                    final String id = m['_id']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: ChoiceChip(
                        label: Text(m['name']?.toString() ?? ''),
                        selected: _subCategoryId == id,
                        onSelected: (_) {
                          setState(() => _subCategoryId = id);
                          _query();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: <Widget>[
                Text(t.dairy_products_count(_total), style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                if (_activeFilterCount > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _brandId = null;
                        _fatLevel = null;
                        _milkType = null;
                        _minPrice = null;
                        _maxPrice = null;
                      });
                      _query();
                    },
                    child: Text(t.dairy_clear_filters),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : RefreshIndicator(
                        onRefresh: _query,
                        child: _results.isEmpty
                            ? ListView(
                                children: <Widget>[
                                  SizedBox(height: 80),
                                  Center(child: Text(AppLocalizations.of(context)!.dairy_no_matches)),
                                ],
                              )
                            : ListView.builder(
                                itemCount: _results.length,
                                itemBuilder: (BuildContext context, int i) => _productTile(asMap(_results[i])),
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _productTile(Map<String, dynamic> product) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final List<dynamic> skus = decodeList(product['skus']);
    final Map<String, dynamic> brand = asMap(product['brand']);
    final Map<String, dynamic> subCat = asMap(product['subCategory']);
    final String subtitle = <String>[
      if (brand.isNotEmpty) brand['name']?.toString() ?? '',
      if (subCat.isNotEmpty) subCat['name']?.toString() ?? '',
    ].where((String s) => s.isNotEmpty).join(' · ');

    return ExpansionTile(
      title: Text(product['name']?.toString() ?? t.dairy_product),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      children: skus.isEmpty
          ? <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.dairy_out_of_stock),
              ),
            ]
          : skus.map((dynamic s) {
              final Map<String, dynamic> sku = asMap(s);
              final Map<String, dynamic> pack = asMap(sku['packSize']);
              final String packLabel = <String>[
                if ((pack['quantity'] ?? 0) != 0) pack['quantity'].toString(),
                pack['unit']?.toString() ?? '',
              ].join(' ');
              return ListTile(
                dense: true,
                title: Text(packLabel.isEmpty ? t.dairy_standard_pack : packLabel),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(formatMoney(sku['price'])),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: t.dairy_add_to_cart,
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () async {
                        final r = await _service.addToCart(
                          sku: sku['_id']?.toString() ?? '',
                          quantity: 1,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(r.success ? t.dairy_added_to_cart : t.dairy_could_not_add)),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
    );
  }
}
