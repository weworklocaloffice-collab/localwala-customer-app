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
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/stores_cart_view.dart';

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
  });

  final String productId;

  /// The outlet and its chain. `POST /cart/add` requires BOTH as ObjectIds, and the
  /// cart is keyed `(customer, outlet)` so BR-37 is decided from the outlet the customer
  /// is actually browsing — not from whatever they last added elsewhere.
  final String storeId;
  final String chainId;

  @override
  State<StoresProductView> createState() => _StoresProductViewState();
}

class _StoresProductViewState extends State<StoresProductView> {
  final StoresCustomerService _service = StoresCustomerService();
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
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
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
          : '${(variants.first as Map<String, dynamic>)['_id']}';
    });
  }

  Map<String, dynamic>? get _selectedVariant {
    if (_selectedVariantId == null) return null;
    for (final dynamic v in _variants) {
      if (v is Map<String, dynamic> && '${v['_id']}' == _selectedVariantId) return v;
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
      final response = await _service.cartAdd(<String, dynamic>{
        'outlet': widget.storeId,
        'chain': widget.chainId,
        'product': widget.productId,
        'variant': variant['_id'],
        'quantity': _quantity,
      });
      if (!mounted) return;
      if (!response.success) {
        final Map<String, dynamic> body = response.body.isEmpty
            ? const <String, dynamic>{}
            : Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        final String code = '${body['code'] ?? ''}';
        if (code == 'CART_OUTLET_CONFLICT') {
          // BR-37, surfaced rather than pre-empted. The app does not merge carts and does
          // not clear one on the customer's behalf; it reports the conflict and lets them
          // decide.
          _snack('Your cart has items from another store. Clear it first, or check out there.');
          return;
        }
        _snack('Could not add to cart.');
        return;
      }
      if (!mounted) return;
      _snack('Added to cart');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => StoresCartView(
            storeId: widget.storeId,
            chainId: widget.chainId,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> attributes = (_product['attributes'] as List?) ?? const <dynamic>[];

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
                    // Variants, not a hand-built form: BR-11 means the axes are data, so
                    // whatever the server sends is what is offered here.
                    if (_variants.length > 1) ...<Widget>[
                      const SizedBox(height: 16),
                      Text('Options', style: Theme.of(context).textTheme.titleMedium),
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
                      Text('Details', style: Theme.of(context).textTheme.titleMedium),
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
                        Text('$_quantity', style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          onPressed: _adding ? null : () => setState(() => _quantity += 1),
                          icon: const Icon(Icons.add),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: (_adding || _selectedVariant == null) ? null : _addToCart,
                          child: _adding
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Add to cart'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}