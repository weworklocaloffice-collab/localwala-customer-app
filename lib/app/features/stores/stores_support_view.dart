/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
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

import 'package:flutter/material.dart';
import 'package:user/app/features/stores/services/stores_customer_service.dart';

/// Returns and exchanges, from the customer side.
///
/// The customer states what is wrong and what they want; the outlet decides. Approving,
/// inspecting and refunding all happen on the partner side, so this screen collects the
/// request faithfully and reports the server's answer — it never previews an outcome the
/// server has not given.
class StoresSupportView extends StatefulWidget {
  const StoresSupportView({super.key, required this.orderId});

  final String orderId;

  @override
  State<StoresSupportView> createState() => _StoresSupportViewState();
}

class _StoresSupportViewState extends State<StoresSupportView> {
  final StoresCustomerService _service = StoresCustomerService();
  final TextEditingController _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit(bool isExchange) async {
    final String reason = _reason.text.trim();
    if (reason.isEmpty) {
      _snack('Please say what went wrong.');
      return;
    }
    setState(() => _busy = true);
    try {
      final response = isExchange
          ? await _service.createExchange(<String, dynamic>{
              'order': widget.orderId,
              'reason': reason,
            })
          : await _service.createReturn(<String, dynamic>{
              'order': widget.orderId,
              'reason': reason,
            });
      if (!mounted) return;
      if (!response.success) {
        _snack('Could not submit. The outlet will need to help directly.');
        return;
      }
      _snack(isExchange ? 'Exchange requested.' : 'Return requested.');
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returns & exchanges')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Tell the store what went wrong. They review every request — '
            'nothing here is decided automatically.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What went wrong?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _submit(false),
                  child: const Text('Request return'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _submit(true),
                  child: const Text('Request exchange'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}