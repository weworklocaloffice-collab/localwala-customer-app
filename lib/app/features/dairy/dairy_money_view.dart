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
import 'package:user/app/core/repositories/wallet_repository.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Wallet balance plus the can-deposit side: what is held, for which cans,
/// and why it releases. Subscriptions are prepaid from the wallet per
/// delivery, so both panels belong on one screen.
class DairyCustomerMoneyView extends StatefulWidget {
  const DairyCustomerMoneyView({super.key});

  @override
  State<DairyCustomerMoneyView> createState() => _DairyCustomerMoneyViewState();
}

class _DairyCustomerMoneyViewState extends State<DairyCustomerMoneyView> {
  final DairyCustomerService _service = DairyCustomerService();
  // The platform class is spelt `WalletRepositry` — kept as-is to match the
  // rest of the app rather than fork the name here.
  final WalletRepositry _walletRepository = WalletRepositry();
  bool _loading = true;
  String? _error;
  double _balance = 0;
  List<dynamic> _transactions = const <dynamic>[];
  int _canCount = 0;
  dynamic _depositOutstanding;
  List<dynamic> _cans = const <dynamic>[];

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
    final String uid = await _walletRepository.userId();
    final wallet = await _walletRepository.getWalletInfo(uid, 10, 1);
    final deposits = await _service.myDeposits();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (wallet.success) {
        final Map<String, dynamic> body = asMap(jsonDecode(wallet.body));
        final Map<String, dynamic> info = asMap(body['info']);
        final dynamic balance = info['balance'];
        if (balance != null) _balance = double.tryParse(balance.toString()) ?? 0;
        _transactions = decodeList(body['transaction']);
      }
      if (deposits.success) {
        final Map<String, dynamic> d = asMap(jsonDecode(deposits.body));
        _canCount = int.tryParse(d['canCount']?.toString() ?? '0') ?? 0;
        _depositOutstanding = d['depositOutstanding'];
        _cans = decodeList(d['cans']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_wallet_deposits)),
      body: _error != null
          ? Center(child: Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(t.dairy_wallet_balance, style: Theme.of(context).textTheme.bodySmall),
                        Text(formatMoney(_balance), style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          t.dairy_wallet_prepaid_note,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(t.dairy_can_deposits_held, style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          _depositOutstanding != null ? formatMoney(_depositOutstanding) : '₹0',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.dairy_deposit_note(_canCount),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_cans.isNotEmpty) ...<Widget>[
                  const Divider(height: 32),
                  Text(t.dairy_your_cans, style: Theme.of(context).textTheme.titleMedium),
                  ..._cans.map((dynamic e) {
                    final Map<String, dynamic> m = asMap(e);
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${m['canCode'] ?? t.dairy_can} (${m['capacityL'] ?? '?'} L)'),
                      subtitle: Text(formatDate(m['lastMovementAt'])),
                      trailing: Text(formatMoney(m['depositAmount'])),
                    );
                  }),
                ],
                const Divider(height: 32),
                Text(t.dairy_recent_transactions, style: Theme.of(context).textTheme.titleMedium),
                if (_transactions.isEmpty)
                  Text(t.dairy_no_transactions)
                else
                  ..._transactions.map((dynamic e) {
                    final Map<String, dynamic> m = asMap(e);
                    final double amount = double.tryParse(m['amount']?.toString() ?? '') ?? 0;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text((m['type'] ?? m['status'] ?? t.dairy_transaction).toString().replaceAll('_', ' ')),
                      subtitle: Text(formatDate(m['createdAt'])),
                      trailing: Text(
                        '${amount < 0 ? '-' : '+'}${formatMoney(amount.abs())}',
                        style: TextStyle(color: amount < 0 ? Colors.red : Colors.green),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
