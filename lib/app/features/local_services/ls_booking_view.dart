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
import 'package:user/app/features/local_services/ls_tracking_view.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';

/// Checkout. The customer picks provider, time, add-ons and payment channel;
/// the backend computes every total and resolves the offering price.
class LsBookingView extends StatefulWidget {
  const LsBookingView({super.key, required this.service});

  final LsService service;

  @override
  State<LsBookingView> createState() => _LsBookingViewState();
}

class _LsBookingViewState extends State<LsBookingView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  LsService? _detail;
  List<LsVariant> _variants = const <LsVariant>[];
  List<LsAddon> _addons = const <LsAddon>[];
  List<LsOffering> _offerings = const <LsOffering>[];
  final Set<String> _selectedAddons = <String>{};

  String? _variantId;
  String? _providerId;
  String _paymentMode = 'gateway';
  DateTime _startAt = DateTime.now().add(const Duration(days: 1));
  Map<String, bool> _availability = <String, bool>{};
  bool _availabilityChecked = false;

  bool _loading = true;
  bool _checkingAvailability = false;
  bool _submitting = false;
  String? _error;

  LsService get _active => _detail ?? widget.service;

  LsVariant? get _selectedVariant {
    for (final LsVariant variant in _variants) {
      if (variant.id == _variantId) return variant;
    }
    return null;
  }

  LsOffering? get _selectedOffering {
    for (final LsOffering offering in _offerings) {
      if (offering.providerId == _providerId) return offering;
    }
    return null;
  }

  int get _durationMinutes {
    final LsVariant? variant = _selectedVariant;
    if (variant != null && variant.durationMinutes > 0) {
      return variant.durationMinutes;
    }
    final LsOffering? offering = _selectedOffering;
    if (offering != null && offering.durationMinutes > 0) {
      return offering.durationMinutes;
    }
    return _active.baseDurationMinutes > 0 ? _active.baseDurationMinutes : 60;
  }

  DateTime get _endAt => _startAt.add(Duration(minutes: _durationMinutes));

  bool get _scheduled =>
      _active.bookingMode == 'SLOT' || _active.bookingMode == 'DATE_RANGE';

  List<LsOffering> get _visibleOfferings {
    final List<LsOffering> matching = _offerings.where((LsOffering offering) {
      if (_variantId != null &&
          _variantId!.isNotEmpty &&
          offering.variantId.isNotEmpty &&
          offering.variantId != _variantId) {
        return false;
      }
      if (_scheduled && _availabilityChecked) {
        return _availability[offering.providerId] == true;
      }
      return true;
    }).toList();
    return matching;
  }

  @override
  void initState() {
    super.initState();
    _startAt = DateTime(
      DateTime.now().add(const Duration(days: 1)).year,
      DateTime.now().add(const Duration(days: 1)).month,
      DateTime.now().add(const Duration(days: 1)).day,
      10,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dynamic res = await _service.serviceDetail(widget.service.id);
      if (res.body.isNotEmpty) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          jsonDecode(res.body) as Map,
        );
        final dynamic rawService = body['service'];
        if (rawService is Map) {
          _detail = LsService.fromJson(Map<String, dynamic>.from(rawService));
        }
        _variants = ((body['variants'] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map e) => LsVariant.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _addons = ((body['addons'] as List?) ?? const <dynamic>[])
            .whereType<Map>()
            .map((Map e) => LsAddon.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (_variants.isNotEmpty && _variantId == null) {
        _variantId = _variants.first.id;
      }
      final String mode = _paymentMode;
      final List<String> allowed = _active.allowedPaymentModes;
      final bool hasCod = allowed.contains('cod');
      final bool hasDirect = allowed.contains('pay_after');
      if (mode == 'cod' && !hasCod) _paymentMode = 'gateway';
      if (mode == 'direct' && !hasDirect && !hasCod) _paymentMode = 'gateway';
      await _loadOfferings();
      if (_scheduled) {
        await _checkAvailability();
      }
    } catch (e) {
      _error = 'Could not load this service: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOfferings() async {
    final dynamic res = await _service.offerings(
      serviceId: _active.id,
      variantId: _variantId,
    );
    if (res.body.isEmpty) {
      _offerings = const <LsOffering>[];
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(res.body) as Map,
    );
    _offerings = ((body['results'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((Map e) => LsOffering.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    if (_providerId != null &&
        !_offerings.any((LsOffering o) => o.providerId == _providerId)) {
      _providerId = null;
    }
  }

  Future<void> _checkAvailability() async {
    if (!_scheduled) return;
    setState(() {
      _checkingAvailability = true;
      _availabilityChecked = false;
    });
    try {
      final dynamic res = await _service.availability(
        serviceId: _active.id,
        startAt: _startAt.toIso8601String(),
        endAt: _endAt.toIso8601String(),
      );
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final Map<String, bool> availability = <String, bool>{};
      for (final dynamic raw
          in (body['results'] as List?) ?? const <dynamic>[]) {
        if (raw is! Map) continue;
        final dynamic provider = raw['provider'];
        if (provider is! Map) continue;
        final String id = '${provider['_id'] ?? provider['id'] ?? ''}';
        if (id.isNotEmpty) availability[id] = raw['available'] == true;
      }
      _availability = availability;
      _availabilityChecked = true;
    } catch (e) {
      _error = 'Availability could not be checked: $e';
    } finally {
      if (mounted) setState(() => _checkingAvailability = false);
    }
  }

  Future<void> _pickStart() async {
    final DateTime? day = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (day == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (time == null) return;
    setState(() {
      _startAt = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    });
    if (_scheduled) await _checkAvailability();
  }

  Future<void> _onVariantChanged(String? id) async {
    setState(() {
      _variantId = id;
      _providerId = null;
    });
    try {
      await _loadOfferings();
      if (_scheduled) await _checkAvailability();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load providers: $e');
    }
    if (mounted) setState(() {});
  }

  String _format(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} '
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_active.pricingMode == 'VARIANT' && _variants.isEmpty) {
      setState(() => _error = 'This service has no bookable variant yet.');
      return;
    }
    if (_active.pricingMode == 'VARIANT' && _variantId == null) {
      setState(() => _error = 'Choose a variant.');
      return;
    }
    if ((_scheduled || !_active.needsQuote) && _providerId == null) {
      setState(() => _error = 'Choose a provider.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final dynamic res = await _service.createBooking(<String, dynamic>{
        'serviceKey': _active.key,
        'bookingMode': _active.bookingMode.isEmpty
            ? 'REQUEST'
            : _active.bookingMode,
        if (_providerId != null && _providerId!.isNotEmpty)
          'provider': _providerId,
        if (_variantId != null && _variantId!.isNotEmpty) 'variant': _variantId,
        if (_scheduled) 'startAt': _startAt.toIso8601String(),
        if (_scheduled) 'endAt': _endAt.toIso8601String(),
        if (_selectedAddons.isNotEmpty)
          'addons': _selectedAddons
              .map((String id) => <String, dynamic>{'id': id, 'quantity': 1})
              .toList(),
        'paymentMode': _paymentMode,
      });
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final dynamic rawBooking = body['booking'];
      if (rawBooking is! Map) {
        setState(() {
          _error = '${body['message'] ?? 'Booking failed'}';
          _submitting = false;
        });
        return;
      }
      final String bookingId = '${rawBooking['_id'] ?? rawBooking['id'] ?? ''}';
      if ((_paymentMode == 'gateway' || _paymentMode == 'wallet') &&
          !_active.needsQuote) {
        await _startPayment(bookingId);
      } else if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LsTrackingView(bookingId: bookingId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Booking failed: $e';
          _submitting = false;
        });
      }
    }
  }

  Future<void> _startPayment(String bookingId) async {
    try {
      final dynamic res = await _service.payBooking(bookingId);
      String initiationId = '';
      bool paidFromWallet = false;
      if (res.body.isNotEmpty) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          jsonDecode(res.body) as Map,
        );
        final dynamic initiation = body['initiation'];
        if (initiation is Map) {
          initiationId = '${initiation['_id'] ?? initiation['id'] ?? ''}';
        }
        // A wallet payment settles on the spot: there is no gateway intent
        // to open, the booking is already paid.
        paidFromWallet = body['wallet'] is Map;
      }
      if (!mounted) return;
      if (initiationId.isEmpty && !paidFromWallet) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LsTrackingView(bookingId: bookingId),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking saved, but payment could not be started.'),
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => LsTrackingView(bookingId: bookingId),
        ),
      );
      if (paidFromWallet) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Paid from your wallet.')));
        return;
      }
      await Navigator.of(
        context,
      ).pushNamed('/make_payments', arguments: <String>[initiationId]);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LsTrackingView(bookingId: bookingId),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking saved, but payment failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> allowed = _active.allowedPaymentModes;
    final bool hasCod = allowed.contains('cod');
    final bool hasDirect = allowed.contains('pay_after') || hasCod;
    final bool hasWallet = allowed.contains('wallet');
    return Scaffold(
      appBar: AppBar(title: Text('Book ${_active.name}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (_active.description.isNotEmpty) ...<Widget>[
                  Text(_active.description),
                  const SizedBox(height: 12),
                ],
                if (_active.needsQuote)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Final price comes as a provider quotation after inspection. '
                        'You can request it now and pay once the quote is accepted.',
                      ),
                    ),
                  ),
                if (_active.depositPercent > 0 && _active.depositPercent < 100)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '${_active.depositPercent}% deposit is due online now. '
                        'The remaining balance is payable before the service is completed.',
                      ),
                    ),
                  ),
                if (_variants.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey<String?>(_variantId),
                    initialValue: _variantId,
                    decoration: const InputDecoration(
                      labelText: 'Variant',
                      border: OutlineInputBorder(),
                    ),
                    items: _variants
                        .map(
                          (LsVariant v) => DropdownMenuItem<String>(
                            value: v.id,
                            child: Text(
                              '${v.name} · ₹${v.price.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _submitting ? null : _onVariantChanged,
                  ),
                ],
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  title: const Text('Start'),
                  subtitle: Text('${_format(_startAt)} – ${_format(_endAt)}'),
                  trailing: const Icon(Icons.edit_calendar),
                  onTap: _submitting ? null : _pickStart,
                ),
                if (_scheduled && _checkingAvailability)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                Text(
                  _active.needsQuote
                      ? 'Preferred provider (optional)'
                      : 'Provider',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_visibleOfferings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _scheduled && _availabilityChecked
                          ? 'No provider is free at this time. Pick another time.'
                          : 'No provider is available for this service yet.',
                    ),
                  )
                else
                  RadioGroup<String>(
                    groupValue: _providerId,
                    onChanged: (String? id) => setState(() => _providerId = id),
                    child: Column(
                      children: <Widget>[
                        for (final LsOffering offering in _visibleOfferings)
                          RadioListTile<String>(
                            value: offering.providerId,
                            title: Text(offering.providerName),
                            subtitle: Text(
                              '₹${offering.price.toStringAsFixed(2)} · ${offering.durationMinutes} min',
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_addons.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  const Text(
                    'Add-ons',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (final LsAddon addon in _addons)
                    CheckboxListTile(
                      value: _selectedAddons.contains(addon.id),
                      title: Text(addon.name),
                      subtitle: Text('₹${addon.price.toStringAsFixed(2)}'),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedAddons.add(addon.id);
                          } else {
                            _selectedAddons.remove(addon.id);
                          }
                        });
                      },
                    ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Payment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioGroup<String>(
                  groupValue: _paymentMode,
                  onChanged: (String? v) =>
                      setState(() => _paymentMode = v ?? 'gateway'),
                  child: Column(
                    children: <Widget>[
                      RadioListTile<String>(
                        title: Text(
                          _active.depositPercent > 0 &&
                                  _active.depositPercent < 100
                              ? 'Online (${_active.depositPercent}% deposit now)'
                              : 'Online',
                        ),
                        value: 'gateway',
                      ),
                      if (hasCod)
                        const RadioListTile<String>(
                          title: Text('Cash on completion'),
                          value: 'cod',
                        ),
                      if (hasDirect)
                        const RadioListTile<String>(
                          title: Text('Pay technician directly'),
                          value: 'direct',
                        ),
                      if (hasWallet)
                        const RadioListTile<String>(
                          title: Text('Pay from wallet'),
                          value: 'wallet',
                        ),
                    ],
                  ),
                ),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(
                    _submitting
                        ? 'Booking…'
                        : _active.needsQuote
                        ? 'Request booking'
                        : 'Confirm booking',
                  ),
                ),
              ],
            ),
    );
  }
}
