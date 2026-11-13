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
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Returns and exchanges, from the customer side.
///
/// The customer only chooses WHICH purchased lines and WHAT went wrong. The
/// server derives the outlet, chain, product snapshot, refund amount and
/// exchange price difference from the order, so nothing money-related is sent
/// from here. Approving, inspecting and refunding happen on the partner side.
class StoresSupportView extends StatefulWidget {
  const StoresSupportView({super.key, required this.orderId});

  /// The delivered order's id. The order (with its items) is fetched on
  /// mount so the view never depends on a caller passing a stale map.
  final String orderId;

  @override
  State<StoresSupportView> createState() => _StoresSupportViewState();
}

class _StoresSupportViewState extends State<StoresSupportView> {
  static const List<String> _conditions = <String>[
    'unopened',
    'opened_unused',
    'defective',
    'damaged',
    'wrong_item',
    'other',
  ];

  final StoresCustomerService _service = StoresCustomerService();
  final TextEditingController _reason = TextEditingController();
  final Map<int, bool> _selected = <int, bool>{};
  final Map<int, int> _quantities = <int, int>{};
  final Map<int, List<Map<String, dynamic>>> _replacementOptions =
      <int, List<Map<String, dynamic>>>{};
  final Map<int, String> _replacementChoices = <int, String>{};
  String _condition = 'damaged';
  bool _busy = false;

  Map<String, dynamic> _order = <String, dynamic>{};
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> get _items {
    final List<dynamic> raw =
        _order['items'] as List? ?? const <dynamic>[];
    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

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
    try {
      final response = await _service.orderTracking(widget.orderId);
      if (!mounted) return;
      if (!response.success) {
        setState(() {
          _loading = false;
          _error = 'Could not load order.';
        });
        return;
      }
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() {
        _order = (body['order'] as Map<String, dynamic>?) ?? body;
        _loading = false;
      });
      for (int i = 0; i < _items.length; i += 1) {
        _selected[i] = true;
        _quantities[i] = 1;
      }
      _loadReplacementOptions();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load order.';
      });
    }
  }

  /// Exchange replacements are optional. A size or colour change is the same
  /// product with another variant, so the catalogue detail endpoint is enough
  /// to offer one. Failures are silent: the server still defaults to the
  /// purchased variant, and the exchange remains valid without a picker.
  Future<void> _loadReplacementOptions() async {
    final List<Map<String, dynamic>> items = _items;
    final Map<int, List<Map<String, dynamic>>> loaded =
        <int, List<Map<String, dynamic>>>{};
    for (int i = 0; i < items.length; i += 1) {
      final String product = '${items[i]['product'] ?? ''}';
      if (product.isEmpty) continue;
      final DioApiResponse response = await _service.product(product);
      if (!mounted) return;
      if (!response.success) continue;
      try {
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        final Object? rawProduct = body['product'];
        final Map<String, dynamic> detail = rawProduct is Map
            ? Map<String, dynamic>.from(rawProduct)
            : body;
        final List<dynamic> rawVariants =
            detail['variants'] as List? ?? const <dynamic>[];
        final List<Map<String, dynamic>> variants = rawVariants
            .whereType<Map>()
            .map(
              (Map<dynamic, dynamic> variant) =>
                  Map<String, dynamic>.from(variant),
            )
            .where(
              (Map<String, dynamic> variant) =>
                  '${variant['_id'] ?? ''}'.isNotEmpty,
            )
            .toList();
        if (variants.length > 1) loaded[i] = variants;
      } catch (_) {
        continue;
      }
    }
    if (!mounted || loaded.isEmpty) return;
    setState(() => _replacementOptions.addAll(loaded));
  }

  String _replacementFor(int index, Map<String, dynamic> item) {
    final String original = '${item['variant'] ?? ''}';
    final String? choice = _replacementChoices[index];
    if (choice == null) return original;
    final List<Map<String, dynamic>>? options = _replacementOptions[index];
    if (options == null) return original;
    for (final Map<String, dynamic> option in options) {
      if ('${option['_id']}' == choice) return choice;
    }
    return original;
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _serverMessage(DioApiResponse response) {
    try {
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      final String message = '${body['message'] ?? ''}'.trim();
      return message.isEmpty ? 'Could not submit the request.' : message;
    } catch (_) {
      return 'Could not submit the request.';
    }
  }

  int _maxQuantity(Map<String, dynamic> item) {
    final int quantity = item['quantity'] is num
        ? (item['quantity'] as num).toInt()
        : 1;
    return quantity < 1 ? 1 : quantity;
  }

  Future<void> _submit(bool isExchange) async {
    final String reason = _reason.text.trim();
    if (reason.length < 3) {
      _snack('Please say what went wrong.');
      return;
    }

    final List<Map<String, dynamic>> items = <Map<String, dynamic>>[];
    for (int i = 0; i < _items.length; i += 1) {
      if (_selected[i] != true) continue;
      final Map<String, dynamic> item = _items[i];
      final String product = '${item['product'] ?? ''}';
      final String variant = '${item['variant'] ?? ''}';
      if (product.isEmpty || variant.isEmpty) continue;
      final int quantity = _quantities[i] ?? 1;
      final String replacement = isExchange
          ? _replacementFor(i, item)
          : variant;
      items.add(
        isExchange
            ? <String, dynamic>{
                'originalProduct': product,
                'originalVariant': variant,
                'quantity': quantity,
                'reason': reason,
                'condition': _condition,
                if (replacement != variant) ...<String, dynamic>{
                  'exchangeForProduct': product,
                  'exchangeForVariant': replacement,
                },
              }
            : <String, dynamic>{
                'product': product,
                'variant': variant,
                'quantity': quantity,
                'reason': reason,
                'condition': _condition,
              },
      );
    }

    if (items.isEmpty) {
      _snack('Select at least one item.');
      return;
    }

      final String orderId = '${_order['_id'] ?? _order['id'] ?? widget.orderId}';
    if (orderId.isEmpty) {
      _snack('This order cannot be found.');
      return;
    }

    setState(() => _busy = true);
    try {
      final Map<String, dynamic> body = <String, dynamic>{
        'order': orderId,
        'items': items,
        'reason': reason,
      };
      final DioApiResponse response = isExchange
          ? await _service.createExchange(body)
          : await _service.createReturn(body);
      if (!mounted) return;
      if (!response.success) {
        _snack(_serverMessage(response));
        return;
      }
      _snack(isExchange ? 'Exchange requested.' : 'Return requested.');
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Returns & exchanges')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(_error!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Choose the items you want to return or exchange. The outlet reviews '
            'every request - nothing here is decided automatically.',
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('This order has no returnable items.')
          else
            ...List<Widget>.generate(items.length, (int index) {
              final Map<String, dynamic> item = items[index];
              final int maxQuantity = _maxQuantity(item);
              final bool selected = _selected[index] == true;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: <Widget>[
                    CheckboxListTile(
                      value: selected,
                      onChanged: _busy
                          ? null
                          : (bool? value) {
                              setState(() => _selected[index] = value == true);
                            },
                      title: Text(
                        item['variantName'] == null
                            ? '${item['name'] ?? 'Item'}'
                            : '${item['name']} - ${item['variantName']}',
                      ),
                      subtitle: Text('Purchased quantity: $maxQuantity'),
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: <Widget>[
                            const Text('Returning'),
                            IconButton(
                              onPressed: _busy || (_quantities[index] ?? 1) <= 1
                                  ? null
                                  : () {
                                      setState(() {
                                        _quantities[index] =
                                            (_quantities[index] ?? 1) - 1;
                                      });
                                    },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${_quantities[index] ?? 1}'),
                            IconButton(
                              onPressed:
                                  _busy ||
                                      (_quantities[index] ?? 1) >= maxQuantity
                                  ? null
                                  : () {
                                      setState(() {
                                        _quantities[index] =
                                            (_quantities[index] ?? 1) + 1;
                                      });
                                    },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                    if (selected &&
                        (_replacementOptions[index]?.length ?? 0) > 1)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text('Exchange replacement (optional)'),
                            const SizedBox(height: 4),
                            DropdownButton<String>(
                              value: _replacementFor(index, item),
                              isExpanded: true,
                              onChanged: _busy
                                  ? null
                                  : (String? value) {
                                      if (value == null) return;
                                      setState(() {
                                        _replacementChoices[index] = value;
                                      });
                                    },
                              items: <DropdownMenuItem<String>>[
                                DropdownMenuItem<String>(
                                  value: '${item['variant'] ?? ''}',
                                  child: const Text('Same item'),
                                ),
                                ...?_replacementOptions[index]
                                    ?.where(
                                      (Map<String, dynamic> option) =>
                                          '${option['_id']}' !=
                                          '${item['variant'] ?? ''}',
                                    )
                                    .map(
                                      (Map<String, dynamic> option) =>
                                          DropdownMenuItem<String>(
                                            value: '${option['_id']}',
                                            child: Text(
                                              '${option['name'] ?? 'Option'}',
                                            ),
                                          ),
                                    ),
                              ],
                            ),
                            const Text(
                              'Any price difference is calculated by the '
                              'outlet when it reviews the exchange.',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          DropdownButton<String>(
            value: _condition,
            isExpanded: true,
            items: _conditions
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: _busy
                ? null
                : (String? value) {
                    if (value != null) setState(() => _condition = value);
                  },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'What went wrong?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _submit(false),
                  child: const Text('Request return'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _submit(true),
                  child: const Text('Request exchange'),
                ),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
