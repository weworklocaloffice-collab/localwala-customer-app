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
import 'package:user/app/features/jhatka/jhatka_subscription_detail_view.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// The customer's subscriptions: pause, resume, skip, quantity, schedule,
/// cancel — all within the edit cutoff, all writing the event trail.
///
/// Changes apply to the NEXT occurrence, never the current one. Cancelling
/// refunds the unused prepaid balance; skipping credits instead of
/// refunding. The server enforces all of it; this screen only asks for the
/// action and the reason.
class JhatkaSubscriptionsView extends StatefulWidget {
  const JhatkaSubscriptionsView({super.key});

  @override
  State<JhatkaSubscriptionsView> createState() =>
      _JhatkaSubscriptionsViewState();
}

class _JhatkaSubscriptionsViewState extends State<JhatkaSubscriptionsView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  bool _loading = true;
  String? _error;
  List<dynamic> _subscriptions = const <dynamic>[];
  String? _actingOn;

  static const List<String> _actions = <String>[
    'pause',
    'resume',
    'skip',
    'cancel',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    final response = await _service.subscriptions();
    if (!mounted) return;
    if (!response.success) {
      setState(() {
        _loading = false;
        _error = l10n.jhatka_could_not_load_subscriptions;
      });
      return;
    }
    final Map<String, dynamic> body = Map<String, dynamic>.from(
      jsonDecode(response.body) as Map,
    );
    setState(() {
      _loading = false;
      _subscriptions = (body['subscriptions'] as List?) ?? const <dynamic>[];
    });
  }

  Future<void> _act(
    String key,
    Future<dynamic> Function() call,
    String done,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    setState(() => _actingOn = key);
    final dynamic response = await call();
    if (!mounted) return;
    setState(() => _actingOn = null);
    final bool ok = response?.success == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? done : l10n.jhatka_did_not_go_through)),
    );
    if (ok) await _load();
  }

  /// Localized label for a manage-action key. The server accepts the raw
  /// snake_case key; the customer sees a word in their language.
  String _actionLabel(AppLocalizations l10n, String action) {
    switch (action) {
      case 'pause':
        return l10n.jhatka_action_pause;
      case 'resume':
        return l10n.jhatka_action_resume;
      case 'skip':
        return l10n.jhatka_action_skip;
      case 'cancel':
        return l10n.jhatka_action_cancel;
    }
    return action;
  }

  Future<void> _actionSheet(String subscriptionId, String action) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool needsReason = action == 'pause' || action == 'cancel';
    final TextEditingController reason = TextEditingController();
    final bool? go = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.jhatka_action_subscription(_actionLabel(l10n, action)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.jhatka_applies_next,
                style: const TextStyle(fontSize: 13),
              ),
              if (needsReason) ...<Widget>[
                const SizedBox(height: 16),
                TextField(
                  controller: reason,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.jhatka_reason_required,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(l10n.jhatka_confirm),
                ),
              ),
            ],
          ),
        );
      },
    );
    final String text = reason.text.trim();
    reason.dispose();
    if (go != true || !mounted) return;
    if (needsReason && text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.jhatka_a_reason_is_required)));
      return;
    }
    await _act(
      '$action:$subscriptionId',
      () => _service.manageSubscription(
        subscriptionId: subscriptionId,
        action: action,
        reason: text.isEmpty ? null : text,
      ),
      l10n.jhatka_done_next_delivery,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // No standalone "New" action: creation needs an outlet, and the outlet
      // comes from browsing (product page → Subscribe button). A bare create
      // button here would have nothing to attach the subscription to.
      appBar: AppBar(title: Text(l10n.jhatka_subscriptions)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _subscriptions.isEmpty
            ? Center(child: Text(l10n.jhatka_no_subscriptions))
            : ListView.builder(
                itemCount: _subscriptions.length,
                itemBuilder: (BuildContext context, int i) {
                  final Map<String, dynamic> sub = Map<String, dynamic>.from(
                    _subscriptions[i] as Map,
                  );
                  final String id = (sub['id'] ?? sub['_id'] ?? '').toString();
                  final String status = (sub['status'] ?? '').toString();
                  final bool busy =
                      _actingOn != null && _actingOn!.endsWith(id);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: InkWell(
                      // Tap for detail: upcoming deliveries with per-delivery
                      // billing state and pay buttons. The inline actions
                      // below stay for the quick moves.
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => JhatkaSubscriptionDetailView(
                              subscriptionId: id,
                            ),
                          ),
                        );
                      },
                      child: ExpansionTile(
                        title: Text(
                          l10n.jhatka_subscription_no(
                            (sub['subscriptionNo'] ?? '—').toString(),
                          ),
                        ),
                        subtitle: Text(
                          '$status · ${(sub['scheduleType'] ?? '').toString()}',
                        ),
                        trailing: busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                ..._actions.map(
                                  (String action) => OutlinedButton(
                                    onPressed: () => _actionSheet(id, action),
                                    child: Text(_actionLabel(l10n, action)),
                                  ),
                                ),
                                // Permanent end via DELETE (idempotent) as
                                // distinct from cancel-via-manage (409 on
                                // repeat). Both close future deliveries;
                                // neither deletes history.
                                if (status != 'cancelled')
                                  OutlinedButton(
                                    onPressed: () => _delete(id),
                                    child: Text(l10n.jhatka_end),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Permanently end a subscription. Separate from cancel-via-manage: DELETE is
  /// idempotent-success on already-cancelled, while manage/cancel 409s — and a
  /// customer tapping twice should not see an error for intent already satisfied.
  /// Pending occurrences are marked cancelled server-side, never deleted.
  Future<void> _delete(String subscriptionId) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? go = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.jhatka_end_this_subscription,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.jhatka_end_explainer),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.jhatka_end_subscription),
              ),
            ],
          ),
        );
      },
    );
    if (go != true || !mounted) return;
    await _act(
      'delete:$subscriptionId',
      () => _service.deleteSubscription(subscriptionId),
      l10n.jhatka_ended,
    );
  }
}
