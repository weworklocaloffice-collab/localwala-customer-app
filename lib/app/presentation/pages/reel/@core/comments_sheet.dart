/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Website: https://localwala.tech
 * Email: weworklocal1@gmail.com
 *
 * Proprietary and Confidential.
 *
 * This source code, including all associated assets,
 * APIs, databases, business logic, designs, and
 * documentation, is proprietary to WeWorkLocal.
 *
 * Unauthorized copying, modification, distribution,
 * publication, resale, reverse engineering, or use of
 * this software without prior written authorization is
 * strictly prohibited.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:user/app/core/repositories/reels_repository.dart';
import 'package:user/gen/l10n/app_localizations.dart';
import 'package:user/app/presentation/pages/reel/@core/bloc/reels_bloc.dart';

// TODO(l10n): move chrome strings below into app_*.arb.
class _SheetComment {
  final String name;
  final String text;

  const _SheetComment({required this.name, required this.text});

  factory _SheetComment.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    String name = 'Localwala user';
    if (user is Map<String, dynamic>) {
      final first = (user['firstName'] as String?) ?? '';
      final last = (user['lastName'] as String?) ?? '';
      final full = '$first $last'.trim();
      if (full.isNotEmpty) name = full;
    }
    return _SheetComment(name: name, text: (json['text'] as String?) ?? '');
  }
}

/// Comments bottom-sheet for a reel. Listing lives here (out of the bloc —
/// it is transient sheet state); adding goes through the bloc so the feed's
/// comment count stays in sync.
Future<void> showReelCommentsSheet(
  BuildContext context, {
  required String reelId,
  required ReelsBloc bloc,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CommentsSheet(reelId: reelId, bloc: bloc),
  );
}

class _CommentsSheet extends StatefulWidget {
  final String reelId;
  final ReelsBloc bloc;

  const _CommentsSheet({required this.reelId, required this.bloc});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final ReelsRepository _repository = ReelsRepository();
  final TextEditingController _controller = TextEditingController();
  List<_SheetComment> _comments = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final response = await _repository.getComments(widget.reelId);
    if (!mounted) return;
    if (response.success) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = (data['results'] as List?) ?? [];
      setState(() {
        _comments = raw
            .map((e) => _SheetComment.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    widget.bloc.add(ReelCommentAdded(widget.reelId, text));
    _controller.clear();
    await _load();
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                translate.comments_title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                  ? Center(child: Text(translate.comments_empty))
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              comment.name.isNotEmpty
                                  ? comment.name.characters.first
                                  : '?',
                            ),
                          ),
                          title: Text(
                            comment.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(comment.text),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: translate.comment_hint,
                        border: const OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
