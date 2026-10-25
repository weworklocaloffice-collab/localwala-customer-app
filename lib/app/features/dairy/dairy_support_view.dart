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
import 'package:user/app/router/app_route_config.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Entry point into the platform support chat for dairy customers.
///
/// The chat UI itself is shared with food/dining/tiffin at
/// `presentation/pages/chats/support_chat/`; this screen lists the user's
/// existing conversations and opens them. New dairy threads start from an
/// order's tracking screen, which keys the room to that order.
class DairySupportView extends StatefulWidget {
  const DairySupportView({super.key});

  @override
  State<DairySupportView> createState() => _DairySupportViewState();
}

class _DairySupportViewState extends State<DairySupportView> {
  final ChatRepository _chatRepository = ChatRepository();
  bool _loading = true;
  List<dynamic> _rooms = const <dynamic>[];
  String? _error;

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
    final String uid = await _chatRepository.userId();
    final r = await _chatRepository.getChatList(uid);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (r.success) {
        _rooms = decodeList(jsonDecode(r.body));
      } else {
        _error = AppLocalizations.of(context)!.dairy_could_not_load_conversations;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context)!;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(t.dairy_support)),
      body: _error != null
          ? Center(child: Text(_error!))
          : _rooms.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      t.dairy_no_conversations,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder: (BuildContext context, int i) {
                    final Map<String, dynamic> m = asMap(_rooms[i]);
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
                  },
                ),
    );
  }
}
