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
import 'package:user/app/core/repositories/chat_repository.dart';
import 'package:user/app/features/dairy/dairy_view_helpers.dart';
import 'package:user/app/features/dairy/services/dairy_customer_service.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Dairy support uses the shared customer support chat and agent workspace.
class LegacyDairySupportView extends StatefulWidget {
  const LegacyDairySupportView({super.key, this.orderId});

  final String? orderId;

  @override
  State<LegacyDairySupportView> createState() => _LegacyDairySupportViewState();
}

class _LegacyDairySupportViewState extends State<LegacyDairySupportView> {
  final ChatRepository _chatRepository = ChatRepository();
  final DairyCustomerService _dairyService = DairyCustomerService();
  bool _loading = true;
  List<dynamic> _rooms = const <dynamic>[];
  List<dynamic> _tickets = const <dynamic>[];
  String? _ticketError;
  String? _chatError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String chatUnavailable =
        AppLocalizations.of(context)!.dairy_could_not_load_conversations;
    setState(() {
      _loading = true;
    });
    List<dynamic> rooms = const <dynamic>[];
    List<dynamic> tickets = const <dynamic>[];
    String? chatError;
    String? ticketError;
    try {
      final String uid = await _chatRepository.userId();
      final r = await _chatRepository.getChatList(uid);
      if (r.success) {
        rooms = decodeList(jsonDecode(r.body));
      } else {
        chatError = chatUnavailable;
      }
    } catch (_) {
      chatError = chatUnavailable;
    }
    try {
      final ticketsResponse = await _dairyService.supportTickets();
      if (ticketsResponse.success) {
        final Map<String, dynamic> body = asMap(jsonDecode(ticketsResponse.body));
        tickets = decodeList(body['tickets']);
      } else {
        ticketError = 'Support cases are temporarily unavailable.';
      }
    } catch (_) {
      ticketError = 'Support cases are temporarily unavailable.';
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      _rooms = rooms;
      _tickets = tickets;
      _chatError = chatError;
      _ticketError = ticketError;
    });
  }

  Future<void> _createTicket() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController subject = TextEditingController();
    final TextEditingController message = TextEditingController();
    String category = 'order';
    final bool? submit = await showDialog<bool>(context: context, builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
        title: const Text('Contact Dairy support'),
        content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Category'), items: const <DropdownMenuItem<String>>[
            DropdownMenuItem(value: 'order', child: Text('Order')), DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
            DropdownMenuItem(value: 'payment', child: Text('Payment')), DropdownMenuItem(value: 'subscription', child: Text('Subscription')),
            DropdownMenuItem(value: 'product_quality', child: Text('Product quality')), DropdownMenuItem(value: 'other', child: Text('Other')),
          ], onChanged: (String? value) { if (value != null) setDialogState(() => category = value); }),
          TextFormField(controller: subject, decoration: const InputDecoration(labelText: 'Subject'), validator: (String? value) => (value?.trim().length ?? 0) < 4 ? 'Enter at least 4 characters' : null),
          TextFormField(controller: message, decoration: const InputDecoration(labelText: 'Describe the issue'), minLines: 3, maxLines: 5, validator: (String? value) => (value?.trim().length ?? 0) < 8 ? 'Add a little more detail' : null),
        ]))),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: const Text('Submit case')),
        ],
      ),
    ));
    if (submit != true) return;
    final result = await _dairyService.createSupportTicket(<String, dynamic>{
      'category': category, 'subject': subject.text.trim(), 'message': message.text.trim(),
      if (widget.orderId != null && widget.orderId!.isNotEmpty) 'order': widget.orderId,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.success ? 'Support case submitted.' : 'Could not submit your case. Try again.')));
    if (result.success) await _load();
  }

  Future<void> _openTicket(Map<String, dynamic> ticket) async {
    final String id = ticket['_id']?.toString() ?? ticket['id']?.toString() ?? '';
    final result = await _dairyService.supportTicket(id);
    if (!mounted || !result.success) return;
    final Map<String, dynamic> detail = asMap(asMap(jsonDecode(result.body))['ticket']);
    final List<dynamic> messages = decodeList(detail['messages']);
    final TextEditingController reply = TextEditingController();
    await showDialog<void>(context: context, builder: (BuildContext dialogContext) => AlertDialog(
      title: Text('${detail['ticketNo'] ?? 'Support case'} · ${detail['status'] ?? ''}'),
      content: SizedBox(width: 460, child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(detail['subject']?.toString() ?? ''), const Divider(),
        Flexible(child: ListView(shrinkWrap: true, children: messages.map((dynamic raw) {
          final Map<String, dynamic> row = asMap(raw);
          return ListTile(title: Text(row['senderType']?.toString() ?? ''), subtitle: Text(row['body']?.toString() ?? ''));
        }).toList())),
        if (detail['status'] != 'closed') TextField(controller: reply, decoration: const InputDecoration(labelText: 'Reply'), minLines: 1, maxLines: 3),
      ])),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        if (detail['status'] != 'closed') FilledButton(onPressed: () async {
          if (reply.text.trim().isEmpty) return;
          final response = await _dairyService.replySupportTicket(id, reply.text.trim());
          if (!dialogContext.mounted) return;
          Navigator.pop(dialogContext);
          if (response.success) await _load();
        }, child: const Text('Send reply')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_support), actions: <Widget>[
        IconButton(onPressed: _load, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
        IconButton(onPressed: _createTicket, icon: const Icon(Icons.add), tooltip: 'New support case'),
      ]),
      body: ListView(
              children: <Widget>[
                ListTile(
                  title: Text(widget.orderId == null ? 'Support cases' : 'Help with this Dairy order'),
                  subtitle: Text(_ticketError ?? (widget.orderId == null
                      ? 'Track responses from the Dairy support team.'
                      : 'Your case will be linked to this order.')),
                  trailing: TextButton(onPressed: _createTicket, child: const Text('New case')),
                ),
                if (_tickets.isEmpty && _ticketError == null) const ListTile(title: Text('No support cases yet')),
                ..._tickets.map((dynamic raw) {
                  final Map<String, dynamic> ticket = asMap(raw);
                  final String id = ticket['_id']?.toString() ?? ticket['id']?.toString() ?? '';
                  return ListTile(
                    leading: const Icon(Icons.support_agent_outlined),
                    title: Text('${ticket['ticketNo'] ?? ''} · ${ticket['subject'] ?? ''}'),
                    subtitle: Text('${ticket['category'] ?? ''} · ${ticket['status'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: id.isEmpty ? null : () => _openTicket(ticket),
                  );
                }),
                const Divider(),
                ListTile(title: Text(t.dairy_support), subtitle: Text(_chatError ?? 'Existing platform conversations')),
                if (_rooms.isEmpty) ListTile(title: Text(t.dairy_no_conversations)),
                ..._rooms.map((dynamic raw) {
                    final Map<String, dynamic> m = asMap(raw);
                    final String type = m['type']?.toString() ?? '';
                    final String typeId = m['typeId']?.toString() ?? '';
                    if (type.isEmpty || typeId.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(type.replaceAll('_', ' ')),
                      subtitle: Text(formatDate(m['createdAt'] ?? m['lastMessageAt'])),
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRouter.supportChatRoute, arguments: <dynamic>[type, typeId]),
                    );
                  }),
              ],
            ),
    );
  }
}

/// Dairy conversations are shared SupportChatRoom threads, routed to the
/// existing platform support agents and queues.
class DairySupportView extends StatefulWidget {
  const DairySupportView({super.key, this.orderId});

  final String? orderId;

  @override
  State<DairySupportView> createState() => _DairySupportViewState();
}

class _DairySupportViewState extends State<DairySupportView> {
  final ChatRepository _chatRepository = ChatRepository();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rooms = <Map<String, dynamic>>[];

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
      final String uid = await _chatRepository.userId();
      final response = await _chatRepository.getSupportChatList(uid);
      if (!response.success) throw StateError('Could not load support chats');
      final Map<String, dynamic> body = asMap(jsonDecode(response.body));
      final List<Map<String, dynamic>> rooms = decodeList(body['chats'])
          .map((dynamic item) => asMap(item))
          .where((Map<String, dynamic> row) {
            final String type = row['supportType']?.toString() ?? '';
            return type == 'dairy' || type == 'dairy_orders';
          })
          .toList();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_conversations;
        _loading = false;
      });
    }
  }

  void _openChat(String type, String typeId) {
    Navigator.of(context).pushNamed(
      AppRouter.supportChatRoute,
      arguments: <dynamic>[type, typeId],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.dairy_support),
        actions: <Widget>[
          IconButton(onPressed: _load, tooltip: 'Refresh', icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(_error!),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ]))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      if (widget.orderId != null && widget.orderId!.isNotEmpty)
                        Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                            title: const Text('Get help with this Dairy order'),
                            subtitle: const Text('The support agent will see the order details.'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openChat('dairy_orders', widget.orderId!),
                          ),
                        ),
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.support_agent_outlined)),
                          title: const Text('Start a Dairy support chat'),
                          subtitle: const Text('Ask about delivery, subscriptions, products or payments.'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openChat('dairy', ''),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Previous Dairy conversations', style: Theme.of(context).textTheme.titleMedium),
                      if (_rooms.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text(t.dairy_no_conversations)),
                        ),
                      ..._rooms.map((Map<String, dynamic> row) {
                        final String type = row['supportType']?.toString() ?? 'dairy';
                        final String typeId = row['dairyOrders']?.toString() ?? '';
                        final bool isOrderChat = type == 'dairy_orders';
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
                            title: Text(isOrderChat ? 'Dairy order conversation' : 'Dairy support'),
                            subtitle: Text(<String>[
                              row['lastMessage']?.toString() ?? 'Conversation',
                              row['status']?.toString() ?? 'open',
                              formatDate(row['updatedAt']),
                            ].where((String value) => value.isNotEmpty).join(' | ')),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openChat(type, isOrderChat ? typeId : ''),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
