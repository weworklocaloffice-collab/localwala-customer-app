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

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/hold_detail.dart';

/// Hold terms screen (plan §6.4, Flow 13).
///
/// The customer sees the price (principal + service fee), the duration,
/// the refund matrix, and must acknowledge before the create-and-pay flow
/// runs. A `createHold` returns `PENDING_PAYMENT`; the actual charge is
/// taken by the shared `property_hold` payment branch — this screen only
/// reserves the property under the BR-12 partial unique index.
///
/// On success, the screen pushes [HoldDetailScreen] for the new hold so
/// the customer can pay (or come back to it from [MyHoldsScreen]).
class HoldTermsScreen extends StatefulWidget {
  final String propertyId;
  const HoldTermsScreen({super.key, required this.propertyId});

  @override
  State<HoldTermsScreen> createState() => _HoldTermsScreenState();
}

class _HoldTermsScreenState extends State<HoldTermsScreen> {
  final _repo = RealEstateRepository();

  bool _loadingProperty = true;
  PropertyModel? _property;
  String? _loadError;

  bool _acknowledge = false;
  bool _submitting = false;

  // Defaults mirror HoldPolicySnapshot defaults. The backend will replace
  // these with the active policy's values on the create call (BR-15).
  static const _principalRupees = 50000.0;
  static const _serviceFeePercent = 5.0;
  static const _durationDays = 15;

  double get _serviceFee => _principalRupees * _serviceFeePercent / 100.0;
  double get _total => _principalRupees + _serviceFee;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _repo.propertyById(widget.propertyId);
      if (!mounted) return;
      setState(() {
        _property = p;
        _loadingProperty = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load property';
        _loadingProperty = false;
      });
    }
  }

  Future<void> _onConfirm() async {
    if (!_acknowledge || _submitting) return;
    setState(() => _submitting = true);
    try {
      final hold = await _repo.createHold(propertyId: widget.propertyId);
      if (!mounted) return;
      // Replace this screen with the detail screen so back goes to property.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HoldDetailScreen(holdId: hold.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = e.toString().toLowerCase().contains('one_active_hold')
          ? 'You already have an active hold on this property.'
          : 'Could not create hold. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_hold_terms_title)),
      body: _loadingProperty
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                  ),
                )
              : _buildBody(theme, translate),
      bottomNavigationBar: _loadingProperty || _loadError != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: (_acknowledge && !_submitting) ? _onConfirm : null,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(translate.re_hold_terms_pay_cta(formatIndianPrice(_total))),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(ThemeData theme, AppLocalizations translate) {
    final p = _property!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Property summary
        Text(p.displayTitle, style: theme.textTheme.titleLarge),
        if (p.addressLine != null || p.locality != null || p.city != null) ...[
          const SizedBox(height: 4),
          Text(
            [p.addressLine, p.locality, p.city]
                .where((e) => e != null && e.toString().isNotEmpty)
                .join(', '),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 16),
        if (p.availability == 'ON_HOLD')
          _warningCard(
            theme,
            'This property is already on hold by another customer. '
            'You can still place a hold request and it will queue if it '
            'expires, but right now you cannot hold this unit.',
          ),

        // Price breakdown
        const SizedBox(height: 16),
        Text('Price breakdown', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _priceRow(theme, 'Hold principal', _principalRupees, bold: false),
        const SizedBox(height: 4),
        _priceRow(
          theme,
          'Service fee (${_serviceFeePercent.toStringAsFixed(1)}%)',
          _serviceFee,
          bold: false,
          muted: true,
        ),
        const Divider(),
        _priceRow(theme, 'Total today', _total, bold: true),

        // Duration
        const SizedBox(height: 24),
        Text('How the hold works', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _bullet(
          theme,
          'For $_durationDays days this property is reserved for you. '
          'Other customers cannot hold it during this window.',
        ),
        _bullet(
          theme,
          'You can cancel any time before the hold converts to a sale. '
          'The principal is refunded 100% to your original payment method.',
        ),
        _bullet(
          theme,
          'The service fee covers verification, taking the property '
          'off-market, and processing your reservation. It is not '
          'refunded on cancellation — the work has been done.',
        ),
        _bullet(
          theme,
          'If the hold converts to a sale, the principal is applied '
          'against the purchase consideration. It is never LocalWala '
          'revenue.',
        ),
        _bullet(
          theme,
          'If the listing is withdrawn by the vendor while you hold it, '
          'both the principal and the service fee are refunded.',
        ),
        _bullet(
          theme,
          'Reminders fire 72 hours, 24 hours and 6 hours before the hold '
          'expires. If you take no action, the hold lapses and the '
          'principal is refunded 100%.',
        ),

        // Refund matrix
        const SizedBox(height: 24),
        Text('Refund matrix', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _refundTable(theme),

        // Acknowledgement
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _acknowledge,
          onChanged: (v) => setState(() => _acknowledge = v == true),
          title: Text(
            translate.re_hold_terms_acknowledge,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _priceRow(ThemeData theme, String label, double rupees,
      {bool bold = false, bool muted = false}) {
    final textStyle = (bold
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
      color: muted ? theme.hintColor : null,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text('₹${formatIndianPrice(rupees)}', style: textStyle),
      ],
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _refundTable(ThemeData theme) {
    final rows = <_RefundRow>[
      _RefundRow('You cancel', 'Principal 100% back', 'Fee retained'),
      _RefundRow('Hold expires', 'Principal 100% back', 'Fee retained'),
      _RefundRow('Converted to sale', 'Applied to sale', 'Already earned'),
      _RefundRow('Listing withdrawn', 'Principal 100% back', 'Fee refunded'),
    ];
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.dividerColor),
        verticalInside: BorderSide(color: theme.dividerColor),
        top: BorderSide(color: theme.dividerColor),
        bottom: BorderSide(color: theme.dividerColor),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest),
          children: const [
            _Cell('Event', header: true),
            _Cell('Principal', header: true),
            _Cell('Service fee', header: true),
          ],
        ),
        ...rows.map(
          (r) => TableRow(
            children: [
              _Cell(r.event),
              _Cell(r.principal),
              _Cell(r.fee),
            ],
          ),
        ),
      ],
    );
  }

  Widget _warningCard(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundRow {
  final String event;
  final String principal;
  final String fee;
  const _RefundRow(this.event, this.principal, this.fee);
}

class _Cell extends StatelessWidget {
  final String text;
  final bool header;
  const _Cell(this.text, {this.header = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: (header ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
            ?.copyWith(
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
