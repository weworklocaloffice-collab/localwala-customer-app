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
import 'package:user/app/presentation/pages/real_estate/loan_application_detail.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';

/// Loan requests list (Flow 12).
///
/// The backend nests each request's applications + offers, so one fetch
/// serves the list (status chip, bank/offer counts) and the detail and
/// compare screens can reuse the rows without a second round-trip.
class LoanApplicationsScreen extends StatefulWidget {
  const LoanApplicationsScreen({super.key});

  @override
  State<LoanApplicationsScreen> createState() => _LoanApplicationsScreenState();
}

class _LoanApplicationsScreenState extends State<LoanApplicationsScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  List<LoanRequestModel> _loans = const [];

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
      final list = await _repo.myLoans();
      if (!mounted) return;
      setState(() {
        _loans = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load loans';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(LoanRequestModel loan) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LoanApplicationDetailScreen(requestId: loan.id),
      ),
    );
    if (result == 'requested') _load();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_loan_list_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  translate.re_error_generic,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _loans.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Icon(
                          Icons.account_balance_outlined,
                          size: 48,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            translate.re_loan_empty,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _loans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final l = _loans[i];
                        final color = _statusColor(l.status);
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => _openDetail(l),
                            title: Text(
                              l.propertyTitle ??
                                  translate.re_loan_request_title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (l.propertyLocality != null ||
                                      l.propertyCity != null)
                                    Text(
                                      [l.propertyLocality, l.propertyCity]
                                          .where(
                                            (e) => e != null && e.isNotEmpty,
                                          )
                                          .join(', '),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [
                                      if (l.requestedAmount != null)
                                        '₹${formatIndianPrice(l.requestedAmount!)}',
                                      translate.re_bank_count(
                                        l.applications.length,
                                      ),
                                      if (l.hasOffers)
                                        translate.re_offer_count(l.offerCount),
                                    ].join(' · '),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color),
                              ),
                              child: Text(
                                translate.loanStatus(l.status),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
