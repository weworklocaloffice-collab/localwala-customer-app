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
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Live status of one dairy order: items, money, can custody, history.
class DairyTrackingView extends StatefulWidget {
  final String orderId;
  const DairyTrackingView({super.key, required this.orderId});

  @override
  State<DairyTrackingView> createState() => _DairyTrackingViewState();
}

class _DairyTrackingViewState extends State<DairyTrackingView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  Map<String, dynamic> _order = <String, dynamic>{};
  List<dynamic> _history = const <dynamic>[];
  String? _error;

  static const Set<String> _cancellable = <String>{'pending_payments', 'confirmed', 'preparing'};

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
    final detail = await _service.orderDetail(widget.orderId);
    final history = await _service.orderHistory(widget.orderId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (detail.success) {
        final Map<String, dynamic> body = asMap(jsonDecode(detail.body));
        _order = asMap(body['order']);
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_order;
        return;
      }
      if (history.success) {
        final Map<String, dynamic> h = asMap(jsonDecode(history.body));
        _history = decodeList(h['history']);
      }
    });
  }

  Future<void> _cancel() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(t.dairy_cancel_order_q),
        content: Text(t.dairy_cancel_order_body),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t.dairy_keep)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t.dairy_cancel_order)),
        ],
      ),
    );
    if (confirmed != true) return;
    final r = await _service.cancelOrder(widget.orderId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r.success ? t.dairy_order_cancelled : t.dairy_could_not_cancel)),
    );
    if (r.success) _load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: Text(t.dairy_tracking)), body: Center(child: Text(_error!)));
    }
    final String status = _order['status']?.toString() ?? '';
    final Map<String, dynamic> business = asMap(_order['business']);
    final List<dynamic> items = decodeList(_order['items']);
    final List<dynamic> cans = decodeList(_order['cansIssued']);
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_order_title(_order['orderNo']?.toString() ?? ''))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'delivered'
                        ? Colors.green
                        : status == 'cancelled'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              ),
              if (_cancellable.contains(status))
                TextButton(onPressed: _cancel, child: Text(t.dairy_cancel_order)),
            ],
          ),
          if (business.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                final String bid = business['_id']?.toString() ?? '';
                if (bid.isNotEmpty) {
                  Navigator.of(context)
                      .pushNamed(AppRouter.dairyOutletRoute, arguments: <dynamic>[bid]);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(t.dairy_from(business['name']?.toString() ?? ''), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 4),
                  Icon(Icons.storefront_outlined,
                      size: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                ],
              ),
            ),
          ],
          const Divider(height: 32),
          Text(t.dairy_items, style: Theme.of(context).textTheme.titleMedium),
          ...items.map((dynamic e) {
            final Map<String, dynamic> m = asMap(e);
            final Map<String, dynamic> sku = asMap(m['sku']);
            final String label = sku.isNotEmpty
                ? (sku['name']?.toString() ?? '')
                : (m['name']?.toString() ?? t.dairy_items);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              trailing: Text('x${m['quantity'] ?? 1}'),
            );
          }),
          const Divider(height: 32),
          if (_order['grandTotal'] != null)
            ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(t.dairy_total), trailing: Text(formatMoney(_order['grandTotal']))),
          if (_order['codCollectionAmount'] != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(t.dairy_cash_on_delivery),
              trailing: Text(formatMoney(_order['codCollectionAmount'])),
            ),
          if (_order['depositTotal'] != null)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(t.dairy_can_deposit_held),
              trailing: Text(formatMoney(_order['depositTotal'])),
            ),
          if (cans.isNotEmpty)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(t.dairy_cans_issued(cans.length)),
              subtitle: Text(cans.join(', ')),
            ),
          const Divider(height: 32),
          Text(t.dairy_history, style: Theme.of(context).textTheme.titleMedium),
          if (_history.isEmpty)
            Text(t.dairy_no_history)
          else
            ..._history.map((dynamic e) {
              final Map<String, dynamic> m = asMap(e);
              final String label = (m['toStatus'] ?? m['status'] ?? '').toString().replaceAll('_', ' ');
              final String note = (m['note'] ?? m['reason'] ?? '').toString();
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.circle, size: 10),
                title: Text(label.isEmpty ? t.dairy_update : label),
                subtitle: Text(<String>[
                  if (note.isNotEmpty) note,
                  formatDate(m['createdAt']),
                ].join(' — ')),
              );
            }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.support_agent),
            label: Text(t.dairy_get_help),
            // The support system keys a room on (user, type, typeId); a dairy
            // complaint rides the existing `complaints` queue.
            onPressed: () => Navigator.of(context)
                .pushNamed(AppRouter.supportChatRoute, arguments: <dynamic>['complaints', widget.orderId]),
          ),
        ],
      ),
    );
  }
}
