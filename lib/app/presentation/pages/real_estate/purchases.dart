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

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/real_estate_l10n.dart';

/// Purchases list - the customer's sale history.
///
/// A purchase is a recorded sale (plan A6.5): it is created by the hold
/// conversion or by an operator, never by the customer, so this screen is
/// strictly read-only. Money is shown in rupees, as the backend serves
/// it.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  List<PurchaseModel> _purchases = const [];

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
      final list = await _repo.myPurchases();
      if (!mounted) return;
      setState(() {
        _purchases = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load purchases';
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(PurchaseModel purchase) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchaseDetailScreen(purchaseId: purchase.id),
      ),
    );
    if (mounted) await _load();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_purchases_title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translate.re_purchases_load_failed,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _load,
                      child: Text(translate.re_retry),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: _purchases.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            translate.re_purchases_empty,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _purchases.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = _purchases[i];
                        final color = _statusColor(p.status);
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => _openDetail(p),
                            title: Text(
                              p.propertyTitle ??
                                  p.propertyCode ??
                                  translate.re_purchase_details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (p.propertyCode != null)
                                    Text(
                                      p.propertyCode!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${formatIndianPrice(p.saleValue)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color),
                              ),
                              child: Text(
                                translate.purchaseStatus(p.status),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

/// Purchase detail - one recorded sale.
///
/// Re-reads the purchase by id, so the screen proves the detail endpoint
/// and never renders a stale row after an operator-side change.
class PurchaseDetailScreen extends StatefulWidget {
  final String purchaseId;
  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  final _repo = RealEstateRepository();

  bool _loading = true;
  String? _error;
  PurchaseModel? _purchase;

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
      final p = await _repo.purchaseById(widget.purchaseId);
      if (!mounted) return;
      setState(() {
        _purchase = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load purchase';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_purchase_details)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _purchase == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  translate.re_error_generic,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _purchase!.propertyTitle ??
                      _purchase!.propertyCode ??
                      translate.re_purchase_details,
                  style: theme.textTheme.titleLarge,
                ),
                if (_purchase!.propertyAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _purchase!.propertyAddress!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                _DetailRow(
                  label: translate.re_purchase_code,
                  value: _purchase!.saleCode ?? '-',
                ),
                _DetailRow(
                  label: translate.re_purchase_value,
                  value:
                      '₹${formatIndianPrice(_purchase!.saleValue)}',
                ),
                if (_purchase!.holdPrincipalApplied > 0)
                  _DetailRow(
                    label: translate.re_purchase_hold_applied,
                    value:
                        '₹${formatIndianPrice(_purchase!.holdPrincipalApplied)}',
                  ),
                if (_purchase!.balancePayable > 0)
                  _DetailRow(
                    label: translate.re_purchase_balance,
                    value: '₹${formatIndianPrice(_purchase!.balancePayable)}',
                  ),
                _DetailRow(
                  label: translate.re_purchase_status,
                  value: translate.purchaseStatus(_purchase!.status),
                ),
                _DetailRow(
                  label: translate.re_purchase_type_buy,
                  value: translate.purchaseType(_purchase!.transactionType),
                ),
                if (_purchase!.holdCode != null)
                  _DetailRow(
                    label: translate.re_hold,
                    value: _purchase!.holdCode!,
                  ),
                if (_purchase!.soldAt != null)
                  _DetailRow(
                    label: translate.re_purchase_date,
                    value: MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(_purchase!.soldAt!),
                  ),
              ],
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
