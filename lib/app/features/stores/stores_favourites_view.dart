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
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/stores_chain_view.dart';

/// Saved CHAINS, not outlets.
///
/// A favourite survives the usual outlet closing or changing, which is the reason the
/// server stores the chain (BR-18). Tapping a saved brand needs an open outlet, so the
/// nearby list is loaded alongside and the first operational outlet of that chain opens.
class StoresFavouritesView extends StatefulWidget {
  const StoresFavouritesView({super.key, this.lat, this.lng});

  final double? lat;
  final double? lng;

  @override
  State<StoresFavouritesView> createState() => _StoresFavouritesViewState();
}

class _StoresFavouritesViewState extends State<StoresFavouritesView> {
  final StoresCustomerService _service = StoresCustomerService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _favourites = <Map<String, dynamic>>[];
  List<dynamic> _outlets = const <dynamic>[];

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
      final favourites = await _service.favourites();
      if (!mounted) return;
      if (!favourites.success) {
        setState(() {
          _loading = false;
          _error = 'Sign in to see your saved stores.';
        });
        return;
      }
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(favourites.body) as Map);
      final List<dynamic> items = (body['items'] as List?) ?? const <dynamic>[];

      List<dynamic> outlets = const <dynamic>[];
      if (widget.lat != null && widget.lng != null) {
        final nearby = await _service.nearby(lat: widget.lat!, lng: widget.lng!);
        if (nearby.success) {
          final Map<String, dynamic> nearbyBody =
              Map<String, dynamic>.from(jsonDecode(nearby.body) as Map);
          outlets = (nearbyBody['outlets'] as List?) ?? const <dynamic>[];
        }
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _favourites = items.whereType<Map<String, dynamic>>().toList();
        _outlets = outlets;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your saved stores.';
      });
    }
  }

  String? _outletFor(String chainId) {
    for (final dynamic raw in _outlets) {
      if (raw is! Map<String, dynamic>) continue;
      final dynamic chain = raw['chain'];
      final String id = '${chain is Map ? chain['_id'] ?? chain['id'] : chain}';
      if (id == chainId) return '${raw['_id'] ?? raw['id'] ?? ''}';
    }
    return null;
  }

  Future<void> _remove(String chainId) async {
    final response = await _service.removeFavourite(chainId);
    if (!mounted || !response.success) return;
    setState(() {
      _favourites = _favourites
          .where((Map<String, dynamic> row) {
            final dynamic chain = row['chain'];
            return '${chain is Map ? chain['_id'] : ''}' != chainId;
          })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved stores')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _favourites.isEmpty
                  ? const Center(child: Text('No saved stores yet.'))
                  : ListView.separated(
                      itemCount: _favourites.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> row = _favourites[index];
                        final dynamic rawChain = row['chain'];
                        final Map<String, dynamic> chain = rawChain is Map<String, dynamic>
                            ? rawChain
                            : <String, dynamic>{};
                        final String chainId = '${chain['_id'] ?? ''}';
                        final String? outletId = _outletFor(chainId);
                        return ListTile(
                          leading: const Icon(Icons.favorite),
                          title: Text('${chain['name'] ?? 'Store'}'),
                          subtitle: Text(outletId == null
                              ? 'No outlet near you is open right now.'
                              : '${chain['description'] ?? ''}'),
                          trailing: IconButton(
                            tooltip: 'Remove from favourites',
                            icon: const Icon(Icons.favorite_border),
                            onPressed: chainId.isEmpty ? null : () => _remove(chainId),
                          ),
                          onTap: outletId == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => StoresChainView(
                                        chainId: chainId,
                                        outletId: outletId,
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
    );
  }
}
