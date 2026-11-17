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
import 'package:user/app/features/local_services/ls_bookings_view.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/widgets/ls_ui.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer review history with a rating summary header.
class LsReviewsView extends StatefulWidget {
  const LsReviewsView({super.key});

  @override
  State<LsReviewsView> createState() => _LsReviewsViewState();
}

class _LsReviewsViewState extends State<LsReviewsView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<LsReview> _items = const <LsReview>[];

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
      final dynamic res = await _service.reviews();
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final List<dynamic> raw = (body['results'] ?? []) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _items = raw
            .whereType<Map<String, dynamic>>()
            .map(LsReview.fromJson)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  double get _average {
    if (_items.isEmpty) return 0;
    final int total = _items.fold<int>(0, (int sum, LsReview r) => sum + r.rating);
    return total / _items.length;
  }

  void _openBookings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LsBookingsView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ls_my_reviews ?? 'My reviews'),
      ),
      body: _loading
          ? const LsSkeletonList(itemCount: 3)
          : _error != null
          ? LsErrorState(message: _error!, onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: <Widget>[
                  if (_items.isNotEmpty) _SummaryCard(
                    average: _average,
                    count: _items.length,
                  ),
                  if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 56),
                      child: LsEmptyState(
                        icon: Icons.star_outline_rounded,
                        title: l10n?.ls_no_reviews_yet ?? 'No reviews yet.',
                        message:
                            'Completed bookings can be rated from the bookings screen.',
                        actionLabel: 'View bookings',
                        onAction: _openBookings,
                      ),
                    )
                  else
                    for (final LsReview review in _items)
                      _ReviewCard(review: review),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.average, required this.count});

  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LsCard(
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                average.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: lsSlate900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count ${count == 1 ? 'review' : 'reviews'}',
                style: theme.textTheme.bodySmall?.copyWith(color: lsSlate500),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _Stars(rating: average.round()),
                const SizedBox(height: 8),
                Text(
                  'Your feedback helps other customers choose the right professional.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: lsSlate600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final LsReview review;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String date = lsFormatDate(review.createdAt);
    return LsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  review.providerName.isNotEmpty
                      ? review.providerName
                      : 'Local Services',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: lsSlate900,
                  ),
                ),
              ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: lsSlate500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              _Stars(rating: review.rating),
              const SizedBox(width: 8),
              Text(
                '${review.rating}.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: lsSlate600,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: lsSlate600,
                height: 1.45,
              ),
            ),
          ],
          if (review.bookingCode.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: lsSlate500,
                ),
                const SizedBox(width: 6),
                Text(
                  review.bookingCode,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: lsSlate500,
                    fontWeight: FontWeight.w600,
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

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFF59E0B),
            size: 18,
          ),
      ],
    );
  }
}
