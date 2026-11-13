/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Customer reviews list (all reviews submitted).
class LsReviewsView extends StatefulWidget {
  const LsReviewsView({super.key});

  @override
  State<LsReviewsView> createState() => _LsReviewsViewState();
}

class _LsReviewsViewState extends State<LsReviewsView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const <Map<String, dynamic>>[];

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
      setState(() {
        _items = raw.whereType<Map<String, dynamic>>().toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.ls_my_reviews ?? 'My reviews')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)?.ls_no_reviews_yet ?? 'No reviews yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Map<String, dynamic> r = _items[i];
                          final int rating = (r['rating'] as num?)?.toInt() ?? 0;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  for (int j = 0; j < 5; j++)
                                    Icon(
                                      j < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                ],
                              ),
                              subtitle: Text('${r['comment'] ?? ''}'),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
