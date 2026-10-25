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

class DairyCheckoutView extends StatefulWidget {
  const DairyCheckoutView({super.key});

  @override
  State<DairyCheckoutView> createState() => _DairyCheckoutViewState();
}

class _DairyCheckoutViewState extends State<DairyCheckoutView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = false;
  String? _error;

  Future<void> _placeOrder() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await _service.checkout(<String, dynamic>{});
    if (!mounted) return;
    setState(() => _loading = false);
    if (r.success) {
      final Map<String, dynamic> d = asMap(jsonDecode(r.body));
      final String? orderId = d.isNotEmpty ? (d['_id']?.toString() ?? d['id']?.toString()) : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.dairy_order_placed}${orderId != null ? ': $orderId' : ''}')),
      );
      Navigator.of(context).pushNamed(
        AppRouter.dairyTrackingRoute,
        arguments: <dynamic>[orderId ?? ''],
      );
    } else {
      setState(() => _error = t.dairy_checkout_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_checkout)),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(onPressed: _placeOrder, child: Text(t.dairy_place_order)),
                ],
              ),
      ),
    );
  }
}
