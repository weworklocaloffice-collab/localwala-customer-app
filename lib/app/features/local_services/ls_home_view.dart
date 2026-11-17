import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/common/vertical_header_scaffold.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/features/local_services/ls_service_view.dart';
import 'package:user/app/features/local_services/ls_bookings_view.dart';
import 'package:user/app/features/local_services/ls_complaints_view.dart';
import 'package:user/app/features/local_services/ls_reviews_view.dart';
import 'package:user/app/features/local_services/ls_recurring_view.dart';
import 'package:user/app/features/local_services/ls_favorites_view.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/widgets/ls_service_card.dart';
import 'package:user/app/features/local_services/widgets/ls_category_chip_row.dart';
import 'package:user/app/features/local_services/widgets/ls_filter_sheet.dart';

/// Local Services storefront: categories as chips + service cards, with a
/// compact filter sheet. Mirrors the polish of the stores/food home screens.
class LsHomeView extends StatefulWidget {
  const LsHomeView({super.key});

  @override
  State<LsHomeView> createState() => _LsHomeViewState();
}

class _LsHomeViewState extends State<LsHomeView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<LsService> _services = const <LsService>[];
  List<Map<String, dynamic>> _categories = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _topCategories = const <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _subcategories = const <Map<String, dynamic>>[];
  String? _selectedCategory;
  String? _selectedTop;
  String _search = '';
  int _visibleCount = 10;

  // Filters (applied client-side).
  double? _minPrice;
  double? _maxPrice;
  int? _minDuration;
  int? _maxDuration;
  double? _ratingFilter;
  bool _instantOnly = false;
  String? _selectedPricingMode;
  String _mediaUrl = '';

  @override
  void initState() {
    super.initState();
    _loadMediaUrl();
    _load();
  }

  Future<void> _loadMediaUrl() async {
    final String url = await AuthRepository().getMediaUrl();
    if (mounted) setState(() => _mediaUrl = url);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _visibleCount = 10;
    });
    try {
      final dynamic catRes = await _service.categories();
      final Map<String, dynamic> catBody =
          Map<String, dynamic>.from(jsonDecode(catRes.body) as Map);
      final List<Map<String, dynamic>> allCats =
          ((catBody['results'] ?? []) as List)
              .whereType<Map<String, dynamic>>()
              .toList();
      final List<Map<String, dynamic>> topCats = allCats
          .where((Map<String, dynamic> c) {
            final dynamic p = c['parent'];
            return p == null || '$p'.isEmpty || '$p' == 'null';
          })
          .toList();
      List<Map<String, dynamic>> subs = const <Map<String, dynamic>>[];
      if (_selectedTop != null && _selectedTop!.isNotEmpty) {
        try {
          final dynamic subRes = await _service.subcategories(_selectedTop!);
          final Map<String, dynamic> subBody =
              Map<String, dynamic>.from(jsonDecode(subRes.body) as Map);
          subs = ((subBody['results'] ?? []) as List)
              .whereType<Map<String, dynamic>>()
              .toList();
        } catch (_) {
          subs = const <Map<String, dynamic>>[];
        }
      }
      final dynamic svcRes = await _service.services(
        categoryId: _selectedCategory,
      );
      final Map<String, dynamic> svcBody =
          Map<String, dynamic>.from(jsonDecode(svcRes.body) as Map);
      setState(() {
        _categories = allCats;
        _topCategories = topCats;
        _subcategories = subs;
        _services = ((svcBody['results'] ?? []) as List)
            .whereType<Map<String, dynamic>>()
            .map(LsService.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load services: $e';
      });
    }
  }

  List<LsService> get _filtered {
    Iterable<LsService> out = _services;
    if (_search.isNotEmpty) {
      final String q = _search.toLowerCase();
      out = out.where((LsService s) =>
          s.name.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q));
    }
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      // category filter already applied server-side; keep for safety.
    }
    if (_minDuration != null) {
      out = out.where((LsService s) => s.baseDurationMinutes >= _minDuration!);
    }
    if (_maxDuration != null) {
      out = out.where((LsService s) => s.baseDurationMinutes <= _maxDuration!);
    }
    if (_minPrice != null) {
      out = out.where((LsService s) => s.maxPrice == 0 || s.maxPrice >= _minPrice!);
    }
    if (_maxPrice != null) {
      out = out.where((LsService s) => s.minPrice == 0 || s.minPrice <= _maxPrice!);
    }
    if (_ratingFilter != null) {
      out = out.where((LsService s) => s.avgRating >= _ratingFilter!);
    }
    if (_instantOnly) {
      out = out.where((LsService s) => s.bookingMode == 'INSTANT');
    }
    if (_selectedPricingMode != null && _selectedPricingMode!.isNotEmpty) {
      out = out.where((LsService s) => s.pricingMode == _selectedPricingMode);
    }
    return out.toList();
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setModal) {
            return LsFilterSheet(
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              minDuration: _minDuration,
              maxDuration: _maxDuration,
              ratingFilter: _ratingFilter,
              instantOnly: _instantOnly,
              selectedPricingMode: _selectedPricingMode,
              onMinPriceChanged: (double? v) =>
                  setModal(() => _minPrice = v),
              onMaxPriceChanged: (double? v) =>
                  setModal(() => _maxPrice = v),
              onMinDurationChanged: (int? v) =>
                  setModal(() => _minDuration = v),
              onMaxDurationChanged: (int? v) =>
                  setModal(() => _maxDuration = v),
              onRatingChanged: (double? v) =>
                  setModal(() => _ratingFilter = v),
              onInstantChanged: (bool v) =>
                  setModal(() => _instantOnly = v),
              onPricingModeChanged: (String? v) =>
                  setModal(() => _selectedPricingMode = v),
              onClear: () {
                setState(() {
                  _minPrice = null;
                  _maxPrice = null;
                  _minDuration = null;
                  _maxDuration = null;
                  _ratingFilter = null;
                  _instantOnly = false;
                  _selectedPricingMode = null;
                });
                Navigator.pop(ctx);
              },
              onApply: () {
                setState(() {});
                Navigator.pop(ctx);
              },
            );
          },
        );
      },
    );
  }

  void _openService(LsService s) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LsServiceView(service: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LsService> services = _filtered;
    final List<LsService> visible = services.take(_visibleCount).toList();
    final bool hasMore = services.length > _visibleCount;
    final AppLocalizations? t = AppLocalizations.of(context);
    return VerticalHeaderScaffold(
      vertical: 'local_services',
      onRefresh: _load,
      extraActions: <Widget>[
        IconButton(
          tooltip: t?.ls_filters ?? 'Filters',
          icon: const Icon(Icons.tune),
          onPressed: _openFilters,
        ),
        PopupMenuButton<String>(
          tooltip: t?.ls_my_services ?? 'My services',
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {
            switch (value) {
              case 'bookings':
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const LsBookingsView()))
                    .then((_) => _load());
                break;
              case 'complaints':
                Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LsComplaintsView()));
                break;
              case 'reviews':
                Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LsReviewsView()));
                break;
              case 'recurring':
                Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LsRecurringView()));
                break;
              case 'favorites':
                Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LsFavoritesView()));
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'bookings',
              child: Row(children: <Widget>[
                Icon(Icons.receipt_long_outlined),
                const SizedBox(width: 12),
                Text(t?.ls_my_bookings ?? 'My bookings'),
              ]),
            ),
            PopupMenuItem<String>(
              value: 'complaints',
              child: Row(children: <Widget>[
                Icon(Icons.report_problem_outlined),
                const SizedBox(width: 12),
                Text(t?.ls_my_complaints ?? 'My complaints'),
              ]),
            ),
            PopupMenuItem<String>(
              value: 'reviews',
              child: Row(children: <Widget>[
                Icon(Icons.star_outline),
                const SizedBox(width: 12),
                Text(t?.ls_my_reviews ?? 'My reviews'),
              ]),
            ),
            PopupMenuItem<String>(
              value: 'recurring',
              child: Row(children: <Widget>[
                Icon(Icons.repeat_outlined),
                const SizedBox(width: 12),
                Text(t?.ls_recurring_services ?? 'Recurring services'),
              ]),
            ),
            PopupMenuItem<String>(
              value: 'favorites',
              child: Row(children: <Widget>[
                Icon(Icons.favorite_border),
                const SizedBox(width: 12),
                Text(t?.ls_favorites ?? 'Favorites'),
              ]),
            ),
          ],
        ),
      ],
      slivers: <Widget>[
        if (_loading)
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int i) => const _SkeletonCard(),
                childCount: 6,
              ),
            ),
          )
        else if (_error != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else ...<Widget>[
          // Top-level category chips
          SliverToBoxAdapter(
            child: LsCategoryChipRow(
              categories: _topCategories.isNotEmpty ? _topCategories : _categories,
              selectedId: _selectedTop,
              mediaUrl: _mediaUrl,
              onSelected: (String? id) {
                setState(() {
                  _selectedTop = id;
                  _selectedCategory = id;
                  _subcategories = const <Map<String, dynamic>>[];
                });
                _load();
              },
            ),
          ),
          // Subcategory chips (drill-down for the selected top-level)
          if (_selectedTop != null && _subcategories.isNotEmpty)
            SliverToBoxAdapter(
              child: LsCategoryChipRow(
                categories: _subcategories,
                mediaUrl: _mediaUrl,
                selectedId: _selectedCategory == _selectedTop
                    ? null
                    : _selectedCategory,
                onSelected: (String? id) {
                  setState(() {
                    _selectedCategory = id ?? _selectedTop;
                  });
                  _load();
                },
              ),
            ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: (AppLocalizations.of(context)?.ls_search_hint ?? 'Search services'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (String v) => setState(() => _search = v),
              ),
            ),
          ),
          if (services.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(AppLocalizations.of(context)?.ls_no_services ?? 'No services found.')),
            )
          else ...<Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int i) {
                    final LsService s = visible[i];
                    return LsServiceCard(
                      service: s,
                      mediaUrl: _mediaUrl,
                      onTap: () => _openService(s),
                    );
                  },
                  childCount: visible.length,
                ),
              ),
            ),
            if (hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _visibleCount += 10),
                      icon: const Icon(Icons.expand_more),
                      label: Text(t?.ls_load_more(services.length - _visibleCount) ??
                          'Load more (${services.length - _visibleCount} remaining)'),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 14, width: 160, color: Colors.grey.shade300),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 220, color: Colors.grey.shade200),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 120, color: Colors.grey.shade200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

