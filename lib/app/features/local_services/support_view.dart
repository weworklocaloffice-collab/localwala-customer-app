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
import 'package:user/app/features/local_services/ls_bookings_view.dart';
import 'package:user/app/features/local_services/ls_complaints_view.dart';
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Support hub: live chat, prior conversations, quick actions and FAQs.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const String _chatType = 'local_services';

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
      final dynamic response = await _chatRepository.getSupportChatList(uid);
      if (!response.success) {
        throw StateError('Could not load conversations');
      }
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(response.body) as Map,
      );
      final List<dynamic> raw = (body['chats'] ?? []) as List<dynamic>;
      final List<Map<String, dynamic>> rooms = raw
          .whereType<Map<String, dynamic>>()
          .where((Map<String, dynamic> row) {
            final String type = row['supportType']?.toString() ?? '';
            return type.startsWith('local_services');
          })
          .toList();
      if (!mounted) return;
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Conversations are temporarily unavailable.';
      });
    }
  }

  Future<void> _openChat(String type, String typeId) async {
    await Navigator.of(context).pushNamed(
      AppRouter.supportChatRoute,
      arguments: <dynamic>[type, typeId],
    );
    if (mounted) await _load();
  }

  String _roomTitle(Map<String, dynamic> room) {
    final String type =
        room['supportType']?.toString() ?? room['type']?.toString() ?? '';
    if (type == 'local_services_booking') return 'Booking support';
    return 'Local services support';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.support ?? 'Support'),
        actions: <Widget>[
          IconButton(
            onPressed: _load,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: <Widget>[
            _SupportHero(onChat: () => _openChat(_chatType, '')),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _QuickAction(
                    icon: Icons.add_comment_outlined,
                    label: 'Raise complaint',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LsComplaintsView(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'My bookings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LsBookingsView(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const LsSectionHeader(title: 'Your conversations'),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Text(
                _error!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: lsSlate500),
              )
            else if (_rooms.isEmpty)
              LsCard(
                child: Row(
                  children: <Widget>[
                    const LsIconBadge(icon: Icons.chat_bubble_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No conversations yet. Start a chat and our team will help you.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: lsSlate500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final Map<String, dynamic> room in _rooms)
                LsCard(
                  onTap: () {
                    final String type =
                        room['type']?.toString() ??
                        room['supportType']?.toString() ??
                        _chatType;
                    final String typeId = room['typeId']?.toString() ?? '';
                    _openChat(type, typeId);
                  },
                  child: Row(
                    children: <Widget>[
                      const LsIconBadge(icon: Icons.support_agent_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _roomTitle(room),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lsFormatDate(
                                '${room['lastMessageAt'] ?? room['createdAt'] ?? ''}',
                              ),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: lsSlate500),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: lsSlate500),
                    ],
                  ),
                ),
            const SizedBox(height: 12),
            const LsSectionHeader(title: 'Frequently asked questions'),
            const _Faq(
              question: 'How do I book a local service?',
              answer:
                  'Pick a service, choose a variant and an available provider slot, then confirm. '
                  'You can track every status change from My bookings.',
            ),
            const _Faq(
              question: 'How do provider quotes work?',
              answer:
                  'For inspection-based services the provider submits a quote after visiting. '
                  'Accept the quote to proceed; a revised quote may arrive if the scope changes.',
            ),
            const _Faq(
              question: 'When am I charged?',
              answer:
                  'A deposit is collected at confirmation when the provider requires one. '
                  'The balance is payable after completion, by wallet or online. '
                  'Invoices are available in the booking timeline.',
            ),
            const _Faq(
              question: 'How do I cancel or reschedule?',
              answer:
                  'Open the booking and use the available actions. Cancellations close to the slot '
                  'may incur a fee as per the provider policy; reschedules may need provider approval.',
            ),
            const _Faq(
              question: 'How do refunds and disputes work?',
              answer:
                  'Raise a dispute from a completed booking with the reason. Our team reviews it with '
                  'the provider and any approved refund is returned to the original payment method.',
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Support is available in-app. A chat transcript is kept for every conversation.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: lsSlate500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportHero extends StatelessWidget {
  const _SupportHero({required this.onChat});

  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1D4ED8), Color(0xFF4F46E5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'We are here to help',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Chat with our support team about bookings, quotes and payments.',
                      style: TextStyle(
                        color: Color(0xFFDBEAFE),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onChat,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1D4ED8),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Chat with support',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LsCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: <Widget>[
          LsIconBadge(icon: icon),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: lsSlate600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: lsSlate500,
          title: Text(
            question,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: lsSlate900,
            ),
          ),
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: lsSlate600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
