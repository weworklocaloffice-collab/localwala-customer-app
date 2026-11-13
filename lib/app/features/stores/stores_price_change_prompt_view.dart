import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

class StoresPriceChangePromptView extends StatefulWidget {
  const StoresPriceChangePromptView({super.key, this.service});

  final StoresCustomerService? service;

  @override
  State<StoresPriceChangePromptView> createState() =>
      _StoresPriceChangePromptViewState();
}

class _StoresPriceChangePromptViewState
    extends State<StoresPriceChangePromptView> {
  late final StoresCustomerService _service;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.awaitingPriceChanges();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load pending price changes.';
      });
      return;
    }
    try {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() {
        _rows = (body['items'] as List? ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map<dynamic, dynamic> m) => Map<String, dynamic>.from(m))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not parse response.';
      });
    }
  }

  Future<void> _accept(Map<String, dynamic> row) async {
    final String subId = '${row['subscription'] is Map ? (row['subscription'] as Map)['_id'] ?? (row['subscription'] as Map)['id'] : row['subscription'] ?? ''}';
    final String occId = '${row['_id'] ?? row['id'] ?? ''}';
    if (subId.isEmpty || occId.isEmpty) return;
    setState(() => _busy = true);
    try {
      final response = await _service.acceptPriceChange(subId, occId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.success ? 'Price accepted; order placed.' : 'Could not accept price change.')),
      );
      if (response.success) _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pause(Map<String, dynamic> row) async {
    final String subId = '${row['subscription'] is Map ? (row['subscription'] as Map)['_id'] ?? (row['subscription'] as Map)['id'] : row['subscription'] ?? ''}';
    if (subId.isEmpty) return;
    setState(() => _busy = true);
    try {
      final response = await _service.pauseSubscription(subId, 'Price change not accepted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.success ? 'Subscription paused.' : 'Could not pause.')),
      );
      if (response.success) _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel(Map<String, dynamic> row) async {
    final String subId = '${row['subscription'] is Map ? (row['subscription'] as Map)['_id'] ?? (row['subscription'] as Map)['id'] : row['subscription'] ?? ''}';
    if (subId.isEmpty) return;
    setState(() => _busy = true);
    try {
      final response = await _service.cancelSubscription(subId, 'Price change not accepted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.success ? 'Subscription cancelled.' : 'Could not cancel.')),
      );
      if (response.success) _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price changes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _rows.isEmpty
                  ? const Center(child: Text('No pending price changes.'))
                  : ListView.separated(
                      itemCount: _rows.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> row = _rows[index];
                        return ListTile(
                          leading: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                          title: Text('Price change on ${row['occurrenceDate'] ?? ''}'),
                          subtitle: Text('${row['skipReason'] ?? ''}'),
                          trailing: Wrap(
                            spacing: 4,
                            children: <Widget>[
                              FilledButton(onPressed: _busy ? null : () => _accept(row), child: const Text('Accept')),
                              OutlinedButton(onPressed: _busy ? null : () => _pause(row), child: const Text('Pause')),
                              TextButton(onPressed: _busy ? null : () => _cancel(row), child: const Text('Cancel')),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
