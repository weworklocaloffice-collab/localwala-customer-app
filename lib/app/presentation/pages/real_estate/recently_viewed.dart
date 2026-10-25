/*
 * WeWorkLocal
 * Hyperlocal Commerce, Delivery & Service Platform
 *
 * Copyright © 2026 WeWorkLocal.
 * All Rights Reserved.
 *
 * Proprietary and Confidential.
 *
 * This source code is proprietary to WeWorkLocal.
 */

import 'package:flutter/material.dart';

import 'package:user/gen/l10n/app_localizations.dart';

import 'package:user/app/core/models/real_estate_property_model.dart';
import 'package:user/app/core/recently_viewed_store.dart';
import 'package:user/app/core/repositories/real_estate_repository.dart';
import 'package:user/app/presentation/pages/real_estate/property_detail.dart';
import 'package:user/app/presentation/pages/real_estate/widgets/property_card.dart';
import 'package:user/app/services/shared_pref.dart';

/// "Recently viewed" — the customer's local-history list of properties
/// they opened. Backed by [RecentlyViewedStore] (no backend round-trip).
///
/// Each saved id is joined against the public property endpoint at
/// load time, so a property that was unpublished since the user viewed
/// it will simply not appear in the list. A "Clear history" button
/// wipes the local store.
class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  final _repo = RealEstateRepository();
  late final _store = RecentlyViewedStore(SharedPreferencesManager());

  bool _loading = true;
  List<PropertyModel> _items = const [];
  String? _error;

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
      final ids = await _store.list();
      if (ids.isEmpty) {
        if (!mounted) return;
        setState(() {
          _items = const [];
          _loading = false;
        });
        return;
      }
      final list = await Future.wait(
        ids.map((id) async {
          try {
            return await _repo.propertyById(id);
          } catch (_) {
            return null;
          }
        }),
      );
      if (!mounted) return;
      setState(() {
        _items = list.whereType<PropertyModel>().toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load your history';
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    final translate = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(translate.re_clear_history),
        content: Text(translate.re_clear_history_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(translate.cancel_title),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(translate.clear),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _store.clear();
      if (!mounted) return;
      setState(() => _items = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate.re_recently_viewed_title),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: translate.re_clear_history,
              onPressed: _clear,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    translate.re_error_generic,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _items.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(translate.re_recently_viewed_empty)),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = _items[i];
                  return PropertyCard(
                    property: p,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(propertyId: p.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
