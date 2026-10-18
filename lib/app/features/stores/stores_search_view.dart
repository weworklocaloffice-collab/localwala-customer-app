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

import 'dart:async';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Find a product across the chain catalogue.
///
/// Deliberately NOT store-scoped. `GET /products/search` matches on name/description across
/// active chain products and does not join the outlet table, so a result here is "this
/// exists in the catalogue" — not "this is on the shelf at your local store". The outlet's
/// own listing remains the source of truth for what can actually be bought, and the
/// product screen that follows is where that gets settled.
///
/// That distinction is worth stating plainly, because the alternative — silently showing
/// catalogue hits that the customer's local store cannot fulfil — is the kind of thing that
/// looks fine in a screenshot and fails at the till.
class StoresSearchView extends StatefulWidget {
  const StoresSearchView({super.key, this.outlet});

  /// Optional: passed through to narrow results, but never required.
  final String? outlet;

  @override
  State<StoresSearchView> createState() => _StoresSearchViewState();
}

class _StoresSearchViewState extends State<StoresSearchView> {
  final StoresCustomerService _service = StoresCustomerService();
  final TextEditingController _query = TextEditingController();

  Timer? _debounce;
  List<dynamic> _results = const <dynamic>[];
  bool _searching = false;
  bool _searched = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  /// One request per pause in typing.
  ///
  /// `?q=` is matched with a case-insensitive regex server-side, so a request per keystroke
  /// would run that regex across the whole catalogue that many times. The timer is cancelled
  /// in `dispose` so an in-flight debounce cannot fire against a dead State.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String raw) async {
    final String q = raw.trim();
    if (q.isEmpty) {
      setState(() {
        _results = const <dynamic>[];
        _searched = false;
      });
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
    });

    final response = await _service.searchProducts(q);

    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _searching = false;
        _searched = true;
        _error = 'Search failed.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    // listProducts returns `{ items, total, page, limit, totalPages }`.
    final List<dynamic> items = (body['items'] as List?) ?? const <dynamic>[];
    if (!mounted) return;
    setState(() {
      _results = items;
      _searching = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search products',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: _search,
        ),
      ),
      body: _searching
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _results.isNotEmpty
                  ? ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic raw = _results[index];
                        final Map<String, dynamic> p =
                            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                        return ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text('${p['name'] ?? 'Product'}'),
                          subtitle: Text('${p['basePrice'] ?? p['baseMrp'] ?? ''}'),
                          // Deliberately not tappable through to the outlet-scoped product
                          // screen: this list has no outlet, so there is nothing to scope to
                          // and opening one would imply availability this result does not
                          // establish. Finding the item is the end of this screen's job.
                        );
                      },
                    )
                  : _searched
                      ? const Center(child: Text('No matches.'))
                      : const Center(child: Text('Type to search the catalogue.')),
    );
  }
}