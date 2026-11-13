import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Subscribe to a standing delivery.
///
/// The customer picks variant, quantity, schedule and start date; the outlet
/// comes from context (where the customer was browsing), never typed. Pricing
/// is the ceiling (§9.5, BR-16): a variable-weight line charges estimate plus
/// ceiling once, never reconciled per occurrence — and the screen states that
/// before the customer commits, because a subscriber discovering it on the
/// invoice is a support ticket.
///
/// Ineligible variants (eggs, whole fish) are refused server-side with a reason;
/// the screen surfaces that reason rather than a bare failure.
class JhatkaSubscriptionCreateView extends StatefulWidget {
  const JhatkaSubscriptionCreateView({
    super.key,
    required this.outletId,
    this.presetVariantId,
    this.presetVariantName,
  });

  final String outletId;
  final String? presetVariantId;
  final String? presetVariantName;

  @override
  State<JhatkaSubscriptionCreateView> createState() =>
      _JhatkaSubscriptionCreateViewState();
}

class _JhatkaSubscriptionCreateViewState
    extends State<JhatkaSubscriptionCreateView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  final TextEditingController _quantity = TextEditingController(text: '1');
  final TextEditingController _customDays = TextEditingController();

  bool _busy = false;
  String _scheduleType = 'weekly';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String? _variantId;
  String _variantLabel = '';

  static const List<String> _schedules = <String>[
    'daily',
    'alternate_days',
    'weekly',
    'custom_days',
  ];

  @override
  void initState() {
    super.initState();
    _variantId = widget.presetVariantId;
    _variantLabel = widget.presetVariantName ?? '';
  }

  @override
  void dispose() {
    _quantity.dispose();
    _customDays.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) setState(() => _startDate = date);
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Localized label for a schedule key. The server stores the snake_case
  /// key; the customer picks from words in their language.
  String _scheduleLabel(AppLocalizations l10n, String schedule) {
    switch (schedule) {
      case 'daily':
        return l10n.jhatka_schedule_daily;
      case 'alternate_days':
        return l10n.jhatka_schedule_alternate_days;
      case 'weekly':
        return l10n.jhatka_schedule_weekly;
      case 'custom_days':
        return l10n.jhatka_schedule_custom_days;
    }
    return schedule;
  }

  Future<void> _submit() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (_variantId == null || _variantId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_pick_variant_first)));
      return;
    }
    final double? qty = double.tryParse(_quantity.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_quantity_positive)));
      return;
    }
    List<int>? customDays;
    if (_scheduleType == 'custom_days') {
      customDays = _customDays.text
          .split(',')
          .map((String s) => int.tryParse(s.trim()))
          .whereType<int>()
          .where((int d) => d >= 0 && d <= 6)
          .toList();
      if (customDays.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.jhatka_custom_days_hint)));
        return;
      }
    }

    setState(() => _busy = true);
    final response = await _service.createSubscription(<String, dynamic>{
      'outlet': widget.outletId,
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'variant': _variantId,
          'quantity': <String, dynamic>{'value': qty, 'unit': 'KG'},
        },
      ],
      'scheduleType': _scheduleType,
      if (customDays case final List<int> days) 'customDays': days,
      'startDate': _iso(_startDate),
      'paymentMode': 'cod',
    });
    if (!mounted) return;
    setState(() => _busy = false);
    if (!response.success) {
      String message = l10n.jhatka_could_not_create_subscription;
      try {
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        final String server = (body['message'] ?? '').toString();
        if (server.isNotEmpty) message = server;
      } catch (_) {
        message = l10n.jhatka_could_not_create_subscription;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.jhatka_new_subscription)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(l10n.jhatka_ceiling_note, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(
                _variantLabel.isEmpty
                    ? l10n.jhatka_no_variant_picked
                    : _variantLabel,
              ),
              subtitle: Text(l10n.jhatka_chosen_where_browsing),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.jhatka_quantity_kg,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _scheduleType,
            decoration: InputDecoration(
              labelText: l10n.jhatka_repeats,
              border: const OutlineInputBorder(),
            ),
            items: _schedules
                .map(
                  (String s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(_scheduleLabel(l10n, s)),
                  ),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _scheduleType = v);
            },
          ),
          if (_scheduleType == 'custom_days') ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: _customDays,
              decoration: InputDecoration(
                labelText: l10n.jhatka_days_example,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            title: Text(l10n.jhatka_starts),
            subtitle: Text(_iso(_startDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.jhatka_subscribe,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
