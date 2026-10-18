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
import 'package:user/app/presentation/pages/real_estate/visit_detail.dart';

/// Visits list (Flow 11) — the customer's site-visit requests, split
/// into upcoming and past.
///
/// One fetch serves both tabs: a visit request row exists from creation
/// (PENDING_ASSIGNMENT) through every visit state, so the split is done
/// client-side off [VisitRequestModel.isPast] instead of two queries.
class VisitsListScreen extends StatefulWidget {
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  List<VisitRequestModel> _visits = const [];

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
      final list = await _repo.myVisits();
      if (!mounted) return;
      setState(() {
        _visits = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load visits';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(VisitRequestModel v) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VisitDetailScreen(visitId: v.id)),
    );
    // The detail screen may have observed a state change; refresh.
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(translate.re_visit_list_title),
          bottom: TabBar(
            tabs: [Tab(text: translate.re_visit_upcoming), Tab(text: translate.re_visit_past)],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                    ),
                  )
                : TabBarView(
                    children: [
                      _VisitList(
                        visits: _visits.where((v) => !v.isPast).toList(),
                        onTap: _openDetail,
                        emptyText: translate.re_visit_empty,
                        onRefresh: _load,
                      ),
                      _VisitList(
                        visits: _visits.where((v) => v.isPast).toList(),
                        onTap: _openDetail,
                        emptyText: translate.re_visit_empty,
                        onRefresh: _load,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _VisitList extends StatelessWidget {
  final List<VisitRequestModel> visits;
  final ValueChanged<VisitRequestModel> onTap;
  final String emptyText;
  final Future<void> Function() onRefresh;

  const _VisitList({
    required this.visits,
    required this.onTap,
    required this.emptyText,
    required this.onRefresh,
  });

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

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (visits.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Icon(Icons.event_available_outlined,
                size: 48, color: theme.hintColor),
            const SizedBox(height: 12),
            Center(child: Text(emptyText, style: theme.textTheme.bodyMedium)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: visits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final v = visits[i];
          final status = v.visitStatus ?? v.status;
          final color = _statusColor(status);
          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: () => onTap(v),
              title: Text(
                v.propertyTitle ?? 'Property visit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (v.propertyLocality != null || v.propertyCity != null)
                      Text(
                        [v.propertyLocality, v.propertyCity]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(', '),
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (v.effectiveDate != null)
                          _formatDate(v.effectiveDate!),
                        if (v.slotLabel.isNotEmpty) v.slotLabel,
                        if (v.executiveName != null) 'with ${v.executiveName}',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color),
                ),
                child: Text(
                  v.statusLabel,
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
    );
  }
}
