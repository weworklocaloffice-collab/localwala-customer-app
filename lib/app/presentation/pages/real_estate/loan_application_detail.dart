/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/core/config/shared_pref_keys.dart';
import 'package:user/app/presentation/pages/real_estate/loan_offers_compare.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';
import 'package:user/app/services/shared_pref.dart';

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
  final _prefs = SharedPreferencesManager();

  bool _loading = true;
  String? _error;
  LoanRequestModel? _loan;
  List<DocumentRequestModel> _documentRequests = const [];

  /// The requests currently uploading, so their button can be disabled.
  Set<String> _uploading = const {};

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
      // The document requests are best-effort: a loan detail screen that
      // refuses to open because the paperwork list failed is worse than
      // one that opens without it.
      List<DocumentRequestModel> requests = const [];
      try {
        requests = await _repo.myDocumentRequests();
      } catch (_) {
        // best-effort
      }
      if (!mounted) return;
      setState(() {
        _loan = loan;
        _documentRequests = requests;
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

  /// Answer a document request: pick a file, upload it, send the path.
  Future<void> _answer(DocumentRequestModel request) async {
    final translate = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() {
      _uploading = {..._uploading, request.id};
    });
    try {
      final uid = await _prefs.getString(SharedPreferencesKey.authKeys.uid) ?? '';
      final path = await _repo.uploadDocumentFile(file, uid);
      await _repo.submitDocumentRequest(
        request.id,
        fileUrl: path,
        fileName: file.name,
        mimeType: 'image/jpeg',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate.re_doc_request_sent)),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate.re_doc_request_failed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = {..._uploading}..remove(request.id);
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'LOAN_LEAD_CREATED':
        return Colors.orange;
      case 'OFFERS_PENDING':
      case 'OFFERS_RECEIVED':
      case 'CUSTOMER_SELECTING':
        return Colors.blue;
      case 'BANK_SELECTED':
      case 'APPLICATION_STARTED':
      case 'DOCUMENTS_PENDING':
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
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
    ),
  );

  Color _docStatusColor(String status) {
    switch (status) {
      case 'REQUESTED':
        return Colors.orange;
      case 'SUBMITTED':
        return Colors.blue;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
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
      appBar: AppBar(title: Text(translate.re_loan_request_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _loan == null
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _loan!.propertyTitle ??
                              translate.re_loan_request_title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        translate.loanStatus(_loan!.status),
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
                          _kv(
                            theme,
                            translate.re_requested_amount,
                            _loan!.requestedAmount != null
                                ? '₹${formatIndianPrice(_loan!.requestedAmount!)}'
                                : '—',
                          ),
                          const Divider(height: 20),
                          _kv(
                            theme,
                            translate.re_tenure,
                            _loan!.tenureMonths != null
                                ? translate.re_months_count(
                                    _loan!.tenureMonths!,
                                  )
                                : translate.re_any_tenure,
                          ),
                          const Divider(height: 20),
                          _kv(
                            theme,
                            translate.re_employment,
                            translate.employmentLabel(_loan!.employment),
                          ),
                          const Divider(height: 20),
                          _kv(
                            theme,
                            translate.re_monthly_income,
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
                  Text(translate.re_banks, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_loan!.applications.isEmpty)
                    Text(
                      translate.re_waiting_for_banks,
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
                                      app.bankName ?? translate.re_bank,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  _chip(
                                    translate.loanStatus(app.status),
                                    _statusColor(app.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (app.sanctionedAmount != null)
                                Text(
                                  translate.re_sanctioned_amount(
                                    '₹${formatIndianPrice(app.sanctionedAmount!)}',
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              if (app.disbursedAmount != null)
                                Text(
                                  translate.re_disbursed_amount(
                                    '₹${formatIndianPrice(app.disbursedAmount!)}',
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              if (app.rejectionReason != null &&
                                  app.rejectionReason!.isNotEmpty)
                                Text(
                                  translate.re_reason_label(
                                    app.rejectionReason!,
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              if (app.offers.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    translate.re_offer_count(app.offers.length),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Document requests (Flow 12 underwriting). The bank
                  // asks, the customer answers from here.
                  if (_documentRequests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      translate.re_doc_requests_title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._documentRequests.map(
                      (request) => Card(
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
                                      request.title,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  _chip(
                                    translate.documentRequestStatus(
                                      request.status,
                                    ),
                                    _docStatusColor(request.status),
                                  ),
                                ],
                              ),
                              if (request.notes != null &&
                                  request.notes!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  request.notes!,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              if (request.dueDate != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  translate.re_doc_request_due(
                                    MaterialLocalizations.of(
                                      context,
                                    ).formatShortDate(request.dueDate!),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                              if (request.reviewNote != null &&
                                  request.reviewNote!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  translate.re_doc_request_rejected(
                                    request.reviewNote!,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                              if (request.needsAnswer) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.upload_file),
                                  label: Text(translate.re_doc_request_upload),
                                  onPressed: _uploading.contains(request.id)
                                      ? null
                                      : () => _answer(request),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

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
                  label: Text(
                    '${translate.re_loan_compare_title} (${_loan!.offerCount})',
                  ),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            LoanOffersCompareScreen(request: _loan!),
                      ),
                    );
                    if (result == 'accepted' && mounted) _load();
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
      SizedBox(width: 140, child: Text(k, style: theme.textTheme.bodySmall)),
      Expanded(child: Text(v, style: theme.textTheme.bodyMedium)),
    ],
  );
}
