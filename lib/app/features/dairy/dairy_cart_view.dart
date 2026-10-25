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

class DairyCartView extends StatefulWidget {
  const DairyCartView({super.key});

  @override
  State<DairyCartView> createState() => _DairyCartViewState();
}

class _DairyCartViewState extends State<DairyCartView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  List<dynamic> _items = const <dynamic>[];
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
    final r = await _service.cart();
    if (!mounted) return;
    final AppLocalizations t = AppLocalizations.of(context)!;
    setState(() {
      _loading = false;
      if (r.success) {
        _items = decodeList(jsonDecode(r.body));
      } else {
        _error = t.dairy_could_not_load_cart;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_cart)),
      body: _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int i) {
                final it = _items[i];
                final m = it is Map ? it : <String, dynamic>{};
                return ListTile(
                  title: Text(m['name']?.toString() ?? t.dairy_items),
                  subtitle: Text(t.dairy_qty(m['quantity']?.toString() ?? '')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final id = m['_id']?.toString() ?? m['id']?.toString();
                      if (id != null) {
                        await _service.removeCartItem(id);
                        _load();
                      }
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRouter.dairyCheckoutRoute),
          child: Text(t.dairy_checkout),
        ),
      ),
    );
  }
}
