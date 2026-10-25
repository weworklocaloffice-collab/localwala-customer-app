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
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';

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

  static const _slots = <String>['MORNING', 'AFTERNOON', 'EVENING'];

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
      final translate = AppLocalizations.of(context)!;
      final msg = raw.contains('409') || raw.contains('conflict')
          ? translate.re_visit_open_exists
          : raw.contains('past date')
          ? translate.re_visit_pick_later
          : raw.contains('no longer available')
          ? translate.re_visit_property_unavailable
          : translate.re_visit_request_failed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
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
          Text(translate.re_preferred_day, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _date == null
                  ? translate.re_choose_date
                  : MaterialLocalizations.of(context).formatFullDate(_date!),
            ),
            onPressed: _submitting ? null : _pickDate,
          ),

          // Slot
          const SizedBox(height: 24),
          Text(translate.re_preferred_time, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._slots.map(
            (slot) => RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: slot,
              groupValue: _slot,
              onChanged: _submitting
                  ? null
                  : (v) => setState(() => _slot = v ?? _slot),
              title: Text(translate.visitSlotDetail(slot)),
            ),
          ),

          // Note
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLength: 500,
            maxLines: 3,
            enabled: !_submitting,
            decoration: InputDecoration(
              labelText: translate.re_visit_note_label,
              hintText: translate.re_visit_note_hint,
              border: const OutlineInputBorder(),
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
                : Text(translate.re_visit_submit),
          ),
        ),
      ),
    );
  }
}
