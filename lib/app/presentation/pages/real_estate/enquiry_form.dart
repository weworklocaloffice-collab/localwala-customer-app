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
import 'package:user/app/presentation/pages/real_estate/my_leads.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Submit a property enquiry. Creates a Lead server-side (BR-06).
/// Auth required — the dio interceptor attaches the customer token.
class EnquiryFormScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  const EnquiryFormScreen({super.key, required this.propertyId, required this.propertyTitle});

  @override
  State<EnquiryFormScreen> createState() => _EnquiryFormScreenState();
}

class _EnquiryFormScreenState extends State<EnquiryFormScreen> {
  final _repo = RealEstateRepository();
  final _form = GlobalKey<FormState>();
  final _message = TextEditingController();
  final _referral = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    _referral.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final lead = await _repo.createEnquiry(
        propertyId: widget.propertyId,
        message: _message.text.trim(),
        referralCode: _referral.text.trim().isEmpty ? null : _referral.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MyLeadsScreen(highlightLeadId: lead.id)),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text(translate.re_submit_enquiry)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.propertyTitle, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _message,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: translate.re_enquiry_message_label,
                  hintText: translate.re_enquiry_message_hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? translate.re_error_generic : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referral,
                decoration: InputDecoration(
                  labelText: translate.re_enquiry_referral_label,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(translate.re_error_generic,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: Text(translate.re_send),
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
