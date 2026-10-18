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

import 'package:user/app/core/repositories/real_estate_repository.dart';

/// Request-visit form (Flow 11).
///
/// The customer picks a day (today or later — the backend rejects past
/// dates), a slot from the closed enum, and an optional note. The body
/// carries the lead id only: the property is resolved server-side from
/// the lead, and there is deliberately no executive/status field — the
/// assignment engine decides.
///
/// Pops with `'requested'` on success so the lead detail screen can
/// refresh its status and activity trail.
class VisitRequestFormScreen extends StatefulWidget {
  final String leadId;
  final String? propertyTitle;

  const VisitRequestFormScreen({
    super.key,
    required this.leadId,
    this.propertyTitle,
  });

  @override
  State<VisitRequestFormScreen> createState() => _VisitRequestFormScreenState();
}

class _VisitRequestFormScreenState extends State<VisitRequestFormScreen> {
  final _repo = RealEstateRepository();
  final _noteController = TextEditingController();

  DateTime? _date;
  String _slot = 'MORNING';
  bool _submitting = false;

  static const _slots = <MapEntry<String, String>>[
    MapEntry('MORNING', 'Morning · 9am – 12pm'),
    MapEntry('AFTERNOON', 'Afternoon · 12pm – 4pm'),
    MapEntry('EVENING', 'Evening · 4pm – 7pm'),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (_date == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _repo.requestVisit(
        leadId: widget.leadId,
        preferredDate: _date!,
        preferredTimeSlot: _slot,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop('requested');
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final raw = e.toString().toLowerCase();
      final msg = raw.contains('409') || raw.contains('conflict')
          ? 'You already have an open visit request for this enquiry.'
          : raw.contains('past date')
              ? 'Pick today or a later date.'
              : raw.contains('no longer available')
                  ? 'This property is no longer available to visit.'
                  : 'Could not request the visit. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _formatDate(DateTime d) {
    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_visit_request_title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.propertyTitle != null) ...[
            Text(widget.propertyTitle!, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
          ],

          // Date
          Text('Preferred day', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(_date == null ? 'Choose a date' : _formatDate(_date!)),
            onPressed: _submitting ? null : _pickDate,
          ),

          // Slot
          const SizedBox(height: 24),
          Text('Preferred time', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._slots.map(
            (s) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: s.key,
              groupValue: _slot,
              onChanged: _submitting
                  ? null
                  : (v) => setState(() => _slot = v ?? _slot),
              title: Text(s.value),
            ),
          ),

          // Note
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLength: 500,
            maxLines: 3,
            enabled: !_submitting,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'Anything the executive should know…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: _date != null && !_submitting ? _submit : null,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(translate.re_loan_submit),
          ),
        ),
      ),
    );
  }
}
