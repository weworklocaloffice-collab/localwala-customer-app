/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Ac 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/stores_product_view.dart';

/// A chain profile: brand, outlet picker, catalogue, policies and reviews.
///
/// The customer buys from an OUTLET, not the chain (BR-37). The chain owns the catalogue
/// and the policies, so this screen loads the chain first, selects an outlet for stock and
/// price, then re-uses the outlet id for the catalogue and product screen.
class StoresChainView extends StatefulWidget {
  const StoresChainView({super.key, required this.chainId, this.outletId});

  final String chainId;

  /// The outlet the customer tapped on the home card. When null the first eligible outlet
  /// is selected so the catalogue always has an availability context.
  final String? outletId;

  @override
  State<StoresChainView> createState() => _StoresChainViewState();
}

class _StoresChainViewState extends State<StoresChainView> with SingleTickerProviderStateMixin {
  final StoresCustomerService _service = StoresCustomerService();
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _chain = <String, dynamic>{};
  List<dynamic> _outlets = const <dynamic>[];
  List<dynamic> _products = const <dynamic>[];
  List<dynamic> _reviews = const <dynamic>[];
  List<dynamic> _offers = const <dynamic>[];
  List<dynamic> _policies = const <dynamic>[];
  String? _selectedOutletId;
  bool _favourite = false;
  bool _favouriteBusy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _selectedOutletId = widget.outletId;
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profileResponse = await _service.chain(widget.chainId);
      if (!mounted) return;
      if (!profileResponse.success) {
        setState(() {
          _loading = false;
          _error = 'Could not load this store.';
        });
        return;
      }

      final Map<String, dynamic> first = Map<String, dynamic>.from(
        jsonDecode(profileResponse.body) as Map,
      );
      final List<dynamic> outlets = first['outlets'] as List? ?? const <dynamic>[];
      final String? selected = _resolveSelection(outlets);
      final bool needsOutletProfile = selected != null && selected != '';

      final profileWithOutlet = needsOutletProfile
          ? await _service.chain(widget.chainId, outlet: selected)
          : profileResponse;

      final results = await Future.wait(<Future>[
        _service.chainProducts(widget.chainId, outlet: selected),
        _service.chainReviews(widget.chainId),
        _service.chainOffers(widget.chainId),
        _service.favourite(widget.chainId),
      ]);
      if (!mounted) return;

      final Map<String, dynamic> profile = profileWithOutlet.success
          ? Map<String, dynamic>.from(jsonDecode(profileWithOutlet.body) as Map)
          : first;

      Map<String, dynamic> decodeAt(int index) {
        final dynamic response = results[index];
        if (!response.success) return <String, dynamic>{};
        return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      }

      final Map<String, dynamic> products = decodeAt(0);
      final Map<String, dynamic> reviews = decodeAt(1);
      final Map<String, dynamic> offers = decodeAt(2);
      final Map<String, dynamic> favourite = decodeAt(3);

      setState(() {
        _loading = false;
        _chain = profile['chain'] as Map<String, dynamic>? ?? <String, dynamic>{};
        _outlets = profile['outlets'] as List? ?? outlets;
        _policies = profile['policies'] as List? ?? const <dynamic>[];
        _selectedOutletId = selected;
        _products = products['items'] as List? ?? const <dynamic>[];
        _reviews = reviews['items'] as List? ?? const <dynamic>[];
        _offers = offers['promotions'] as List? ?? const <dynamic>[];
        _favourite = favourite['favourite'] == true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this store.';
      });
    }
  }

  String? _resolveSelection(List<dynamic> outlets) {
    if (outlets.isEmpty) return null;
    final String requested = widget.outletId ?? '';
    if (requested.isNotEmpty) {
      final bool present = outlets.any((dynamic row) {
        final Map<String, dynamic> outlet = _asMap(row);
        return '${outlet['_id'] ?? outlet['id'] ?? ''}' == requested;
      });
      if (present) return requested;
    }
    final Map<String, dynamic> first = _asMap(outlets.first);
    final String id = '${first['_id'] ?? first['id'] ?? ''}';
    return id.isEmpty ? null : id;
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  Future<void> _selectOutlet(String id) async {
    if (id == _selectedOutletId) return;
    setState(() => _selectedOutletId = id);
    await _load();
  }

  Future<void> _toggleFavourite() async {
    if (_favouriteBusy) return;
    setState(() => _favouriteBusy = true);
    try {
      final dynamic response =
          _favourite ? await _service.removeFavourite(widget.chainId) : await _service.addFavourite(widget.chainId);
      if (!mounted) return;
      if (!response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save stores.')),
        );
        return;
      }
      setState(() => _favourite = !_favourite);
    } finally {
      if (mounted) setState(() => _favouriteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_chain['name'] ?? 'Store'}'),
        actions: <Widget>[
          IconButton(
            onPressed: _favouriteBusy ? null : _toggleFavourite,
            icon: Icon(_favourite ? Icons.favorite : Icons.favorite_border),
            tooltip: _favourite ? 'Remove from favourites' : 'Save store',
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'Products'),
            Tab(text: 'Offers'),
            Tab(text: 'Reviews'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : TabBarView(
                  controller: _tabs,
                  children: <Widget>[
                    _ProductsTab(
                      chainId: widget.chainId,
                      outletId: _selectedOutletId,
                      products: _products,
                    ),
                    _OffersTab(offers: _offers),
                    _ReviewsTab(reviews: _reviews),
                    _AboutTab(
                      chain: _chain,
                      outlets: _outlets,
                      policies: _policies,
                      selectedOutletId: _selectedOutletId,
                      onSelectOutlet: _selectOutlet,
                    ),
                  ],
                ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({required this.chainId, required this.outletId, required this.products});

  final String chainId;
  final String? outletId;
  final List<dynamic> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Nothing listed here yet.'));
    }
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic raw = products[index];
        final Map<String, dynamic> product =
            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final String id = '${product['_id'] ?? product['id'] ?? ''}';
        final dynamic availabilityRaw = product['availability'];
        final Map<String, dynamic> availability = availabilityRaw is Map<String, dynamic>
            ? availabilityRaw
            : <String, dynamic>{};
        final bool inStock = availability['inStock'] != false;
        final String price = '${product['basePrice'] ?? product['price'] ?? ''}';
        return ListTile(
          enabled: id.isNotEmpty,
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text('${product['name'] ?? 'Product'}'),
          subtitle: Text(
            <String>[
              if (price.isNotEmpty) price,
              if (availability['availableQty'] != null)
                inStock ? 'In stock' : 'Out of stock at this outlet',
            ].join(' · '),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: id.isEmpty || outletId == null
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StoresProductView(
                        productId: id,
                        storeId: outletId!,
                        chainId: chainId,
                      ),
                    ),
                  );
                },
        );
      },
    );
  }
}

class _OffersTab extends StatelessWidget {
  const _OffersTab({required this.offers});

  final List<dynamic> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const Center(child: Text('No offers right now.'));
    return ListView.separated(
      itemCount: offers.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic raw = offers[index];
        final Map<String, dynamic> offer =
            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final String code = '${offer['code'] ?? ''}';
        final dynamic outlet = offer['outlet'];
        final String outletName = outlet is Map ? '${outlet['name'] ?? ''}' : '';
        return ListTile(
          leading: const Icon(Icons.local_offer_outlined),
          title: Text('${offer['name'] ?? 'Offer'}'),
          subtitle: Text(
            <String>[
              if ('${offer['description'] ?? ''}'.isNotEmpty) '${offer['description']}',
              if (outletName.isNotEmpty) 'At $outletName',
              if (code.isNotEmpty) 'Code: $code',
            ].join('\n'),
          ),
          isThreeLine: code.isNotEmpty,
        );
      },
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.reviews});

  final List<dynamic> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const Center(child: Text('No reviews yet.'));
    return ListView.separated(
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic raw = reviews[index];
        final Map<String, dynamic> review =
            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        return ListTile(
          leading: const Icon(Icons.rate_review_outlined),
          title: Text('${review['title'] ?? 'Review'}'),
          subtitle: Text('${review['comment'] ?? ''}'),
          trailing: Text('${review['rating'] ?? ''} ★'),
        );
      },
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.chain,
    required this.outlets,
    required this.policies,
    required this.selectedOutletId,
    required this.onSelectOutlet,
  });

  final Map<String, dynamic> chain;
  final List<dynamic> outlets;
  final List<dynamic> policies;
  final String? selectedOutletId;
  final ValueChanged<String> onSelectOutlet;

  static const List<String> _policyOrder = <String>[
    'return',
    'exchange',
    'cancellation',
    'warranty',
    'delivery',
    'privacy',
    'terms',
  ];

  @override
  Widget build(BuildContext context) {
    final String description = '${chain['description'] ?? ''}';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (description.isNotEmpty) ...<Widget>[
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
        ],
        Text('Choose an outlet', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (outlets.isEmpty)
          const Text('No outlets are available for delivery right now.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: outlets.map((dynamic raw) {
              final dynamic value = raw;
              final Map<String, dynamic> outlet =
                  value is Map<String, dynamic> ? value : <String, dynamic>{};
              final String id = '${outlet['_id'] ?? outlet['id'] ?? ''}';
              final bool isOpen = outlet['isOpenNow'] != false;
              return ChoiceChip(
                label: Text('${outlet['name'] ?? 'Outlet'}${isOpen ? '' : ' · closed'}'),
                selected: id == selectedOutletId,
                onSelected: id.isEmpty ? null : (_) => onSelectOutlet(id),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        Text('Policies', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (policies.isEmpty)
          const Text('This store has not published its policies yet.')
        else
          ..._policyOrder.map((String type) {
            final dynamic match = policies.cast<dynamic>().firstWhere(
                  (dynamic raw) {
                    final dynamic value = raw;
                    return value is Map && '${value['type']}' == type;
                  },
                  orElse: () => null,
                );
            if (match == null) return const SizedBox.shrink();
            final Map<String, dynamic> policy =
                match is Map<String, dynamic> ? match : <String, dynamic>{};
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text('${policy['title'] ?? type}'),
                subtitle: _windowText(policy),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${policy['content'] ?? ''}'),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget? _windowText(Map<String, dynamic> policy) {
    if (policy['returnWindowDays'] != null && policy['type'] == 'return') {
      return Text('${policy['returnWindowDays']} days');
    }
    if (policy['exchangeWindowDays'] != null && policy['type'] == 'exchange') {
      return Text('${policy['exchangeWindowDays']} days');
    }
    if (policy['warrantyDefaultMonths'] != null && policy['type'] == 'warranty') {
      return Text('${policy['warrantyDefaultMonths']} months');
    }
    if (policy['cancellationWindowHours'] != null && policy['type'] == 'cancellation') {
      return Text('${policy['cancellationWindowHours']} hours');
    }
    return null;
  }
}
