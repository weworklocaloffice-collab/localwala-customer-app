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
import 'package:user/gen/l10n/app_localizations.dart';

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
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
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
        _error = AppLocalizations.of(context)?.ls_bookings_load_failed ??
            'Could not load bookings.';
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
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_failed_error('$e') ??
                  'Failed: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _review(LsCustomerBooking b) async {
    try {
      await _service.review(b.id, 5);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_review_thanks ??
                  'Thanks for the 5-star review',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_failed_error('$e') ??
                  'Failed: $e',
            ),
          ),
        );
      }
    }
  }

  String _actionLabel(AppLocalizations? l10n, String action) {
    switch (action) {
      case 'REQUESTED':
        return l10n?.ls_action_request ?? 'Request';
      case 'CANCELLED':
        return l10n?.ls_cancel ?? 'Cancel';
      case 'DISPUTED':
        return l10n?.ls_dispute ?? 'Dispute';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.ls_my_bookings ?? 'My bookings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _items.isEmpty
            ? Center(child: Text(l10n?.ls_no_bookings ?? 'No bookings yet.'))
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
                        '${b.status} \u00b7 \u20b9${b.serviceValue} \u00b7 ${b.paymentStatus}',
                      ),
                      onTap: () => Navigator.of(context)
                          .push(
                            MaterialPageRoute<void>(
                              builder: (_) => LsTrackingView(bookingId: b.id),
                            ),
                          )
                          .then((_) => _load()),
                      trailing: Wrap(
                        spacing: 4,
                        children: <Widget>[
                          for (final String a in b.actions)
                            TextButton(
                              onPressed: () => _act(b, a),
                              child: Text(_actionLabel(l10n, a)),
                            ),
                          if (b.status == 'COMPLETED')
                            TextButton(
                              onPressed: () => _review(b),
                              child: Text(l10n?.ls_review ?? 'Review'),
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
