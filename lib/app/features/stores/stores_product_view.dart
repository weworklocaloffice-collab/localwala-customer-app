/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
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
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/stores_cart_view.dart';
import 'package:user/app/features/stores/stores_subscribe_view.dart';

/// One product: what it is, what it costs HERE, and how to buy it.
///
/// The price shown is the outlet's (`resolveBasket` recomputes server-side from the
/// outlet row). A price the client sends is not trusted, so this screen sends product +
/// variant + quantity and nothing else — the server answers with what it actually costs.
///
/// BR-11: attributes are template-driven, so this screen renders whatever attribute rows
/// arrive rather than a per-category form. A twenty-first category with new attributes
/// needs no client change.
class StoresProductView extends StatefulWidget {
  const StoresProductView({
    super.key,
    required this.productId,
    required this.storeId,
    required this.chainId,
    this.service,
  });

  final String productId;

  /// The outlet and its chain. `POST /cart/add` requires BOTH as ObjectIds, and the
  /// cart is keyed `(customer, outlet)` so BR-37 is decided from the outlet the customer
  /// is actually browsing — not from whatever they last added elsewhere.
  final String storeId;
  final String chainId;

  /// Scripted in widget tests; production reads the app's own service.
  final StoresCustomerService? service;

  @override
  State<StoresProductView> createState() => _StoresProductViewState();
}

class _StoresProductViewState extends State<StoresProductView> {
  late final StoresCustomerService _service;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _product = <String, dynamic>{};
  List<dynamic> _variants = const <dynamic>[];
  String? _selectedVariantId;
  int _quantity = 1;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.product(widget.productId);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load this product.';
      });
      return;
    }
    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not read this product.';
      });
      return;
    }
    final Map<String, dynamic> product =
        (body['product'] as Map<String, dynamic>?) ?? body;
    final List<dynamic> variants =
        (product['variants'] as List?) ?? const <dynamic>[];
    setState(() {
      _loading = false;
      _product = product;
      _variants = variants;
      // Server sorts by name, so the first is a stable default rather than an arbitrary
      // one. The customer can pick another below.
      _selectedVariantId = variants.isEmpty
          ? null
          : '${(variants.first as Map<String, dynamic>)['_id'] ?? ''}';
      if (_selectedVariantId == 'null' || _selectedVariantId == '') _selectedVariantId = null;
    });
  }

  Map<String, dynamic>? get _selectedVariant {
    if (_selectedVariantId == null) return null;
    for (final dynamic v in _variants) {
      if (v is Map<String, dynamic> && '${v['_id']}' == _selectedVariantId) {
        return v;
      }
    }
    return null;
  }

  Future<void> _addToCart() async {
    final Map<String, dynamic>? variant = _selectedVariant;
    if (variant == null) {
      _snack('Choose an option first.');
      return;
    }
    setState(() => _adding = true);
    try {
      Future<DioApiResponse> add() => _service.cartAdd(<String, dynamic>{
        'outlet': widget.storeId,
        'chain': widget.chainId,
        'product': widget.productId,
        'variant': variant['_id'],
        'quantity': _quantity,
      });

      DioApiResponse response = await add();
      if (!mounted) return;

      if (!response.success) {
        final Map<String, dynamic> body = response.body.isEmpty
            ? const <String, dynamic>{}
            : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        if ('${body['code'] ?? ''}' != 'CART_OUTLET_CONFLICT') {
          _snack('Could not add to cart.');
          return;
        }

        // BR-37: never merge and never clear silently. The server refuses the add and
        // returns both outlet ids; the customer makes the choice here.
        final bool? clear = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text(
              'Your cart contains products from another outlet',
            ),
            content: const Text(
              'A cart can only hold items from one outlet. Clear the existing cart and add this item?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Clear cart and continue'),
              ),
            ],
          ),
        );
        if (clear != true || !mounted) return;

        final DioApiResponse cleared = await _service.cartClear();
        if (!mounted) return;
        if (!cleared.success) {
          _snack('Could not clear the existing cart.');
          return;
        }
        response = await add();
        if (!mounted) return;
        if (!response.success) {
          _snack('Could not add to cart.');
          return;
        }
      }

      _snack('Added to cart');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              StoresCartView(storeId: widget.storeId, chainId: widget.chainId),
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> attributes =
        (_product['attributes'] as List?) ?? const <dynamic>[];

    return Scaffold(
      appBar: AppBar(title: Text('${_product['name'] ?? 'Product'}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Text(
                  '${_product['name'] ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedVariant?['price'] ?? _product['basePrice'] ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Price at this store. What you pay is confirmed at checkout.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if ((_product['description'] ?? '') != '') ...<Widget>[
                  const SizedBox(height: 12),
                  Text('${_product['description']}'),
                ],
                if (_product['brandCertified'] == false) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.warning_amber_rounded, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Unverified seller for this brand',
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Variants, not a hand-built form: BR-11 means the axes are data, so
                // whatever the server sends is what is offered here.
                if (_variants.length > 1) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    'Options',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final dynamic v in _variants)
                        if (v is Map<String, dynamic>)
                          ChoiceChip(
                            label: Text('${v['name'] ?? ''}'),
                            selected: '${v['_id']}' == _selectedVariantId,
                            onSelected: (_) => setState(
                              () => _selectedVariantId = '${v['_id']}',
                            ),
                          ),
                    ],
                  ),
                ],
                if (_variants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'This product has no options available, so it cannot be '
                      'added to a cart yet.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (attributes.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final dynamic a in attributes)
                    ListTile(
                      dense: true,
                      title: Text('${a is Map ? a['label'] ?? a['key'] : a}'),
                      subtitle: a is Map ? Text('${a['value'] ?? ''}') : null,
                    ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: _adding || _quantity <= 1
                          ? null
                          : () => setState(() => _quantity -= 1),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: _adding
                          ? null
                          : () => setState(() => _quantity += 1),
                      icon: const Icon(Icons.add),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: (_adding || _selectedVariant == null)
                          ? null
                          : _addToCart,
                      child: _adding
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add to cart'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: (_adding || _selectedVariant == null)
                          ? null
                          : () {
                              final String? vId = _selectedVariant?['_id']?.toString();
                              if (vId == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => StoresSubscribeView(
                                    storeId: widget.storeId,
                                    items: <Map<String, dynamic>>[
                                      <String, dynamic>{
                                        'variant': vId,
                                        'quantity': _quantity,
                                      },
                                    ],
                                  ),
                                ),
                              );
                            },
                      child: const Text('Subscribe'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
