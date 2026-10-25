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
import 'package:user/app/presentation/pages/real_estate/visit_request_form.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/withdraw_dialog.dart';

/// Lead detail — status, property snapshot, activity history, and a
/// withdraw control that opens a reason dialog. The "withdrawn" return
/// is the same control used by the food module's order cancel pattern.
class LeadDetailScreen extends StatefulWidget {
  final String leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  LeadModel? _lead;
  List<LeadActivityEntry> _activity = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final lead = await _repo.leadById(widget.leadId);
      List<LeadActivityEntry> act = const [];
      try {
        act = await _repo.leadActivity(widget.leadId);
      } catch (_) {
        // activity is best-effort
      }
      if (!mounted) return;
      setState(() {
        _lead = lead;
        _activity = act;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load enquiry';
        _loading = false;
      });
    }
  }

  Future<void> _onWithdraw() async {
    final result = await showDialog(
      context: context,
      builder: (_) => WithdrawDialog(leadId: widget.leadId),
    );
    if (result == null || !mounted) return;
    if (result is Map && result['event'] == 'withdrawn') {
      await _load();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  /// Flow 11 — open the visit-request form. On `'requested'` the lead
  /// may have advanced to VISIT_REQUESTED, so the trail reloads.
  Future<void> _onRequestVisit(LeadModel lead) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitRequestFormScreen(
          leadId: widget.leadId,
          propertyTitle: lead.propertySnapshot,
        ),
      ),
    );
    if (result != 'requested' || !mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.re_visit_requested)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'NEW':
      case 'CONTACTED':
        return Colors.orange;
      case 'VISIT_REQUESTED':
      case 'VISIT_SCHEDULED':
        return Colors.blue;
      case 'VISIT_COMPLETED':
      case 'FOLLOW_UP':
        return Colors.indigo;
      case 'OFFERS_RECEIVED':
      case 'CUSTOMER_SELECTING':
        return Colors.teal;
      case 'HOLD':
        return Colors.purple;
      case 'SALE':
        return Colors.green;
      case 'LOST':
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
      appBar: AppBar(title: Text(translate.re_my_enquiries)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(translate.re_error_generic),
              ),
            )
          : _buildBody(theme, _lead!, translate),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LeadModel lead,
    AppLocalizations translate,
  ) {
    final canWithdraw = !{'SALE', 'LOST'}.contains(lead.status);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(lead.status).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _statusColor(lead.status)),
          ),
          child: Text(
            translate.leadStatus(lead.status),
            style: TextStyle(
              color: _statusColor(lead.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Header
        Text(
          lead.leadCode ?? translate.re_enquiry,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        if (lead.propertySnapshot != null)
          Text(lead.propertySnapshot!, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        if (lead.createdAt != null)
          Text(
            translate.re_submitted_on(
              MaterialLocalizations.of(
                context,
              ).formatShortDate(lead.createdAt!),
            ),
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 24),

        // Activity
        Text(translate.re_activity, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_activity.isEmpty)
          Text(translate.re_no_activity, style: theme.textTheme.bodySmall)
        else
          ..._activity.map(
            (a) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.circle, size: 8),
              title: Text(a.action),
              trailing: a.at != null
                  ? Text(
                      MaterialLocalizations.of(context).formatShortDate(a.at!),
                      style: theme.textTheme.bodySmall,
                    )
                  : null,
            ),
          ),

        const SizedBox(height: 24),

        // Flow 11 — request a site visit against this enquiry. The
        // backend refuses on LOST/SALE leads, duplicate open requests,
        // and sold/rented properties, so the same gate as withdraw is
        // enough here; server-side guards stay authoritative.
        if (canWithdraw) ...[
          FilledButton.tonalIcon(
            icon: const Icon(Icons.event_available_outlined),
            label: Text(translate.re_visit_request_title),
            onPressed: () => _onRequestVisit(lead),
          ),
          const SizedBox(height: 12),
        ],

        if (canWithdraw)
          OutlinedButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: Text(translate.re_withdraw),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: _onWithdraw,
          )
        else
          Text(
            lead.status == 'SALE'
                ? translate.re_enquiry_closed_sale
                : translate.re_enquiry_closed,
            style: theme.textTheme.bodySmall,
          ),
      ],
    );
  }
}
