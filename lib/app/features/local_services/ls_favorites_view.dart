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

import 'package:user/app/core/repositories/auth_repository.dart';
import 'package:user/app/features/local_services/ls_service_view.dart';
import 'package:user/app/features/local_services/models/models.dart';
import 'package:user/app/features/local_services/services/local_services_customer_service.dart';
import 'package:user/app/features/local_services/widgets/ls_service_card.dart';
import 'package:user/gen/l10n/app_localizations.dart';

/// Saved local services. Shows the same rich card as the catalogue so a
/// favourited service reads identically from either surface.
class LsFavoritesView extends StatefulWidget {
  const LsFavoritesView({super.key});

  @override
  State<LsFavoritesView> createState() => _LsFavoritesViewState();
}

class _LsFavoritesViewState extends State<LsFavoritesView> {
  final LocalServicesCustomerService _service = LocalServicesCustomerService();

  bool _loading = true;
  String? _error;
  List<LsService> _items = const <LsService>[];
  String _mediaUrl = '';

  @override
  void initState() {
    super.initState();
    _loadMediaUrl();
    _load();
  }

  Future<void> _loadMediaUrl() async {
    final String url = await AuthRepository().getMediaUrl();
    if (mounted) setState(() => _mediaUrl = url);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dynamic res = await _service.favorites();
      final Map<String, dynamic> body = Map<String, dynamic>.from(
        jsonDecode(res.body) as Map,
      );
      final List<dynamic> raw = (body['items'] ?? []) as List<dynamic>;
      final List<LsService> items = <LsService>[];
      for (final dynamic row in raw) {
        if (row is Map && row['service'] is Map) {
          items.add(
            LsService.fromJson(
              Map<String, dynamic>.from(row['service'] as Map),
            ),
          );
        }
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _openService(LsService service) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LsServiceView(service: service),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.ls_favorites ?? 'Favorites')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          t?.ls_no_favorites ?? 'No favorites yet.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _items.length,
                        itemBuilder: (BuildContext context, int i) {
                          final LsService s = _items[i];
                          return LsServiceCard(
                            service: s,
                            mediaUrl: _mediaUrl,
                            onTap: () => _openService(s),
                          );
                        },
                      ),
      ),
    );
  }
}
