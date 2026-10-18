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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user/app/features/jhatka/jhatka_customer_money.dart'
    as jhatka_money;
import 'package:user/app/features/jhatka/jhatka_subscription_create_view.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// Product detail with per-variant add-to-cart.
///
/// WEIGHT variants take grams; COUNT variants (eggs, prawn tiers) take
/// pieces and are exact — never weighed, never adjusted. Prices carry `~`
/// for weight: the customer pays the estimate and any shortfall is refunded
/// automatically.
class JhatkaProductView extends StatefulWidget {
  const JhatkaProductView({super.key, required this.productId, this.outletId});

  final String productId;
  final String? outletId;

  @override
  State<JhatkaProductView> createState() => _JhatkaProductViewState();
}

class _JhatkaProductViewState extends State<JhatkaProductView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _product = const <String, dynamic>{};
  List<dynamic> _variants = const <dynamic>[];
  final Map<String, TextEditingController> _qty = <String, TextEditingController>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final TextEditingController c in _qty.values) {
      c.dispose();
    }
    super.dispose();
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
    setState(() {
      _loading = false;
      _product = body;
      _variants = (body['variants'] as List?) ?? const <dynamic>[];
    });
  }

  TextEditingController _controllerFor(String id) {
    return _qty.putIfAbsent(id, () => TextEditingController());
  }

  Future<void> _add(Map<String, dynamic> variant) async {
    final String id = (variant['id'] ?? variant['_id'] ?? '').toString();
    final String mode = (variant['measurementMode'] ?? 'WEIGHT').toString();
    final num? qty = num.tryParse((_qty[id]?.text ?? '').trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mode == 'COUNT'
                ? 'Enter pieces (a dozen is 12).'
                : 'Enter grams.',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    final response = await _service.addToCart(
      variant: id,
      quantity: <String, dynamic>{
        'value': qty,
        'unit': mode == 'COUNT' ? 'PIECE' : 'GRAM',
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.success ? 'Added to cart.' : 'Could not add that line.',
        ),
      ),
    );
    if (response.success) _qty[id]?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: <Widget>[
                      Text(
                        (_product['name'] ?? '').toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((_product['description'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _product['description'].toString(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 12),
                      ..._variants.map(_variantCard),
                    ],
                  ),
                ),
    );
  }

  Widget _variantCard(dynamic raw) {
    final Map<String, dynamic> variant =
        Map<String, dynamic>.from(raw as Map);
    final String id = (variant['id'] ?? variant['_id'] ?? '').toString();
    final String mode = (variant['measurementMode'] ?? 'WEIGHT').toString();
    final bool isCount = mode == 'COUNT';
    final bool inStock = (variant['inStock'] ?? true) == true;
    // Subscription-ineligible variants (eggs, whole fish) get no button at
    // all — offering one the server will refuse is a button that lies.
    final bool subscribable = variant['subscriptionEligible'] != false;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              (variant['name'] ?? variant['sku'] ?? '').toString(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Lean read: pricePerUnit arrives as RAW PAISE.
              isCount
                  ? '${variant['pricePerUnit'] is num ? jhatka_money.formatPaise(variant['pricePerUnit'] as num) : '—'} each · exact'
                  : '~${variant['pricePerUnit'] is num ? jhatka_money.formatPaise(variant['pricePerUnit'] as num) : '—'} '
                      '${(variant['priceBasis'] ?? '').toString()} · approx, you pay the lower',
              style: const TextStyle(fontSize: 13),
            ),
            if (!inStock)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Out of stock right now',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerFor(id),
                    enabled: inStock && !_busy,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: isCount ? 'Pieces' : 'Grams',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed:
                      inStock && !_busy ? () => _add(variant) : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                    child: Text('Add'),
                  ),
                ),
              ],
            ),
            // Subscribing is a separate commitment from buying once: ceiling
            // pricing, no per-occurrence reconciliation. Only offered where the
            // outlet can fulfil it (in stock) and the variant allows it, and
            // only where the screen knows which outlet this is.
            if (subscribable && inStock && widget.outletId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => JhatkaSubscriptionCreateView(
                          outletId: widget.outletId!,
                          presetVariantId: id,
                          presetVariantName: (variant['name'] ??
                                  variant['sku'] ??
                                  '')
                              .toString(),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Subscribe — standing delivery'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
