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
import 'package:user/app/features/jhatka/jhatka_customer_money.dart'
    as jhatka_money;
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// Orders, tracking, and the weight-confirmation acknowledgement.
///
/// The acknowledgement is a notification receipt, not an approval gate: the
/// meat is already bagged when the weight is confirmed, so there is nothing
/// left to approve — only something to have seen. Cancellation is allowed
/// until ACCEPTED; later it needs the outlet, and the server enforces that.
class JhatkaOrdersView extends StatefulWidget {
  const JhatkaOrdersView({super.key});

  @override
  State<JhatkaOrdersView> createState() => _JhatkaOrdersViewState();
}

class _JhatkaOrdersViewState extends State<JhatkaOrdersView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  List<dynamic> _orders = const <dynamic>[];
  String? _actingOn;

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
      _orders = (body['orders'] as List?) ?? const <dynamic>[];
    });
  }

  Future<void> _act(
    String key,
    Future<dynamic> Function() call,
    String done,
  ) async {
    setState(() => _actingOn = key);
    final dynamic response = await call();
    if (!mounted) return;
    setState(() => _actingOn = null);
    final bool ok = response?.success == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? done : 'That did not go through. Retry.')),
    );
    if (ok) await _load();
  }

  Future<bool?> _showOrderDetailDialog(BuildContext context, Map<String, dynamic> order) async {
    final String orderNo = (order['orderNo'] ?? '—').toString();
    final String lifecycle = (order['lifecycle'] ?? '').toString();
    final dynamic items = order['items'] ?? const <dynamic>[];
    final num subtotal = (order['subtotal'] ?? order['estimatedTotal'] ?? 0) as num;
    final num tax = (order['tax'] ?? 0) as num;
    final num total = (order['finalTotal'] ?? subtotal + tax) as num;
    final String paymentStatus = (order['paymentStatus'] ?? '').toString();
    final String createdAt = (order['createdAt'] ?? '').toString();

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order $orderNo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lifecycle: $lifecycle'),
                Text('Payment status: $paymentStatus'),
                Text('Created at: $createdAt'),
                const Divider(),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(items as List).map((dynamic item) {
                  final String name = (item['name'] ?? '—').toString();
                  final num price = (item['price'] ?? 0) as num;
                  final int quantity = (item['quantity'] ?? 1) as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- $name x $quantity @ ${jhatka_money.formatPaise(price)}'),
                  );
                }),
                const Divider(),
                const Text('Subtotal: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(jhatka_money.formatPaise(subtotal)),
                const Text('Tax: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(jhatka_money.formatPaise(tax)),
                const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(jhatka_money.formatPaise(total)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSheet(String orderId) async {
    final TextEditingController reason = TextEditingController();
    final bool? go = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Cancel order',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reason,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Reason (required)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Cancel order'),
                ),
              ),
            ],
          ),
        );
      },
    );
    final String text = reason.text.trim();
    reason.dispose();
    if (go != true || text.isEmpty || !mounted) return;
    await _act(
      'cancel:$orderId',
      () => _service.cancelOrder(orderId, text),
      'Cancellation requested.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your orders'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Help & feedback',
            icon: const Icon(Icons.support_agent_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/jhatka/support'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _orders.isEmpty
                    ? const Center(
                        child: Text('No orders yet.'),
                      )
                    : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Map<String, dynamic> order =
                              Map<String, dynamic>.from(
                            _orders[i] as Map,
                          );
                          final String id = (order['id'] ??
                                  order['_id'] ??
                                  '')
                              .toString();
                          final String lifecycle =
                              (order['lifecycle'] ?? '').toString();
                          final bool busy = _actingOn != null &&
                              _actingOn!.endsWith(id);
                          final bool cancellable = lifecycle == 'CREATED' ||
                              lifecycle == 'PAYMENT_PENDING' ||
                              lifecycle == 'PAID' ||
                              lifecycle == 'OUTLET_RECEIVED' ||
                              lifecycle == 'ACCEPTED';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: InkWell(
                              onTap: () async {
                                final response = await _service.orderDetail(id);
                                if (!mounted) return;
                                if (!response.success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not load order details.')),
                                  );
                                  return;
                                }
                                final Map<String, dynamic> body =
                                    Map<String, dynamic>.from(jsonDecode(response.body) as Map);
                                await _showOrderDetailDialog(context, body);
                              },
                              child: ExpansionTile(
                              title: Text(
                                'Order ${order['orderNo'] ?? '—'}',
                              ),
                              subtitle: Text(
                                // Lean read: totals arrive as RAW PAISE.
                                '$lifecycle · '
                                '${(order['finalTotal'] ?? order['estimatedTotal']) is num ? jhatka_money.formatPaise(((order['finalTotal'] ?? order['estimatedTotal']) as num)) : '—'}',
                              ),
                              trailing: busy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    children: <Widget>[
                                      if (lifecycle == 'WEIGHT_CONFIRMED' ||
                                          lifecycle == 'DELIVERED')
                                        OutlinedButton(
                                          onPressed: () => _act(
                                            'ack:$id',
                                            () => _service
                                                .confirmWeight(id),
                                            'Noted — thanks.',
                                          ),
                                          child: const Text('Got it'),
                                        ),
                                      if (cancellable)
                                        OutlinedButton(
                                          onPressed: () =>
                                              _cancelSheet(id),
                                          child: const Text('Cancel'),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
