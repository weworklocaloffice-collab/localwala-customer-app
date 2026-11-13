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
import 'package:user/app/features/stores/stores_tracking_view.dart';
import 'package:user/app/router/app_route_config.dart';

/// The customer's orders, and one order's detail.
///
/// Tapping a row opens the detail, which is also where tracking lives: the lifecycle,
/// the payment state and the delivery state are one story on one screen, because a
/// customer asking "where is my order" should not have to assemble it from three tabs.
///
/// Cancelling is offered only while the server allows it. The service answers 409 past
/// the cancellable window, and the app surfaces that message rather than hiding the
/// button based on a locally re-implemented copy of the table.
class StoresOrdersView extends StatefulWidget {
  const StoresOrdersView({super.key});

  @override
  State<StoresOrdersView> createState() => _StoresOrdersViewState();
}

class _StoresOrdersViewState extends State<StoresOrdersView> {
  final StoresCustomerService _service = StoresCustomerService();
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = const <dynamic>[];
  int _page = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (!more) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
      });
    }
    final response = await _service.orders(page: _page);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load your orders.';
      });
      return;
    }
    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not read your orders.';
      });
      return;
    }
    setState(() {
      _loading = false;
      final List<dynamic> page = body['items'] as List? ?? const <dynamic>[];
      if (more) {
        _orders = <dynamic>[..._orders, ...page];
      } else {
        _orders = page;
      }
      _totalPages = (body['totalPages'] as num?)?.toInt() ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your orders'),
        actions: <Widget>[
          // Subscriptions live here rather than behind a separate tab: a customer looking
          // for "where are my recurring deliveries" is already looking at their orders.
          IconButton(
            tooltip: 'Subscriptions',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.storesSubscriptionsRoute);
            },
            icon: const Icon(Icons.autorenew),
          ),
          IconButton(onPressed: () { setState(() => _page = 1); _load(); }, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders yet.'))
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            itemCount: _orders.length + (_page < _totalPages ? 1 : 0),
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= _orders.length) {
                                return ListTile(
                                  title: const Text('Load more'),
                                  onTap: () {
                                    setState(() => _page += 1);
                                    _load(more: true);
                                  },
                                );
                              }
                              final dynamic raw = _orders[index];
                        final Map<String, dynamic> order =
                            raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                        final String id = '${order['_id'] ?? order['id'] ?? ''}';
                        return ListTile(
                          leading: const Icon(Icons.shopping_bag_outlined),
                          title: Text('Order #${order['orderNo'] ?? '—'}'),
                          subtitle: Text(
                            '${order['lifecycle'] ?? order['status'] ?? ''}'
                            ' · ${order['grandTotal'] ?? ''}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: id.isEmpty
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => StoresTrackingView(orderId: id),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                  ),
              );
            }
}