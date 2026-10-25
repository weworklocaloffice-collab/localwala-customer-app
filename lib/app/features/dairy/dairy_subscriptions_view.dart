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
import 'package:user/app/features/dairy/dairy_subscription_create_view.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DairySubscriptionsView extends StatefulWidget {
  const DairySubscriptionsView({super.key});

  @override
  State<DairySubscriptionsView> createState() => _DairySubscriptionsViewState();
}

class _DairySubscriptionsViewState extends State<DairySubscriptionsView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  List<dynamic> _subs = const <dynamic>[];
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
    final r = await _service.subscriptions();
    if (!mounted) return;
    final AppLocalizations t = AppLocalizations.of(context)!;
    setState(() {
      _loading = false;
      if (r.success) {
        _subs = decodeList(jsonDecode(r.body));
      } else {
        _error = t.dairy_could_not_load_subscriptions;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_subscriptions)),
      body: _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
              itemCount: _subs.length,
              itemBuilder: (BuildContext context, int i) {
                final m = _subs[i] is Map ? _subs[i] as Map : <String, dynamic>{};
                return ListTile(
                  title: Text(m['sku']?.toString() ?? t.dairy_subscription),
                  subtitle: Text(m['status']?.toString() ?? ''),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRouter.dairySubscriptionDetailRoute,
                    arguments: <dynamic>[m['_id']?.toString() ?? ''],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (BuildContext context) => const DairySubscriptionCreateView()),
          );
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
