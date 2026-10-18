import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/jhatka/jhatka_customer_money.dart' as jhatka_money;
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// One subscription: status, upcoming deliveries with billing state, actions.
///
/// Upcoming occurrences carry `payDue` — one predicate, server-defined. The app
/// shows a pay button exactly there, so client and server cannot disagree about
/// what is owed. A prepaid delivery that was never charged shows pay; one that
/// was charged shows paid; one skipped for non-payment shows credited, not owed.
class JhatkaSubscriptionDetailView extends StatefulWidget {
  const JhatkaSubscriptionDetailView({
    super.key,
    required this.subscriptionId,
  });

  final String subscriptionId;

  @override
  State<JhatkaSubscriptionDetailView> createState() =>
      _JhatkaSubscriptionDetailViewState();
}

class _JhatkaSubscriptionDetailViewState
    extends State<JhatkaSubscriptionDetailView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  bool _busy = false;
  String? _error;
  Map<String, dynamic> _subscription = <String, dynamic>{};
  List<dynamic> _occurrences = const <dynamic>[];

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
    final response =
        await _service.subscriptionDetail(widget.subscriptionId);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load the subscription.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    setState(() {
      _loading = false;
      _subscription =
          Map<String, dynamic>.from((body['subscription'] ?? {}) as Map);
      _occurrences = (body['occurrences'] as List?) ?? const <dynamic>[];
    });
  }

  /// Pay for one occurrence. The amount is the frozen ceiling — the screen never
  /// sends one, and the server refuses a body carrying it. What returns is an
  /// initiation to complete in the shared checkout, not a receipt. No gateway
  /// id is sent either: the server resolves the outlet default, same as the
  /// billing sweep, because subscriptions have no quote endpoint to discover
  /// one through.
  Future<void> _pay(String occurrenceId) async {
    setState(() => _busy = true);
    final response = await _service.paySubscriptionOccurrence(
      subscriptionId: widget.subscriptionId,
      occurrenceId: occurrenceId,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start payment. Retry.')),
      );
      return;
    }
    // Same handoff as orders: the shared checkout owns the gateway from here.
    String initiationId = '';
    try {
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final dynamic initiation = decoded['initiation'];
      if (initiation is Map) {
        initiationId = (initiation['id'] ?? initiation['_id'] ?? '').toString();
      } else if (initiation != null) {
        initiationId = initiation.toString();
      }
    } catch (_) {
      initiationId = '';
    }
    if (initiationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment started but unreadable. Retry.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed('/make_payments', arguments: [initiationId]);
  }

  Widget _occurrenceTile(dynamic raw) {
    final Map<String, dynamic> occurrence =
        Map<String, dynamic>.from(raw as Map);
    final String id = (occurrence['id'] ?? '').toString();
    final bool payDue = occurrence['payDue'] == true;
    final String paymentStatus =
        (occurrence['paymentStatus'] ?? '').toString();
    final String date = (occurrence['occurrenceDate'] ?? '').toString();
    // Lean read: paise. formatPaise, never a bare /100 at the call site.
    final num charge = (occurrence['chargeAmountPaise'] ?? 0) as num;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(date.isEmpty ? 'Delivery' : date.split('T').first),
        subtitle: Text(
          '${jhatka_money.formatPaise(charge)} · '
          '${(occurrence['generationStatus'] ?? '').toString()}'
          '${paymentStatus.isNotEmpty ? ' · $paymentStatus' : ''}',
        ),
        trailing: payDue
            ? FilledButton.tonal(
                onPressed: _busy ? null : () => _pay(id),
                child: const Text('Pay'),
              )
            : paymentStatus == 'paid'
                ? const Icon(Icons.check_circle_outline,
                    color: Colors.green)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription ${_subscription['subscriptionNo'] ?? ''}',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: <Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${(_subscription['status'] ?? '').toString()} · '
                                '${(_subscription['scheduleType'] ?? '').toString()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Next: ${(_subscription['nextOccurrenceDate'] ?? '').toString().split('T').first}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Upcoming deliveries — pay only where asked. A skipped '
                          'delivery shows credited, never owed.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_occurrences.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No upcoming deliveries.'),
                          ),
                        )
                      else
                        ..._occurrences.map(_occurrenceTile),
                    ],
                  ),
      ),
    );
  }
}
