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
  bool _startingPayment = false;
  String? _error;
  Map<String, dynamic>? _booking;
  Map<String, dynamic>? _invoice;
  List<Map<String, dynamic>> _quotes = const <Map<String, dynamic>>[];
  bool _disputing = false;
  bool _acceptingQuote = false;

  Future<void> _dispute() async {
    final TextEditingController reason = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Dispute booking'),
        content: TextField(
          controller: reason,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirm != true) {
      reason.dispose();
      return;
    }
    setState(() => _disputing = true);
    try {
      await _service.transitionBooking(
        widget.bookingId,
        'DISPUTED',
        <String, dynamic>{'reason': reason.text.trim()},
      );
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dispute failed: $e')));
      }
    } finally {
      reason.dispose();
      if (mounted) setState(() => _disputing = false);
    }
  }

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
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      Map<String, dynamic>? invoice;
      try {
        final dynamic inv = await _service.invoice(widget.bookingId);
        final Map<String, dynamic> invBody = Map<String, dynamic>.from(
          jsonDecode(inv.body) as Map,
        );
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
        final dynamic rawQuotes = body['quotes'];
        _quotes = rawQuotes is List
            ? rawQuotes.whereType<Map<String, dynamic>>().toList()
            : const <Map<String, dynamic>>[];
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

  double _amount(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  double get _total => _amount(_booking?['serviceValue']);

  double get _paid => _amount(_booking?['amountPaid']);

  double get _deposit => _amount(_booking?['depositAmount']);

  double get _balance => _amount(_booking?['balanceAmount']);

  double get _amountDue {
    if (_paid <= 0 && _deposit > 0 && _balance > 0) return _deposit;
    final double remaining = _total - _paid;
    return remaining > 0 ? remaining : 0;
  }

  bool get _canPay {
    if (_booking == null) return false;
    final String mode = '${_booking!['paymentMode'] ?? 'gateway'}';
    if (mode != 'gateway' && mode != 'wallet') return false;
    if (_booking!['paymentStatus'] == 'paid') return false;
    if (_amountDue <= 0) return false;
    return <String>[
      'DRAFT',
      'ACCEPTED',
      'PAYMENT_PENDING',
      'CONFIRMED',
      'IN_PROGRESS',
    ].contains('${_booking!['status'] ?? ''}');
  }

  String get _payLabel {
    if (_paid > 0 && _balance > 0) {
      return 'Pay balance \u20b9${_amountDue.toStringAsFixed(2)}';
    }
    if (_paid <= 0 && _deposit > 0 && _balance > 0) {
      return 'Pay deposit \u20b9${_amountDue.toStringAsFixed(2)}';
    }
    return _booking!['paymentStatus'] == 'failed' ? 'Retry payment' : 'Pay now';
  }

  String get _providerName {
    final dynamic provider = _booking?['provider'];
    if (provider is Map) return '${provider['businessName'] ?? ''}';
    return '';
  }

  Future<void> _acceptQuote(String quoteId) async {
    setState(() => _acceptingQuote = true);
    try {
      await _service.acceptQuote(quoteId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not accept quote: $e')));
      }
    } finally {
      if (mounted) setState(() => _acceptingQuote = false);
    }
  }

  Future<void> _pay() async {
    setState(() {
      _startingPayment = true;
      _error = null;
    });
    try {
      final dynamic res = await _service.payBooking(widget.bookingId);
      String initiationId = '';
      bool paidFromWallet = false;
      if (res.body.isNotEmpty) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          jsonDecode(res.body) as Map,
        );
        final dynamic initiation = body['initiation'];
        if (initiation is Map) {
          initiationId = '${initiation['_id'] ?? initiation['id'] ?? ''}';
        }
        // Wallet payments settle immediately: no gateway intent to open.
        paidFromWallet = body['wallet'] is Map;
      }
      if (!mounted) return;
      if (initiationId.isEmpty && !paidFromWallet) {
        setState(() {
          _startingPayment = false;
          _error = 'Payment could not be started.';
        });
        return;
      }
      if (paidFromWallet) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paid from your wallet.')));
        await _load();
        return;
      }
      await Navigator.of(
        context,
      ).pushNamed('/make_payments', arguments: <String>[initiationId]);
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() {
          _startingPayment = false;
          _error = 'Payment failed to start: $e';
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
                    'Payment: ${_booking!['paymentStatus'] ?? 'pending'}'
                    '${_booking!['paymentMode'] == null ? '' : ' · ${_booking!['paymentMode']}'}',
                  ),
                  if (_providerName.isNotEmpty)
                    Text('Provider: $_providerName'),
                  if (_booking!['startAt'] != null)
                    Text('Start: ${_booking!['startAt']}'),
                  Text(
                    'Labour ₹${_booking!['labourAmount'] ?? 0} · '
                    'Parts ₹${_booking!['partsAmount'] ?? 0}',
                  ),
                  Text(
                    'Total \u20b9${_booking!['serviceValue'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_deposit > 0 && _balance > 0) ...<Widget>[
                    Text('Deposit \u20b9${_deposit.toStringAsFixed(2)}'),
                    Text('Paid \u20b9${_paid.toStringAsFixed(2)}'),
                    Text(
                      'Balance \u20b9${(_total - _paid).clamp(0, double.infinity).toStringAsFixed(2)}',
                    ),
                  ] else if (_paid > 0) ...<Widget>[
                    Text('Paid \u20b9${_paid.toStringAsFixed(2)}'),
                  ],
                  if (_canPay) ...<Widget>[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _startingPayment ? null : _pay,
                      child: Text(
                        _startingPayment ? 'Starting payment\u2026' : _payLabel,
                      ),
                    ),
                  ],
                  if (_booking!['status'] == 'IN_PROGRESS' ||
                      _booking!['status'] == 'COMPLETED') ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _disputing ? null : _dispute,
                      icon: const Icon(Icons.flag),
                      label: Text(_disputing ? 'Submitting\u2026' : 'Dispute'),
                    ),
                  ],
                  if (_quotes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    const Text(
                      'Pending quote',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final Map<String, dynamic> q in _quotes)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Labour \u20b9${q['labourAmount'] ?? 0} · '
                                'Parts \u20b9${q['partsAmount'] ?? 0}',
                              ),
                              if ((q['scopeOfWork'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                                Text('${q['scopeOfWork']}'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _acceptingQuote
                                    ? null
                                    : () => _acceptQuote(
                                        '${q['_id'] ?? q['id'] ?? ''}',
                                      ),
                                child: Text(
                                  _acceptingQuote
                                      ? 'Accepting\u2026'
                                      : 'Accept quote',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
