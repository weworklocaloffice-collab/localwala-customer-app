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
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer booking list with status filters and status-aware actions.
class LsBookingsView extends StatefulWidget {
  const LsBookingsView({super.key});

  @override
  State<LsBookingsView> createState() => _LsBookingsViewState();
}

class _LsBookingsViewState extends State<LsBookingsView> {
  static const List<MapEntry<String, String>> _filters =
      <MapEntry<String, String>>[
    MapEntry<String, String>('ALL', 'All'),
    MapEntry<String, String>('REQUESTED', 'Requested'),
    MapEntry<String, String>('CONFIRMED', 'Confirmed'),
    MapEntry<String, String>('IN_PROGRESS', 'In progress'),
    MapEntry<String, String>('COMPLETED', 'Completed'),
    MapEntry<String, String>('CANCELLED', 'Cancelled'),
  ];

  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  String _statusFilter = 'ALL';
  List<LsCustomerBooking> _items = const <LsCustomerBooking>[];

  List<LsCustomerBooking> get _filtered => _statusFilter == 'ALL'
      ? _items
      : _items.where((LsCustomerBooking b) => b.status == _statusFilter).toList();

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
    try {
      final dynamic res = await _service.bookings();
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final List<dynamic> raw = (body['results'] ?? []) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _items = raw
            .whereType<Map<String, dynamic>>()
            .map(LsCustomerBooking.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)?.ls_bookings_load_failed ??
            'Could not load bookings.';
      });
    }
  }

  Future<void> _act(LsCustomerBooking b, String status) async {
    if (status == 'CANCELLED') {
      final bool confirmed = await _confirmCancel(b);
      if (!confirmed) return;
    }
    try {
      await _service.transitionBooking(b.id, status);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.ls_failed_error('$e') ?? 'Failed: $e',
          ),
        ),
      );
    }
  }

  Future<bool> _confirmCancel(LsCustomerBooking b) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text(
          '${b.displayTitle} (${b.code}) will be cancelled. '
          'Any refund is processed as per the service policy.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _review(LsCustomerBooking b) async {
    int rating = 5;
    final TextEditingController comment = TextEditingController();
    final bool? submitted = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Rate this service'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  b.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 1; i <= 5; i++)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setDialogState(() => rating = i),
                        icon: Icon(
                          i <= rating ? Icons.star_rounded : Icons.star_outline,
                          color: const Color(0xFFF59E0B),
                          size: 32,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: comment,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'How was the service?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Submit review'),
              ),
            ],
          );
        },
      ),
    );
    if (submitted != true) {
      comment.dispose();
      return;
    }
    try {
      await _service.review(b.id, rating, comment.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanks for the $rating-star review')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.ls_failed_error('$e') ?? 'Failed: $e',
          ),
        ),
      );
    } finally {
      comment.dispose();
    }
  }

  void _open(LsCustomerBooking b) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LsTrackingView(bookingId: b.id),
          ),
        )
        .then((_) => _load());
  }

  String _actionLabel(AppLocalizations? l10n, String action) {
    switch (action) {
      case 'REQUESTED':
        return l10n?.ls_action_request ?? 'Request';
      case 'CANCELLED':
        return l10n?.ls_cancel ?? 'Cancel';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    final List<LsCustomerBooking> visible = _filtered;
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.ls_my_bookings ?? 'My bookings')),
      body: _loading
          ? const LsSkeletonList()
          : _error != null
          ? LsErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: <Widget>[
                  _FilterBar(
                    filters: _filters,
                    selected: _statusFilter,
                    counts: <String, int>{
                      for (final MapEntry<String, String> f in _filters)
                        f.key: f.key == 'ALL'
                            ? _items.length
                            : _items
                                  .where(
                                    (LsCustomerBooking b) =>
                                        b.status == f.key,
                                  )
                                  .length,
                    },
                    onSelected: (String value) =>
                        setState(() => _statusFilter = value),
                  ),
                  const SizedBox(height: 8),
                  if (visible.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: LsEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: _statusFilter == 'ALL'
                            ? (l10n?.ls_no_bookings ?? 'No bookings yet.')
                            : 'No ${_statusFilter.toLowerCase().replaceAll('_', ' ')} bookings',
                        message: 'Book a local service and track every step here.',
                        actionLabel: 'Browse services',
                        onAction: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )
                  else
                    for (final LsCustomerBooking b in visible)
                      _BookingCard(
                        booking: b,
                        actionLabel: (String action) =>
                            _actionLabel(l10n, action),
                        onOpen: () => _open(b),
                        onAction: (String action) => _act(b, action),
                        onReview: () => _review(b),
                      ),
                ],
              ),
            ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final List<MapEntry<String, String>> filters;
  final String selected;
  final Map<String, int> counts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final MapEntry<String, String> filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selected == filter.key,
                onSelected: (_) => onSelected(filter.key),
                label: Text(
                  '${filter.value} (${counts[filter.key] ?? 0})',
                  style: const TextStyle(fontSize: 12),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.actionLabel,
    required this.onOpen,
    required this.onAction,
    required this.onReview,
  });

  final LsCustomerBooking booking;
  final String Function(String action) actionLabel;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String schedule =
        lsFormatDate(booking.scheduleRaw.isNotEmpty ? booking.scheduleRaw : booking.createdAt);
    final List<String> actions = booking.actions
        .where((String action) => action != 'DISPUTED')
        .toList();
    final double amount = booking.serviceValue > 0
        ? booking.serviceValue
        : booking.labourAmount + booking.partsAmount;
    return LsCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  booking.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: lsSlate900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LsStatusChip(status: booking.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            <String>[
              booking.code,
              if (booking.providerName.isNotEmpty) booking.providerName,
              if (booking.variantName.isNotEmpty) booking.variantName,
            ].join('  \u00b7  '),
            style: theme.textTheme.bodySmall?.copyWith(color: lsSlate500),
          ),
          if (schedule.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.event_outlined,
                  size: 15,
                  color: lsSlate500,
                ),
                const SizedBox(width: 6),
                Text(
                  schedule,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: lsSlate600,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: <Widget>[
              Text(
                lsMoney(amount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: lsSlate900,
                ),
              ),
              const SizedBox(width: 8),
              LsStatusChip(status: booking.paymentStatus, payment: true),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: lsSlate500),
            ],
          ),
          if (actions.isNotEmpty || booking.status == 'COMPLETED') ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                for (final String action in actions)
                  OutlinedButton(
                    onPressed: () => onAction(action),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(actionLabel(action)),
                  ),
                if (booking.status == 'COMPLETED')
                  FilledButton.icon(
                    onPressed: onReview,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: Text(
                      AppLocalizations.of(context)?.ls_review ?? 'Review',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
