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
import 'package:user/gen/l10n/app_localizations.dart';

/// Support: help center, FAQ, contact, dispute actions.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // No API load needed — static FAQ page.
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.support ?? 'Support')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  // Not a `const` list: every ListTile below carries an `onTap` closure, and a closure is
// not a constant expression. The subtrees with no closure keep their own `const`.
children: <Widget>[
                    Text(
                      l10n?.ls_help_center ?? 'Help Center',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l10n?.ls_faq ?? 'FAQ'),
                      onTap: () {
                        // Navigate to FAQ
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(l10n?.ls_contact_support ?? 'Contact support'),
                      onTap: () {
                        // Open contact form
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: Text(l10n?.ls_dispute_a_booking ?? 'Dispute a booking'),
                      onTap: () {
                        // Open dispute flow
                      },
                    ),
                  ],
                ),
    );
  }
}