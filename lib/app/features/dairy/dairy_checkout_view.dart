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
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

class DairyCheckoutView extends StatefulWidget {
  const DairyCheckoutView({super.key});

  @override
  State<DairyCheckoutView> createState() => _DairyCheckoutViewState();
}

class _DairyCheckoutViewState extends State<DairyCheckoutView> {
  final DairyCustomerService _service = DairyCustomerService();
  final TextEditingController _couponController = TextEditingController();
  bool _loading = false;
  bool _couponLoading = false;
  String? _error;
  String? _appliedCouponCode;
  Map<String, dynamic>? _couponQuote;
  List<Map<String, dynamic>> _availableCoupons = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadAvailableCoupons();
  }

  Future<void> _loadAvailableCoupons() async {
    final response = await _service.availableCoupons();
    if (!mounted || !response.success) return;
    final Map<String, dynamic> body = _decodeBody(response.body ?? '');
    setState(() => _availableCoupons = body['coupons'] is List
        ? (body['coupons'] as List).whereType<Map>().map(asMap).toList()
        : <Map<String, dynamic>>[]);
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      return asMap(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _applyCoupon() async {
    final String code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty || _couponLoading || _loading) return;
    setState(() { _couponLoading = true; _error = null; });
    final response = await _service.quoteCoupon(code);
    if (!mounted) return;
    final Map<String, dynamic> body = _decodeBody(response.body ?? '');
    final Map<String, dynamic> quote = asMap(body['quote']);
    setState(() {
      _couponLoading = false;
      if (response.success && quote.isNotEmpty) {
        _appliedCouponCode = code;
        _couponQuote = quote;
        _couponController.text = code;
      } else {
        _appliedCouponCode = null;
        _couponQuote = null;
        _error = body['message']?.toString() ?? 'This coupon cannot be applied to your cart.';
      }
    });
  }

  Future<void> _placeOrder() async {
    final AppLocalizations t = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final r = await _service.checkout(<String, dynamic>{
      if (_appliedCouponCode != null) 'couponCode': _appliedCouponCode,
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (r.success) {
      final Map<String, dynamic> response = _decodeBody(r.body);
      final Map<String, dynamic> d = asMap(response['order']).isNotEmpty
          ? asMap(response['order'])
          : response;
      final String? orderId = d.isNotEmpty ? (d['_id']?.toString() ?? d['id']?.toString()) : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.dairy_order_placed}${orderId != null ? ': $orderId' : ''}')),
      );
      Navigator.of(context).pushNamed(
        AppRouter.dairyTrackingRoute,
        arguments: <dynamic>[orderId ?? ''],
      );
    } else {
      setState(() => _error = _decodeBody(r.body)['message']?.toString() ?? t.dairy_checkout_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_checkout)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Have a coupon?', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(children: <Widget>[
                          Expanded(child: TextField(
                            controller: _couponController,
                            textCapitalization: TextCapitalization.characters,
                            enabled: !_couponLoading && _appliedCouponCode == null,
                            decoration: const InputDecoration(labelText: 'Coupon code', border: OutlineInputBorder()),
                            onChanged: (_) => setState(() { _appliedCouponCode = null; _couponQuote = null; }),
                          )),
                          const SizedBox(width: 8),
                          _appliedCouponCode == null
                              ? OutlinedButton(
                                  onPressed: _couponLoading ? null : _applyCoupon,
                                  child: _couponLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Apply'),
                                )
                              : TextButton(onPressed: () => setState(() { _appliedCouponCode = null; _couponQuote = null; _couponController.clear(); }), child: const Text('Remove')),
                        ]),
                        if (_couponQuote != null) ...<Widget>[
                          const SizedBox(height: 10),
                          Text('${_couponQuote!['title'] ?? _appliedCouponCode} applied'),
                          Text('You save ${formatMoney(_couponQuote!['discountAmount'])}', style: const TextStyle(color: Colors.green)),
                        ],
                        if (_availableCoupons.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          const Text('Available for this cart'),
                          const SizedBox(height: 6),
                          Wrap(spacing: 8, runSpacing: 4, children: _availableCoupons.map((Map<String, dynamic> coupon) => ActionChip(
                            label: Text('${coupon['code']} · save ${formatMoney(coupon['discountAmount'])}'),
                            onPressed: _couponLoading || _loading ? null : () {
                              _couponController.text = coupon['code']?.toString() ?? '';
                              _applyCoupon();
                            },
                          )).toList()),
                        ],
                      ],
                    ),
                  ),
                ),
                if (_error != null) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _placeOrder, child: Text(t.dairy_place_order)),
              ],
            ),
    );
  }
}
