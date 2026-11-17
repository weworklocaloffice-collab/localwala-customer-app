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
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/gen/l10n/app_localizations.dart';
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

  double get _estimate {
    final LsOffering? offering = _selectedOffering;
    final LsVariant? variant = _selectedVariant;
    double total = offering != null ? offering.price : (variant?.price ?? 0);
    for (final LsAddon addon in _addons) {
      if (_selectedAddons.contains(addon.id)) total += addon.price;
    }
    return total;
  }

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
    final ThemeData theme = Theme.of(context);
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final List<String> allowed = _active.allowedPaymentModes;
    final bool hasCod = allowed.contains('cod');
    final bool hasDirect = allowed.contains('pay_after') || hasCod;
    final bool hasWallet = allowed.contains('wallet');
    final bool needsQuote = _active.needsQuote;
    final int depositPercent = _active.depositPercent;
    final bool showDeposit = depositPercent > 0 && depositPercent < 100;
    final double depositDue = _estimate * depositPercent / 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ls_book_title(_active.name) ?? 'Book ${_active.name}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: <Widget>[
                LsCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const LsIconBadge(icon: Icons.home_repair_service_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _active.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: lsSlate900,
                              ),
                            ),
                            if (_active.description.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                _active.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: lsSlate600,
                                  height: 1.45,
                                ),
                              ),
                            ],
                            if (needsQuote || showDeposit) ...<Widget>[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  if (needsQuote)
                                    const _Pill(
                                      icon: Icons.request_quote_outlined,
                                      label: 'Quote after inspection',
                                      color: Color(0xFF2563EB),
                                    ),
                                  if (showDeposit)
                                    _Pill(
                                      icon: Icons.account_balance_wallet_outlined,
                                      label: '$depositPercent% deposit online',
                                      color: const Color(0xFFD97706),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_variants.isNotEmpty)
                  LsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _cardTitle(context, 'Choose a variant'),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          key: ValueKey<String?>(_variantId),
                          initialValue: _variantId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _variants
                              .map(
                                (LsVariant v) => DropdownMenuItem<String>(
                                  value: v.id,
                                  child: Text(
                                    '${v.name}  \u00b7  ${lsMoney(v.price)}',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: _submitting ? null : _onVariantChanged,
                        ),
                      ],
                    ),
                  ),
                LsCard(
                  onTap: _submitting ? null : _pickStart,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _cardTitle(context, 'Schedule'),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const LsIconBadge(icon: Icons.event_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  lsFormatDate(_startAt.toIso8601String()),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: lsSlate900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration \u00b7 $_durationMinutes min',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: lsSlate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _submitting ? null : _pickStart,
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                      if (_scheduled && _checkingAvailability) ...<Widget>[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
                  ),
                ),
                LsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _cardTitle(
                        context,
                        needsQuote ? 'Preferred provider (optional)' : 'Provider',
                      ),
                      const SizedBox(height: 10),
                      if (_visibleOfferings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _scheduled && _availabilityChecked
                                ? 'No provider is free at this time. Pick another time.'
                                : 'No provider is available for this service yet.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: lsSlate500,
                            ),
                          ),
                        )
                      else ...<Widget>[
                        for (final LsOffering offering in _visibleOfferings)
                          _ProviderTile(
                            offering: offering,
                            selected: _providerId == offering.providerId,
                            onTap: _submitting
                                ? null
                                : () => setState(() {
                                    if (needsQuote &&
                                        _providerId == offering.providerId) {
                                      _providerId = null;
                                    } else {
                                      _providerId = offering.providerId;
                                    }
                                  }),
                          ),
                        if (_scheduled && _availabilityChecked)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_visibleOfferings.length} available at the selected time',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: lsSlate500,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                if (_addons.isNotEmpty)
                  LsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _cardTitle(context, 'Add-ons'),
                        const SizedBox(height: 4),
                        for (final LsAddon addon in _addons)
                          CheckboxListTile(
                            value: _selectedAddons.contains(addon.id),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              addon.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: lsSlate900,
                              ),
                            ),
                            subtitle: Text(
                              '+ ${lsMoney(addon.price)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: lsSlate500,
                              ),
                            ),
                            onChanged: _submitting
                                ? null
                                : (bool? selected) {
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
                    ),
                  ),
                LsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _cardTitle(context, 'Payment'),
                      const SizedBox(height: 6),
                      _PaymentTile(
                        icon: Icons.credit_card_outlined,
                        title: showDeposit
                            ? 'Online ($depositPercent% deposit now)'
                            : 'Online',
                        subtitle: 'UPI, cards and netbanking',
                        selected: _paymentMode == 'gateway',
                        onTap: _submitting
                            ? null
                            : () => setState(() => _paymentMode = 'gateway'),
                      ),
                      if (hasCod)
                        _PaymentTile(
                          icon: Icons.payments_outlined,
                          title: 'Cash on completion',
                          subtitle: 'Pay the professional after the job',
                          selected: _paymentMode == 'cod',
                          onTap: _submitting
                              ? null
                              : () => setState(() => _paymentMode = 'cod'),
                        ),
                      if (hasDirect)
                        _PaymentTile(
                          icon: Icons.handshake_outlined,
                          title: 'Pay technician directly',
                          subtitle: 'Settle the balance with the professional',
                          selected: _paymentMode == 'direct',
                          onTap: _submitting
                              ? null
                              : () => setState(() => _paymentMode = 'direct'),
                        ),
                      if (hasWallet)
                        _PaymentTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Pay from wallet',
                          subtitle: 'Use your available wallet balance',
                          selected: _paymentMode == 'wallet',
                          onTap: _submitting
                              ? null
                              : () => setState(() => _paymentMode = 'wallet'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.6)),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: lsSlate900.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_error != null) ...<Widget>[
                Text(
                  _error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          needsQuote ? 'Price on request' : 'Estimated total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: lsSlate500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          needsQuote
                              ? 'Final quote after inspection'
                              : lsMoney(_estimate),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: lsSlate900,
                          ),
                        ),
                        if (!needsQuote && showDeposit && depositDue > 0) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            'Pay now ${lsMoney(depositDue)} ($depositPercent%)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: lsSlate500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              needsQuote
                                  ? (l10n?.ls_request_booking ??
                                      'Request booking')
                                  : (l10n?.ls_confirm_booking ??
                                      'Confirm booking'),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardTitle(BuildContext context, String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: lsSlate900,
            ),
      );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.offering,
    required this.selected,
    required this.onTap,
  });

  final LsOffering offering;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.7),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? theme.colorScheme.primary : lsSlate500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        offering.providerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: lsSlate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${offering.durationMinutes} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: lsSlate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lsMoney(offering.price),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: lsSlate900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.7),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, size: 20, color: lsSlate600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: lsSlate900,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: lsSlate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? theme.colorScheme.primary : lsSlate500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
