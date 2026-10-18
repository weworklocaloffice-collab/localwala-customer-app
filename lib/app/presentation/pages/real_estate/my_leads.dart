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
import 'package:user/app/presentation/pages/real_estate/lead_detail.dart';
import 'package:user/app/presentation/pages/real_estate/loan_applications.dart';
import 'package:user/app/presentation/pages/real_estate/visits_list.dart';

/// My leads — the customer's own enquiries, newest first.
/// Mirrors the food module's "My Orders" list visual language.
class MyLeadsScreen extends StatefulWidget {
  /// When set, the list scrolls to and pulses this lead on load (e.g.
  /// from the enquiry form confirmation).
  final String? highlightLeadId;
  const MyLeadsScreen({super.key, this.highlightLeadId});

  @override
  State<MyLeadsScreen> createState() => _MyLeadsScreenState();
}

class _MyLeadsScreenState extends State<MyLeadsScreen> {
  final _repo = RealEstateRepository();
  final _scroll = ScrollController();
  final _highlightKey = GlobalKey();

  bool _loading = true;
  List<LeadModel> _leads = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.myLeads(limit: 50);
      if (!mounted) return;
      setState(() {
        _leads = list;
        _loading = false;
      });
      if (widget.highlightLeadId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your enquiries';
        _loading = false;
      });
    }
  }

  void _scrollToHighlight() {
    final idx = _leads.indexWhere((l) => l.id == widget.highlightLeadId);
    if (idx < 0) return;
    final extents = _scroll.position.maxScrollExtent;
    final approx = 88.0 * idx;
    if (approx < extents) {
      _scroll.animateTo(
        approx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'NEW':
      case 'CONTACTED':
      case 'VISIT_REQUESTED':
      case 'VISIT_SCHEDULED':
        return scheme.tertiary;
      case 'VISIT_COMPLETED':
      case 'FOLLOW_UP':
      case 'OFFERS_RECEIVED':
      case 'CUSTOMER_SELECTING':
      case 'APPLICATION_STARTED':
      case 'DOCUMENTS_PENDING':
      case 'UNDER_BANK_REVIEW':
        return scheme.primary;
      case 'HOLD':
        return scheme.secondary;
      case 'SALE':
        return Colors.green;
      case 'LOST':
        return scheme.outline;
      default:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_my_enquiries),
        actions: [
          IconButton(
            tooltip: translate.re_visit_list_title,
            icon: const Icon(Icons.event_available_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VisitsListScreen()),
            ),
          ),
          IconButton(
            tooltip: translate.re_loan_list_title,
            icon: const Icon(Icons.account_balance_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoanApplicationsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                    ),
                  )
                : _leads.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(translate.re_no_enquiries)),
                        ],
                      )
                    : ListView.separated(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: _leads.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final lead = _leads[i];
                          final isHighlighted =
                              lead.id == widget.highlightLeadId;
                          return Card(
                            key: isHighlighted ? _highlightKey : null,
                            color: isHighlighted
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : null,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(context, lead.status).withOpacity(0.2),
                                child: Icon(
                                  Icons.apartment,
                                  color: _statusColor(context, lead.status),
                                ),
                              ),
                              title: Text(lead.leadCode ?? 'Enquiry'),
                              subtitle: Text(
                                [
                                  lead.propertySnapshot ?? '—',
                                  lead.status,
                                  if (lead.createdAt != null)
                                    _formatDate(lead.createdAt!),
                                ].join(' • '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LeadDetailScreen(leadId: lead.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/${d.year}';
  }
}
