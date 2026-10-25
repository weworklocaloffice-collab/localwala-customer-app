/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 */

import 'package:flutter/material.dart';

import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Withdraw confirmation dialog. Asks for a reason, calls the
/// `withdraw` endpoint, returns `{ event: 'withdrawn' }` on success.
class WithdrawDialog extends StatefulWidget {
  final String leadId;
  const WithdrawDialog({super.key, required this.leadId});

  @override
  State<WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<WithdrawDialog> {
  final _repo = RealEstateRepository();
  final _reason = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'reason_required');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo.withdrawLead(widget.leadId, reason: reason);
      if (!mounted) return;
      Navigator.of(context).pop({'event': 'withdrawn'});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'submit_failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(translate.re_withdraw),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(translate.re_withdraw_body),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: translate.re_withdraw_reason,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error == 'reason_required'
                  ? translate.re_withdraw_reason_required
                  : translate.re_error_generic,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(translate.re_close),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(translate.re_withdraw_confirm),
        ),
      ],
    );
  }
}
