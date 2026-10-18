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
import 'package:user/app/core/config/api_request_service.dart';

/// Support: help center, FAQ, contact, dispute actions.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiRequestService _api = ApiRequestService();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  // Not a `const` list: every ListTile below carries an `onTap` closure, and a closure is
// not a constant expression. The subtrees with no closure keep their own `const`.
children: <Widget>[
                    const Text(
                      'Help Center',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: Icon(Icons.help_outline),
                      title: Text('FAQ'),
                      onTap: () {
                        // Navigate to FAQ
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Contact support'),
                      onTap: () {
                        // Open contact form
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.flag),
                      title: Text('Dispute a booking'),
                      onTap: () {
                        // Open dispute flow
                      },
                    ),
                  ],
                ),
    );
  }
}