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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';
import 'package:user/app/features/stores/services/stores_tracking_socket.dart';
import 'package:user/app/features/stores/stores_support_view.dart';
import 'package:user/app/features/stores/stores_warranty_view.dart';

/// One order: lifecycle, payment, delivery, and the actions allowed right now.
///
/// The actions here are deliberately few. Pay is offered while the order is unpaid.
/// Cancel is offered always and refused server-side past the window — offering it
/// unconditionally is honest because the refusal message names the reason, while hiding
/// it requires the client to re-implement the cancellable-states table and drift from it.
/// Review, return and exchange appear once the order is delivered, for the same reason:
///
/// the server owns every one of these state machines and the app mirrors none of them.
class StoresTrackingView extends StatefulWidget {
  const StoresTrackingView({super.key, required this.orderId, this.service});

  final String orderId;

  /// Injectable for widget tests.
  ///
  /// This screen is pushed directly by checkout, not only through the router — so a
  /// service injected into checkout has to travel with it, or the injected double silently
  /// stops applying at the navigation boundary and the next screen quietly hits the real
  /// network. That reads as a test that hangs rather than as a missing parameter.
  final StoresCustomerService? service;

  @override
  State<StoresTrackingView> createState() => _StoresTrackingViewState();
}

class _StoresTrackingViewState extends State<StoresTrackingView> {
  late final StoresCustomerService _service;
  final StoresTrackingSocket _trackingSocket = StoresTrackingSocket();
  GoogleMapController? _mapController;
  LatLng? _driverLocation;
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _order = <String, dynamic>{};
  Map<String, dynamic> _tracking = <String, dynamic>{};
  bool _busy = false;
  bool _statusReloading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? StoresCustomerService();
    _load();
  }

  @override
  void dispose() {
    _trackingSocket.disconnect();
    super.dispose();
  }

  Future<void> _load({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    final response = await _service.orderTracking(widget.orderId);
    if (!mounted) return;
    if (!response.success) {
      if (quiet) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this order.';
      });
      return;
    }
    Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      if (quiet) return;
      setState(() {
        _loading = false;
        _error = 'Could not read this order.';
      });
      return;
    }
    setState(() {
      _loading = false;
      _order = (body['order'] as Map<String, dynamic>?) ?? body;
      _tracking =
          (body['tracking'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    });

    // A delivery row does not exist until the store dispatches, so keying the
    // socket off `deliveryStatus` missed every order-level change before that
    // (accepted, picking, packing, ready). Join for any live order; the map
    // still appears only once the driver actually has a location.
    const Set<String> terminal = <String>{
      'delivered',
      'completed',
      'failed',
      'cancelled',
      'rejected',
      'payment_failed',
    };
    if (terminal.contains('${_order['lifecycle'] ?? ''}')) {
      _trackingSocket.disconnect();
    } else {
      unawaited(_startLiveTracking());
    }
  }

  void _onStatus(Map<String, dynamic> status) {
    if (!mounted) return;
    final String lifecycle = '${status['lifecycle'] ?? ''}';
    final String deliveryStatus = '${status['deliveryStatus'] ?? ''}';
    setState(() {
      if (lifecycle.isNotEmpty) _order['lifecycle'] = lifecycle;
      if (deliveryStatus.isNotEmpty) {
        _tracking['deliveryStatus'] = deliveryStatus;
      }
    });

    const Set<String> terminal = <String>{
      'delivered',
      'completed',
      'failed',
      'cancelled',
      'rejected',
      'payment_failed',
    };
    if (terminal.contains(lifecycle) || terminal.contains(deliveryStatus)) {
      _trackingSocket.disconnect();
    }

    if (_statusReloading) return;
    _statusReloading = true;
    unawaited(_load(quiet: true).whenComplete(() => _statusReloading = false));
  }

  Future<void> _startLiveTracking() async {
    final String token = await _service.authToken();
    if (!mounted || token.isEmpty) return;
    _trackingSocket.connect(
      orderId: widget.orderId,
      authToken: token,
      onLocation: (double latitude, double longitude) {
        if (!mounted) return;
        final LatLng location = LatLng(latitude, longitude);
        setState(() => _driverLocation = location);
        _mapController?.animateCamera(CameraUpdate.newLatLng(location));
      },
      onStatus: _onStatus,
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancel() async {
    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cancel this order?'),
          content: const Text(
            'The server decides whether cancellation is still possible.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Keep'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cancel order'),
            ),
          ],
        );
      },
    );
    if (go != true) return;

    setState(() => _busy = true);
    try {
      final response = await _service.cancelOrder(
        widget.orderId,
        <String, dynamic>{},
      );
      if (!mounted) return;
      if (!response.success) {
        _snack('This order can no longer be cancelled.');
        return;
      }
      _snack('Order cancelled.');
      _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pay() async {
    setState(() => _busy = true);
    try {
      // The body carries the PaymentConfig id and nothing else. An `amount` would be
      // refused server-side: the amount is the order's own frozen total.
      final response = await _service.payOrder(
        widget.orderId,
        <String, dynamic>{},
      );
      if (!mounted) return;
      if (!response.success) {
        _snack('Payment could not be started.');
        return;
      }
      _snack('Payment started. Complete it to confirm the order.');
      _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit() async {
    final String orderId = '${_order['_id'] ?? _order['id'] ?? ''}';
    if (orderId.isEmpty || orderId == 'null') return;
    final List<dynamic> items = (_order['items'] as List?) ?? const <dynamic>[];
    final List<Map<String, dynamic>> draft = items
        .whereType<Map>()
        .map((Map<dynamic, dynamic> m) => <String, dynamic>{
              'variant': m['variant'],
              'quantity': m['quantity'] ?? 1,
              'name': m['name'] ?? 'Item',
            })
        .toList();
    if (draft.isEmpty) return;

    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Edit order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < draft.length; i++)
                    Row(
                      children: <Widget>[
                        Expanded(child: Text('${draft[i]['name']}')),
                        IconButton(
                          onPressed: (draft[i]['quantity'] as int) <= 1
                              ? null
                              : () => setState(() => draft[i]['quantity'] = (draft[i]['quantity'] as int) - 1),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('${draft[i]['quantity']}'),
                        IconButton(
                          onPressed: () => setState(() => draft[i]['quantity'] = (draft[i]['quantity'] as int) + 1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );
    if (go != true) return;
    setState(() => _busy = true);
    try {
      final List<Map<String, dynamic>> payload = draft
          .map((Map<String, dynamic> d) => <String, dynamic>{
                'variant': d['variant'],
                'quantity': d['quantity'],
              })
          .toList();
      final response = await _service.editOrder(orderId, payload);
      if (!mounted) return;
      _snack(response.success ? 'Order updated.' : 'Could not update order.');
      if (response.success) _load();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  Future<void> _review() async {
    final TextEditingController comment = TextEditingController();
    double storeRating = 5;
    final List<dynamic> items = (_order['items'] as List?) ?? const <dynamic>[];
    final List<double> productRatings = List<double>.filled(items.length, 5);

    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Rate this order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Store rating'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(5, (int i) {
                        return IconButton(
                          onPressed: () => setState(() => storeRating = i + 1.0),
                          icon: Icon(
                            i < storeRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    const Text('Product ratings'),
                    for (int i = 0; i < items.length; i++)
                      Column(
                        children: <Widget>[
                          Text('${items[i] is Map ? items[i]['name'] ?? 'Item' : 'Item'}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(5, (int j) {
                              return IconButton(
                                onPressed: () => setState(() => productRatings[i] = j + 1.0),
                                icon: Icon(
                                  j < productRatings[i] ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    TextField(
                      controller: comment,
                      decoration: const InputDecoration(
                        labelText: 'Comment (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    final String text = comment.text.trim();
    comment.dispose();
    if (go != true) return;

    setState(() => _busy = true);
    try {
      final List<Map<String, dynamic>> productRatingsPayload = <Map<String, dynamic>>[];
      for (int i = 0; i < items.length; i++) {
        if (items[i] is Map) {
          final String? productId = items[i]['product']?.toString();
          if (productId != null && productId.isNotEmpty && productId != 'null') {
            productRatingsPayload.add(<String, dynamic>{
              'product': productId,
              'rating': productRatings[i].toInt(),
              if (text.isNotEmpty) 'comment': text,
            });
          }
        }
      }
      final response = await _service.reviewOrder(
        widget.orderId,
        <String, dynamic>{
          'rating': storeRating.toInt(),
          if (text.isNotEmpty) 'comment': text,
          'productRatings': productRatingsPayload,
        },
      );
      if (!mounted) return;
      _snack(
        response.success
            ? 'Thanks for the review.'
            : 'Could not submit the review.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String lifecycle = '${_order['lifecycle'] ?? _order['status'] ?? ''}';
    final String paymentStatus = '${_order['paymentStatus'] ?? ''}';
    final bool delivered = lifecycle == 'delivered' || lifecycle == 'completed';
    final bool unpaid = paymentStatus == 'pending' || paymentStatus == 'unpaid';

    final List<dynamic> items = (_order['items'] as List?) ?? const <dynamic>[];

    final String deliveryStatus = '${_tracking['deliveryStatus'] ?? ''}';
    final Map<String, dynamic> driver = _tracking['driver'] is Map
        ? Map<String, dynamic>.from(_tracking['driver'] as Map)
        : <String, dynamic>{};
    final String driverName = '${driver['name'] ?? ''}';
    final String driverMobile = '${driver['mobile'] ?? ''}';
    final int? eta = _tracking['estimatedMinutes'] is num
        ? (_tracking['estimatedMinutes'] as num).toInt()
        : null;
    final String failureReason = '${_tracking['failureReason'] ?? ''}';

    return Scaffold(
      appBar: AppBar(title: Text('Order #${_order['orderNo'] ?? '—'}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _StatusRow(label: 'Status', value: lifecycle),
                _StatusRow(
                  label: 'Payment',
                  value: paymentStatus.isEmpty ? '—' : paymentStatus,
                ),
                if (deliveryStatus.isNotEmpty)
                  _StatusRow(label: 'Delivery', value: deliveryStatus),
                if (driverName.isNotEmpty)
                  _StatusRow(
                    label: 'Driver',
                    value: driverMobile.isEmpty
                        ? driverName
                        : '$driverName - $driverMobile',
                  ),
                if (eta != null)
                  _StatusRow(label: 'Estimated time', value: '$eta min'),
                if (failureReason.isNotEmpty)
                  _StatusRow(label: 'Delivery note', value: failureReason),
                if (!delivered &&
                    const <String>{
                      'assigned',
                      'accepted',
                      'picked_up',
                      'out_for_delivery',
                    }.contains(deliveryStatus)) ...<Widget>[
                  if (_driverLocation != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        height: 220,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _driverLocation!,
                              zoom: 15,
                            ),
                            markers: <Marker>{
                              Marker(
                                markerId: const MarkerId('driver'),
                                position: _driverLocation!,
                                infoWindow: const InfoWindow(title: 'Driver'),
                              ),
                            },
                            onMapCreated: (GoogleMapController controller) {
                              _mapController = controller;
                            },
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),
                    )
                  else
                    const ListTile(
                      dense: true,
                      leading: Icon(Icons.location_searching),
                      title: Text('Waiting for the driver location...'),
                    ),
                ],
                _StatusRow(
                  label: 'Total',
                  value: '${_order['grandTotal'] ?? ''}',
                ),
                const SizedBox(height: 8),
                const Text('Items'),
                for (final dynamic raw in items)
                  ListTile(
                    dense: true,
                    title: Text(
                      '${raw is Map ? raw['name'] ?? 'Item' : 'Item'}',
                    ),
                    subtitle: raw is Map
                        ? Text(
                            'Qty ${raw['quantity'] ?? 1} · ${raw['lineGrand'] ?? raw['lineTotal'] ?? ''}',
                          )
                        : null,
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (unpaid)
                      FilledButton(
                        onPressed: _busy ? null : _pay,
                        child: const Text('Pay now'),
                      ),
                    if ('${_order['lifecycle'] ?? ''}' == 'created')
                      OutlinedButton(
                        onPressed: _busy ? null : _edit,
                        child: const Text('Edit'),
                      ),
                    OutlinedButton(
                      onPressed: _busy ? null : _cancel,
                      child: const Text('Cancel'),
                    ),
                    if (delivered)
                      OutlinedButton(
                        onPressed: _busy ? null : _review,
                        child: const Text('Review'),
                      ),
                    if (delivered)
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        StoresSupportView(orderId: '${_order['_id'] ?? _order['id'] ?? ''}'),
                                  ),
                                );
                              },
                        child: const Text('Return / exchange'),
                      ),
                    if (delivered && items.isNotEmpty)
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => StoresWarrantyView(
                                      order: _order,
                                      service: _service,
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Warranty'),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 90,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
