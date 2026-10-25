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
import 'package:user/app/router/app_route_config.dart';

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
  static const int _pageSize = 20;

  final ReelsRepository _repository = ReelsRepository();
  final TextEditingController _controller = TextEditingController();
  List<_SheetComment> _comments = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _sending = false;
  String? _loadError;
  String? _postError;
  bool _signInRequired = false;

  bool get _hasMore => _page < _totalPages;

  @override
  void initState() {
    super.initState();
    _load(page: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load({required int page}) async {
    final response = await _repository.getComments(
      widget.reelId,
      page: page,
      limit: _pageSize,
    );
    if (!mounted) return;
    if (!response.success) {
      _failLoad();
      return;
    }
    Map<String, dynamic>? decodedMap;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) decodedMap = decoded;
    } catch (_) {
      decodedMap = null;
    }
    if (decodedMap == null) {
      _failLoad();
      return;
    }
    final data = decodedMap;
    final raw = (data['results'] as List?) ?? const [];
    final parsed = <_SheetComment>[
      for (final entry in raw)
        if (entry is Map<String, dynamic>) _SheetComment.fromJson(entry),
    ];
    setState(() {
      _comments = page == 1 ? parsed : [..._comments, ...parsed];
      _page = (data['page'] as num?)?.toInt() ?? page;
      _totalPages = (data['totalPages'] as num?)?.toInt() ?? page;
      _loading = false;
      _loadingMore = false;
      _loadError = null;
    });
  }

  void _failLoad() {
    setState(() {
      _loading = false;
      _loadingMore = false;
      _loadError = AppLocalizations.of(context)!.comments_load_failed;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    await _load(page: _page + 1);
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final translate = AppLocalizations.of(context)!;
    setState(() {
      _sending = true;
      _postError = null;
      _signInRequired = false;
    });
    // Posted from the sheet, not the bloc: the bloc never returns an outcome, so a
    // failed post was indistinguishable from a successful one and the draft was
    // cleared either way. Now the text survives a failure.
    final response = await _repository.addComment(widget.reelId, text);
    if (!mounted) return;
    if (!response.success) {
      final signIn = response.statusCode == 401;
      setState(() {
        _sending = false;
        _signInRequired = signIn;
        _postError = signIn
            ? translate.reels_sign_in_to_comment
            : translate.comment_post_failed;
      });
      return;
    }
    _controller.clear();
    widget.bloc.add(ReelCommentPosted(widget.reelId));
    await _load(page: 1);
    if (mounted) setState(() => _sending = false);
  }

  void _retryLoad() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _load(page: 1);
  }

  void _goToLogin() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(AppRouter.loginRoute);
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
                  : _loadError != null && _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _retryLoad,
                            child: Text(translate.re_retry),
                          ),
                        ],
                      ),
                    )
                  : _comments.isEmpty
                  ? Center(child: Text(translate.comments_empty))
                  : ListView.builder(
                      itemCount: _comments.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _comments.length) {
                          return Center(
                            child: _loadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: _loadMore,
                                    child: Text(translate.comments_load_more),
                                  ),
                          );
                        }
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
            if (_postError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _postError!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    if (_signInRequired)
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(translate.sign_in),
                      ),
                  ],
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
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
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
