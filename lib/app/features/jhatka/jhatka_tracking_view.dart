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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/jhatka/jhatka_customer_money.dart'
    as jhatka_money;
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// Order tracking as a milestone timeline.
///
/// Milestones carry `reached` flags from server timestamps — the screen
/// renders progress, it never infers it. A reached-but-unseen weight
/// confirmation offers the acknowledgement inline.
class JhatkaTrackingView extends StatefulWidget {
  const JhatkaTrackingView({super.key, required this.orderId});

  final String orderId;

  @override
  State<JhatkaTrackingView> createState() => _JhatkaTrackingViewState();
}

class _JhatkaTrackingViewState extends State<JhatkaTrackingView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic> _tracking = const <String, dynamic>{};
  bool _busy = false;
  // OTP state. The code itself is shown ONCE at issue and never stored —
  // a re-render must not be able to leak it from state that outlives the call.
  String? _otpCode;
  Map<String, dynamic>? _otpStatus;
  List<dynamic> _refunds = const <dynamic>[];

  @override
  void dispose() {
    super.dispose();
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
    final response = await _service.orderTracking(widget.orderId);
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load tracking.';
      });
      return;
    }
    setState(() {
      _loading = false;
      _tracking =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    });
    // OTP status + refunds ride along, best-effort: tracking is the point of
    // this screen, and neither may fail its load.
    unawaited(_loadOtpStatus());
    unawaited(_loadRefunds());
  }

  Future<void> _loadOtpStatus() async {
    final response = await _service.requestOrderOtp(widget.orderId);
    // GET is status-only (enabled/expires/attempts) — it never returns the code.
    // A 4xx here means no code is issuable right now (already delivered); that
    // is a state, not an error, so it clears rather than alarms.
    if (!mounted) return;
    if (!response.success) {
      setState(() => _otpStatus = null);
      return;
    }
    try {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() => _otpStatus = body);
    } catch (_) {
      // Malformed status body: treat as no OTP rather than crash the screen.
    }
  }

  Future<void> _loadRefunds() async {
    final response = await _service.orderRefunds(widget.orderId);
    if (!mounted || !response.success) return;
    try {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      setState(() {
        _refunds = (body['refunds'] as List?) ?? const <dynamic>[];
      });
    } catch (_) {
      // Refunds are informational here; the orders screen owns the money view.
    }
  }

  Future<void> _acknowledge() async {
    setState(() => _busy = true);
    final response = await _service.confirmWeight(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.success ? 'Noted — thanks.' : 'That did not go through.',
        ),
      ),
    );
  }

  /// Issue a delivery code. Returned ONCE — shown big, memorised or shared
  /// with the rider, then gone. Regenerating resets the attempt counter, so a
  /// mistyped code is recoverable without locking anyone out of their parcel.
  Future<void> _issueOtp() async {
    setState(() {
      _busy = true;
      _otpCode = null;
    });
    final response = await _service.requestOrderOtp(widget.orderId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No code issuable right now — already delivered?'),
        ),
      );
      return;
    }
    try {
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final String code = (body['code'] ?? '').toString();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code issued but unreadable. Retry.')),
        );
        return;
      }
      setState(() => _otpCode = code);
      await _loadOtpStatus();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code issued but unreadable. Retry.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> milestones =
        (_tracking['milestones'] as List?) ?? const <dynamic>[];
    final String lifecycle = (_tracking['lifecycle'] ?? '').toString();
    final bool weightSeen = milestones.any((dynamic raw) {
      final Map<String, dynamic> m = Map<String, dynamic>.from(raw as Map);
      return m['key'] == 'weight_confirmed' && m['reached'] == true;
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Tracking')),
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
                        child: ListTile(
                          title: Text(
                            'Order ${(_tracking['orderNo'] ?? '—').toString()}',
                          ),
                          subtitle: Text(
                            '$lifecycle'
                            '${(_tracking['hasDriver'] ?? false) == true ? ' · rider assigned' : ''}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...milestones.map((dynamic raw) {
                        final Map<String, dynamic> m =
                            Map<String, dynamic>.from(raw as Map);
                        final bool reached = m['reached'] == true;
                        return ListTile(
                          leading: Icon(
                            reached
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: reached ? Colors.green : Colors.grey,
                          ),
                          title: Text((m['label'] ?? '').toString()),
                          subtitle: m['at'] != null
                              ? Text(m['at'].toString().split('.').first)
                              : null,
                        );
                      }),
                      if (weightSeen) ...<Widget>[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const Text(
                                  'Final weight is in — tap to confirm you saw it.',
                                  style: TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                FilledButton.tonal(
                                  onPressed:
                                      _busy ? null : _acknowledge,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    child: Text('Got it'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _otpCard(),
                      const SizedBox(height: 12),
                      _refundsCard(),
                    ],
                  ),
      ),
    );
  }

  /// Delivery handover code. Issued on demand, shown once, verified rider-side
  /// at deliver time.
  Widget _otpCard() {
    final bool hasCode = (_otpCode ?? '').isNotEmpty;
    final bool enabled = (_otpStatus?['enabled'] ?? false) == true;
    final bool verified = (_otpStatus?['verifiedAt'] ?? '') != '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Handover code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Read it to the rider at the door. Shown once.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            if (verified)
              const Row(
                children: <Widget>[
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('Handed over.'),
                ],
              )
            else if (hasCode)
              Center(
                child: Text(
                  _otpCode!,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                  ),
                ),
              )
            else
              FilledButton.tonal(
                onPressed: _busy ? null : _issueOtp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(enabled ? 'Show new code' : 'Get handover code'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Refunds on this order, newest first. Every refund is a document.
  Widget _refundsCard() {
    if (_refunds.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Refunds (${_refunds.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._refunds.map((dynamic raw) {
              final Map<String, dynamic> refund =
                  Map<String, dynamic>.from(raw as Map);
              final num amount = (refund['amount'] ?? 0) as num;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        (refund['reasonNote'] ?? refund['reason'] ?? 'Refund').toString(),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          jhatka_money.formatPaise(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (refund['status'] ?? '').toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
