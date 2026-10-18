/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Turn the current cart into a recurring delivery.
///
/// Reached from the cart, because that is what a subscription IS: the same basket, on a
/// schedule. The items come from the server's own cart read, so the variant ids here are
/// the ones the store will actually bill.
///
/// NOTHING ABOUT PRICE IS SENT. The payload carries variant + quantity and nothing else.
/// The server re-derives every price from the outlet's own rows at billing time (BR-36),
/// so a price field here would be both ignored and dangerous — a customer could believe
/// they locked a price by sending one.
///
/// The four fields the server insists on — cadence, delivery day, slot, address — are
/// required rather than defaulted, because guessing any of them would create deliveries the
/// customer did not agree to. Start date defaults to today, which is the one value where a
/// sensible default is unambiguous.
class StoresSubscribeView extends StatefulWidget {
  const StoresSubscribeView({
    super.key,
    required this.storeId,
    required this.items,
    this.service,
    this.addresses,
    this.auth,
  });

  final String storeId;

  /// `{ variant, quantity }` pairs taken from the cart the server returned.
  final List<Map<String, dynamic>> items;

  /// Injectable for widget tests; omitted in the app.
  final StoresCustomerService? service;
  final AddressRepository? addresses;
  final AuthRepository? auth;

  @override
  State<StoresSubscribeView> createState() => _StoresSubscribeViewState();
}

class _StoresSubscribeViewState extends State<StoresSubscribeView> {
  late final StoresCustomerService _service;
  late final AddressRepository _addresses;
  late final AuthRepository _auth;

  List<Map<String, dynamic>> _addressList = <Map<String, dynamic>>[];
  String? _addressId;

  String _cadence = 'weekly';
  int _day = DateTime.now().weekday % 7; // DateTime.weekday is 1=Mon..7=Sun; server wants 0=Sun
  TimeOfDay _from = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 9, minute: 0);

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _addresses = widget.addresses ?? AddressRepository();
    _auth = widget.auth ?? AuthRepository();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = await _auth.userId();
      final response = await _addresses.getMyAddressList(uid);
      if (!mounted) return;
      if (!response.success) {
        setState(() {
          _loading = false;
          _error = 'Could not load your addresses.';
        });
        return;
      }
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final List<dynamic> list = (body['list'] as List?) ?? const <dynamic>[];
      final parsed = list.whereType<Map<String, dynamic>>().toList();
      if (!mounted) return;
      setState(() {
        _addressList = parsed;
        _addressId = parsed.isEmpty ? null : '${parsed.first['id']}';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your addresses.';
      });
    }
  }

  String _hhmm(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay initial = isStart ? _from : _to;
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _from = picked;
        // Keep the window coherent rather than letting it invert: a start after the end is
        // silently treated as an overnight slot, which is not what anyone means here.
        if (_to.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_addressId == null) {
      _snack('Choose a delivery address.');
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await _service.createSubscription(<String, dynamic>{
        'outlet': widget.storeId,
        'items': widget.items
            .map((Map<String, dynamic> i) => <String, dynamic>{
                  'variant': i['variant'],
                  'quantity': i['quantity'] ?? 1,
                })
            .toList(),
        'cadence': _cadence,
        'deliveryDayOfWeek': _day,
        'deliverySlot': <String, dynamic>{
          'startTime': _hhmm(_from),
          'endTime': _hhmm(_to),
        },
        'address': _addressId,
        'startDate': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      if (!response.success) {
        _snack('Could not create the subscription.');
        return;
      }
      _snack('Subscription created.');
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscribe')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                      '${widget.items.length} item(s) from your cart will be delivered '
                      'on this schedule.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _label(context, 'How often'),
                    RadioGroup<String>(
                      groupValue: _cadence,
                      onChanged: (String? v) {
                        if (v != null) setState(() => _cadence = v);
                      },
                      child: Column(
                        children: <Widget>[
                          RadioListTile<String>(
                            value: 'weekly',
                            title: const Text('Every week'),
                          ),
                          RadioListTile<String>(
                            value: 'biweekly',
                            title: const Text('Every two weeks'),
                          ),
                          RadioListTile<String>(
                            value: 'monthly',
                            title: const Text('Every month'),
                          ),
                        ],
                      ),
                    ),
                    _label(context, 'Delivery day'),
                    DropdownButtonFormField<int>(
                      initialValue: _day,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const <DropdownMenuItem<int>>[
                        DropdownMenuItem<int>(value: 0, child: Text('Sunday')),
                        DropdownMenuItem<int>(value: 1, child: Text('Monday')),
                        DropdownMenuItem<int>(value: 2, child: Text('Tuesday')),
                        DropdownMenuItem<int>(value: 3, child: Text('Wednesday')),
                        DropdownMenuItem<int>(value: 4, child: Text('Thursday')),
                        DropdownMenuItem<int>(value: 5, child: Text('Friday')),
                        DropdownMenuItem<int>(value: 6, child: Text('Saturday')),
                      ],
                      onChanged: (int? v) {
                        if (v != null) setState(() => _day = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    _label(context, 'Delivery window'),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickTime(true),
                            child: Text('From ${_hhmm(_from)}'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _pickTime(false),
                            child: Text('To ${_hhmm(_to)}'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label(context, 'Deliver to'),
                    if (_addressList.isEmpty)
                      const Text('No saved addresses yet. Add one in Address Book.')
                    else
                      DropdownButtonFormField<String>(
                        initialValue: _addressId,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: _addressList
                            .map((Map<String, dynamic> a) =>
                                DropdownMenuItem<String>(
                                  value: '${a['id']}',
                                  child: Text('${a['flatHouse'] ?? ''}'),
                                ))
                            .toList(),
                        onChanged: (String? v) => setState(() => _addressId = v),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: (_saving || _addressId == null) ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create subscription'),
                    ),
                  ],
                ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleSmall),
      );
}