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
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';

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
  final _repo = RealEstateRepository();
  _LoanOfferSort _sort = _LoanOfferSort.rate;
  bool _accepting = false;

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

  Future<void> _acceptOffer(BankOfferModel offer) async {
    final translate = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translate.re_loan_accept_title),
        content: Text(
          translate.re_loan_accept_body(offer.bankName ?? translate.re_bank),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(translate.cancel_title),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(translate.re_loan_select_offer),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _accepting = true);
    try {
      await _repo.acceptLoanOffer(
        requestId: widget.request.id,
        offerId: offer.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop('accepted');
    } catch (_) {
      if (!mounted) return;
      setState(() => _accepting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(translate.re_loan_accept_failed)));
    }
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
                translate.re_requested_value(
                  '₹${formatIndianPrice(widget.request.requestedAmount!)}',
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),

          // Sort control — the checklist's three axes.
          SegmentedButton<_LoanOfferSort>(
            segments: [
              ButtonSegment(
                value: _LoanOfferSort.rate,
                label: Text(translate.re_rate),
                icon: const Icon(Icons.percent_outlined),
              ),
              ButtonSegment(
                value: _LoanOfferSort.amount,
                label: Text(translate.re_amount),
                icon: const Icon(Icons.currency_rupee_outlined),
              ),
              ButtonSegment(
                value: _LoanOfferSort.tenure,
                label: Text(translate.re_tenure),
                icon: const Icon(Icons.schedule_outlined),
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
                  Icon(Icons.hourglass_empty, size: 48, color: theme.hintColor),
                  const SizedBox(height: 12),
                  Text(
                    translate.re_no_offers_yet,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            ...offers.map((o) => _offerCard(theme, translate, o)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _offerCard(
    ThemeData theme,
    AppLocalizations translate,
    BankOfferModel o,
  ) {
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
                    o.bankName ?? translate.re_bank,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (o.interestRate != null)
                  Text(
                    translate.re_interest_rate(o.interestRate.toString()),
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
                  _stat(
                    theme,
                    translate.re_amount,
                    '₹${formatIndianPrice(o.loanAmount!)}',
                  ),
                if (o.tenureMonths != null)
                  _stat(
                    theme,
                    translate.re_tenure,
                    translate.re_months_short(o.tenureMonths!),
                  ),
                if (o.processingFee != null && o.processingFee != 0)
                  _stat(
                    theme,
                    translate.re_fee,
                    '₹${formatIndianPrice(o.processingFee!)}',
                  ),
              ],
            ),
            if (o.otherTerms != null && o.otherTerms!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(o.otherTerms!, style: theme.textTheme.bodySmall),
            ],
            if (!o.isPending) ...[
              const SizedBox(height: 8),
              _offerStatus(translate, o),
            ],
            if (widget.request.isOfferSelectable(o)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _accepting ? null : () => _acceptOffer(o),
                  icon: _accepting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(translate.re_loan_select_offer),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _offerStatus(AppLocalizations translate, BankOfferModel offer) {
    final color = offer.isAccepted
        ? Colors.green
        : offer.isRejected
        ? Colors.grey
        : offer.isWithdrawn
        ? Colors.grey
        : Colors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        offer.isAccepted
            ? translate.re_loan_selected
            : translate.offerStatus(offer.status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
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
