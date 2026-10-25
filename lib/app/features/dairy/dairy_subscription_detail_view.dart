/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DairySubscriptionDetailView extends StatefulWidget {
  final String subscriptionId;
  const DairySubscriptionDetailView({super.key, required this.subscriptionId});

  @override
  State<DairySubscriptionDetailView> createState() => _DairySubscriptionDetailViewState();
}

class _DairySubscriptionDetailViewState extends State<DairySubscriptionDetailView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  Map<String, dynamic> _subscription = <String, dynamic>{};
  String? _error;

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
    final r = await _service.subscriptionDetail(widget.subscriptionId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) {
        final d = jsonDecode(r.body);
        _subscription = d is Map ? d as Map<String, dynamic>? ?? <String, dynamic>{} : <String, dynamic>{};
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_subscriptions;
      }
    });
  }

  Future<void> _reactivate() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final r = await _service.reactivateSubscription(widget.subscriptionId);
    if (!mounted) return;
    if (r.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.dairy_subscription_reactivated)));
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.dairy_failed(r.body))));
    }
  }

  Future<void> _cancel() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    final r = await _service.cancelSubscription(widget.subscriptionId);
    if (!mounted) return;
    if (r.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.dairy_subscription_cancelled)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.dairy_failed(r.body))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: Text(t.dairy_subscription)), body: Center(child: Text(_error!)));
    }
    return Scaffold(
      appBar: AppBar(title: Text('${t.dairy_subscription} ${_subscription['_id']?.toString() ?? widget.subscriptionId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(t.dairy_sku(_subscription['sku']?.toString() ?? '')),
            Text(t.dairy_quantity_label(_subscription['quantity']?.toString() ?? '')),
            Text(t.dairy_status_label(_subscription['status']?.toString() ?? '')),
            Text(t.dairy_schedule_label(_subscription['scheduleType']?.toString() ?? '')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _reactivate, child: Text(t.dairy_reactivate)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _cancel, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(t.dairy_cancel)),
          ],
        ),
      ),
    );
  }
}