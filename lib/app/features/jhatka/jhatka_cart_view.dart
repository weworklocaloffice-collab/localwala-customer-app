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
import 'package:user/app/core/config/api_request_service.dart';
import 'package:user/app/core/repositories/address_repository.dart';
import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// The cart, the quote, and checkout.
///
/// Money is recomputed on READ server side: a client-supplied price is
/// structurally impossible to honour, so this screen sends quantities only
/// and renders what the quote returns. Cart lines carry no settled money —
/// `finalAmount` and `actualQuantity` belong to the order, frozen at the
/// counter, not to the cart.
class JhatkaCartView extends StatefulWidget {
  const JhatkaCartView({super.key, required this.outletId});

  /// The outlet this cart belongs to. A cart is per-outlet server-side, and the
  /// cart, quote and order calls all name it.
  final String outletId;

  @override
  State<JhatkaCartView> createState() => _JhatkaCartViewState();
}

class _JhatkaCartViewState extends State<JhatkaCartView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();
  final AddressRepository _addresses = AddressRepository();
  final AuthRepository _auth = AuthRepository();

  bool _loading = true;
  String? _error;
  List<dynamic> _items = const <dynamic>[];
  Map<String, dynamic> _quote = const <String, dynamic>{};
  bool _busy = false;

  // OD-12 fulfilment. Delivery is the default; pickup is offered only when the
  // outlet opted in (the quote says so). Delivery needs a SAVED address id —
  // the server resolves it against UserAddress scoped to this account, so a
  // typed-in address is not accepted at this endpoint.
  List<Map<String, dynamic>> _addressList = const <Map<String, dynamic>>[];
  String? _selectedAddressId;
  bool _pickupMode = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadAddresses();
  }

  /// The customer's saved addresses, from the shared platform address book.
  /// Best-effort: checkout can still proceed as pickup without them, and a
  /// delivery attempt without one is stopped with an explicit message.
  Future<void> _loadAddresses() async {
    try {
      final String uid = await _auth.userId();
      final response = await _addresses.getMyAddressList(uid);
      if (!mounted || !response.success) return;
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      final List<Map<String, dynamic>> parsed =
          ((body['list'] as List?) ?? const <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .toList();
      setState(() {
        _addressList = parsed;
        _selectedAddressId = parsed.isEmpty
            ? null
            : (parsed.first['id'] ?? parsed.first['_id'])?.toString();
      });
      // The first quote ran before the address book was loaded. Re-quote so the
      // delivery band (and therefore the total) reflects the default address.
      await _refreshQuote();
    } catch (_) {
      // No addresses is a state the customer can see and act on (the selector
      // says so); a load failure must not break the cart.
    }
  }

  Future<void> _load() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final cart = await _service.cart(outletId: widget.outletId);
    if (!mounted) return;
    if (!cart.success) {
      setState(() {
        _loading = false;
        _error = l10n.jhatka_could_not_load_cart;
      });
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(cart.body) as Map,
    );
    setState(() {
      _loading = false;
      _items = (body['items'] as List?) ?? const <dynamic>[];
    });
    await _refreshQuote();
  }

  Future<void> _refreshQuote() async {
    // The quote requires the outlet (a cart is per-outlet); without it the
    // quote 400s and the payment handoff never loads. Delivery also sends the
    // saved address so the quote prices the delivery band; pickup deliberately
    // sends none.
    final quote = await _service.checkoutQuote(
      outlet: widget.outletId,
      address: _pickupMode ? null : _selectedAddressId,
    );
    if (!mounted || !quote.success) return;
    setState(() {
      _quote = Map<String, dynamic>.from(jsonDecode(quote.body) as Map);
    });
  }

  Future<void> _editQty(String itemId, Map<String, dynamic> line) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final dynamic qty = line['quantity'];
    final String current = qty is Map
        ? (qty['value']?.toString() ?? '')
        : qty.toString();
    final TextEditingController ctrl = TextEditingController(text: current);
    final String? newQty = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.jhatka_change_quantity),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.jhatka_quantity),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.jhatka_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(l10n.jhatka_update),
          ),
        ],
      ),
    );
    if (newQty == null || newQty.isEmpty || newQty == current) return;
    final num? parsed = num.tryParse(newQty);
    if (parsed == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_invalid_quantity)));
      return;
    }
    setState(() => _busy = true);
    final Map<String, dynamic> quantity = qty is Map
        ? <String, dynamic>{'value': parsed, 'unit': qty['unit'] ?? 'GRAM'}
        : <String, dynamic>{'value': parsed, 'unit': 'GRAM'};
    final response = await _service.updateCartItem(
      itemId: itemId,
      quantity: quantity,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (response.success) {
      await _load();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.jhatka_could_not_update_quantity)),
      );
    }
  }

  Future<void> _remove(String itemId) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    final response = await _service.removeCartItem(itemId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (response.success) {
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.jhatka_could_not_remove_line)),
      );
    }
  }

  /// Checkout, with the payment step wired to the gateway.
  ///
  /// ## Why payment mode is chosen BEFORE the order is placed
  ///
  /// `POST /orders` takes `paymentMode` and stores it on the order; `POST /orders/:id/pay`
  /// then refuses anything that is not `'gateway'`. So placing first and paying second
  /// is the order the API requires, and the mode has to be settled before the first
  /// call — there is no patch that changes it afterwards.
  ///
  /// ## Why the pay step is separate
  ///
  /// The order is committed at placement with `lifecycle: CREATED` and
  /// `paymentStatus: pending`. Only a VERIFIED gateway callback moves it to `PAID`, and
  /// that comes back through `payment.dispatch.js`, not through this screen. So the
  /// honest thing this screen can do after a successful initiation is say the payment
  /// is being processed, not that it worked.
  Future<void> _checkout({required bool payOnline}) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    // A delivery order needs a saved address id; the server refuses a typed-in
    // one. Stopping HERE, before the order exists, is cheaper than a 400 after.
    if (!_pickupMode && (_selectedAddressId ?? '').isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_choose_address)));
      return;
    }
    if (widget.outletId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_checkout_failed)));
      return;
    }

    setState(() => _busy = true);

    final response = await _service.placeOrder(<String, dynamic>{
      'outlet': widget.outletId,
      'items': _items,
      'paymentMode': payOnline ? 'gateway' : 'cod',
      // OD-12: pickup skips the rider entirely — READY hands over at the
      // counter. Delivery carries the saved-address id the server resolves.
      'fulfilmentMode': _pickupMode ? 'pickup' : 'delivery',
      if (!_pickupMode) 'address': _selectedAddressId,
    });

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    if (!response.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_checkout_failed)));
      return;
    }

    final String orderId = _orderIdOf(response);
    if (!payOnline || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            payOnline
                ? l10n.jhatka_order_placed_no_payment
                : l10n.jhatka_order_placed_cod,
          ),
        ),
      );
      await _load();
      return;
    }

    await _startPayment(orderId);
    await _load();
  }

  /// Pull the order id out of the placement response.
  ///
  /// Reads the nested shapes the API can return rather than assuming one, because a
  /// null id here would send the customer to a payment screen with nothing to pay.
  static String _orderIdOf(DioApiResponse response) {
    if (response.body.isEmpty) {
      return '';
    }
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return '';
      }
      final dynamic order = decoded['order'];
      if (order is Map) {
        return (order['id'] ?? order['_id'] ?? '').toString();
      }
      return '';
    } on FormatException {
      return '';
    }
  }

  /// Create the payment initiation and hand off to the shared checkout.
  ///
  /// `paymentConfigId` is WHICH gateway. The amount is never sent: the server reads
  /// the order's own frozen `estimatedTotal`, and a body carrying an `amount` is
  /// refused rather than ignored.
  Future<void> _startPayment(String orderId) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String gateway = await _resolveGateway();
    if (gateway.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_no_payment_method)));
      return;
    }

    final DioApiResponse pay = await _service.payOrder(
      orderId: orderId,
      paymentConfigId: gateway,
    );

    if (!mounted) {
      return;
    }

    if (!pay.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.jhatka_could_not_start_payment)),
      );
      return;
    }

    // Hand off to the shared checkout: it fetches the initiation, opens the
    // gateway (Razorpay/Stripe), and verifies on callback. The order becomes
    // PAID on the verified callback, not on this screen — so there is no
    // success message here, only the handoff.
    String initiationId = '';
    try {
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(
        jsonDecode(pay.body) as Map,
      );
      final dynamic initiation = decoded['initiation'];
      if (initiation is Map) {
        initiationId = (initiation['id'] ?? initiation['_id'] ?? '').toString();
      } else {
        initiationId = initiation.toString();
      }
    } catch (_) {
      initiationId = '';
    }
    if (initiationId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_payment_unreadable)));
      return;
    }
    Navigator.of(
      context,
    ).pushNamed('/make_payments', arguments: [initiationId]);
  }

  /// Which PaymentConfig to charge through.
  ///
  /// The quote hands this back as `payment` (the same id the server expects on
  /// `POST /orders/:id/pay`). Returns an empty string when none is configured, which
  /// the caller turns into an explicit message rather than an attempt. Guessing a
  /// gateway would be worse than saying none is available.
  Future<String> _resolveGateway() async {
    // The quote loaded with the cart already carries the gateway. Prefer it: the
    // order exists by now, and a second round trip only adds a way to fail.
    final dynamic cached = _quote['payment'] ?? _quote['paymentConfig'];
    final String cachedId = cached is Map
        ? (cached['id'] ?? cached['_id'] ?? '').toString()
        : (cached is String ? cached : '');
    if (cachedId.isNotEmpty) return cachedId;

    final DioApiResponse response = await _service.checkoutQuote(
      outlet: widget.outletId,
      address: _pickupMode ? null : _selectedAddressId,
    );
    if (!response.success || response.body.isEmpty) {
      return '';
    }
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return '';
      }
      final dynamic payment = decoded['payment'] ?? decoded['paymentConfig'];
      if (payment is Map) {
        return (payment['id'] ?? payment['_id'] ?? '').toString();
      }
      if (payment is String) {
        return payment;
      }
      return '';
    } on FormatException {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.jhatka_your_cart)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _items.isEmpty
          ? Center(child: Text(l10n.jhatka_cart_empty))
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (BuildContext context, int i) {
                      final Map<String, dynamic> line =
                          Map<String, dynamic>.from(_items[i] as Map);
                      final String id = (line['id'] ?? line['_id'] ?? '')
                          .toString();
                      final dynamic qty = line['quantity'];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            (line['name'] ?? line['sku'] ?? l10n.jhatka_line)
                                .toString(),
                          ),
                          subtitle: Text(
                            qty is Map
                                ? '~${qty['value']} ${qty['unit'] ?? ''}'
                                : qty.toString(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: _busy
                                    ? null
                                    : () => _editQty(id, line),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _busy ? null : () => _remove(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        l10n.jhatka_estimated_total(
                          (_quote['estimatedTotal'] ?? '—').toString(),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.jhatka_approx_note,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),

                      // §3.3, in the customer's own words, before they pay:
                      // the amount above is what they are charged, whatever
                      // the scale says. Stating it here is what makes the
                      // weight notification at pickup a confirmation rather
                      // than a surprise.
                      Text(
                        l10n.jhatka_refund_promise,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // OD-12: delivery (the default) or counter pickup where
                      // the outlet offers it. The mode must be settled before
                      // the order exists — the server has no patch for it.
                      if ((_quote['pickupEnabled'] ?? false) == true)
                        SegmentedButton<bool>(
                          segments: <ButtonSegment<bool>>[
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(l10n.jhatka_mode_delivery),
                              icon: const Icon(Icons.two_wheeler_outlined),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(l10n.jhatka_mode_pickup),
                              icon: const Icon(Icons.storefront_outlined),
                            ),
                          ],
                          selected: <bool>{_pickupMode},
                          onSelectionChanged: (Set<bool> s) {
                            setState(() => _pickupMode = s.first);
                            // Pickup has no delivery fee; delivery re-prices
                            // with the selected address.
                            _refreshQuote();
                          },
                        )
                      else
                        Row(
                          children: <Widget>[
                            const Icon(Icons.two_wheeler_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.jhatka_mode_delivery),
                          ],
                        ),
                      if (!_pickupMode) ...<Widget>[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedAddressId,
                          decoration: InputDecoration(
                            labelText: l10n.jhatka_delivery_address,
                            border: const OutlineInputBorder(),
                          ),
                          items: _addressList.map((Map<String, dynamic> a) {
                            final String id = (a['id'] ?? a['_id'] ?? '')
                                .toString();
                            final String label =
                                '${a['flatHouse'] ?? ''}, ${a['locality'] ?? ''}';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (String? v) {
                            setState(() => _selectedAddressId = v);
                            _refreshQuote();
                          },
                        ),
                        if (_addressList.isEmpty)
                          Text(
                            l10n.jhatka_no_addresses,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                      const SizedBox(height: 16),

                      FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _checkout(payOnline: true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            l10n.jhatka_pay_online,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _checkout(payOnline: false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            _pickupMode
                                ? l10n.jhatka_pay_at_counter
                                : l10n.jhatka_cash_on_delivery,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pickupMode
                            ? l10n.jhatka_pickup_note
                            : l10n.jhatka_cod_note,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
