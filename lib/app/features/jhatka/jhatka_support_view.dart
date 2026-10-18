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

import 'package:flutter/material.dart';
import 'package:user/app/features/jhatka/services/jhatka_customer_service.dart';

/// Complaints and reviews, one screen, two modes.
///
/// A complaint is about something that went wrong — it optionally names the
/// order so the outlet sees the batch trail. A review carries a 1–5 rating.
/// Both are fire-and-record: the server owns the thread from here.
class JhatkaSupportView extends StatefulWidget {
  const JhatkaSupportView({super.key, this.orderId});

  final String? orderId;

  @override
  State<JhatkaSupportView> createState() => _JhatkaSupportViewState();
}

enum _SupportMode { complaint, review }

class _JhatkaSupportViewState extends State<JhatkaSupportView> {
  final JhatkaCustomerService _service = JhatkaCustomerService();

  _SupportMode _mode = _SupportMode.complaint;
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _body = TextEditingController();
  int _rating = 5;
  bool _busy = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_mode == _SupportMode.review) {
      final response = await _service.review(<String, dynamic>{
        if (widget.orderId != null) 'order': widget.orderId,
        'rating': _rating,
        if (_body.text.trim().isNotEmpty) 'comment': _body.text.trim(),
      });
      _after(response.success, 'Thanks — review recorded.');
      return;
    }
    if (_subject.text.trim().isEmpty || _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject and details are required.')),
      );
      return;
    }
    final response = await _service.complaint(<String, dynamic>{
      if (widget.orderId != null) 'order': widget.orderId,
      'subject': _subject.text.trim(),
      'description': _body.text.trim(),
    });
    _after(response.success, 'Complaint filed — the outlet will respond.');
  }

  void _after(bool ok, String done) {
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? done : 'That did not go through. Retry.'),
      ),
    );
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isReview = _mode == _SupportMode.review;
    return Scaffold(
      appBar: AppBar(title: const Text('Help & feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          SegmentedButton<_SupportMode>(
            segments: const <ButtonSegment<_SupportMode>>[
              ButtonSegment<_SupportMode>(
                value: _SupportMode.complaint,
                label: Text('Complaint'),
              ),
              ButtonSegment<_SupportMode>(
                value: _SupportMode.review,
                label: Text('Review'),
              ),
            ],
            selected: <_SupportMode>{_mode},
            onSelectionChanged: (Set<_SupportMode> s) =>
                setState(() => _mode = s.first),
          ),
          const SizedBox(height: 16),
          if (!isReview)
            TextField(
              controller: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
          if (!isReview) const SizedBox(height: 12),
          if (isReview) ...<Widget>[
            Row(
              children: List<Widget>.generate(5, (int i) {
                final int star = i + 1;
                return IconButton(
                  icon: Icon(
                    star <= _rating
                        ? Icons.star
                        : Icons.star_border_outlined,
                  ),
                  color: Colors.amber,
                  iconSize: 36,
                  onPressed: () => setState(() => _rating = star),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _body,
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              labelText:
                  isReview ? 'Comment (optional)' : 'What happened?',
              border: const OutlineInputBorder(),
            ),
          ),
          if (widget.orderId != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Linked to order ${widget.orderId}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy
                ? null
                : () {
                    setState(() => _busy = true);
                    _submit();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isReview ? 'Submit review' : 'File complaint',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
