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
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// One SKU with its price, quantity stepper and add-to-cart.
class DairyProductView extends StatefulWidget {
  final String productId;
  const DairyProductView({super.key, required this.productId});

  @override
  State<DairyProductView> createState() => _DairyProductViewState();
}

class _DairyProductViewState extends State<DairyProductView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  Map<String, dynamic> _product = <String, dynamic>{};
  String? _error;
  int _qty = 1;

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
    final r = await _service.skuList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) {
        final list = decodeList(jsonDecode(r.body));
        for (final dynamic e in list) {
          if (e is Map && (e['_id']?.toString() == widget.productId || e['id']?.toString() == widget.productId)) {
            _product = Map<String, dynamic>.from(e);
            break;
          }
        }
        if (_product.isEmpty && list.isNotEmpty) {
          _product = Map<String, dynamic>.from(list.first as Map);
        }
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_product;
      }
    });
  }

  Future<void> _addToCart() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final String sku = _product['_id']?.toString() ?? _product['id']?.toString() ?? widget.productId;
    final r = await _service.addToCart(sku: sku, quantity: _qty);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? t.dairy_added_to_cart : t.dairy_could_not_add)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: Text(t.dairy_product)), body: Center(child: Text(_error!)));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_product['name']?.toString() ?? t.dairy_product)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_product['name']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_product['packSize'] != null) Text(t.dairy_pack_label(_product['packSize'].toString())),
            Text(t.dairy_price_label(formatMoney(_product['price']))),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                IconButton(onPressed: () => setState(() { if (_qty > 1) _qty--; }), icon: const Icon(Icons.remove)),
                Text('$_qty'),
                IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _addToCart, child: Text(t.dairy_add_to_cart)),
          ],
        ),
      ),
    );
  }
}
