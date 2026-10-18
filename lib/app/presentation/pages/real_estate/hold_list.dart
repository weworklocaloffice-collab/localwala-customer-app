/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/hold_detail.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer's holds list (Flow 13).
///
/// Grouped tabs mirror the lifecycle a customer cares about:
///   • Active        — currently reserving a property
///   • Pending       — payment not yet completed
///   • Closed        — cancelled / expired / refunded / converted
/// Each row opens [HoldDetailScreen].
class MyHoldsScreen extends StatefulWidget {
  const MyHoldsScreen({super.key});

  @override
  State<MyHoldsScreen> createState() => _MyHoldsScreenState();
}

class _MyHoldsScreenState extends State<MyHoldsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = RealEstateRepository();
  late final TabController _tabs;

  bool _loading = true;
  String? _error;
  List<HoldModel> _all = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _repo.myHolds();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'load_failed';
        _loading = false;
      });
    }
  }

  List<HoldModel> _filter(_HoldBucket b) => _all.where((h) {
      switch (b) {
        case _HoldBucket.active:
          return h.status == 'ACTIVE';
        case _HoldBucket.pending:
          return h.status == 'PENDING_PAYMENT' || h.status == 'REFUND_PENDING';
        case _HoldBucket.closed:
          return h.isTerminal;
      }
    }).toList(growable: false);

  Future<void> _open(HoldModel hold) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => HoldDetailScreen(holdId: hold.id)),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_hold_list_title),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(translate.re_error_generic, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _HoldList(
                        holds: _filter(_HoldBucket.active),
                        onTap: _open,
                        emptyMessage: translate.re_hold_list_empty,
                      ),
                      _HoldList(
                        holds: _filter(_HoldBucket.pending),
                        onTap: _open,
                        emptyMessage: translate.re_hold_list_empty,
                      ),
                      _HoldList(
                        holds: _filter(_HoldBucket.closed),
                        onTap: _open,
                        emptyMessage: translate.re_hold_list_empty,
                      ),
                    ],
                  ),
                ),
    );
  }
}

enum _HoldBucket { active, pending, closed }

class _HoldList extends StatelessWidget {
  final List<HoldModel> holds;
  final String emptyMessage;
  final Future<void> Function(HoldModel) onTap;

  const _HoldList({
    required this.holds,
    required this.emptyMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (holds.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(emptyMessage)),
        ],
      );
    }
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: holds.length,
      separatorBuilder: (context, i) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final h = holds[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              h.propertySnapshot ?? h.holdCode ?? 'Hold',
              style: theme.textTheme.titleSmall,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '₹${formatIndianPrice(h.total)} • ${h.statusLabel}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            trailing: h.expiresAt != null && (h.status == 'PENDING_PAYMENT' || h.status == 'ACTIVE')
                ? Text(
                    'Exp ${_formatDate(h.expiresAt!)}',
                    style: theme.textTheme.bodySmall,
                  )
                : null,
            onTap: () => onTap(h),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$day/$m/${d.year}';
  }
}
