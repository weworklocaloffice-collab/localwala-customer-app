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

/// Checkout. The customer picks mode, time and payment channel; the backend
/// computes every total (the `pricing` block is input rates only).
/// Booking fee vs quotation stay on separate lines per §14-C.
class LsBookingView extends StatefulWidget {
  const LsBookingView({super.key, required this.service});

  final LsService service;

  @override
  State<LsBookingView> createState() => _LsBookingViewState();
}

class _LsBookingViewState extends State<LsBookingView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();
  final TextEditingController _labour = TextEditingController(text: '400');
  final TextEditingController _parts = TextEditingController(text: '0');

  String _paymentMode = 'gateway';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _labour.dispose();
    _parts.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final double? labour = double.tryParse(_labour.text.trim());
    final double? parts = double.tryParse(_parts.text.trim());
    if (labour == null || parts == null) {
      setState(() => _error = 'Enter labour and parts amounts.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final DateTime when = DateTime.now().add(const Duration(days: 1));
      final dynamic res = await _service.createBooking(<String, dynamic>{
        'serviceKey': widget.service.key,
        'bookingMode':
            widget.service.bookingMode.isEmpty ? 'REQUEST' : widget.service.bookingMode,
        'scheduledAt': when.toIso8601String(),
        'labourAmount': labour,
        'partsAmount': parts,
        'paymentMode': _paymentMode,
      });
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(res.body) as Map);
      final dynamic raw = body['booking'];
      if (!mounted) return;
      if (raw is! Map<String, dynamic>) {
        setState(() {
          _error = '${body['message'] ?? 'Booking failed'}';
          _submitting = false;
        });
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LsTrackingView(bookingId: '${raw['_id'] ?? ''}'),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Booking failed: $e';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (widget.service.needsQuote)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Final price comes as a provider quotation after inspection. '
                  'The booking fee (if any) shows separately at checkout.',
                ),
              ),
            ),
          TextField(
            controller: _labour,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Labour estimate ₹',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _parts,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Parts estimate ₹',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Payment'),
          RadioGroup<String>(
            groupValue: _paymentMode,
            onChanged: (String? v) =>
                setState(() => _paymentMode = v ?? 'gateway'),
            child: Column(
              children: <Widget>[
                for (final String m in <String>['gateway', 'cod', 'direct'])
                  RadioListTile<String>(
                    title: Text(
                      m == 'gateway'
                          ? 'Online'
                          : m == 'cod'
                              ? 'Cash on completion (where enabled)'
                              : 'Pay technician directly (reconciled at settlement)',
                    ),
                    value: m,
                  ),
              ],
            ),
          ),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Booking…' : 'Confirm booking'),
          ),
        ],
      ),
    );
  }
}
