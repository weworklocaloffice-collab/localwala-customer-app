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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

import 'invoice_download_stub.dart'
    if (dart.library.html) 'invoice_download_web.dart';

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
  bool _complaining = false;
  bool _completing = false;
  bool _downloadingInvoice = false;

  Future<void> _dispute() async {
    final TextEditingController reason = TextEditingController();
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n?.ls_dispute ?? 'Dispute booking'),
        content: TextField(
          controller: reason,
          decoration: InputDecoration(
            labelText: l10n?.ls_reason ?? 'Reason',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.ls_cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n?.ls_submit ?? 'Submit'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_dispute_failed('$e') ??
                  'Dispute failed: $e',
            ),
          ),
        );
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
          _error =
              AppLocalizations.of(context)?.ls_booking_load_failed ??
              'Could not load booking.';
        });
      }
    }
  }

  double _amount(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  Widget _amountRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\u20b9${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

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
    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (_paid > 0 && _balance > 0) {
      return l10n?.ls_pay_balance(_amountDue.toStringAsFixed(2)) ??
          'Pay balance \u20b9${_amountDue.toStringAsFixed(2)}';
    }
    if (_paid <= 0 && _deposit > 0 && _balance > 0) {
      return l10n?.ls_pay_deposit(_amountDue.toStringAsFixed(2)) ??
          'Pay deposit \u20b9${_amountDue.toStringAsFixed(2)}';
    }
    return _booking!['paymentStatus'] == 'failed'
        ? (l10n?.ls_retry_payment ?? 'Retry payment')
        : (l10n?.ls_pay_now ?? 'Pay now');
  }

  String get _providerName {
    final dynamic provider = _booking?['provider'];
    if (provider is Map) return '${provider['businessName'] ?? ''}';
    return '';
  }

  Future<void> _downloadInvoice() async {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      setState(() => _downloadingInvoice = true);
      try {
        final Uint8List? bytes = await _service.invoicePdfBytes(widget.bookingId);
        if (bytes == null) throw Exception('Download failed');
        downloadInvoiceBytes(
          bytes,
          'LocalWala_LocalService_Invoice_${widget.bookingId}.pdf',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.download_invoice ?? 'Download invoice')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.ls_failed_error('$e') ?? 'Failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _downloadingInvoice = false);
      }
      return;
    }
    setState(() => _downloadingInvoice = true);
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path =
          '${directory.path}/LocalWala_LocalService_Invoice_${widget.bookingId}.pdf';
      final bool ok = await _service.invoicePdf(widget.bookingId, path);
      if (!ok) throw Exception('Download failed');
      await SharePlus.instance.share(
        ShareParams(
          title: l10n?.ls_invoice ?? 'Invoice',
          files: <XFile>[XFile(path)],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.ls_failed_error('$e') ?? 'Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingInvoice = false);
    }
  }

  Future<void> _confirmCompletion() async {
    setState(() => _completing = true);
    try {
      await _service.confirmCompletion(widget.bookingId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_completion_confirmed ??
                  'Completion confirmed',
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
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _openSupportChat() async {
    await Navigator.of(context).pushNamed(
      AppRouter.supportChatRoute,
      arguments: <dynamic>['local_services_booking', widget.bookingId],
    );
  }

  Future<void> _complain() async {
    final TextEditingController reason = TextEditingController();
    final AppLocalizations? l10n = AppLocalizations.of(context);
    String? errorText;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) =>
            AlertDialog(
              title: Text(l10n?.ls_complaint ?? 'Raise a complaint'),
              content: TextField(
                controller: reason,
                minLines: 3,
                maxLines: 5,
                maxLength: 1000,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) =>
                    setDialogState(() => errorText = null),
                decoration: InputDecoration(
                  labelText: 'What happened?',
                  hintText: 'Describe the issue with this booking',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(l10n?.ls_cancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (reason.text.trim().length < 5) {
                      setDialogState(
                        () => errorText = 'Please describe the issue.',
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(l10n?.ls_submit ?? 'Submit'),
                ),
              ],
            ),
      ),
    );
    if (confirm != true) {
      reason.dispose();
      return;
    }
    setState(() => _complaining = true);
    try {
      await _service.createComplaint(<String, dynamic>{
        'booking': widget.bookingId,
        'reason': reason.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_complaint_submitted ??
                  'Complaint submitted',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_complaint_failed('$e') ??
                  'Failed: $e',
            ),
          ),
        );
      }
    } finally {
      reason.dispose();
      if (mounted) setState(() => _complaining = false);
    }
  }

  Future<void> _acceptQuote(String quoteId) async {
    setState(() => _acceptingQuote = true);
    try {
      await _service.acceptQuote(quoteId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_could_not_accept_quote('$e') ??
                  'Could not accept quote: $e',
            ),
          ),
        );
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
          _error =
              AppLocalizations.of(context)?.ls_payment_could_not_start ??
              'Payment could not be started.';
        });
        return;
      }
      if (paidFromWallet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.ls_paid_from_wallet ??
                  'Paid from your wallet.',
            ),
          ),
        );
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
          _error =
              AppLocalizations.of(context)?.ls_payment_failed_to_start('$e') ??
              'Payment failed to start: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String startLabel = lsFormatDate(
      '${_booking?['startAt'] ?? _booking?['scheduledAt'] ?? ''}',
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.ls_tracking_title ?? 'Tracking',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null || _booking == null
            ? Center(
                child: Text(
                  _error ??
                      (AppLocalizations.of(context)?.ls_not_found ??
                          'Not found'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  LsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${_booking!['bookingCode'] ?? ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: lsSlate900,
                                        ),
                                  ),
                                  if (_providerName.isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 4),
                                    Text(
                                      _providerName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: lsSlate500),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            LsStatusChip(
                              status: '${_booking!['status'] ?? ''}',
                            ),
                          ],
                        ),
                        if (startLabel.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.event_outlined,
                                size: 15,
                                color: lsSlate500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Scheduled: $startLabel',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: lsSlate600),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            LsStatusChip(
                              status:
                                  '${_booking!['paymentStatus'] ?? 'pending'}',
                              payment: true,
                            ),
                            if (_booking!['paymentMode'] != null)
                              Chip(
                                visualDensity: VisualDensity.compact,
                                avatar: const Icon(
                                  Icons.payments_outlined,
                                  size: 15,
                                ),
                                label: Text(
                                  '${_booking!['paymentMode']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Status timeline
                  _StatusTimeline(status: '${_booking!['status'] ?? ''}'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)?.ls_amount_breakdown ??
                                'Amount breakdown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _amountRow(
                            AppLocalizations.of(context)?.ls_labour ?? 'Labour',
                            _amount(_booking!['labourAmount']),
                          ),
                          _amountRow(
                            AppLocalizations.of(context)?.ls_parts ?? 'Parts',
                            _amount(_booking!['partsAmount']),
                          ),
                          const Divider(),
                          _amountRow(
                            AppLocalizations.of(context)?.ls_total ?? 'Total',
                            _total,
                            bold: true,
                          ),
                          if (_deposit > 0 && _balance > 0) ...<Widget>[
                            _amountRow(
                              AppLocalizations.of(context)?.ls_deposit ??
                                  'Deposit',
                              _deposit,
                            ),
                            _amountRow(
                              AppLocalizations.of(context)?.ls_paid ?? 'Paid',
                              _paid,
                            ),
                            _amountRow(
                              AppLocalizations.of(context)?.ls_balance ??
                                  'Balance',
                              _total - _paid,
                              bold: true,
                            ),
                          ] else if (_paid > 0) ...<Widget>[
                            _amountRow(
                              AppLocalizations.of(context)?.ls_paid ?? 'Paid',
                              _paid,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_canPay) ...<Widget>[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _startingPayment ? null : _pay,
                      child: Text(
                        _startingPayment
                            ? (AppLocalizations.of(
                                    context,
                                  )?.ls_starting_payment ??
                                  'Starting payment...')
                            : _payLabel,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openSupportChat,
                      icon: const Icon(Icons.headset_mic_outlined, size: 18),
                      label: const Text('Chat with support'),
                    ),
                  ),
                  if (_booking!['status'] == 'IN_PROGRESS' ||
                      _booking!['status'] == 'COMPLETED') ...<Widget>[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _disputing ? null : _dispute,
                      icon: const Icon(Icons.flag),
                      label: Text(
                        _disputing
                            ? (AppLocalizations.of(context)?.ls_submitting ??
                                  'Submitting...')
                            : (AppLocalizations.of(context)?.ls_dispute ??
                                  'Dispute'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _complaining ? null : _complain,
                      icon: const Icon(Icons.report_problem_outlined),
                      label: Text(
                        _complaining
                            ? (AppLocalizations.of(context)?.ls_submitting ??
                                  'Submitting...')
                            : (AppLocalizations.of(context)?.ls_complaint ??
                                  'Complaint'),
                      ),
                    ),
                  ],
                  if (_booking!['status'] == 'IN_PROGRESS') ...<Widget>[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _completing ? null : _confirmCompletion,
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        _completing
                            ? (AppLocalizations.of(context)?.ls_confirming ??
                                  'Confirming...')
                            : (AppLocalizations.of(
                                    context,
                                  )?.ls_confirm_completion ??
                                  'Confirm completion'),
                      ),
                    ),
                  ],
                  if (_quotes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.ls_pending_quote ??
                          'Pending quote',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final Map<String, dynamic> q in _quotes)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${AppLocalizations.of(context)?.ls_labour ?? 'Labour'} \u20b9${q['labourAmount'] ?? 0} \u00b7 '
                                '${AppLocalizations.of(context)?.ls_parts ?? 'Parts'} \u20b9${q['partsAmount'] ?? 0}',
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
                                      ? (AppLocalizations.of(
                                              context,
                                            )?.ls_accepting ??
                                            'Accepting...')
                                      : (AppLocalizations.of(
                                              context,
                                            )?.ls_accept_quote ??
                                            'Accept quote'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (_invoice != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)?.ls_invoice ??
                                      'Invoice',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                if (_downloadingInvoice)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                else
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    tooltip:
                                        AppLocalizations.of(
                                          context,
                                        )?.download_invoice ??
                                        'Download invoice',
                                    onPressed: _downloadInvoice,
                                    icon: const Icon(
                                      Icons.download_outlined,
                                      size: 20,
                                    ),
                                  ),
                                Chip(
                                  label: Text('${_invoice!['status'] ?? ''}'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            const Divider(),
                            for (final dynamic line
                                in (_invoice!['lines'] ?? []) as List<dynamic>)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        '${(line as Map<String, dynamic>)['label'] ?? ''}',
                                      ),
                                    ),
                                    Text(
                                      '\u20b9${(line as Map)['amount'] ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context)?.ls_total ??
                                      'Total',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '\u20b9${_invoice!['total'] ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  static const List<String> _steps = <String>[
    'DRAFT',
    'REQUESTED',
    'CONFIRMED',
    'IN_PROGRESS',
    'COMPLETED',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int current = _steps.indexOf(status.toUpperCase());
    final int active = current < 0 ? 0 : current;
    return Row(
      children: List<Widget>.generate(_steps.length, (int i) {
        final bool done = i <= active;
        final bool isLast = i == _steps.length - 1;
        return Expanded(
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: done
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 10),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lsStatusLabel(_steps[i]),
                    style: TextStyle(
                      fontSize: 9,
                      color: done ? theme.colorScheme.primary : Colors.grey,
                      fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < active
                        ? theme.colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
