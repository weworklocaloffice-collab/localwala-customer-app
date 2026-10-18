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
import 'package:user/app/presentation/pages/real_estate/loan_offers_compare.dart';

/// Loan request detail (Flow 12) — one request with its per-bank
/// applications and, once banks answer, a route to the compare screen.
///
/// Read-only: sanction / reject / disburse are bank-only (BR-10) and
/// the customer surface must not even offer those fields.
class LoanApplicationDetailScreen extends StatefulWidget {
  final String requestId;

  const LoanApplicationDetailScreen({super.key, required this.requestId});

  @override
  State<LoanApplicationDetailScreen> createState() =>
      _LoanApplicationDetailScreenState();
}

class _LoanApplicationDetailScreenState
    extends State<LoanApplicationDetailScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  LoanRequestModel? _loan;

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
      final loan = await _repo.loanById(widget.requestId);
      if (!mounted) return;
      setState(() {
        _loan = loan;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this loan request';
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'LOAN_LEAD_CREATED':
        return Colors.orange;
      case 'OFFERS_PENDING':
      case 'OFFERS_RECEIVED':
        return Colors.blue;
      case 'BANK_SELECTED':
      case 'APPLICATION_STARTED':
      case 'UNDER_BANK_REVIEW':
        return Colors.teal;
      case 'SANCTIONED':
      case 'DISBURSED':
        return Colors.green;
      case 'REJECTED':
      case 'WITHDRAWN':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_loan_request_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _loan == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(translate.re_error_generic,
                        textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _loan!.propertyTitle ?? translate.re_loan_request_title,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _chip(
                            _loan!.statusLabel,
                            _statusColor(_loan!.status),
                          ),
                        ],
                      ),
                      if (_loan!.propertyLocality != null ||
                          _loan!.propertyCity != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          [
                            _loan!.propertyLocality,
                            _loan!.propertyCity,
                          ].where((e) => e != null && e.isNotEmpty).join(', '),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],

                      // Requested terms
                      const SizedBox(height: 16),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _kv(theme, 'Requested amount',
                                  _loan!.requestedAmount != null
                                      ? '₹${formatIndianPrice(_loan!.requestedAmount!)}'
                                      : '—'),
                              const Divider(height: 20),
                              _kv(theme, 'Tenure',
                                  _loan!.tenureMonths != null
                                      ? '${_loan!.tenureMonths} months'
                                      : 'Any'),
                              const Divider(height: 20),
                              _kv(theme, 'Employment',
                                  _loan!.employmentLabel),
                              const Divider(height: 20),
                              _kv(
                                theme,
                                'Monthly income',
                                _loan!.monthlyIncome != null
                                    ? '₹${formatIndianPrice(_loan!.monthlyIncome!)}'
                                    : '—',
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Applications per bank
                      const SizedBox(height: 24),
                      Text('Banks', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (_loan!.applications.isEmpty)
                        Text(
                          'Waiting for the request to reach banks…',
                          style: theme.textTheme.bodySmall,
                        )
                      else
                        ..._loan!.applications.map(
                          (app) => Card(
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
                                          app.bankName ?? 'Bank',
                                          style:
                                              theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      _chip(app.statusLabel,
                                          _statusColor(app.status)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (app.sanctionedAmount != null)
                                    Text(
                                      'Sanctioned: ₹${formatIndianPrice(app.sanctionedAmount!)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (app.disbursedAmount != null)
                                    Text(
                                      'Disbursed: ₹${formatIndianPrice(app.disbursedAmount!)}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (app.rejectionReason != null &&
                                      app.rejectionReason!.isNotEmpty)
                                    Text(
                                      'Reason: ${app.rejectionReason}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  if (app.offers.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${app.offers.length} offer(s)',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                                  color: theme
                                                      .colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
      bottomNavigationBar: _loan != null && _loan!.hasOffers
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.compare_arrows),
                  label: Text('${translate.re_loan_compare_title} (${_loan!.offerCount})'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            LoanOffersCompareScreen(request: _loan!),
                      ),
                    );
                    if (result == 'requested' && mounted) _load();
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _kv(ThemeData theme, String k, String v) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(k, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Text(v, style: theme.textTheme.bodyMedium),
          ),
        ],
      );
}
