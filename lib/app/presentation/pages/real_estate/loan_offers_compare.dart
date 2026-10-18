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

/// The three sort axes the checklist names: rate, amount, tenure.
enum _LoanOfferSort { rate, amount, tenure }

/// Loan offers compare (Flow 12) — every bank's offer side by side,
/// sortable by rate, amount or tenure (the three axes the checklist
/// names).
///
/// Input is the request's nested offers, already fetched by the detail
/// screen — no second round-trip, no pagination to get wrong.
class LoanOffersCompareScreen extends StatefulWidget {
  final LoanRequestModel request;

  const LoanOffersCompareScreen({super.key, required this.request});

  @override
  State<LoanOffersCompareScreen> createState() =>
      _LoanOffersCompareScreenState();
}

class _LoanOffersCompareScreenState extends State<LoanOffersCompareScreen> {
  _LoanOfferSort _sort = _LoanOfferSort.rate;

  List<BankOfferModel> get _offers {
    final list = [...widget.request.allOffers];
    switch (_sort) {
      case _LoanOfferSort.rate:
        list.sort((a, b) => a.rateSort.compareTo(b.rateSort));
        break;
      case _LoanOfferSort.amount:
        list.sort((a, b) => a.amountSort.compareTo(b.amountSort));
        break;
      case _LoanOfferSort.tenure:
        list.sort((a, b) => a.tenureSort.compareTo(b.tenureSort));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    final offers = _offers;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_loan_compare_title)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (widget.request.propertyTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.request.propertyTitle!,
                style: theme.textTheme.titleMedium,
              ),
            ),
          if (widget.request.requestedAmount != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Requested ₹${formatIndianPrice(widget.request.requestedAmount!)}',
                style: theme.textTheme.bodySmall,
              ),
            ),

          // Sort control — the checklist's three axes.
          SegmentedButton<_LoanOfferSort>(
            segments: const [
              ButtonSegment(
                value: _LoanOfferSort.rate,
                label: Text('Rate'),
                icon: Icon(Icons.percent_outlined),
              ),
              ButtonSegment(
                value: _LoanOfferSort.amount,
                label: Text('Amount'),
                icon: Icon(Icons.currency_rupee_outlined),
              ),
              ButtonSegment(
                value: _LoanOfferSort.tenure,
                label: Text('Tenure'),
                icon: Icon(Icons.schedule_outlined),
              ),
            ],
            selected: {_sort},
            onSelectionChanged: (s) => setState(() => _sort = s.first),
          ),
          const SizedBox(height: 4),
          Text(
            _sort == _LoanOfferSort.rate
                ? translate.re_loan_sort_rate
                : _sort == _LoanOfferSort.amount
                    ? translate.re_loan_sort_amount
                    : translate.re_loan_sort_tenure,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),

          if (offers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Icon(Icons.hourglass_empty,
                      size: 48, color: theme.hintColor),
                  const SizedBox(height: 12),
                  Text(
                    'No offers yet — banks are reviewing your request.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            ...offers.map((o) => _offerCard(theme, o)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _offerCard(ThemeData theme, BankOfferModel o) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    o.bankName ?? 'Bank',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (o.interestRate != null)
                  Text(
                    '${o.interestRate}% p.a.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                if (o.loanAmount != null)
                  _stat(theme, 'Amount', '₹${formatIndianPrice(o.loanAmount!)}'),
                if (o.tenureMonths != null)
                  _stat(theme, 'Tenure', '${o.tenureMonths} mo'),
                if (o.processingFee != null && o.processingFee != 0)
                  _stat(
                    theme,
                    'Fee',
                    '₹${formatIndianPrice(o.processingFee!)}',
                  ),
              ],
            ),
            if (o.otherTerms != null && o.otherTerms!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(o.otherTerms!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      );
}
