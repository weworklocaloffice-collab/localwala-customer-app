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
import 'package:user/app/features/local_services/ls_tracking_view.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';

/// Customer booking list with status-derived actions (cancel where the
/// state table allows, dispute after completion, review after completion).
class LsBookingsView extends StatefulWidget {
  const LsBookingsView({super.key});

  @override
  State<LsBookingsView> createState() => _LsBookingsViewState();
}

class _LsBookingsViewState extends State<LsBookingsView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<LsCustomerBooking> _items = const <LsCustomerBooking>[];

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
    try {
      final dynamic res = await _service.bookings();
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      final List<dynamic> raw = (body['results'] ?? []) as List<dynamic>;
      setState(() {
        _items = raw
            .whereType<Map<String, dynamic>>()
            .map(LsCustomerBooking.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load bookings.';
      });
    }
  }

  Future<void> _act(LsCustomerBooking b, String status) async {
    try {
      await _service.transitionBooking(b.id, status);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _review(LsCustomerBooking b) async {
    try {
      await _service.review(b.id, 5);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for the 5-star review')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My bookings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? const Center(child: Text('No bookings yet.'))
                    : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final LsCustomerBooking b = _items[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(b.code),
                              subtitle: Text(
                                '${b.status} · ₹${b.labourAmount} + ₹${b.partsAmount} parts',
                              ),
                              onTap: () => Navigator.of(context)
                                  .push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => LsTrackingView(
                                        bookingId: b.id,
                                      ),
                                    ),
                                  )
                                  .then((_) => _load()),
                              trailing: Wrap(
                                spacing: 4,
                                children: <Widget>[
                                  for (final String a in b.actions)
                                    TextButton(
                                      onPressed: () => _act(b, a),
                                      child: Text(a),
                                    ),
                                  if (b.status == 'COMPLETED')
                                    TextButton(
                                      onPressed: () => _review(b),
                                      child: const Text('REVIEW'),
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
