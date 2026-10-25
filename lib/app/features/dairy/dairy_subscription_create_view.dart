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
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Full subscription create flow per the plan's §11.2:
/// Product → Quantity → Schedule → Start Date → Slot → Address → Payment.
///
/// The server requires `startDate` and a `deliverySlot` window, and debits the
/// wallet per delivery at generation time — so all of it is chosen here, not
/// defaulted silently.
class DairySubscriptionCreateView extends StatefulWidget {
  const DairySubscriptionCreateView({super.key});

  @override
  State<DairySubscriptionCreateView> createState() => _DairySubscriptionCreateViewState();
}

class _DairySubscriptionCreateViewState extends State<DairySubscriptionCreateView> {
  final DairyCustomerService _service = DairyCustomerService();
  final AddressRepository _addressRepository = AddressRepository();

  static const List<String> _scheduleTypes = <String>['daily', 'alternate_days', 'weekly', 'custom_days'];
  static const List<String> _dayLabels = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> _paymentModes = <String>['wallet', 'cod', 'gateway'];

  List<dynamic> _skus = const <dynamic>[];
  List<dynamic> _addresses = const <dynamic>[];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  String? _skuId;
  int _qty = 1;
  String _scheduleType = 'daily';
  final Set<int> _customDays = <int>{};
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String _slotStart = '06:00';
  String _slotEnd = '08:00';
  String? _addressId;
  final TextEditingController _addressRaw = TextEditingController();
  final TextEditingController _receiverName = TextEditingController();
  final TextEditingController _receiverContact = TextEditingController();
  String _paymentMode = 'wallet';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _addressRaw.dispose();
    _receiverName.dispose();
    _receiverContact.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final skus = await _service.skuList();
    final String uid = await _addressRepository.userId();
    final addresses = await _addressRepository.getMyAddressList(uid);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (skus.success) {
        _skus = decodeList(jsonDecode(skus.body));
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_products;
      }
      if (addresses.success) {
        _addresses = decodeList(jsonDecode(addresses.body));
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay initial = _parseTime(isStart ? _slotStart : _slotEnd);
    final TimeOfDay? t = await showTimePicker(context: context, initialTime: initial);
    if (t == null) return;
    final String value =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (isStart) {
        _slotStart = value;
      } else {
        _slotEnd = value;
      }
    });
  }

  TimeOfDay _parseTime(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _submit() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_skuId == null) {
      setState(() => _error = t.dairy_choose_product);
      return;
    }
    if (_scheduleType == 'custom_days' && _customDays.isEmpty) {
      setState(() => _error = t.dairy_pick_day);
      return;
    }
    if (_slotEnd.compareTo(_slotStart) <= 0) {
      setState(() => _error = t.dairy_slot_order);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final Map<String, dynamic> body = <String, dynamic>{
      'sku': _skuId,
      'quantity': _qty,
      'scheduleType': _scheduleType,
      'startDate': _startDate.toIso8601String(),
      'deliverySlot': <String, dynamic>{'startTime': _slotStart, 'endTime': _slotEnd},
      'paymentMode': _paymentMode,
      if (_scheduleType == 'custom_days') 'customDays': _customDays.toList()..sort(),
      if (_addressId != null) 'address': _addressId,
      if (_addressId == null && _addressRaw.text.trim().isNotEmpty) 'addressRaw': _addressRaw.text.trim(),
      if (_receiverName.text.trim().isNotEmpty) 'receiverName': _receiverName.text.trim(),
      if (_receiverContact.text.trim().isNotEmpty)
        'receiverContact': int.tryParse(_receiverContact.text.trim()),
    };
    final r = await _service.createSubscription(body);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (r.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.dairy_subscription_created)),
      );
      Navigator.of(context).pop();
    } else {
      // Surface the server's own message (validation is Joi-authored there).
      dynamic msg;
      try {
        msg = asMap(jsonDecode(r.body))['message'];
      } catch (_) {
        msg = null;
      }
      setState(() => _error = msg?.toString() ?? t.dairy_could_not_create_subscription);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_new_subscription)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          DropdownButtonFormField<String>(
            initialValue: _skuId,
            decoration: InputDecoration(labelText: t.dairy_product, border: const OutlineInputBorder()),
            items: _skus.map((dynamic e) {
              final Map<String, dynamic> m = asMap(e);
              final String id = m['_id']?.toString() ?? m['id']?.toString() ?? '';
              final String name = m['name']?.toString() ?? t.dairy_product;
              final String pack = m['packSize']?.toString() ?? '';
              final String price = m['price'] != null ? ' — ${formatMoney(m['price'])}' : '';
              return DropdownMenuItem<String>(value: id, child: Text('$name${pack.isNotEmpty ? ' ($pack)' : ''}$price'));
            }).toList(),
            onChanged: (String? v) => setState(() => _skuId = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(t.dairy_quantity),
              const SizedBox(width: 8),
              IconButton(onPressed: () => setState(() { if (_qty > 1) _qty--; }), icon: const Icon(Icons.remove)),
              Text('$_qty', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => _qty++), icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _scheduleType,
            decoration: InputDecoration(labelText: t.dairy_schedule, border: const OutlineInputBorder()),
            items: _scheduleTypes
                .map((String s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(s == 'daily'
                          ? t.dairy_daily
                          : s == 'alternate_days'
                              ? t.dairy_alternate_days
                              : s == 'weekly'
                                  ? t.dairy_weekly
                                  : t.dairy_custom_days),
                    ))
                .toList(),
            onChanged: (String? v) => setState(() => _scheduleType = v ?? 'daily'),
          ),
          if (_scheduleType == 'custom_days') ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: List<Widget>.generate(7, (int i) {
                final bool selected = _customDays.contains(i);
                return ChoiceChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (bool on) => setState(() {
                    if (on) {
                      _customDays.add(i);
                    } else {
                      _customDays.remove(i);
                    }
                  }),
                );
              }),
            ),
          ],
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(t.dairy_starts(formatDate(_startDate.toIso8601String()))),
            subtitle: Text(t.dairy_tap_change_date),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.dairy_window_start),
                  subtitle: Text(_slotStart),
                  onTap: () => _pickTime(isStart: true),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.dairy_window_end),
                  subtitle: Text(_slotEnd),
                  onTap: () => _pickTime(isStart: false),
                ),
              ),
            ],
          ),
          if (_addresses.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: _addressId,
              decoration: InputDecoration(labelText: t.dairy_delivery_address, border: const OutlineInputBorder()),
              items: <DropdownMenuItem<String>>[
                ..._addresses.map((dynamic e) {
                  final Map<String, dynamic> m = asMap(e);
                  final String id = m['_id']?.toString() ?? m['id']?.toString() ?? '';
                  final List<String> parts = <String>[
                    if ((m['title']?.toString() ?? '').isNotEmpty) m['title'].toString(),
                    if ((m['flatHouse']?.toString() ?? '').isNotEmpty) m['flatHouse'].toString(),
                    if ((m['locality']?.toString() ?? '').isNotEmpty) m['locality'].toString(),
                  ];
                  return DropdownMenuItem<String>(value: id, child: Text(parts.join(', ')));
                }),
              ],
              onChanged: (String? v) => setState(() => _addressId = v),
            )
          else
            TextField(
              controller: _addressRaw,
              decoration: InputDecoration(
                labelText: t.dairy_delivery_address,
                hintText: t.dairy_address_hint,
                border: const OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _receiverName,
            decoration: InputDecoration(labelText: t.dairy_receiver_name, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _receiverContact,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: t.dairy_receiver_contact, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            decoration: InputDecoration(labelText: t.dairy_pay_per_delivery, border: const OutlineInputBorder()),
            items: _paymentModes
                .map((String s) => DropdownMenuItem<String>(
                      value: s,
                      child: Text(s == 'cod'
                          ? t.dairy_cash_on_delivery
                          : s == 'gateway'
                              ? t.dairy_payment_gateway
                              : t.dairy_wallet),
                    ))
                .toList(),
            onChanged: (String? v) => setState(() => _paymentMode = v ?? 'wallet'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(t.dairy_start_subscription),
          ),
        ],
      ),
    );
  }
}
