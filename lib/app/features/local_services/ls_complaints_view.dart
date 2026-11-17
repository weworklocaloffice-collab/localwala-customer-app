/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets, APIs, databases,
 * business logic, designs, and documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution, publication, resale,
 * reverse engineering, or use of this software without prior written
 * authorization is strictly prohibited.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer complaints with a "raise complaint" flow.
class LsComplaintsView extends StatefulWidget {
  const LsComplaintsView({super.key});

  @override
  State<LsComplaintsView> createState() => _LsComplaintsViewState();
}

class _LsComplaintsViewState extends State<LsComplaintsView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<LsComplaint> _items = const <LsComplaint>[];
  List<LsCustomerBooking> _bookings = const <LsCustomerBooking>[];

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
      final dynamic complaintsRes = await _service.myComplaints();
      final dynamic bookingsRes = await _service.bookings();
      final Map<String, dynamic> complaintsBody = Map<String, dynamic>.from(
        jsonDecode(complaintsRes.body) as Map,
      );
      final Map<String, dynamic> bookingsBody = Map<String, dynamic>.from(
        jsonDecode(bookingsRes.body) as Map,
      );
      if (!mounted) return;
      setState(() {
        _items = ((complaintsBody['results'] ?? []) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(LsComplaint.fromJson)
            .toList();
        _bookings = ((bookingsBody['results'] ?? []) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(LsCustomerBooking.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _raise() async {
    String? bookingId;
    final TextEditingController reason = TextEditingController();
    String? errorText;
    bool submitting = false;
    final bool? submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Raise a complaint',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tell us what went wrong. Our team reviews every complaint.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: lsSlate500),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: '',
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Booking (optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('General complaint (no booking)'),
                      ),
                      for (final LsCustomerBooking b in _bookings)
                        DropdownMenuItem<String>(
                          value: b.id,
                          child: Text(
                            '${b.displayTitle} \u00b7 ${b.code}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (String? value) =>
                        setSheetState(() => bookingId = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reason,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setSheetState(() => errorText = null),
                    decoration: InputDecoration(
                      labelText: 'What happened?',
                      hintText: 'Describe the issue in detail',
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                      errorText: errorText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (BuildContext context) {
                        return FilledButton(
                          onPressed: submitting
                              ? null
                              : () async {
                                  final String text = reason.text.trim();
                                  if (text.length < 5) {
                                    setSheetState(
                                      () => errorText =
                                          'Please describe the issue.',
                                    );
                                    return;
                                  }
                                  setSheetState(() => submitting = true);
                                  try {
                                    await _service.createComplaint(
                                      <String, dynamic>{
                                        if ((bookingId ?? '').isNotEmpty)
                                          'booking': bookingId,
                                        'reason': text,
                                      },
                                    );
                                    if (sheetContext.mounted) {
                                      Navigator.pop(sheetContext, true);
                                    }
                                  } catch (e) {
                                    setSheetState(() {
                                      submitting = false;
                                      errorText =
                                          AppLocalizations.of(
                                            context,
                                          )?.ls_failed_error('$e') ??
                                          'Failed: $e';
                                    });
                                  }
                                },
                          child: submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit complaint'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    reason.dispose();
    if (submitted == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted. Our team will review it.'),
        ),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ls_my_complaints ?? 'My complaints'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _raise,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Raise complaint'),
      ),
      body: _loading
          ? const LsSkeletonList(itemCount: 3)
          : _error != null
          ? LsErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: <Widget>[
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 56),
                      child: LsEmptyState(
                        icon: Icons.verified_user_outlined,
                        title: l10n?.ls_no_complaints ?? 'No complaints.',
                        message:
                            'If something goes wrong with a booking, raise it here.',
                        actionLabel: 'Raise complaint',
                        onAction: _raise,
                      ),
                    )
                  else
                    for (final LsComplaint complaint in _items)
                      _ComplaintCard(complaint: complaint),
                ],
              ),
            ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint});

  final LsComplaint complaint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String date = lsFormatDate(complaint.createdAt);
    return LsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  complaint.reason,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: lsSlate900,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LsStatusChip(status: complaint.status),
            ],
          ),
          if (complaint.bookingCode.isNotEmpty || date.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (complaint.bookingCode.isNotEmpty) ...<Widget>[
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 14,
                    color: lsSlate500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    complaint.bookingCode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: lsSlate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (complaint.bookingCode.isNotEmpty && date.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('\u00b7', style: TextStyle(color: lsSlate500)),
                  ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: lsSlate500,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
