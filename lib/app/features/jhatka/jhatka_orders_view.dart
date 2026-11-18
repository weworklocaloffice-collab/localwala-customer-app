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
import 'package:user/gen/l10n/app_localizations.dart';

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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.orders();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = l10n.jhatka_could_not_load_orders;
      });
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body) as Map,
    );
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _actingOn = key);
    final dynamic response = await call();
    if (!mounted) return;
    setState(() => _actingOn = null);
    final bool ok = response?.success == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? done : l10n.jhatka_did_not_go_through)),
    );
    if (ok) await _load();
  }

  Future<void> _openInvoice(String orderId) async {
    if (orderId.isEmpty) return;
    final response = await _service.orderInvoice(orderId);
    if (!mounted) return;
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.jhatka_could_not_load_order_details,
          ),
        ),
      );
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body) as Map,
    );
    final Map<String, dynamic> inv = (body['invoice'] is Map)
        ? Map<String, dynamic>.from(body['invoice'] as Map)
        : <String, dynamic>{};
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final List<dynamic> lines =
            (inv['lines'] as List?) ?? const <dynamic>[];
        final List<dynamic> charges =
            (inv['charges'] as List?) ?? const <dynamic>[];
        final Map<String, dynamic> totals = (inv['totals'] is Map)
            ? Map<String, dynamic>.from(inv['totals'] as Map)
            : <String, dynamic>{};
        final Map<String, dynamic>? seller = (inv['seller'] is Map)
            ? Map<String, dynamic>.from(inv['seller'] as Map)
            : null;
        return AlertDialog(
          title: Text('Invoice ${inv['invoiceNo'] ?? (inv['preview'] == true ? '(preview)' : '')}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (seller != null) ...<Widget>[
                  Text('Seller: ${seller['name'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (seller['gstin'] != null) Text('GSTIN: ${seller['gstin']}'),
                  if (seller['address'] != null) Text('${seller['address']}'),
                  const Divider(),
                ],
                Text('Status: ${inv['status'] ?? ''}'),
                if (inv['issuedAt'] != null) Text('Issued: ${inv['issuedAt']}'),
                const Divider(),
                ...lines.map((dynamic l) {
                  final Map<String, dynamic> line = l is Map
                      ? Map<String, dynamic>.from(l)
                      : <String, dynamic>{};                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${line['description'] ?? ''} x${line['quantity'] ?? ''}',
                          ),
                        ),
                        Text(jhatka_money.formatRupees(
                            (line['total'] ?? 0) as num)),
                      ],
                    ),
                  );
                }),
                if (charges.isNotEmpty) ...<Widget>[
                  const Divider(),
                  ...charges.map((dynamic c) {
                    final Map<String, dynamic> ch = c is Map
                        ? Map<String, dynamic>.from(c)
                        : <String, dynamic>{};
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${ch['description'] ?? ch['code'] ?? ''}'),
                        Text(jhatka_money.formatRupees(
                            (ch['total'] ?? 0) as num)),
                      ],
                    );
                  }),
                ],
                const Divider(),
                _invoiceTotalRow('Taxable', totals['taxableValue']),
                _invoiceTotalRow('CGST', totals['cgst']),
                _invoiceTotalRow('SGST', totals['sgst']),
                _invoiceTotalRow('IGST', totals['igst']),
                _invoiceTotalRow('Tax total', totals['taxTotal']),
                _invoiceTotalRow('Grand total', totals['grandTotal']),
                if ((totals['amountRefunded'] ?? 0) != 0)
                  _invoiceTotalRow('Refunded', totals['amountRefunded']),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.jhatka_close),
            ),
          ],
        );
      },
    );
  }

  Widget _invoiceTotalRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(jhatka_money.formatRupees((value ?? 0) as num)),
        ],
      ),
    );
  }

  Future<bool?> _showOrderDetailDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(this.context)!;
    final Map<String, dynamic> o = (order['order'] is Map)
        ? Map<String, dynamic>.from(order['order'] as Map)
        : order;
    final String orderNo = (o['orderNo'] ?? '—').toString();
    final String lifecycle = (o['lifecycle'] ?? '').toString();
    final dynamic items = o['items'] ?? const <dynamic>[];
    final num subtotal =
        (o['itemsSubtotal'] ?? o['estimatedTotal'] ?? 0) as num;
    final num tax = (o['taxTotal'] ?? 0) as num;
    final num total = (o['finalTotal'] ?? o['estimatedTotal'] ?? subtotal + tax) as num;
    final String paymentStatus = (o['paymentStatus'] ?? '').toString();
    final String createdAt = (o['placedAt'] ?? o['createdAt'] ?? '').toString();
    final Map<String, dynamic>? invoice = (o['invoice'] is Map)
        ? Map<String, dynamic>.from(o['invoice'] as Map)
        : null;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.jhatka_order_no(orderNo)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(l10n.jhatka_lifecycle(lifecycle)),
                Text(l10n.jhatka_payment_status_label(paymentStatus)),
                Text(l10n.jhatka_created_at(createdAt)),
                const Divider(),
                Text(
                  l10n.jhatka_items,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(items as List).map((dynamic item) {
                  final String name = (item['name'] ?? '—').toString();
                  final num price = (item['price'] ?? 0) as num;
                  final int quantity = (item['quantity'] ?? 1) as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      l10n.jhatka_item_summary(
                        name,
                        quantity.toString(),
                        jhatka_money.formatPaise(price),
                      ),
                    ),
                  );
                }),
                const Divider(),
                Text(
                  l10n.jhatka_subtotal,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(jhatka_money.formatPaise(subtotal)),
                Text(
                  l10n.jhatka_tax,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(jhatka_money.formatPaise(tax)),
                Text(
                  l10n.jhatka_total,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(jhatka_money.formatPaise(total)),
                if (invoice != null) ...<Widget>[
                  const Divider(),
                  Text(
                    'Invoice: ${invoice['invoiceNo']?.toString() ?? '—'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${invoice['status'] ?? ''} ${invoice['isVoided'] == true ? '(void)' : ''}',
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openInvoice(o['id']?.toString() ?? '');
              },
              child: const Text('Invoice'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.jhatka_close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelSheet(String orderId) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.jhatka_cancel_order,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reason,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.jhatka_reason_required,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(l10n.jhatka_cancel_order),
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
      l10n.jhatka_cancellation_requested,
    );
  }

  /// Order detail on tap. A State method (not a builder closure) so the
  /// post-await snackbar and dialog use this State's own context behind its
  /// own `mounted` guard.
  Future<void> _openOrderDetail(String orderId) async {
    final response = await _service.orderDetail(orderId);
    if (!mounted) return;
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.jhatka_could_not_load_order_details,
          ),
        ),
      );
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body) as Map,
    );
    await _showOrderDetailDialog(context, body);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jhatka_your_orders),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.jhatka_help_feedback,
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
            ? Center(child: Text(l10n.jhatka_no_orders))
            : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (BuildContext context, int i) {
                  final Map<String, dynamic> order = Map<String, dynamic>.from(
                    _orders[i] as Map,
                  );
                  final String id = (order['id'] ?? order['_id'] ?? '')
                      .toString();
                  final String lifecycle = (order['lifecycle'] ?? '')
                      .toString();
                  final bool busy =
                      _actingOn != null && _actingOn!.endsWith(id);
                  final bool cancellable =
                      lifecycle == 'CREATED' ||
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
                      onTap: () => _openOrderDetail(id),
                      child: ExpansionTile(
                        title: Text(
                          l10n.jhatka_order_no(
                            (order['orderNo'] ?? '—').toString(),
                          ),
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
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Wrap(
                              spacing: 8,
                              children: <Widget>[
                                if (lifecycle == 'WEIGHT_CONFIRMED' ||
                                    lifecycle == 'DELIVERED')
                                  OutlinedButton(
                                    onPressed: () => _act(
                                      'ack:$id',
                                      () => _service.confirmWeight(id),
                                      l10n.jhatka_noted_thanks,
                                    ),
                                    child: Text(l10n.jhatka_got_it),
                                  ),
                                if (cancellable)
                                  OutlinedButton(
                                    onPressed: () => _cancelSheet(id),
                                    child: Text(l10n.jhatka_cancel),
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
