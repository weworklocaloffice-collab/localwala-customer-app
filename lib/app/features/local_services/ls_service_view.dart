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
import 'package:user/app/features/local_services/ls_booking_view.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';

/// Service detail: what it is, how it books, live availability, and the
/// honest price line — "quote needed" for quote modes, never a fake fixed
/// amount. Booking starts here via [LsBookingView].
class LsServiceView extends StatefulWidget {
  const LsServiceView({super.key, required this.service});

  final LsService service;

  @override
  State<LsServiceView> createState() => _LsServiceViewState();
}

class _LsServiceViewState extends State<LsServiceView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _checking = false;
  List<dynamic> _slots = const <dynamic>[];
  String? _slotError;

  Future<void> _checkAvailability() async {
    setState(() {
      _checking = true;
      _slotError = null;
    });
    try {
      final DateTime start = DateTime.now().add(const Duration(days: 1));
      final DateTime end = start.add(
        Duration(minutes: widget.service.baseDurationMinutes),
      );
      final dynamic res = await _service.availability(
        serviceId: widget.service.id,
        startAt: start.toIso8601String(),
        endAt: end.toIso8601String(),
      );
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      setState(() {
        _slots = (body['results'] ?? []) as List<dynamic>;
        _checking = false;
      });
    } catch (e) {
      setState(() {
        _slotError = 'Availability unavailable right now.';
        _checking = false;
      });
    }
  }

  void _openBooking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LsBookingView(service: widget.service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LsService s = widget.service;
    final int available = _slots
        .where((dynamic e) => (e as Map)['available'] == true)
        .length;
    return Scaffold(
      appBar: AppBar(title: Text(s.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            s.needsQuote ? 'Quote needed' : 'Booking: ${s.bookingMode}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Pricing: ${s.pricingMode}'),
          const SizedBox(height: 16),
          if (s.needsQuote)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Final price comes as a provider quotation after inspection. '
                  'The booking fee (if any) shows separately at checkout.',
                ),
              ),
            ),
          if (s.needsQuote) ...const [SizedBox(height: 16)],
          ElevatedButton(
            onPressed: _checking ? null : _openBooking,
            child: Text(s.needsQuote ? 'Request quote' : 'Book now'),
          ),
          TextButton(
            onPressed: _checking ? null : _checkAvailability,
            child: Text(
              _checking ? 'Checking…' : 'Check tomorrow’s availability',
            ),
          ),
          if (_slotError != null) Text(_slotError!),
          if (_slots.isNotEmpty)
            Text(
              '$available provider(s) free tomorrow'
              '${_slots.any((dynamic e) => (e as Map)['sponsored'] == true) ? ' · sponsored marked' : ''}',
            ),
        ],
      ),
    );
  }
}
