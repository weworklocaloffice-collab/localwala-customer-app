import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

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

  Future<void> _submit() async {
    if (_variantId == null || _variantId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a variant first.')),
      );
      return;
    }
    final double? qty = double.tryParse(_quantity.text.trim());
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be a positive number.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom days: comma-separated 0 (Sun) – 6 (Sat).'),
          ),
        );
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
      String message = 'Could not create the subscription.';
      try {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        final String server = (body['message'] ?? '').toString();
        if (server.isNotEmpty) message = server;
      } catch (_) {
        message = 'Could not create the subscription.';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New subscription')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Charged at the ceiling, once per delivery — never reconciled '
            'afterwards. The weight may come in under; the extra is absorbed, '
            'never billed.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(
                _variantLabel.isEmpty ? 'No variant picked' : _variantLabel,
              ),
              subtitle: const Text('Chosen where you were browsing.'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantity,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantity (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _scheduleType,
            decoration: const InputDecoration(
              labelText: 'Repeats',
              border: OutlineInputBorder(),
            ),
            items: _schedules
                .map((String s) =>
                    DropdownMenuItem<String>(value: s, child: Text(s)))
                .toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _scheduleType = v);
            },
          ),
          if (_scheduleType == 'custom_days') ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: _customDays,
              decoration: const InputDecoration(
                labelText: 'Days, e.g. 1,3,5 (0 = Sunday)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Starts'),
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
                  : const Text('Subscribe', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
