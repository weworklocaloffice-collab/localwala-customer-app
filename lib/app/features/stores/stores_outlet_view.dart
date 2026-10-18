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
import 'package:user/app/features/stores/stores_product_view.dart';

/// One store: profile, products, reviews, offers.
///
/// BR-36 is why this screen has two data sources: the CHAIN owns the catalogue (names,
/// descriptions, images) and the OUTLET owns availability and price. A product listed here
/// is sellable at this outlet; the same product may be absent two streets away, and that
/// is correct rather than a sync bug.
class StoresOutletView extends StatefulWidget {
  const StoresOutletView({super.key, required this.storeId});

  final String storeId;

  @override
  State<StoresOutletView> createState() => _StoresOutletViewState();
}

class _StoresOutletViewState extends State<StoresOutletView> with SingleTickerProviderStateMixin {
  final StoresCustomerService _service = StoresCustomerService();
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _store = <String, dynamic>{};
  List<dynamic> _products = const <dynamic>[];
  List<dynamic> _reviews = const <dynamic>[];
  List<dynamic> _offers = const <dynamic>[];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
      final results = await Future.wait(<Future>[
        _service.store(widget.storeId),
        _service.storeProducts(widget.storeId),
        _service.storeReviews(widget.storeId),
        _service.storeOffers(widget.storeId),
      ]);
      if (!mounted) return;
      if (results.any((r) => !r.success)) {
        setState(() {
          _loading = false;
          _error = 'Could not load this store.';
        });
        return;
      }
      Map<String, dynamic> decode(dynamic response) =>
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      // Exact response keys, verified against stores.customer.route.js: the profile
      // route sends `{ outlet }`, and the paged list routes send
      // `{ items, total, page, limit, totalPages }` — not `products`/`data`.
      // Offers are the exception: that route sends `{ promotions }`.
      final Map<String, dynamic> store = decode(results[0]);
      final Map<String, dynamic> products = decode(results[1]);
      final Map<String, dynamic> reviews = decode(results[2]);
      final Map<String, dynamic> offers = decode(results[3]);
      setState(() {
        _loading = false;
        _store = store['outlet'] as Map<String, dynamic>? ?? <String, dynamic>{};
        _products = products['items'] as List? ?? const <dynamic>[];
        _reviews = reviews['items'] as List? ?? const <dynamic>[];
        _offers = offers['promotions'] as List? ?? const <dynamic>[];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this store.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_store['name'] ?? 'Store'}'),
        actions: <Widget>[
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Widget>[
            Tab(text: 'Products'),
            Tab(text: 'Reviews'),
            Tab(text: 'Offers'),
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
                    _ProductList(
                      products: _products,
                      // The chain comes from the POPULATED profile, not from the product
                      // row: `GET /:store` populates `chain` with `name slug logo`, and
                      // `POST /cart/add` needs that chain's id. Taking it from the
                      // product instead would work only when the product happens to be
                      // joined, which the browse route does not do.
                      storeId: widget.storeId,
                      chainId: '${(_store['chain'] is Map) ? (_store['chain'] as Map)['_id'] ?? '' : ''}',
                      onOpen: (String id) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StoresProductView(
                              productId: id,
                              storeId: widget.storeId,
                              chainId: '${(_store['chain'] is Map) ? (_store['chain'] as Map)['_id'] ?? '' : ''}',
                            ),
                          ),
                        );
                      },
                    ),
                    _ReviewList(reviews: _reviews),
                    _OfferList(offers: _offers),
                  ],
                ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products, required this.storeId, required this.chainId, required this.onOpen});

  final List<dynamic> products;
  final String storeId;
  final String chainId;
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Nothing listed here yet.'));
    }
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic p = products[index];
        final Map<String, dynamic> product =
            p is Map<String, dynamic> ? p : <String, dynamic>{};
        final String id = '${product['_id'] ?? product['id'] ?? ''}';
        return ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text('${product['name'] ?? 'Product'}'),
          subtitle: Text('${product['price'] ?? product['mrp'] ?? ''}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: id.isEmpty ? null : () => onOpen(id),
        );
      },
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.reviews});

  final List<dynamic> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text('No reviews yet.'));
    }
    return ListView.separated(
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic r = reviews[index];
        final Map<String, dynamic> review =
            r is Map<String, dynamic> ? r : <String, dynamic>{};
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

class _OfferList extends StatelessWidget {
  const _OfferList({required this.offers});

  final List<dynamic> offers;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return const Center(child: Text('No offers right now.'));
    }
    return ListView.separated(
      itemCount: offers.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final dynamic o = offers[index];
        final Map<String, dynamic> offer =
            o is Map<String, dynamic> ? o : <String, dynamic>{};
        return ListTile(
          leading: const Icon(Icons.local_offer_outlined),
          title: Text('${offer['title'] ?? offer['name'] ?? 'Offer'}'),
          subtitle: Text('${offer['description'] ?? ''}'),
        );
      },
    );
  }
}