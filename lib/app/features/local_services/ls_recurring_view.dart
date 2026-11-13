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
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer recurring agreements list with pause/resume/cancel actions.
class LsRecurringView extends StatefulWidget {
  const LsRecurringView({super.key});

  @override
  State<LsRecurringView> createState() => _LsRecurringViewState();
}

class _LsRecurringViewState extends State<LsRecurringView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const <Map<String, dynamic>>[];

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
      final dynamic res = await _service.recurring();
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final List<dynamic> raw = (body['results'] ?? body['agreements'] ?? [])
          as List<dynamic>;
      setState(() {
        _items = raw.whereType<Map<String, dynamic>>().toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _setStatus(String id, String status) async {
    try {
      await _service.setRecurringStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_agreement_status(status) ??
                  'Agreement $status',
            ),
          ),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_failed_error('$e') ?? 'Failed: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.ls_recurring_services ?? 'Recurring services')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)?.ls_no_recurring ?? 'No recurring agreements yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Map<String, dynamic> ag = _items[i];
                          final String id = '${ag['_id'] ?? ag['id'] ?? ''}';
                          final String status =
                              '${ag['status'] ?? 'active'}';
                          final String cadence =
                              '${ag['cadence'] ?? 'weekly'}';
                          final String next =
                              '${ag['nextOccurrenceDate'] ?? ''}';
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(
                                AppLocalizations.of(context)?.ls_cadence(cadence) ??
                                    'Cadence: $cadence',
                              ),
                              subtitle: Text(
                                AppLocalizations.of(context)?.ls_status_next(status, next) ??
                                    'Status: $status · Next: $next',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (String v) => _setStatus(id, v),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  if (status != 'active')
                                    PopupMenuItem<String>(
                                      value: 'active',
                                      child: Text(
                                        AppLocalizations.of(context)?.ls_resume ??
                                            'Resume',
                                      ),
                                    ),
                                  if (status == 'active')
                                    PopupMenuItem<String>(
                                      value: 'paused',
                                      child: Text(
                                        AppLocalizations.of(context)?.ls_pause ??
                                            'Pause',
                                      ),
                                    ),
                                  PopupMenuItem<String>(
                                    value: 'cancelled',
                                    child: Text(
                                      AppLocalizations.of(context)?.ls_cancel ??
                                          'Cancel',
                                    ),
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
