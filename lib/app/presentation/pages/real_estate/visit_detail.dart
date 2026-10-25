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

/// Visit detail (Flow 11) — scheduled time, executive, property, status.
///
/// Fetches by id so the screen shows the server's view (the executive
/// may have accepted or checked in since the list loaded); a
/// PENDING_ASSIGNMENT request simply shows "awaiting assignment" with
/// the customer's preferred day and slot.
class VisitDetailScreen extends StatefulWidget {
  final String visitId;
  const VisitDetailScreen({super.key, required this.visitId});

  @override
  State<VisitDetailScreen> createState() => _VisitDetailScreenState();
}

class _VisitDetailScreenState extends State<VisitDetailScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  VisitRequestModel? _visit;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final v = await _repo.visitById(widget.visitId);
      if (!mounted) return;
      setState(() {
        _visit = v;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load visit';
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING_ASSIGNMENT':
        return Colors.orange;
      case 'ASSIGNED':
      case 'ACCEPTED':
        return Colors.blue;
      case 'CHECK_IN':
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDateTime(BuildContext context, DateTime d) {
    final localizations = MaterialLocalizations.of(context);
    final time = TimeOfDay.fromDateTime(d).format(context);
    return '${localizations.formatMediumDate(d)} · $time';
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_visit_list_title)),
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
          : _buildBody(context, _visit!),
    );
  }

  Widget _buildBody(BuildContext context, VisitRequestModel v) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    final status = v.visitStatus ?? v.status;
    final color = _statusColor(status);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color),
            ),
            child: Text(
              translate.visitStatus(status),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Property
          Text(translate.re_property, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            v.propertyTitle ?? translate.re_property,
            style: theme.textTheme.titleLarge,
          ),
          if (v.propertyLocality != null || v.propertyCity != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                v.propertyLocality,
                v.propertyCity,
              ].where((e) => e != null && e.isNotEmpty).join(', '),
              style: theme.textTheme.bodyMedium,
            ),
          ],

          const SizedBox(height: 16),
          const Divider(),

          // Schedule
          Text(translate.schedule, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _row(
            theme,
            Icons.calendar_today_outlined,
            translate.re_day,
            v.effectiveDate != null
                ? _formatDateTime(context, v.effectiveDate!)
                : '—',
          ),
          if (v.preferredTimeSlot != null)
            _row(
              theme,
              Icons.wb_sunny_outlined,
              translate.re_preferred_slot,
              translate.visitSlot(v.preferredTimeSlot),
            ),
          if (v.isPendingAssignment)
            _row(
              theme,
              Icons.hourglass_top_outlined,
              translate.re_assignment,
              translate.re_waiting_assignment,
            ),

          const SizedBox(height: 16),
          const Divider(),

          // Executive
          Text(translate.re_executive, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (v.executiveName != null) ...[
            _row(theme, Icons.person_outline, translate.name, v.executiveName!),
            if (v.executiveMobile != null)
              _row(
                theme,
                Icons.phone_outlined,
                translate.mobile,
                v.executiveMobile!,
              ),
          ] else
            Text(
              v.isPendingAssignment ? translate.re_not_assigned_yet : '—',
              style: theme.textTheme.bodyMedium,
            ),

          if (v.visitCancellationReason != null ||
              v.cancellationReason != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            Text(translate.re_cancellation, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              v.visitCancellationReason ?? v.cancellationReason ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ],

          if (v.completedAt != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            _row(
              theme,
              Icons.check_circle_outline,
              translate.completed,
              _formatDateTime(context, v.completedAt!),
            ),
          ],

          const SizedBox(height: 24),
          Text(translate.re_visit_geo_note, style: theme.textTheme.bodySmall),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
