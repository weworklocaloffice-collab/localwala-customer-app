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
import 'package:flutter/services.dart';

import 'package:user/app/core/repositories/real_estate_repository.dart';

/// Request-loan form (Flow 12).
///
/// The checklist fields: amount, employment, income (plus an optional
/// tenure). The body carries property + optional lead only — there is
/// deliberately no customer, status or bank field: the tenant is the
/// token, the backend fans the request out to every active bank, and a
/// customer cannot pick which banks see the lead or self-sanction
/// (BR-10).
///
/// Pops with `'requested'` on success so the calling screen can refresh.
class LoanRequestFormScreen extends StatefulWidget {
  final String propertyId;
  final String? propertyTitle;
  final String? leadId;

  const LoanRequestFormScreen({
    super.key,
    required this.propertyId,
    this.propertyTitle,
    this.leadId,
  });

  @override
  State<LoanRequestFormScreen> createState() => _LoanRequestFormScreenState();
}

class _LoanRequestFormScreenState extends State<LoanRequestFormScreen> {
  final _repo = RealEstateRepository();
  final _amountController = TextEditingController();
  final _incomeController = TextEditingController();

  String _employment = 'SALARIED';
  int? _tenureMonths;
  bool _submitting = false;

  static const _tenures = <int>[60, 120, 180, 240, 300, 360];

  static const _employments = <MapEntry<String, String>>[
    MapEntry('SALARIED', 'Salaried'),
    MapEntry('SELF_EMPLOYED', 'Self employed'),
    MapEntry('BUSINESS', 'Business'),
    MapEntry('OTHER', 'Other'),
  ];

  int? get _amount {
    final v = int.tryParse(_amountController.text.trim());
    if (v == null || v < 1000 || v > 1000000000) return null;
    return v;
  }

  int? get _income {
    final v = int.tryParse(_incomeController.text.trim());
    if (v == null || v < 0 || v > 100000000) return null;
    return v;
  }

  bool get _canSubmit => _amount != null && _income != null && !_submitting;

  @override
  void dispose() {
    _amountController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      await _repo.requestLoan(
        propertyId: widget.propertyId,
        leadId: widget.leadId,
        requestedAmount: _amount!,
        tenureMonths: _tenureMonths,
        employment: _employment,
        monthlyIncome: _income!,
      );
      if (!mounted) return;
      Navigator.of(context).pop('requested');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final raw = e.toString().toLowerCase();
      final msg = raw.contains('409') || raw.contains('conflict')
          ? 'You already have an open loan request for this property.'
          : raw.contains('403') || raw.contains('disabled')
              ? 'Requesting a loan is currently disabled.'
                : raw.contains('404')
                  ? 'This property is no longer available.'
                  : AppLocalizations.of(context)!.re_error_generic;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_loan_request_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.propertyTitle != null) ...[
            Text(widget.propertyTitle!, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
          ],

          // Amount
          Text('How much do you need?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            enabled: !_submitting,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Loan amount (₹)',
              hintText: 'e.g. 5000000',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),

          // Tenure (optional)
          const SizedBox(height: 24),
          Text('Tenure (optional)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: _tenureMonths,
            decoration: const InputDecoration(
              labelText: 'Repayment period',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Any tenure'),
              ),
              ..._tenures.map(
                (t) => DropdownMenuItem<int?>(
                  value: t,
                  child: Text('$t months (${t ~/ 12} years)'),
                ),
              ),
            ],
            onChanged: _submitting
                ? null
                : (v) => setState(() => _tenureMonths = v),
          ),

          // Employment
          const SizedBox(height: 24),
          Text('Employment', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._employments.map(
            (e) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: e.key,
              groupValue: _employment,
              onChanged: _submitting
                  ? null
                  : (v) => setState(() => _employment = v ?? _employment),
              title: Text(e.value),
            ),
          ),

          // Income
          const SizedBox(height: 16),
          TextField(
            controller: _incomeController,
            enabled: !_submitting,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Monthly income (₹)',
              hintText: 'e.g. 75000',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _canSubmit ? _submit : null,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(translate.re_loan_submit),
          ),
        ),
      ),
    );
  }
}
