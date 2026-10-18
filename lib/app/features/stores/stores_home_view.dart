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
import 'package:user/app/features/stores/stores_outlet_view.dart';

/// Nearby stores — the customer entry point for the vertical.
///
/// Shows active outlets near the customer. Inactive or suspended outlets never appear:
/// the server 404s them and excludes them from listings, so there is nothing here to
/// filter client-side and no "ghost store" state to handle.
class StoresHomeView extends StatefulWidget {
  const StoresHomeView({super.key, this.lat, this.lng});

  /// Where the customer is. `GET /nearby` requires both — it answers 400 without
  /// them and offers no "all stores" fallback — so when either is null this screen
  /// shows an empty state instead of firing a request it already knows will fail.
  /// Nothing in this app writes a location yet, so callers may legitimately pass
  /// none; that is a real gap, not a placeholder to paper over.
  final double? lat;
  final double? lng;

  @override
  State<StoresHomeView> createState() => _StoresHomeViewState();
}

class _StoresHomeViewState extends State<StoresHomeView> {
  final StoresCustomerService _service = StoresCustomerService();
  bool _loading = true;
  String? _error;
  List<dynamic> _outlets = const <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.lat == null || widget.lng == null) {
      setState(() {
        _loading = false;
        _outlets = const <dynamic>[];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.nearby(lat: widget.lat!, lng: widget.lng!);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load stores near you.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    setState(() {
      _loading = false;
      // `getNearbyOutlets` returns lean StoreOutlet docs: real `name`, `locality`,
      // `rating`, `ratingCount`. It uses `$near` without an aggregation stage, so
      // there is NO distance field — do not render one.
      _outlets = body['outlets'] as List? ?? const <dynamic>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores near you'),
        actions: <Widget>[
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _outlets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          widget.lat == null || widget.lng == null
                              ? 'Add a delivery address to see stores near you.'
                              : 'No stores nearby yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _outlets.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic outlet = _outlets[index];
                        final Map<String, dynamic> o =
                            outlet is Map<String, dynamic> ? outlet : <String, dynamic>{};
                        final String id = '${o['_id'] ?? o['id'] ?? o['slug'] ?? ''}';
                        return ListTile(
                          leading: const Icon(Icons.storefront_outlined),
                          title: Text('${o['name'] ?? 'Store'}'),
                          subtitle: Text(
                            <String>[
                              if ('${o['locality'] ?? ''}'.isNotEmpty) '${o['locality']}',
                              if (o['rating'] != null && '${o['rating']}' != '0')
                                '${o['rating']} ★ (${o['ratingCount'] ?? 0})',
                            ].join(' · '),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: id.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => StoresOutletView(storeId: id),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
    );
  }
}