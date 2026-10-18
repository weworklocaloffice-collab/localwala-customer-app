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
import 'package:user/app/features/stores/stores_checkout_logic.dart';
import 'package:user/app/features/stores/stores_tracking_view.dart';

/// Checkout: pick an address, pick how to pay, see the server's own quote, place the order.
///
/// THREE RULES THIS SCREEN EXISTS TO KEEP.
///
/// 1. PRICES COME FROM THE SERVER, NEVER FROM THE CART. Everything in the totals column
///    is `POST /checkout/summary`. The server recomputes the basket from the outlet's own
///    prices (BR-36) and that is the figure the order is written from, so computing
///    anything locally would show one number and charge another.
///
/// 2. ELIGIBILITY IS THE SERVER'S CALL. `POST /checkout/eligibility` answers
///    `{ eligible, reasons }` with machine-readable codes (BR-27) — closed, out of
///    radius, at capacity, on holiday. Those are translated to words here purely for
///    reading; this screen never decides any of them, and never re-checks them to
///    "optimistically" let the customer through.
///
/// 3. THE ADDRESS IS SENT TWICE, ON PURPOSE. `addressId` is the saved address the
///    customer can manage later; `addressSnapshot` is a frozen copy of what it said at
///    purchase time. Editing the saved address later must not rewrite where an order was
///    actually delivered to, because that is exactly what a refund dispute turns on.
class StoresCheckoutView extends StatefulWidget {
  const StoresCheckoutView({
    super.key,
    required this.storeId,
    required this.chainId,
    this.service,
    this.addresses,
    this.auth,
  });

  final String storeId;
  final String chainId;

  /// Injectable for widget tests; omitted in the app.
  final StoresCustomerService? service;
  final AddressRepository? addresses;
  final AuthRepository? auth;

  @override
  State<StoresCheckoutView> createState() => _StoresCheckoutViewState();
}

class _StoresCheckoutViewState extends State<StoresCheckoutView> {
  late final StoresCustomerService _service;
  late final AddressRepository _addresses;
  late final AuthRepository _auth;

  List<Map<String, dynamic>> _addressList = <Map<String, dynamic>>[];
  Map<String, dynamic>? _selected;

  String _paymentMode = 'gateway';
  Map<String, dynamic> _summary = <String, dynamic>{};
  List<String> _reasons = <String>[];

  bool _loading = true;
  bool _eligible = true;
  bool _placing = false;
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
    setState(() {
      _loading = true;
      _error = null;
    });

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
      final parsed = list
          .whereType<Map<String, dynamic>>()
          .toList();
      if (!mounted) return;
      setState(() {
        _addressList = parsed;
        // Default to the first saved address. The customer can change it; this is not a
        // decision being made for them, just a starting point.
        _selected = parsed.isEmpty ? null : parsed.first;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your addresses.';
      });
      return;
    }

    await _checkEligibility();
    await _loadSummary();
    if (mounted) setState(() => _loading = false);
  }

  /// The shape `addressSnapshot` validation demands. `line1` comes from `flatHouse`
  /// because that is the app's name for the door-level address, and `location` is sent as
  /// GeoJSON so the server can measure delivery distance. The mapping itself lives in
  /// `StoresCheckoutLogic` so it can be tested without a widget tree.
  Map<String, dynamic> _snapshotFor(Map<String, dynamic> address) =>
      StoresCheckoutLogic.addressSnapshot(address);

  Future<void> _checkEligibility() async {
    final Map<String, dynamic>? address = _selected;
    if (address == null) {
      setState(() {
        _eligible = false;
        _reasons = <String>['NO_ADDRESS_SELECTED'];
      });
      return;
    }
    final response = await _service.checkoutEligibility(<String, dynamic>{
      'outlet': widget.storeId,
      'address': address['id'],
      'addressLocation': _snapshotFor(address)['location'],
    });
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _eligible = false;
        _reasons = <String>['ELIGIBILITY_CHECK_FAILED'];
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    final List<dynamic> reasons = (body['reasons'] as List?) ?? const <dynamic>[];
    if (!mounted) return;
    setState(() {
      _eligible = body['eligible'] == true;
      _reasons = reasons.map((dynamic r) => '$r').toList();
    });
  }

  Future<void> _loadSummary() async {
    final response = await _service.checkoutSummary(<String, dynamic>{
      'outlet': widget.storeId,
      'chain': widget.chainId,
      'address': _selected?['id'],
      'paymentMode': _paymentMode,
    });
    if (!mounted) return;
    if (!response.success) {
      setState(() => _summary = <String, dynamic>{});
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    if (!mounted) return;
    setState(() => _summary = body);
  }

  Future<void> _selectAddress(Map<String, dynamic> address) async {
    setState(() => _selected = address);
    await _checkEligibility();
    await _loadSummary();
  }

  Future<void> _setPaymentMode(String mode) async {
    setState(() => _paymentMode = mode);
    // The mode changes fees and the COD ceiling, so the quote is re-fetched rather than
    // patched. Same basket, same totals — computed by the server both times.
    await _loadSummary();
  }

  Future<void> _placeOrder() async {
    final Map<String, dynamic>? address = _selected;
    if (address == null) return;

    setState(() => _placing = true);
    try {
      // Items are NOT sent. `createOrder` reads the server's own cart for this outlet, so
      // a client cannot place an order for something it never added, at a price it chose.
      final response = await _service.placeOrder(<String, dynamic>{
        'outlet': widget.storeId,
        'chain': widget.chainId,
        'addressId': address['id'],
        'addressSnapshot': _snapshotFor(address),
        'paymentMode': _paymentMode,
      });
      if (!mounted) return;
      if (!response.success) {
        _snack('Could not place the order.');
        return;
      }
      final Map<String, dynamic> body =
          Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      final Map<String, dynamic> order =
          (body['order'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final String orderId = '${order['_id'] ?? order['id'] ?? ''}';
      if (!mounted) return;
      if (orderId.isEmpty) {
        _snack('Order placed.');
        return;
      }
      // Straight to tracking: an order with a number is worth watching, and the customer
      // has just paid attention to it.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => StoresTrackingView(orderId: orderId, service: widget.service),
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// BR-27 reason codes in words, via the shared, tested mapping.
  String _reasonText(String code) => StoresCheckoutLogic.reasonText(code);

  Map<String, dynamic> get _snapshot {
    final Map<String, dynamic>? address = _selected;
    if (address == null) return <String, dynamic>{};
    return StoresCheckoutLogic.addressSnapshot(address);
  }

  /// Place order is offered only when the snapshot the server demands can actually be
  /// built from the chosen address. Better to say which field is missing than to send a
  /// request that 400s.
  bool get _canPlace =>
      _selected != null && StoresCheckoutLogic.snapshotIsComplete(_snapshot);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> lines = (_summary['items'] as List?) ?? const <dynamic>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    _sectionTitle(context, 'Deliver to'),
                    if (_addressList.isEmpty)
                      const Text('No saved addresses yet. Add one in Address Book.')
                    else
                      // `RadioGroup` owns the selection; the deprecated `groupValue` /
                      // `onChanged` pair on `RadioListTile` was removed in this Flutter.
                      RadioGroup<String>(
                        groupValue: '${_selected?['id'] ?? ''}',
                        onChanged: (String? id) {
                          final match = _addressList
                              .where((Map<String, dynamic> a) => '${a['id']}' == id)
                              .toList();
                          if (match.isNotEmpty) _selectAddress(match.first);
                        },
                        child: Column(
                          children: <Widget>[
                            for (final Map<String, dynamic> a in _addressList)
                              RadioListTile<String>(
                                value: '${a['id']}',
                                title: Text('${a['receiverName'] ?? ''}'),
                                subtitle: Text(
                                  '${a['flatHouse'] ?? ''}'
                                  '${'${a['locality'] ?? ''}'.isNotEmpty ? ', ${a['locality']}' : ''}',
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (!_eligible) ...<Widget>[
                      const SizedBox(height: 8),
                      for (final String r in _reasons)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _reasonText(r),
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ],
                    _sectionTitle(context, 'Payment'),
                    RadioGroup<String>(
                      groupValue: _paymentMode,
                      onChanged: (String? v) {
                        if (v != null) _setPaymentMode(v);
                      },
                      child: Column(
                        children: <Widget>[
                          for (final String mode in <String>['gateway', 'wallet', 'cod'])
                            RadioListTile<String>(
                              value: mode,
                              title: Text(switch (mode) {
                                'gateway' => 'Pay online',
                                'wallet' => 'Wallet',
                                _ => 'Cash on delivery',
                              }),
                            ),
                        ],
                      ),
                    ),
                    if (lines.isNotEmpty) ...<Widget>[
                      _sectionTitle(context, 'Order summary'),
                      for (final dynamic raw in lines)
                        if (raw is Map<String, dynamic>)
                          ListTile(
                            dense: true,
                            title: Text('${raw['name'] ?? 'Item'}'),
                            subtitle: Text('Qty ${raw['quantity'] ?? 1}'),
                            trailing: Text('${raw['lineGrand'] ?? raw['lineTotal'] ?? ''}'),
                          ),
                      const Divider(),
                      _totalRow(context, 'Subtotal', _summary['itemsSubtotal']),
                      if ((_summary['itemDiscountTotal'] ?? 0) != 0)
                        _totalRow(context, 'Discount', '-${_summary['itemDiscountTotal']}'),
                      _totalRow(context, 'Tax', _summary['taxTotal']),
                      _totalRow(context, 'Delivery', _summary['deliveryFee']),
                      _totalRow(context, 'Packaging', _summary['packagingFee']),
                      const Divider(),
                      _totalRow(
                        context,
                        'Total',
                        _summary['grandTotal'] ?? _summary['total'],
                        bold: true,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: (_placing || !_eligible || !_canPlace)
                          ? null
                          : _placeOrder,
                      child: _placing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Place order'),
                    ),
                  ],
                ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );

  Widget _totalRow(BuildContext context, String label, Object? value, {bool bold = false}) {
    final TextStyle? style = bold ? Theme.of(context).textTheme.titleMedium : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text('${value ?? ''}', style: style),
        ],
      ),
    );
  }
}