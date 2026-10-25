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

class DairyOrdersView extends StatefulWidget {
  const DairyOrdersView({super.key});

  @override
  State<DairyOrdersView> createState() => _DairyOrdersViewState();
}

class _DairyOrdersViewState extends State<DairyOrdersView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  List<dynamic> _orders = const <dynamic>[];
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
    final r = await _service.orders();
    if (!mounted) return;
    final AppLocalizations t = AppLocalizations.of(context)!;
    setState(() {
      _loading = false;
      if (r.success) {
        _orders = decodeList(jsonDecode(r.body));
      } else {
        _error = t.dairy_could_not_load_orders;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_orders)),
      body: _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (BuildContext context, int i) {
                final m = _orders[i] is Map ? _orders[i] as Map : <String, dynamic>{};
                return ListTile(
                  title: Text(m['orderNo']?.toString() ?? t.dairy_order_title('')),
                  subtitle: Text(m['status']?.toString().replaceAll('_', ' ') ?? ''),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRouter.dairyTrackingRoute,
                    arguments: <dynamic>[m['_id']?.toString() ?? m['id']?.toString() ?? ''],
                  ),
                );
              },
            ),
    );
  }
}
