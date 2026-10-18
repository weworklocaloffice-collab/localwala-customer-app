/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Hold detail screen (Flow 13).
///
/// Shows the full hold: status, money breakdown, the policy snapshot
/// the hold was created under, a timeline, and the actions the customer
/// can take. The actions are gated on status — the backend enforces the
/// same, but the UI must not even offer the wrong control (BR-09 / §6.2).
class HoldDetailScreen extends StatefulWidget {
  final String holdId;
  const HoldDetailScreen({super.key, required this.holdId});

  @override
  State<HoldDetailScreen> createState() => _HoldDetailScreenState();
}

class _HoldDetailScreenState extends State<HoldDetailScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  HoldModel? _hold;
  bool _busy = false;

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
      final h = await _repo.holdById(widget.holdId);
      if (!mounted) return;
      setState(() {
        _hold = h;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load hold';
        _loading = false;
      });
    }
  }

  /// Pay a PENDING_PAYMENT hold through the shared payment stack.
  ///
  /// Creates the `property_hold` initiation, opens it in the shared
  /// MakePayment screen, then reloads — the hold is ACTIVE once the
  /// gateway confirms. Server errors surface verbatim so an OD-01
  /// custody block explains itself instead of a generic failure.
  Future<void> _onPay() async {
    final h = _hold;
    if (h == null || h.status != 'PENDING_PAYMENT') return;
    setState(() => _busy = true);
    try {
      final payLink = await _repo.payHold(h.id);
      if (!mounted) return;
      setState(() => _busy = false);
      await Navigator.of(context).pushNamed(AppRouter.makePaymentRoute, arguments: [payLink]);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_serverMessage(e))),
      );
    }
  }

  String _serverMessage(Object e) {
    final s = e.toString().replaceFirst('Exception: ', '');
    if (s.trim().isEmpty) return 'Could not start payment. Please try again.';
    return s;
  }

  Future<void> _onCancel() async {
    final h = _hold;
    if (h == null || !h.canCancel) return;
    final translate = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translate.re_hold_detail_cancel),
        content: const Text(
          'Your principal will be refunded 100% to your original payment method. '
          'The service fee is retained because the property was taken off-market '
          'and verified while your hold was active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep hold'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(translate.re_hold_detail_cancel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await _repo.cancelHold(h.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hold cancelled. Refund initiated.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not cancel hold. Please try again.')),
      );
    }
  }

  Future<void> _onConvertToSale() async {
    final h = _hold;
    if (h == null || !h.canConvertToSale) return;
    // Sale value is the agreed consideration. The principal is applied
    // against it. We default to the property's listing price when available,
    // but the customer can correct it. A real implementation will need a
    // proper sale form — this minimal version captures the BR-13 contract.
    final controller = TextEditingController();
    final value = await showDialog<double>(
      context: context,
      builder: (_) {
        final dialogTranslate = AppLocalizations.of(context)!;
        return AlertDialog(
        title: Text(dialogTranslate.re_hold_detail_convert),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The hold principal will be applied against the sale consideration. '
              'It is never LocalWala revenue.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Sale value (₹)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v == null || v <= 0) return;
              Navigator.of(context).pop(v);
            },
            child: const Text('Convert'),
          ),
        ],
        );
      },
    );
    if (value == null) return;
    setState(() => _busy = true);
    try {
      await _repo.convertHoldToSale(h.id, saleValue: value);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hold converted to sale.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not convert hold. Please try again.')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING_PAYMENT':
        return Colors.orange;
      case 'REFUND_PENDING':
        return Colors.amber;
      case 'REFUNDED':
      case 'CANCELLED':
      case 'EXPIRED':
        return Colors.grey;
      case 'CONVERTED_TO_SALE':
        return Colors.indigo;
      case 'ADJUSTED':
        return Colors.blueGrey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_hold?.holdCode ?? 'Hold')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                  ),
                )
              : _buildBody(theme, _hold!, translate),
    );
  }

  Widget _buildBody(ThemeData theme, HoldModel h, AppLocalizations translate) {
    final color = _statusColor(h.status);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            h.statusLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        // Property
        if (h.propertySnapshot != null)
          Text(h.propertySnapshot!, style: theme.textTheme.titleMedium),
        if (h.holdCode != null)
          Text(h.holdCode!, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),

        // Price
        Text('Money', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _row(theme, 'Principal (held in trust)', h.principal),
        _row(theme, 'Service fee (revenue)', h.serviceFee, muted: true),
        const Divider(),
        _row(theme, 'Total paid', h.total, bold: true),
        const SizedBox(height: 8),
        if (h.status == 'REFUND_PENDING' || h.status == 'REFUNDED')
          Text(
            'Principal refunded per the §6.2 refund matrix.',
            style: theme.textTheme.bodySmall,
          ),

        const SizedBox(height: 24),

        // Policy snapshot
        Text('Hold terms (frozen at creation)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _row(theme, 'Duration', _daysLabel(h.policySnapshot.durationDays)),
        _row(theme, 'Grace period', '${h.policySnapshot.gracePeriodHours} h'),
        _row(theme, 'Cancellation refundable', _yesNo(h.policySnapshot.cancellationRefundable)),
        _row(theme, 'Expiry refundable', _yesNo(h.policySnapshot.expiryRefundable)),
        _row(
          theme,
          'Fee refundable on listing withdrawal',
          _yesNo(h.policySnapshot.feeRefundableOnListingWithdrawal),
        ),
        _row(
          theme,
          'Forfeiture requires dual control',
          _yesNo(h.policySnapshot.forfeitureRequiresDualControl),
        ),

        const SizedBox(height: 24),

        // Timeline
        Text('Timeline', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (h.placedAt != null)
          _timelineRow(theme, 'Placed', h.placedAt!, done: true),
        if (h.activatedAt != null)
          _timelineRow(theme, 'Activated', h.activatedAt!, done: true),
        if (h.expiresAt != null && (h.status == 'PENDING_PAYMENT' || h.status == 'ACTIVE'))
          _timelineRow(theme, 'Expires', h.expiresAt!, done: false),
        if (h.cancelledAt != null)
          _timelineRow(theme, 'Cancelled', h.cancelledAt!, done: true),
        if (h.status == 'CONVERTED_TO_SALE')
          _timelineRow(theme, 'Converted to sale', DateTime.now(), done: true),
        if (h.status == 'REFUND_PENDING')
          _timelineRow(theme, 'Refund pending', DateTime.now(), done: true),

        const SizedBox(height: 24),

        // Actions
        if (h.status == 'PENDING_PAYMENT') ...[
          FilledButton.icon(
            icon: const Icon(Icons.payment),
            label: Text(translate.re_hold_detail_pay_activate(formatIndianPrice(h.total))),
            onPressed: _busy ? null : _onPay,
          ),
          const SizedBox(height: 8),
        ],
        if (h.canCancel)
          OutlinedButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: Text(translate.re_hold_detail_cancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: _busy ? null : _onCancel,
          ),
        if (h.canConvertToSale) ...[
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.handshake),
            label: Text(translate.re_hold_detail_convert),
            onPressed: _busy ? null : _onConvertToSale,
          ),
        ],
        if (h.isTerminal)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'This hold is closed (${h.statusLabel}). No further action is possible.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _row(ThemeData theme, String label, Object value,
      {bool bold = false, bool muted = false}) {
    final style = (bold ? theme.textTheme.bodyLarge : theme.textTheme.bodyMedium)
        ?.copyWith(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: muted ? theme.hintColor : null,
    );
    final valueStr = value is double ? '₹${formatIndianPrice(value)}' : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(valueStr, style: style),
        ],
      ),
    );
  }

  Widget _timelineRow(ThemeData theme, String label, DateTime at, {required bool done}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.schedule,
            size: 16,
            color: done ? theme.colorScheme.primary : theme.hintColor,
          ),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(_formatDate(at), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/${d.year}';
  }

  String _daysLabel(int? days) {
    if (days == null) return '—';
    return '$days days';
  }

  String _yesNo(bool v) => v ? 'Yes' : 'No';
}
