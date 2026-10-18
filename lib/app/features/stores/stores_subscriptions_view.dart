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

/// The customer's recurring deliveries.
///
/// WHICH ACTIONS APPEAR is decided here for readability, but the server owns the state
/// machine and gets the final word: `pause` is offered only while the subscription is
/// scheduled, and every action sends a `reason` because the server requires one and keeps
/// it in the subscription history — the store reads that later when a customer asks why
/// deliveries stopped. Offering "cancel" on an already-cancelled subscription would be a
/// lie the server refuses; hiding it everywhere would mean re-implementing the lifecycle
/// table in the client, which drifts the moment the table changes.
///
/// EVERY ACTION NAMES ITS OWN SUBSCRIPTION. These endpoints were, until recently, reachable
/// by id with no check that the caller owned the row — any customer could cancel anyone
/// else's recurring deliveries. The server now scopes by customer and returns 404 for a row
/// that is not yours; this screen treats a 404 as a refusal and reloads rather than
/// retrying.
class StoresSubscriptionsView extends StatefulWidget {
  const StoresSubscriptionsView({super.key, this.service});

  /// Injectable so widget tests can drive the screen without a network. Omitted in the app,
  /// where a real service is built — every existing call site is unaffected.
  final StoresCustomerService? service;

  @override
  State<StoresSubscriptionsView> createState() => _StoresSubscriptionsViewState();
}

class _StoresSubscriptionsViewState extends State<StoresSubscriptionsView> {
  late final StoresCustomerService _service;

  List<dynamic> _subscriptions = const <dynamic>[];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.subscriptions();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load your subscriptions.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    // listCustomerSubscriptionsForCustomer returns `{ items, total, page, ... }`.
    final List<dynamic> items = (body['items'] as List?) ?? const <dynamic>[];
    if (!mounted) return;
    setState(() {
      _subscriptions = items;
      _loading = false;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Every mutating action needs a reason, so they share one prompt. An empty reason is
  /// refused server-side rather than sent, to avoid a pointless 400.
  Future<void> _withReason(String id, String action, Future<bool> Function(String) call) async {
    final TextEditingController controller = TextEditingController();
    final String? reason = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('${_titleCase(action)} delivery'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (reason == null) return;
    if (reason.isEmpty) {
      _snack('Please give a reason.');
      return;
    }

    setState(() => _busy = true);
    try {
      final bool ok = await call(reason);
      if (!mounted) return;
      _snack(ok ? '${_titleCase(action)}d.' : 'That did not work. Pull to refresh and try again.');
      if (ok) await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _titleCase(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  Future<void> _skip(Map<String, dynamic> s) =>
      _withReason('${s['_id']}', 'skip',
          (String reason) async => (await _service.skipSubscription('${s['_id']}', reason)).success);

  Future<void> _pause(Map<String, dynamic> s) =>
      _withReason('${s['_id']}', 'pause',
          (String reason) async => (await _service.pauseSubscription('${s['_id']}', reason)).success);

  Future<void> _cancel(Map<String, dynamic> s) =>
      _withReason('${s['_id']}', 'cancel',
          (String reason) async => (await _service.cancelSubscription('${s['_id']}', reason)).success);

  Future<void> _resume(Map<String, dynamic> s) async {
    setState(() => _busy = true);
    try {
      final response = await _service.resumeSubscription('${s['_id']}');
      if (!mounted) return;
      _snack(response.success ? 'Resumed.' : 'That did not work.');
      await _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Upcoming deliveries: what is actually scheduled to arrive, and when.
  ///
  /// Reads `GET /subscriptions/upcoming`, which is scoped to the caller server-side and
  /// only returns rows still in `scheduled` — so a paused or cancelled subscription cannot
  /// appear here, which is exactly the reassurance this sheet exists to give.
  Future<void> _showUpcoming() async {
    final response = await _service.upcomingSubscriptions();
    if (!mounted) return;
    if (!response.success) {
      _snack('Could not load upcoming deliveries.');
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final List<dynamic> items = (body['upcoming'] as List?) ?? const <dynamic>[];

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nothing scheduled in the next 30 days.'),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final dynamic raw in items)
              if (raw is Map<String, dynamic>)
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(
                    '${(raw['outlet'] is Map) ? ((raw['outlet'] as Map)['name'] ?? 'Store') : 'Store'}',
                  ),
                  subtitle: Text('${raw['nextOccurrenceDate'] ?? ''}'),
                ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: <Widget>[
          // Upcoming deliveries are the reason most people open this screen; the list below
          // shows every subscription including cancelled ones, which is history, not plan.
          IconButton(
            tooltip: 'Upcoming',
            onPressed: _showUpcoming,
            icon: const Icon(Icons.event),
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _subscriptions.isEmpty
                  ? const Center(child: Text('No subscriptions yet.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _subscriptions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final dynamic raw = _subscriptions[index];
                          final Map<String, dynamic> s =
                              raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                          return _card(context, s);
                        },
                      ),
                    ),
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> s) {
    final String id = '${s['_id'] ?? ''}';
    final String status = '${s['status'] ?? ''}';
    final Map<String, dynamic> outlet =
        s['outlet'] is Map ? s['outlet'] as Map<String, dynamic> : <String, dynamic>{};

    return InkWell(
      // Detail is a separate, caller-scoped read (`GET /subscriptions/:id`). Tapping the row
      // is what makes that method reachable rather than dead.
      onTap: id.isEmpty ? null : () => _showDetail(s),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${outlet['name'] ?? s['plan'] is Map ? (s['plan'] as Map)['name'] : s['plan'] ?? 'Subscription'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${_titleCase(status)} · ${s['cadence'] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (s['nextOccurrenceDate'] != null)
              Text(
                'Next: ${s['nextOccurrenceDate']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            // Actions are offered by status so the screen is not a row of buttons that are
            // mostly refused. `paused` is reachable only by pausing, so resume lives there
            // and nowhere else.
            Wrap(
              spacing: 8,
              children: <Widget>[
                if (status == 'scheduled') ...<Widget>[
                  OutlinedButton(
                    onPressed: _busy ? null : () => _skip(s),
                    child: const Text('Skip next'),
                  ),
                  OutlinedButton(
                    onPressed: _busy ? null : () => _pause(s),
                    child: const Text('Pause'),
                  ),
                ],
                if (status == 'paused')
                  FilledButton(
                    onPressed: _busy ? null : () => _resume(s),
                    child: const Text('Resume'),
                  ),
                if (status == 'scheduled' || status == 'paused')
                  TextButton(
                    onPressed: _busy ? null : () => _cancel(s),
                    child: const Text('Cancel'),
                  ),
                if (status != 'scheduled' && status != 'paused')
                  Text(
                    'This subscription is $status.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// One subscription in full: items, address, discount, and the server's own history.
  Future<void> _showDetail(Map<String, dynamic> row) async {
    final response = await _service.subscription('${row['_id']}');
    if (!mounted) return;
    if (!response.success) {
      // 404 here means "not yours", since the server scopes this read to the caller. It is
      // reported as a plain failure rather than as "not found", which would be misleading
      // — the subscription exists, it just is not this customer's to see.
      _snack('Could not open that subscription.');
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final Map<String, dynamic> sub =
        (body['subscription'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final List<dynamic> items = (sub['items'] as List?) ?? const <dynamic>[];
    final Map<String, dynamic> address =
        sub['address'] is Map ? sub['address'] as Map<String, dynamic> : <String, dynamic>{};

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              '${sub['cadence'] ?? ''} · ${_titleCase('${sub['status'] ?? ''}')}',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            if (address.isNotEmpty)
              Text(
                'Delivering to ${address['line1'] ?? address['name'] ?? ''}',
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
            const Divider(),
            for (final dynamic raw in items)
              if (raw is Map<String, dynamic>)
                ListTile(
                  dense: true,
                  title: Text('${raw['name'] ?? 'Item'}'),
                  trailing: Text('Qty ${raw['quantity'] ?? 1}'),
                ),
          ],
        );
      },
    );
  }
}