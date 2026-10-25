/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright Ac 2026 WeWorkLocal.
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
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Raises a warranty request against an item in a delivered order.
///
/// The customer only chooses which purchased variant is affected and states the
/// fault. The server derives the outlet, chain, product snapshot and purchase
/// date from the order, so this screen never sends a name, price or merchant.
class StoresWarrantyView extends StatefulWidget {
  const StoresWarrantyView({
    super.key,
    required this.order,
    this.service,
  });

  final Map<String, dynamic> order;
  final StoresCustomerService? service;

  @override
  State<StoresWarrantyView> createState() => _StoresWarrantyViewState();
}

class _StoresWarrantyViewState extends State<StoresWarrantyView> {
  late final StoresCustomerService _service;
  final TextEditingController _issue = TextEditingController();

  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _existing = <Map<String, dynamic>>[];
  int _selectedItem = 0;
  String _warrantyType = 'manufacturer';
  String _issueCategory = 'manufacturing_defect';
  int _months = 12;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _items = ((widget.order['items'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((Map raw) => Map<String, dynamic>.from(raw))
        .where((Map<String, dynamic> item) =>
            _idOf(item['product']) != null && _idOf(item['variant']) != null)
        .toList(growable: false);
    _loadExisting();
  }

  @override
  void dispose() {
    _issue.dispose();
    super.dispose();
  }

  String? _idOf(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    if (value is Map && value['_id'] != null) return '${value['_id']}';
    return null;
  }

  DateTime _purchaseDate() {
    for (final String key in <String>[
      'deliveredAt',
      'completedAt',
      'placedAt',
      'createdAt',
    ]) {
      final DateTime? parsed = DateTime.tryParse('${widget.order[key] ?? ''}');
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  DateTime _expiryDate(DateTime purchase) {
    return DateTime(purchase.year, purchase.month + _months, purchase.day);
  }

  Future<void> _loadExisting() async {
    final response = await _service.warranties();
    if (!mounted) return;
    final List<Map<String, dynamic>> found = <Map<String, dynamic>>[];
    if (response.success) {
      try {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(jsonDecode(response.body) as Map);
        final String orderId = '${widget.order['_id'] ?? ''}';
        final List<dynamic> raw =
            (body['items'] as List?) ?? const <dynamic>[];
        for (final dynamic entry in raw) {
          if (entry is Map && _idOf(entry['order']) == orderId) {
            found.add(Map<String, dynamic>.from(entry));
          }
        }
      } catch (_) {
        // The form still works when the history read fails.
      }
    }
    if (!mounted) return;
    setState(() {
      _existing = found;
      _loading = false;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_items.isEmpty) return;
    final String description = _issue.text.trim();
    if (description.isEmpty) {
      _snack('Please describe the fault.');
      return;
    }

    final Map<String, dynamic> item = _items[_selectedItem];
    final String? product = _idOf(item['product']);
    final String? variant = _idOf(item['variant']);
    if (product == null || variant == null) {
      _snack('This order item cannot be claimed.');
      return;
    }

    final DateTime purchase = _purchaseDate();
    setState(() => _busy = true);
    try {
      final response = await _service.createWarranty(<String, dynamic>{
        'order': widget.order['_id'],
        'product': product,
        'variant': variant,
        'warrantyType': _warrantyType,
        'warrantyMonths': _months,
        'purchaseDate': purchase.toIso8601String(),
        'warrantyExpiryDate': _expiryDate(purchase).toIso8601String(),
        'issueCategory': _issueCategory,
        'issueDescription': description,
      });
      if (!mounted) return;
      if (!response.success) {
        _snack('Could not submit the warranty request.');
        return;
      }
      _snack('Warranty request submitted.');
      _issue.clear();
      await _loadExisting();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Warranty')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const Text(
                  'Choose the item you bought and tell the store what went wrong. '
                  'They review every request; nothing here is approved automatically.',
                ),
                if (_existing.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text('Requests for this order'),
                  for (final Map<String, dynamic> request in _existing)
                    ListTile(
                      dense: true,
                      title: Text('${request['productName'] ?? 'Warranty'}'),
                      subtitle: Text(
                        '${request['status'] ?? 'requested'}'
                        '${request['issueDescription'] == null ? '' : ' - ${request['issueDescription']}'}',
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                if (_items.isEmpty)
                  const Text('No warranty-eligible item was found in this order.')
                else ...<Widget>[
                  DropdownButtonFormField<int>(
                    initialValue: _selectedItem,
                    decoration: const InputDecoration(
                      labelText: 'Item',
                      border: OutlineInputBorder(),
                    ),
                    items: List<DropdownMenuItem<int>>.generate(
                      _items.length,
                      (int index) {
                        final Map<String, dynamic> item = _items[index];
                        final String name = '${item['name'] ?? 'Item'}';
                        final String variant = '${item['variantName'] ?? ''}';
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(variant.isEmpty ? name : '$name - $variant'),
                        );
                      },
                    ),
                    onChanged: _busy
                        ? null
                        : (int? value) {
                            if (value != null) {
                              setState(() => _selectedItem = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _warrantyType,
                    decoration: const InputDecoration(
                      labelText: 'Warranty type',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'manufacturer',
                        child: Text('Manufacturer'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'store',
                        child: Text('Store'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'manufacturer_service_centre',
                        child: Text('Manufacturer service centre'),
                      ),
                    ],
                    onChanged: _busy
                        ? null
                        : (String? value) {
                            if (value != null) {
                              setState(() => _warrantyType = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _months,
                    decoration: const InputDecoration(
                      labelText: 'Warranty period',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(value: 3, child: Text('3 months')),
                      DropdownMenuItem<int>(value: 6, child: Text('6 months')),
                      DropdownMenuItem<int>(value: 12, child: Text('12 months')),
                      DropdownMenuItem<int>(value: 24, child: Text('24 months')),
                      DropdownMenuItem<int>(value: 36, child: Text('36 months')),
                    ],
                    onChanged: _busy
                        ? null
                        : (int? value) {
                            if (value != null) {
                              setState(() => _months = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _issueCategory,
                    decoration: const InputDecoration(
                      labelText: 'Problem',
                      border: OutlineInputBorder(),
                    ),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'manufacturing_defect',
                        child: Text('Manufacturing defect'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'parts_failure',
                        child: Text('Parts failure'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'electrical_issue',
                        child: Text('Electrical issue'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'physical_damage',
                        child: Text('Physical damage'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: _busy
                        ? null
                        : (String? value) {
                            if (value != null) {
                              setState(() => _issueCategory = value);
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _issue,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'What went wrong?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit warranty request'),
                  ),
                ],
              ],
            ),
    );
  }
}
