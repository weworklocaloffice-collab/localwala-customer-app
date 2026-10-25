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

/// Public profile of one dairy outlet plus its products.
class DairyOutletView extends StatefulWidget {
  final String outletId;
  const DairyOutletView({super.key, required this.outletId});

  @override
  State<DairyOutletView> createState() => _DairyOutletViewState();
}

class _DairyOutletViewState extends State<DairyOutletView> {
  final DairyCustomerService _service = DairyCustomerService();
  bool _loading = true;
  Map<String, dynamic> _outlet = <String, dynamic>{};
  List<dynamic> _products = const <dynamic>[];
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
    final profile = await _service.outletDetail(widget.outletId);
    // A closed or unverified outlet still resolves — the customer should see
    // why they cannot order, not an error.
    final products = await _service.productList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (profile.success) {
        final Map<String, dynamic> body = asMap(jsonDecode(profile.body));
        _outlet = body.isNotEmpty ? body : asMap(body['business']);
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_outlet;
        return;
      }
      if (products.success) {
        final List<dynamic> all = decodeList(jsonDecode(products.body));
        // Keep only this outlet's items when the rows carry a business ref.
        _products = all.where((dynamic e) {
          final Map<String, dynamic> m = asMap(e);
          final dynamic b = m['business'];
          final String bid = b is Map ? (b['_id']?.toString() ?? '') : b.toString();
          return bid == widget.outletId;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: Text(t.dairy_outlet)), body: Center(child: Text(_error!)));
    }
    final bool verified = _outlet['verified'] == true;
    final bool open = _outlet['status'] == true;
    final dynamic city = _outlet['city'];
    final dynamic locality = _outlet['locality'];
    final String cityLabel = city is Map ? (city['name']?.toString() ?? '') : '';
    final String localityLabel = locality is Map ? (locality['name']?.toString() ?? '') : '';
    return Scaffold(
      appBar: AppBar(title: Text(_outlet['name']?.toString() ?? t.dairy_outlet)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(_outlet['name']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Icon(
                verified ? Icons.verified : Icons.schedule,
                color: verified ? Colors.green : Colors.orange,
                semanticLabel: verified ? t.dairy_verified : t.dairy_pending_review,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            <String>[
              if (localityLabel.isNotEmpty) localityLabel,
              if (cityLabel.isNotEmpty) cityLabel,
            ].join(', '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <Widget>[
              Chip(label: Text(_outlet['businessModel']?.toString().replaceAll('_', ' ') ?? '')),
              if (_outlet['rating'] != null) Chip(label: Text(t.dairy_rating(_outlet['rating'].toString()))),
              Chip(
                label: Text(open ? t.dairy_open : t.dairy_closed),
                backgroundColor: open ? null : Colors.red.shade100,
              ),
            ],
          ),
          if ((_outlet['description']?.toString() ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(_outlet['description'].toString()),
          ],
          const Divider(height: 32),
          Text(t.dairy_products, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_products.isEmpty)
            Text(t.dairy_no_products)
          else
            ..._products.map((dynamic e) {
              final Map<String, dynamic> m = asMap(e);
              final String id = m['_id']?.toString() ?? m['id']?.toString() ?? '';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m['name']?.toString() ?? t.dairy_product),
                subtitle: m['price'] != null ? Text(formatMoney(m['price'])) : null,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRouter.dairyProductRoute, arguments: <dynamic>[id]),
              );
            }),
        ],
      ),
    );
  }
}
