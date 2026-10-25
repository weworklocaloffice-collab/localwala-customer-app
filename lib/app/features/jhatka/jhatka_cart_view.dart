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
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// The cart, the quote, and checkout.
///
/// Money is recomputed on READ server side: a client-supplied price is
/// structurally impossible to honour, so this screen sends quantities only
/// and renders what the quote returns. Cart lines carry no settled money —
/// `finalAmount` and `actualQuantity` belong to the order, frozen at the
/// counter, not to the cart.
class JhatkaCartView extends StatefulWidget {
  const JhatkaCartView({super.key});

  @override
  State<JhatkaCartView> createState() => _JhatkaCartViewState();
}

class _JhatkaCartViewState extends State<JhatkaCartView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  List<dynamic> _items = const <dynamic>[];
  Map<String, dynamic> _quote = const <String, dynamic>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final cart = await _service.cart();
    if (!mounted) return;
    if (!cart.success) {
      setState(() {
        _loading = false;
        _error = 'Could not load your cart.';
      });
      return;
    }
    final Map<String, dynamic> body =
        Map<String, dynamic>.from(jsonDecode(cart.body) as Map);
    setState(() {
      _loading = false;
      _items = (body['items'] as List?) ?? const <dynamic>[];
    });
    await _refreshQuote();
  }

  Future<void> _refreshQuote() async {
    final quote = await _service.checkoutQuote();
    if (!mounted || !quote.success) return;
    setState(() {
      _quote =
          Map<String, dynamic>.from(jsonDecode(quote.body) as Map);
    });
  }

Future<void> _editQty(String itemId, Map<String, dynamic> line) async {
    final dynamic qty = line['quantity'];
    final String current =
        qty is Map ? (qty['value']?.toString() ?? '') : qty.toString();
    final TextEditingController ctrl =
        TextEditingController(text: current);
    final String? newQty = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Change quantity'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Quantity',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (newQty == null || newQty.isEmpty || newQty == current) return;
    final num? parsed = num.tryParse(newQty);
    if (parsed == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid quantity.')),
      );
      return;
    }
    setState(() => _busy = true);
    final Map<String, dynamic> quantity = qty is Map
        ? <String, dynamic>{
            'value': parsed,
            'unit': qty['unit'] ?? 'GRAM',
          }
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
        const SnackBar(content: Text('Could not update quantity.')),
      );
    }
  }

  Future<void> _remove(String itemId) async {
    setState(() => _busy = true);
    final response = await _service.removeCartItem(itemId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (response.success) {
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove that line.')),
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
    setState(() => _busy = true);

    final response = await _service.placeOrder(<String, dynamic>{
      'items': _items,
      'paymentMode': payOnline ? 'gateway' : 'cod',
    });

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed. Retry.')),
      );
      return;
    }

    final String orderId = _orderIdOf(response);
    if (!payOnline || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(payOnline
              ? 'Order placed, but we could not start the payment.'
              : 'Order placed. Pay at the door.'),
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
    final String gateway = await _resolveGateway();
    if (gateway.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No payment method is available right now. '
              'Choose cash on delivery, or try again later.'),
        ),
      );
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
        const SnackBar(
          content: Text('Could not start the payment. Your order is saved — '
              'retry from Orders.'),
        ),
      );
      return;
    }

    // Hand off to the shared checkout: it fetches the initiation, opens the
    // gateway (Razorpay/Stripe), and verifies on callback. The order becomes
    // PAID on the verified callback, not on this screen — so there is no
    // success message here, only the handoff.
    String initiationId = '';
    try {
      final Map<String, dynamic> decoded =
          Map<String, dynamic>.from(jsonDecode(pay.body) as Map);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment started but unreadable. Retry from Orders.'),
        ),
      );
      return;
    }
    Navigator.of(context).pushNamed('/make_payments', arguments: [initiationId]);
  }

  /// Which PaymentConfig to charge through.
  ///
  /// Returns an empty string when none is configured, which the caller turns into an
  /// explicit message rather than an attempt. Guessing a gateway would be worse than
  /// saying none is available.
  Future<String> _resolveGateway() async {
    final DioApiResponse response = await _service.checkoutQuote();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
                  ? const Center(child: Text('Your cart is empty.'))
                  : Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (BuildContext context, int i) {
                              final Map<String, dynamic> line =
                                  Map<String, dynamic>.from(
                                _items[i] as Map,
                              );
                              final String id = (line['id'] ??
                                      line['_id'] ??
                                      '')
                                  .toString();
                              final dynamic qty = line['quantity'];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  title: Text(
                                    (line['name'] ??
                                            line['sku'] ??
                                            'Line')
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
                                        onPressed: _busy
                                            ? null
                                            : () => _remove(id),
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
                                'Estimated total '
                                '${(_quote['estimatedTotal'] ?? '—').toString()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Approx. Final weight confirmed at the outlet; '
                                'you are charged the lower of the two.',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),

                              // §3.3, in the customer's own words, before they pay:
                              // the amount above is what they are charged, whatever
                              // the scale says. Stating it here is what makes the
                              // weight notification at pickup a confirmation rather
                              // than a surprise.
                              const Text(
                                'You pay the estimate above. If the outlet weighs '
                                'less, the difference is refunded automatically — '
                                'you do not need to ask.',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 16),

                              FilledButton(
                                onPressed: _busy
                                    ? null
                                    : () => _checkout(payOnline: true),
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Pay online',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _busy
                                    ? null
                                    : () => _checkout(payOnline: false),
                                child: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Cash on delivery',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Riders collect the lower of the estimate and the '
                                'actual weight. The amount is fixed before they '
                                'leave the shop, so it cannot change at your door.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
