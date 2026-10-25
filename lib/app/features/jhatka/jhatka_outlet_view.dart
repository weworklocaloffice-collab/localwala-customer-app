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
import 'package:user/app/features/jhatka/jhatka_cart_view.dart';
import 'package:user/app/features/jhatka/jhatka_orders_view.dart';
import 'package:user/app/features/jhatka/jhatka_customer_money.dart'
    as jhatka_money;
import 'package:user/app/features/jhatka/jhatka_product_view.dart';
import 'package:user/app/features/jhatka/jhatka_subscriptions_view.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// One shop's public card: name, address, service radius and how soon it
/// can deliver.
///
/// Only active outlets resolve — the server 404s anything else, so a closed
/// shop reads as "not found" rather than as a shop with no stock. From here
/// the customer goes to the cart or to subscriptions; product browsing hangs
/// off the product route once a listing endpoint can scope it by outlet.
class JhatkaOutletView extends StatefulWidget {
  const JhatkaOutletView({super.key, required this.outletId});

  final String outletId;

  @override
  State<JhatkaOutletView> createState() => _JhatkaOutletViewState();
}

class _JhatkaOutletViewState extends State<JhatkaOutletView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _outlet = const <String, dynamic>{};
  List<dynamic> _products = const <dynamic>[];

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
    final response = await _service.outlet(widget.outletId);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = response.statusCode == 404
            ? 'This outlet is not available right now.'
            : 'Could not load this outlet.';
      });
      return;
    }
    setState(() {
      _loading = false;
      _outlet =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    });
    final products = await _service.outletProducts(widget.outletId);
    if (!mounted || !products.success) return;
    setState(() {
      _products = (Map<String, dynamic>.from(
                jsonDecode(products.body) as Map,
              )['products'] as List?) ??
          const <dynamic>[];
    });
  }

  void _go(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  Widget _productTile(dynamic raw) {
    final Map<String, dynamic> product =
        Map<String, dynamic>.from(raw as Map);
    final List<dynamic> variants =
        (product['variants'] as List?) ?? const <dynamic>[];
    final String productId =
        (product['id'] ?? product['_id'] ?? '').toString();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        title: Text((product['name'] ?? '').toString()),
        subtitle: Text('${variants.length} variant(s)'),
        children: variants.map((dynamic rawVariant) {
          final Map<String, dynamic> variant =
              Map<String, dynamic>.from(rawVariant as Map);
          // Lean paise reads — never raw.
          final String price = variant['pricePerUnit'] is num
              ? jhatka_money.formatPaise(variant['pricePerUnit'] as num)
              : '—';
          return ListTile(
            dense: true,
            title: Text((variant['name'] ?? variant['sku'] ?? '').toString()),
            subtitle: Text(
              '$price'
              '${(variant['priceOverridden'] ?? false) == true ? ' (offer)' : ''} · '
              '${(variant['inStock'] ?? true) == true ? 'in stock' : 'out of stock'}',
            ),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: productId.isEmpty
                ? null
                : () => _go(JhatkaProductView(
                      productId: productId,
                      outletId: widget.outletId,
                    )),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outlet')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                (_outlet['name'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if ((_outlet['outletCode'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text(
                                  (_outlet['outletCode'] ?? '').toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                (_outlet['address'] ??
                                        _outlet['locality'] ??
                                        '')
                                    .toString(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Delivers within ${(_outlet['serviceRadiusKm'] ?? 5).toString()} km'
                                ' · from ${(_outlet['minDeliveryMinutes'] ?? '—').toString()} min',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Prices and availability are estimates; the order confirms both.',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      ..._products.map(_productTile),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            _go(const JhatkaCartView()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            'View cart',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            _go(const JhatkaOrdersView()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('My orders'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () =>
                            _go(const JhatkaSubscriptionsView()),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Subscriptions'),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
