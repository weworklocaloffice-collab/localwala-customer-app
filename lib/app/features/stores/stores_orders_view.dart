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
    final response = await _service.orders();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load your orders.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    setState(() {
      _loading = false;
      // listOrders returns `{ items, total, page, limit, totalPages }`.
      _orders = body['items'] as List? ?? const <dynamic>[];
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
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _orders.isEmpty
                  ? const Center(child: Text('No orders yet.'))
                  : ListView.separated(
                      itemCount: _orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
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
    );
  }
}