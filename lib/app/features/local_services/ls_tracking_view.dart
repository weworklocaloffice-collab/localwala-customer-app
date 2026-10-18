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
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';

/// Booking tracking: live status, amounts and invoice (once issued).
/// Refunds appear as reversal records against the original payment —
/// the original total is never rewritten.
class LsTrackingView extends StatefulWidget {
  const LsTrackingView({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<LsTrackingView> createState() => _LsTrackingViewState();
}

class _LsTrackingViewState extends State<LsTrackingView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _booking;
  Map<String, dynamic>? _invoice;

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
      final dynamic res = await _service.booking(widget.bookingId);
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      Map<String, dynamic>? invoice;
      try {
        final dynamic inv = await _service.invoice(widget.bookingId);
        final Map<String, dynamic> invBody =
            Map<String, dynamic>.from(jsonDecode(inv.body) as Map);
        final dynamic raw = invBody['invoice'];
        if (raw is Map<String, dynamic>) invoice = raw;
      } catch (_) {
        invoice = null;
      }
      if (!mounted) return;
      setState(() {
        final dynamic raw = body['booking'];
        _booking = raw is Map<String, dynamic> ? raw : null;
        _invoice = invoice;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load booking.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _booking == null
                ? Center(child: Text(_error ?? 'Not found'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Text(
                        '${_booking!['bookingCode'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Status: ${_booking!['status'] ?? ''}'),
                      Text(
                        'Labour ₹${_booking!['labourAmount'] ?? 0} · '
                        'Parts ₹${_booking!['partsAmount'] ?? 0}',
                      ),
                      if (_invoice != null) ...<Widget>[
                        const SizedBox(height: 12),
                        const Text(
                          'Invoice',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (final dynamic line
                            in (_invoice!['lines'] ?? []) as List<dynamic>)
                          ListTile(
                            dense: true,
                            title: Text('${(line as Map)['label'] ?? ''}'),
                            trailing: Text('₹${line['amount'] ?? 0}'),
                          ),
                        Text(
                          'Total ₹${_invoice!['total'] ?? 0} (${_invoice!['status'] ?? ''})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}
