/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer complaints list.
class LsComplaintsView extends StatefulWidget {
  const LsComplaintsView({super.key});

  @override
  State<LsComplaintsView> createState() => _LsComplaintsViewState();
}

class _LsComplaintsViewState extends State<LsComplaintsView> {
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
      final dynamic res = await _service.myComplaints();
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final List<dynamic> raw = (body['results'] ?? []) as List<dynamic>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.ls_my_complaints ?? 'My complaints')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)?.ls_no_complaints ?? 'No complaints.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Map<String, dynamic> c = _items[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text('${c['subject'] ?? 'Complaint'}'),
                              subtitle: Text(
                                'Status: ${c['status'] ?? ''}\n'
                                '${c['description'] ?? ''}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
