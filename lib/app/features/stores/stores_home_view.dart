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
import 'package:user/app/features/stores/stores_chain_view.dart';
import 'package:user/app/features/stores/stores_favourites_view.dart';
import 'package:user/app/features/stores/stores_outlet_view.dart';

/// Nearby stores �?" the customer entry point for the vertical.
///
/// Chain-first: one card per brand, with its eligible outlets inline. A chain with four
/// branches is one card, not four, and the customer picks the outlet that has stock. Every
/// outlet here is active and operational; the server excludes the rest.
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
  List<dynamic> _chains = const <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.lat == null || widget.lng == null) {
      setState(() {
        _loading = false;
        _chains = const <dynamic>[];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.chains(lat: widget.lat!, lng: widget.lng!);
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
      _chains = body['chains'] as List? ?? const <dynamic>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stores near you'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Saved stores',
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => StoresFavouritesView(lat: widget.lat, lng: widget.lng),
                ),
              );
            },
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _chains.isEmpty
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
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _chains.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic raw = _chains[index];
                        final Map<String, dynamic> chain =
                            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                        return _ChainCard(chain: chain);
                      },
                    ),
    );
  }
}

/// One brand card. The outlets are inline, not four separate cards: choosing a branch is
/// the first decision the customer makes, and it belongs on the chain card (BR-37).
class _ChainCard extends StatelessWidget {
  const _ChainCard({required this.chain});

  final Map<String, dynamic> chain;

  @override
  Widget build(BuildContext context) {
    final String id = '${chain['_id'] ?? chain['id'] ?? ''}';
    final String logo = '${chain['logo'] ?? ''}';
    final List<dynamic> outlets = chain['outlets'] as List? ?? const <dynamic>[];
    final dynamic rating = chain['rating'];
    final dynamic distance = chain['nearestOutletKm'];
    final dynamic openCount = chain['openOutletCount'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: logo.isEmpty ? null : NetworkImage(logo),
              child: logo.isEmpty ? const Icon(Icons.storefront_outlined) : null,
            ),
            title: Text('${chain['name'] ?? 'Store'}'),
            subtitle: Text(
              <String>[
                if (rating != null && '$rating' != '0') '$rating rating',
                if (distance != null && '$distance' != 'Infinity') '$distance km away',
                if (openCount != null) '$openCount open',
              ].join('  |  '),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: id.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StoresChainView(chainId: id),
                      ),
                    );
                  },
          ),
          if (outlets.isNotEmpty)
            const Divider(height: 1)
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('No outlet is open for delivery right now.'),
            ),
          ...outlets.map((dynamic raw) {
            final Map<String, dynamic> outlet =
                raw is Map<String, dynamic> ? raw : <String, dynamic>{};
            final String outletId = '${outlet['_id'] ?? outlet['id'] ?? ''}';
            final bool isOpen = outlet['isOpenNow'] != false;
            final dynamic outletDistance = outlet['distanceKm'];
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 32, right: 16),
              leading: Icon(
                Icons.circle,
                size: 10,
                color: isOpen ? Colors.green : Colors.grey,
              ),
              title: Text('${outlet['name'] ?? 'Outlet'}'),
              subtitle: Text(
                <String>[
                  if (outletDistance != null) '$outletDistance km',
                  isOpen ? 'Open' : 'Closed',
                ].join('  |  '),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: outletId.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => id.isEmpty
                              ? StoresOutletView(storeId: outletId)
                              : StoresChainView(chainId: id, outletId: outletId),
                        ),
                      );
                    },
            );
          }),
        ],
      ),
    );
  }
}