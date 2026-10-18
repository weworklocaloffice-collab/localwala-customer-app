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
import 'package:user/app/features/stores/stores_checkout_view.dart';
import 'package:user/app/features/stores/stores_subscribe_view.dart';

/// The cart. Exactly one outlet per cart (BR-37).
///
/// The cart is keyed `(customer, outlet)`, so this screen is always opened FOR an outlet
/// and the outlet travels in the query on every read.
///
/// The server enforces the one-outlet rule with `409 CART_OUTLET_CONFLICT`, carrying both
/// outlet ids so the app can render the specification's dialog ("Your cart contains
/// products from another outlet") with its two explicit choices: clear here and shop
/// there, or check out there first. The server decides nothing on the customer's behalf,
/// and neither does this screen — it surfaces the conflict instead of silently merging or
/// clearing.
class StoresCartView extends StatefulWidget {
  const StoresCartView({super.key, required this.storeId, required this.chainId});

  final String storeId;

  /// Checkout needs the chain id: the order carries `chain` alongside `outlet`.
  final String chainId;

  @override
  State<StoresCartView> createState() => _StoresCartViewState();
}

class _StoresCartViewState extends State<StoresCartView> {
  final StoresCustomerService _service = StoresCustomerService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _cart = <String, dynamic>{};

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
    final response = await _service.cart(outlet: widget.storeId);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load your cart.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    setState(() {
      _loading = false;
      _cart = (body['cart'] as Map<String, dynamic>?) ?? body;
    });
  }

  Future<void> _updateQty(Map<String, dynamic> item, int delta) async {
    final int qty = ((item['quantity'] as num?)?.toInt() ?? 1) + delta;
    if (qty < 1) {
      await _remove(item);
      return;
    }
    final response = await _service.cartUpdate(<String, dynamic>{
      'variant': item['variant'],
      'quantity': qty,
    });
    if (!mounted) return;
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update quantity.')));
      return;
    }
    _load();
  }

  Future<void> _remove(Map<String, dynamic> item) async {
    final response = await _service.cartRemove(<String, dynamic>{
      'variant': item['variant'],
    });
    if (!mounted) return;
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not remove item.')));
      return;
    }
    _load();
  }

  Future<void> _clear() async {
    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Clear cart?'),
          content: const Text('This removes everything in your cart.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
    if (go != true) return;
    await _service.cartClear();
    if (!mounted) return;
    _load();
  }

  /// Builds `{ variant, quantity }` for the subscribe payload.
  ///
  /// Only those two fields. The server re-prices from the outlet's own rows at billing
  /// time (BR-36), so sending anything price-shaped would be ignored at best.
  List<Map<String, dynamic>> _subscribableItems() {
    final List<dynamic> items = (_cart['items'] as List?) ?? const <dynamic>[];
    final List<Map<String, dynamic>> out = <Map<String, dynamic>>[];
    for (final dynamic raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final dynamic variant = raw['variant'];
      // A populated variant reads back as a document; the cart GET populates it.
      final dynamic id = variant is Map ? variant['_id'] : variant;
      if (id == null) continue;
      out.add(<String, dynamic>{
        'variant': '$id',
        'quantity': (raw['quantity'] as num?)?.toInt() ?? 1,
      });
    }
    return out;
  }

  Future<void> _subscribe() async {
    final List<Map<String, dynamic>> items = _subscribableItems();
    if (items.isEmpty) {
      _snack('This cart cannot be subscribed to.');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StoresSubscribeView(storeId: widget.storeId, items: items),
      ),
    );
    // The cart is unchanged by subscribing, but re-reading keeps the totals honest if the
    // server moved anything while the sheet was open.
    await _load();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Checkout used to be absent from this screen, because `POST /orders` needs an
  // `addressId` and an `addressSnapshot` this feature could not reach. It can now: the
  // address book is a first-class API and `StoresCheckoutView` reads from it. The button
  // below opens that screen and nothing more — placing the order is its decision, not
  // this one's.

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = (_cart['items'] as List?) ?? const <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: <Widget>[
          if (items.isNotEmpty)
            IconButton(
              // "Deliver this on a schedule" lives on the cart because that is what a
              // subscription is: the same basket, recurring. Reaching it from anywhere
              // else would mean re-picking the items.
              tooltip: 'Subscribe',
              onPressed: _subscribe,
              icon: const Icon(Icons.autorenew),
            ),
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Clear cart',
              onPressed: _clear,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : items.isEmpty
                  ? const Center(child: Text('Your cart is empty.'))
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              final dynamic raw = items[index];
                              final Map<String, dynamic> item =
                                  raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                              final int qty = (item['quantity'] as num?)?.toInt() ?? 1;
                              return ListTile(
                                title: Text('${item['name'] ?? 'Item'}'),
                                subtitle: Text('${item['unitPrice'] ?? item['price'] ?? ''}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () => _updateQty(item, -1),
                                      icon: const Icon(Icons.remove),
                                    ),
                                    Text('$qty'),
                                    IconButton(
                                      onPressed: () => _updateQty(item, 1),
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Total ${(_cart['grandTotal'] ?? _cart['total'] ?? '')}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => StoresCheckoutView(
                                          storeId: widget.storeId,
                                          chainId: widget.chainId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Checkout'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}