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
import 'package:user/app/features/jhatka/jhatka_outlet_view.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// Jhatka storefront: nearby outlets and what they have right now.
///
/// Prices carry `~` — approximate weight, final confirmed at the outlet, and
/// the customer is never charged above the estimate (refund-only, BR-06).
/// Availability is address-scoped: an outlet outside the delivery area is not
/// shown, rather than shown and refused at checkout.
class JhatkaHomeView extends StatefulWidget {
  const JhatkaHomeView({super.key});

  @override
  State<JhatkaHomeView> createState() => _JhatkaHomeViewState();
}

class _JhatkaHomeViewState extends State<JhatkaHomeView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  List<dynamic> _outlets = const <dynamic>[];

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
    final response = await _service.home();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load stores near you.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    setState(() {
      _loading = false;
      _outlets =
          (body['outlets'] as List?) ?? (body['data'] as List?) ?? const <dynamic>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jhatka near you')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _outlets.isEmpty
                    ? const Center(
                        child: Text('No Jhatka outlets deliver here yet.'),
                      )
                    : ListView.builder(
                        itemCount: _outlets.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Map<String, dynamic> outlet =
                              Map<String, dynamic>.from(
                            _outlets[i] as Map,
                          );
                          final String outletId = (outlet['id'] ??
                                  outlet['_id'] ??
                                  '')
                              .toString();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                (outlet['name'] ?? 'Outlet').toString(),
                              ),
                              subtitle: Text(
                                (outlet['address'] ?? outlet['locality'] ?? '')
                                    .toString(),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: outletId.isEmpty
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => JhatkaOutletView(
                                            outletId: outletId,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
